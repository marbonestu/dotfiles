#!/usr/bin/env python3
"""
Analyze Claude Code session data and compute token usage and costs.
Reads all local session files and generates a detailed cost report.

Usage:
    python3 analyze_claude_sessions.py [--start-date YYYY-MM-DD] [--end-date YYYY-MM-DD] [--by-day]

Examples:
    # Analyze all sessions
    python3 analyze_claude_sessions.py

    # Analyze sessions from a specific date onwards
    python3 analyze_claude_sessions.py --start-date 2026-01-20

    # Analyze sessions within a date range
    python3 analyze_claude_sessions.py --start-date 2026-01-20 --end-date 2026-01-23

    # Analyze sessions up to a specific date
    python3 analyze_claude_sessions.py --end-date 2026-01-22

    # Aggregate sessions by day
    python3 analyze_claude_sessions.py --by-day

    # Daily breakdown for a specific week
    python3 analyze_claude_sessions.py --start-date 2026-01-20 --end-date 2026-01-26 --by-day

The script will:
1. Scan ~/.claude/projects/ for all session files
2. Parse token usage from each session
3. Calculate costs based on current Anthropic pricing
4. Generate a detailed report to stdout
5. Export full analysis to claude_sessions_analysis.json in current directory

Requirements:
    - Python 3.6+
    - Standard library only (no external dependencies)
"""

import argparse
import json
import os
import re
from pathlib import Path
from datetime import datetime
from collections import defaultdict
from typing import Dict, List, Tuple, Optional

# Claude API pricing (as of January 2025)
# https://www.anthropic.com/api#pricing
PRICING = {
    "claude-opus-4-5": {
        "input": 0.015 / 1000,      # $15 per MTok
        "output": 0.075 / 1000,     # $75 per MTok
        "cache_write": 0.01875 / 1000,  # $18.75 per MTok
        "cache_read": 0.0015 / 1000,    # $1.50 per MTok
    },
    "claude-sonnet-4-5": {
        "input": 0.003 / 1000,      # $3 per MTok
        "output": 0.015 / 1000,     # $15 per MTok
        "cache_write": 0.00375 / 1000,  # $3.75 per MTok
        "cache_read": 0.0003 / 1000,    # $0.30 per MTok
    },
    "claude-sonnet-3-5": {
        "input": 0.003 / 1000,      # $3 per MTok
        "output": 0.015 / 1000,     # $15 per MTok
        "cache_write": 0.00375 / 1000,  # $3.75 per MTok
        "cache_read": 0.0003 / 1000,    # $0.30 per MTok
    },
    "claude-haiku-4-5": {
        "input": 0.0008 / 1000,     # $0.80 per MTok
        "output": 0.004 / 1000,     # $4 per MTok
        "cache_write": 0.001 / 1000,    # $1 per MTok
        "cache_read": 0.00008 / 1000,   # $0.08 per MTok
    },
    "claude-haiku-3-5": {
        "input": 0.0008 / 1000,     # $0.80 per MTok
        "output": 0.004 / 1000,     # $4 per MTok
        "cache_write": 0.001 / 1000,    # $1 per MTok
        "cache_read": 0.00008 / 1000,   # $0.08 per MTok
    },
}

# Model name mapping (various formats to canonical)
MODEL_MAP = {
    "claude-opus-4-5": "claude-opus-4-5",
    "claude-opus-4": "claude-opus-4-5",
    "claude-opus": "claude-opus-4-5",
    "claude-sonnet-4-5": "claude-sonnet-4-5",
    "claude-sonnet-4": "claude-sonnet-4-5",
    "claude-sonnet": "claude-sonnet-4-5",
    "claude-sonnet-3-5": "claude-sonnet-3-5",
    "claude-haiku-4-5": "claude-haiku-4-5",
    "claude-haiku-3-5": "claude-haiku-3-5",
    "claude-haiku": "claude-haiku-4-5",
}


def normalize_model_name(model: str) -> str:
    """Normalize model name to canonical form."""
    # Remove version suffixes like -20250929 or -20251101
    base_model = re.sub(r'-20\d{6}$', '', model)
    return MODEL_MAP.get(base_model, base_model)


def calculate_cost(model: str, usage: Dict) -> float:
    """Calculate cost for a given usage object."""
    normalized_model = normalize_model_name(model)

    if normalized_model not in PRICING:
        # Skip synthetic model (internal Claude Code marker)
        if normalized_model != "<synthetic>":
            print(f"Warning: Unknown model {model} (normalized: {normalized_model}), using Sonnet 4.5 pricing")
        normalized_model = "claude-sonnet-4-5"

    pricing = PRICING[normalized_model]

    input_tokens = usage.get("input_tokens", 0)
    output_tokens = usage.get("output_tokens", 0)
    cache_creation = usage.get("cache_creation_input_tokens", 0)
    cache_read = usage.get("cache_read_input_tokens", 0)

    cost = (
        input_tokens * pricing["input"] +
        output_tokens * pricing["output"] +
        cache_creation * pricing["cache_write"] +
        cache_read * pricing["cache_read"]
    )

    return cost


def parse_session_file(session_path: Path) -> Tuple[Dict, List[Dict]]:
    """Parse a session JSONL file and extract usage data."""
    messages = []
    session_data = {
        "input_tokens": 0,
        "output_tokens": 0,
        "cache_creation_tokens": 0,
        "cache_read_tokens": 0,
        "max_context_per_turn": 0,
        "total_context_all_turns": 0,
        "turn_count": 0,
        "turns_over_200k": 0,
        "cost_by_model": defaultdict(float),
        "tokens_by_model": defaultdict(lambda: {
            "input": 0,
            "output": 0,
            "cache_creation": 0,
            "cache_read": 0
        })
    }

    try:
        with open(session_path, 'r') as f:
            for line in f:
                if not line.strip():
                    continue
                try:
                    msg = json.loads(line)
                    messages.append(msg)

                    # Extract usage data - it can be in msg.usage or msg.message.usage
                    usage = None
                    model = None

                    if "usage" in msg:
                        usage = msg["usage"]
                        model = msg.get("model", "unknown")
                    elif "message" in msg and isinstance(msg["message"], dict) and "usage" in msg["message"]:
                        usage = msg["message"]["usage"]
                        model = msg["message"].get("model", "unknown")

                    if usage and model:
                        normalized_model = normalize_model_name(model)

                        input_tok = usage.get("input_tokens", 0)
                        output_tok = usage.get("output_tokens", 0)
                        cache_create = usage.get("cache_creation_input_tokens", 0)
                        cache_read = usage.get("cache_read_input_tokens", 0)

                        session_data["input_tokens"] += input_tok
                        session_data["output_tokens"] += output_tok
                        session_data["cache_creation_tokens"] += cache_create
                        session_data["cache_read_tokens"] += cache_read

                        # Track context size per turn
                        turn_context = input_tok + cache_create + cache_read
                        session_data["max_context_per_turn"] = max(session_data["max_context_per_turn"], turn_context)
                        session_data["total_context_all_turns"] += turn_context
                        session_data["turn_count"] += 1
                        if turn_context > 200_000:
                            session_data["turns_over_200k"] += 1

                        # Track by model
                        session_data["tokens_by_model"][normalized_model]["input"] += input_tok
                        session_data["tokens_by_model"][normalized_model]["output"] += output_tok
                        session_data["tokens_by_model"][normalized_model]["cache_creation"] += cache_create
                        session_data["tokens_by_model"][normalized_model]["cache_read"] += cache_read

                        # Calculate cost
                        cost = calculate_cost(model, usage)
                        session_data["cost_by_model"][normalized_model] += cost

                except json.JSONDecodeError:
                    continue
    except Exception as e:
        print(f"Error reading {session_path}: {e}")

    return session_data, messages


def format_number(num: int) -> str:
    """Format large numbers with commas and k/M suffixes."""
    if num >= 1_000_000:
        return f"{num / 1_000_000:.1f}M"
    elif num >= 1_000:
        return f"{num / 1_000:.1f}k"
    return str(num)


def parse_date_filter(date_str: str) -> datetime:
    """Parse date string in YYYY-MM-DD format to datetime with UTC timezone."""
    try:
        # Parse date and make it timezone-aware (UTC) at start of day
        dt = datetime.strptime(date_str, "%Y-%m-%d")
        return dt.replace(tzinfo=datetime.now().astimezone().tzinfo)
    except ValueError:
        raise ValueError(f"Invalid date format: {date_str}. Expected YYYY-MM-DD")


def is_in_date_range(session_date_str: Optional[str], start_date: Optional[datetime], end_date: Optional[datetime]) -> bool:
    """Check if a session date is within the specified range."""
    if not session_date_str:
        return True  # Include sessions with no date

    try:
        session_date = datetime.fromisoformat(session_date_str.replace('Z', '+00:00'))
    except:
        return True  # Include sessions with invalid dates

    if start_date and session_date < start_date:
        return False
    if end_date:
        # Set end_date to end of day (23:59:59)
        end_of_day = end_date.replace(hour=23, minute=59, second=59)
        if session_date > end_of_day:
            return False

    return True


def aggregate_by_day(sessions: List[Dict]) -> Dict[str, Dict]:
    """Aggregate sessions by day."""
    daily_data = defaultdict(lambda: {
        "sessions": [],
        "total_cost": 0.0,
        "input_tokens": 0,
        "output_tokens": 0,
        "cache_read_tokens": 0,
        "cache_creation_tokens": 0,
        "max_context_per_turn": 0,
        "total_turns": 0,
        "turns_over_200k": 0,
        "tokens_by_model": defaultdict(lambda: {
            "input": 0,
            "output": 0,
            "cache_read": 0,
            "cache_creation": 0
        }),
        "cost_by_model": defaultdict(float)
    })

    for session in sessions:
        created = session.get("created")
        if not created:
            day_key = "Unknown"
        else:
            try:
                dt = datetime.fromisoformat(created.replace('Z', '+00:00'))
                day_key = dt.strftime("%Y-%m-%d")
            except:
                day_key = "Unknown"

        daily = daily_data[day_key]
        daily["sessions"].append(session)
        daily["total_cost"] += session["total_cost"]
        daily["input_tokens"] += session["usage"]["input_tokens"]
        daily["output_tokens"] += session["usage"]["output_tokens"]
        daily["cache_read_tokens"] += session["usage"]["cache_read_tokens"]
        daily["cache_creation_tokens"] += session["usage"]["cache_creation_tokens"]
        daily["max_context_per_turn"] = max(daily["max_context_per_turn"], session["usage"]["max_context_per_turn"])
        daily["total_turns"] += session["usage"]["turn_count"]
        daily["turns_over_200k"] += session["usage"]["turns_over_200k"]

        # Aggregate by model
        for model, tokens in session["usage"]["tokens_by_model"].items():
            daily["tokens_by_model"][model]["input"] += tokens["input"]
            daily["tokens_by_model"][model]["output"] += tokens["output"]
            daily["tokens_by_model"][model]["cache_read"] += tokens["cache_read"]
            daily["tokens_by_model"][model]["cache_creation"] += tokens["cache_creation"]

        for model, cost in session["usage"]["cost_by_model"].items():
            daily["cost_by_model"][model] += cost

    return dict(daily_data)


def analyze_all_sessions(start_date: Optional[datetime] = None, end_date: Optional[datetime] = None, aggregate_by_day_flag: bool = False):
    """Analyze all Claude Code sessions, optionally filtered by date range."""
    claude_dir = Path.home() / ".claude"
    projects_dir = claude_dir / "projects"

    if not projects_dir.exists():
        print(f"Error: Claude projects directory not found at {projects_dir}")
        return

    all_sessions = []

    # Find all project directories
    for project_dir in projects_dir.iterdir():
        if not project_dir.is_dir():
            continue

        index_file = project_dir / "sessions-index.json"
        if not index_file.exists():
            continue

        # Load session index
        try:
            with open(index_file, 'r') as f:
                index_data = json.load(f)
        except Exception as e:
            print(f"Error reading {index_file}: {e}")
            continue

        entries = index_data.get("entries", [])
        original_path = index_data.get("originalPath", "Unknown")

        # Process each session
        for entry in entries:
            session_id = entry.get("sessionId")
            session_file = project_dir / f"{session_id}.jsonl"

            if not session_file.exists():
                continue

            usage_data, messages = parse_session_file(session_file)

            # Also scan subagent sessions if they exist
            subagents_list = []
            subagents_dir = project_dir / session_id / "subagents"
            if subagents_dir.exists():
                for subagent_file in sorted(subagents_dir.glob("agent-*.jsonl")):
                    subagent_usage, _ = parse_session_file(subagent_file)
                    subagent_cost = sum(subagent_usage["cost_by_model"].values())
                    # Determine primary model for this subagent
                    primary_model = max(
                        subagent_usage["cost_by_model"].items(),
                        key=lambda x: x[1],
                        default=("unknown", 0)
                    )[0] if subagent_usage["cost_by_model"] else "unknown"

                    subagents_list.append({
                        "id": subagent_file.stem,  # agent-xxxxx
                        "model": primary_model,
                        "turns": subagent_usage["turn_count"],
                        "cost": subagent_cost,
                        "tokens_by_model": dict(subagent_usage["tokens_by_model"]),
                        "cost_by_model": dict(subagent_usage["cost_by_model"]),
                    })

                    # Merge subagent usage into main session totals
                    usage_data["input_tokens"] += subagent_usage["input_tokens"]
                    usage_data["output_tokens"] += subagent_usage["output_tokens"]
                    usage_data["cache_creation_tokens"] += subagent_usage["cache_creation_tokens"]
                    usage_data["cache_read_tokens"] += subagent_usage["cache_read_tokens"]
                    usage_data["max_context_per_turn"] = max(
                        usage_data["max_context_per_turn"],
                        subagent_usage["max_context_per_turn"]
                    )
                    usage_data["total_context_all_turns"] += subagent_usage["total_context_all_turns"]
                    usage_data["turn_count"] += subagent_usage["turn_count"]
                    usage_data["turns_over_200k"] += subagent_usage["turns_over_200k"]
                    # Merge model-specific data
                    for model, tokens in subagent_usage["tokens_by_model"].items():
                        usage_data["tokens_by_model"][model]["input"] += tokens["input"]
                        usage_data["tokens_by_model"][model]["output"] += tokens["output"]
                        usage_data["tokens_by_model"][model]["cache_creation"] += tokens["cache_creation"]
                        usage_data["tokens_by_model"][model]["cache_read"] += tokens["cache_read"]
                    for model, cost in subagent_usage["cost_by_model"].items():
                        usage_data["cost_by_model"][model] += cost

            # Calculate total cost
            total_cost = sum(usage_data["cost_by_model"].values())

            session_info = {
                "session_id": session_id,
                "project_path": original_path,
                "first_prompt": entry.get("firstPrompt", "")[:100],
                "summary": entry.get("summary", ""),
                "message_count": entry.get("messageCount", 0),
                "created": entry.get("created"),
                "modified": entry.get("modified"),
                "git_branch": entry.get("gitBranch", ""),
                "usage": usage_data,
                "total_cost": total_cost,
                "subagents": subagents_list,
            }

            # Filter by date range if specified
            if is_in_date_range(session_info["created"], start_date, end_date):
                all_sessions.append(session_info)

    # Sort by creation date (newest first)
    all_sessions.sort(key=lambda x: x.get("created", ""), reverse=True)

    # Print report
    print("=" * 120)
    print("CLAUDE CODE SESSION ANALYSIS")
    if start_date or end_date:
        date_range = []
        if start_date:
            date_range.append(f"From: {start_date.strftime('%Y-%m-%d')}")
        if end_date:
            date_range.append(f"To: {end_date.strftime('%Y-%m-%d')}")
        print(f"Date Range: {' | '.join(date_range)}")
    print("=" * 120)
    print(f"\nTotal sessions found: {len(all_sessions)}")
    print()

    # Overall statistics
    total_cost = sum(s["total_cost"] for s in all_sessions)
    total_input = sum(s["usage"]["input_tokens"] for s in all_sessions)
    total_output = sum(s["usage"]["output_tokens"] for s in all_sessions)
    total_cache_read = sum(s["usage"]["cache_read_tokens"] for s in all_sessions)
    total_cache_create = sum(s["usage"]["cache_creation_tokens"] for s in all_sessions)

    print(f"{'OVERALL TOTALS':<30} {'Input':<12} {'Output':<12} {'Cache Read':<12} {'Cache Write':<12} {'Cost':<12}")
    print("-" * 120)
    print(f"{'All Sessions':<30} {format_number(total_input):<12} {format_number(total_output):<12} "
          f"{format_number(total_cache_read):<12} {format_number(total_cache_create):<12} ${total_cost:.4f}")
    print()

    # Context size statistics
    max_context = max((s["usage"]["max_context_per_turn"] for s in all_sessions), default=0)
    total_turns = sum(s["usage"]["turn_count"] for s in all_sessions)
    total_context_sum = sum(s["usage"]["total_context_all_turns"] for s in all_sessions)
    total_over_200k = sum(s["usage"]["turns_over_200k"] for s in all_sessions)
    avg_context = total_context_sum // total_turns if total_turns else 0

    print(f"{'CONTEXT WINDOW ANALYSIS':<30} (base context: 200k tokens)")
    print("-" * 120)
    print(f"  Peak context (single turn):   {format_number(max_context)} tokens")
    print(f"  Average context per turn:     {format_number(avg_context)} tokens")
    print(f"  Total API turns:              {total_turns}")
    print(f"  Turns exceeding 200k:         {total_over_200k}" +
          (f"  ⚠ Extended context used!" if total_over_200k > 0 else ""))
    print()

    # Breakdown (by day or by session)
    print("\n" + "=" * 120)
    if aggregate_by_day_flag:
        print("DAILY BREAKDOWN")
        print("=" * 120)

        daily_data = aggregate_by_day(all_sessions)
        # Sort by date (newest first)
        sorted_days = sorted(daily_data.keys(), reverse=True)

        for day in sorted_days:
            data = daily_data[day]
            session_count = len(data["sessions"])

            print(f"\n{day} ({session_count} session{'s' if session_count != 1 else ''}) "
                  f"| peak ctx: {format_number(data['max_context_per_turn'])} | turns: {data['total_turns']}"
                  + (f" | ⚠ {data['turns_over_200k']} over 200k" if data["turns_over_200k"] > 0 else ""))
            print(f"    {'Model':<20} {'Input':<12} {'Output':<12} {'Cache Read':<12} {'Cache Write':<12} {'Cost':<12}")
            print(f"    {'-' * 100}")

            for model, tokens in data["tokens_by_model"].items():
                cost = data["cost_by_model"][model]
                print(f"    {model:<20} {format_number(tokens['input']):<12} {format_number(tokens['output']):<12} "
                      f"{format_number(tokens['cache_read']):<12} {format_number(tokens['cache_creation']):<12} ${cost:.4f}")

            print(f"    {'-' * 100}")
            print(f"    {'TOTAL':<20} {format_number(data['input_tokens']):<12} {format_number(data['output_tokens']):<12} "
                  f"{format_number(data['cache_read_tokens']):<12} {format_number(data['cache_creation_tokens']):<12} "
                  f"${data['total_cost']:.4f}")

    else:
        print("PER-SESSION BREAKDOWN")
        print("=" * 120)

        for idx, session in enumerate(all_sessions, 1):
            usage = session["usage"]
            created = session["created"]
            if created:
                try:
                    dt = datetime.fromisoformat(created.replace('Z', '+00:00'))
                    date_str = dt.strftime("%Y-%m-%d %H:%M")
                except:
                    date_str = created[:16]
            else:
                date_str = "Unknown"

            print(f"\n[{idx}] Session: {session['session_id'][:8]}...")
            print(f"    Project: {session['project_path']}")
            print(f"    Created: {date_str}")
            if session['git_branch']:
                print(f"    Branch: {session['git_branch']}")
            print(f"    Messages: {session['message_count']}")
            avg_ctx = usage["total_context_all_turns"] // usage["turn_count"] if usage["turn_count"] else 0
            print(f"    Context:  max={format_number(usage['max_context_per_turn'])} avg={format_number(avg_ctx)} turns={usage['turn_count']}"
                  + (f" ⚠ {usage['turns_over_200k']} turns over 200k" if usage["turns_over_200k"] > 0 else ""))
            if session['first_prompt']:
                print(f"    First prompt: {session['first_prompt']}...")

            print(f"\n    {'Model':<20} {'Input':<12} {'Output':<12} {'Cache Read':<12} {'Cache Write':<12} {'Cost':<12}")
            print(f"    {'-' * 100}")

            for model, tokens in usage["tokens_by_model"].items():
                cost = usage["cost_by_model"][model]
                print(f"    {model:<20} {format_number(tokens['input']):<12} {format_number(tokens['output']):<12} "
                      f"{format_number(tokens['cache_read']):<12} {format_number(tokens['cache_creation']):<12} ${cost:.4f}")

            print(f"    {'-' * 100}")
            print(f"    {'TOTAL':<20} {format_number(usage['input_tokens']):<12} {format_number(usage['output_tokens']):<12} "
                  f"{format_number(usage['cache_read_tokens']):<12} {format_number(usage['cache_creation_tokens']):<12} "
                  f"${session['total_cost']:.4f}")

            # Show subagents if any
            if session.get("subagents"):
                print(f"\n    Subagents ({len(session['subagents'])}):")
                for sa in session["subagents"]:
                    print(f"      - {sa['id']}: {sa['model']} | {sa['turns']} turns | ${sa['cost']:.4f}")

    print("\n" + "=" * 120)
    print(f"GRAND TOTAL COST: ${total_cost:.4f}")
    print("=" * 120)

    # Export to JSON
    output_file = Path.cwd() / "claude_sessions_analysis.json"
    export_data = {
        "generated_at": datetime.now().isoformat(),
        "total_sessions": len(all_sessions),
        "total_cost": total_cost,
        "total_tokens": {
            "input": total_input,
            "output": total_output,
            "cache_read": total_cache_read,
            "cache_creation": total_cache_create,
        },
        "context_analysis": {
            "peak_context_tokens": max_context,
            "avg_context_per_turn": avg_context,
            "total_api_turns": total_turns,
            "turns_over_200k": total_over_200k,
        },
    }

    if aggregate_by_day_flag:
        export_data["aggregated_by"] = "day"
        export_data["daily_data"] = aggregate_by_day(all_sessions)
    else:
        export_data["sessions"] = all_sessions

    with open(output_file, 'w') as f:
        json.dump(export_data, f, indent=2, default=str)

    print(f"\nDetailed analysis exported to: {output_file.absolute()}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Analyze Claude Code session data and compute token usage and costs.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Analyze all sessions
  %(prog)s

  # Analyze sessions from a specific date onwards
  %(prog)s --start-date 2026-01-20

  # Analyze sessions within a date range
  %(prog)s --start-date 2026-01-20 --end-date 2026-01-23

  # Analyze sessions up to a specific date
  %(prog)s --end-date 2026-01-22

  # Aggregate sessions by day
  %(prog)s --by-day

  # Daily breakdown for a specific week
  %(prog)s --start-date 2026-01-20 --end-date 2026-01-26 --by-day
        """
    )
    parser.add_argument(
        "--start-date",
        type=str,
        help="Start date for filtering sessions (YYYY-MM-DD format, inclusive)"
    )
    parser.add_argument(
        "--end-date",
        type=str,
        help="End date for filtering sessions (YYYY-MM-DD format, inclusive)"
    )
    parser.add_argument(
        "--by-day",
        action="store_true",
        help="Aggregate sessions by day instead of showing individual sessions"
    )

    args = parser.parse_args()

    # Parse dates if provided
    start_date = None
    end_date = None

    try:
        if args.start_date:
            start_date = parse_date_filter(args.start_date)
        if args.end_date:
            end_date = parse_date_filter(args.end_date)
    except ValueError as e:
        print(f"Error: {e}")
        parser.print_help()
        exit(1)

    # Validate date range
    if start_date and end_date and start_date > end_date:
        print("Error: Start date cannot be after end date")
        exit(1)

    analyze_all_sessions(start_date=start_date, end_date=end_date, aggregate_by_day_flag=args.by_day)
