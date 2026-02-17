#!/usr/bin/env python3
"""Cargo diagnostics parser with token-efficient output and cross-run tracking."""

import argparse
import json
import re
import select
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

PRIORITY_TIERS = {
    1: {"E0432", "E0433"},
    2: {"E0412", "E0405"},
    3: {"E0599", "E0609"},
}


def find_workspace_root(start: Path = Path.cwd()) -> Path:
    """Walk up to find the workspace Cargo.toml."""
    current = start.resolve()
    while current != current.parent:
        toml = current / "Cargo.toml"
        if toml.exists():
            content = toml.read_text()
            if "[workspace]" in content:
                return current
        current = current.parent
    current = start.resolve()
    while current != current.parent:
        if (current / "Cargo.toml").exists():
            return current
        current = current.parent
    print("ERROR: No Cargo.toml found", file=sys.stderr)
    sys.exit(1)


def project_name(root: Path) -> str:
    toml = root / "Cargo.toml"
    for line in toml.read_text().splitlines():
        if line.strip().startswith("name"):
            parts = line.split("=", 1)
            if len(parts) == 2:
                return parts[1].strip().strip('"').strip("'")
    return root.name


def tracker_path(name: str) -> Path:
    return Path(f"/tmp/cargo-tracker-{name}.json")


def raw_log_path() -> Path:
    ts = datetime.now().strftime("%Y%m%d-%H%M%S")
    return Path(f"/tmp/cargo-diag-raw-{ts}.log")


def load_tracker(path: Path) -> dict:
    if path.exists():
        try:
            return json.loads(path.read_text())
        except (json.JSONDecodeError, OSError):
            pass
    return {"project": "", "last_run": "", "run_count": 0, "diagnostics": {}}


def save_tracker(path: Path, data: dict):
    path.write_text(json.dumps(data, indent=2))


def diag_key(code: str, file: str, line: int) -> str:
    return f"{code}::{file}:{line}"


STALL_TIMEOUT = 120  # seconds with no output before warning
OVERALL_TIMEOUT = 600  # 10 minutes max
HEARTBEAT_INTERVAL = 30  # seconds between progress heartbeats


def run_cargo(
    cmd: str,
    root: Path,
    package: str | None = None,
    compile_only: bool = False,
    manifest_path: Path | None = None,
) -> tuple[str, int, str]:
    """Run cargo command with JSON output, stall detection, and progress heartbeats."""
    args = ["cargo", cmd, "--message-format=json", "--color=never"]

    if manifest_path:
        args.extend(["--manifest-path", str(manifest_path)])

    if package:
        args.extend(["-p", package])

    if cmd in ("check", "clippy"):
        args.append("--tests")

    if cmd == "clippy":
        args.extend(["--", "-D", "warnings"])

    if cmd == "test" and compile_only:
        args.append("--no-run")

    proc = subprocess.Popen(
        args,
        cwd=root,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )

    stdout_lines: list[str] = []
    stderr_chunks: list[str] = []
    crates_compiled = 0
    last_crate = ""
    last_output_time = time.monotonic()
    start_time = last_output_time
    stall_warned = False

    while proc.poll() is None:
        ready, _, _ = select.select(
            [proc.stdout, proc.stderr], [], [], HEARTBEAT_INTERVAL
        )

        now = time.monotonic()

        for stream in ready:
            line = stream.readline()
            if not line:
                continue
            last_output_time = now
            stall_warned = False

            if stream == proc.stdout:
                stdout_lines.append(line.rstrip("\n"))
                # Count compiled crates for progress
                try:
                    msg = json.loads(line)
                    if msg.get("reason") == "compiler-artifact":
                        crates_compiled += 1
                        last_crate = msg.get("target", {}).get("name", "")
                except (json.JSONDecodeError, ValueError):
                    pass
            else:
                stderr_chunks.append(line)

        elapsed = now - start_time
        silent = now - last_output_time

        # Heartbeat: show progress so the caller knows we're alive
        if silent >= HEARTBEAT_INTERVAL and crates_compiled > 0:
            print(
                f"[cargo-diag] {elapsed:.0f}s elapsed, "
                f"{crates_compiled} crates compiled (last: {last_crate})",
                file=sys.stderr,
            )

        # Stall detection
        if silent >= STALL_TIMEOUT and not stall_warned:
            print(
                f"[cargo-diag] WARNING: no output for {silent:.0f}s — "
                f"cargo may be stuck (pid {proc.pid})",
                file=sys.stderr,
            )
            stall_warned = True

        # Overall timeout
        if elapsed >= OVERALL_TIMEOUT:
            print(
                f"[cargo-diag] TIMEOUT: {OVERALL_TIMEOUT}s exceeded, killing cargo",
                file=sys.stderr,
            )
            proc.kill()
            proc.wait()
            return "\n".join(stdout_lines), -1, "".join(stderr_chunks)

    # Drain remaining output
    for line in proc.stdout:
        stdout_lines.append(line.rstrip("\n"))
    for line in proc.stderr:
        stderr_chunks.append(line)

    return "\n".join(stdout_lines), proc.returncode, "".join(stderr_chunks)


def extract_compiled_packages(raw_output: str) -> set[str]:
    """Extract source directories of packages that were actually compiled.

    Returns a set of relative directory prefixes (e.g. {"backend", "crates/kratono-core"}).
    """
    src_dirs = set()
    for line in raw_output.splitlines():
        try:
            msg = json.loads(line.strip())
        except (json.JSONDecodeError, ValueError):
            continue
        if msg.get("reason") == "compiler-artifact" and not msg.get("fresh", True):
            target = msg.get("target", {})
            src_path = target.get("src_path", "")
            if src_path:
                parts = Path(src_path).parts
                for i, part in enumerate(parts):
                    if part == "src" and i > 0:
                        break
        if msg.get("reason") == "compiler-message":
            spans = msg.get("message", {}).get("spans", [])
            for span in spans:
                fname = span.get("file_name", "")
                if fname and not fname.startswith("/"):
                    parts = Path(fname).parts
                    if len(parts) >= 2:
                        if parts[0] == "crates" and len(parts) >= 3:
                            src_dirs.add(f"{parts[0]}/{parts[1]}")
                        else:
                            src_dirs.add(parts[0])
    return src_dirs


def split_output(raw_output: str) -> tuple[list[str], list[str]]:
    """Split raw output into JSON lines (cargo diagnostics) and plain text lines (test output)."""
    json_lines = []
    text_lines = []
    for line in raw_output.splitlines():
        stripped = line.strip()
        if not stripped:
            continue
        try:
            json.loads(stripped)
            json_lines.append(stripped)
        except (json.JSONDecodeError, ValueError):
            text_lines.append(line)
    return json_lines, text_lines


def parse_diagnostics(raw_output: str, include_warnings: bool = False) -> list[dict]:
    """Parse cargo JSON output into diagnostic entries."""
    diagnostics = []
    seen_keys = set()

    for line in raw_output.splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            msg = json.loads(line)
        except json.JSONDecodeError:
            continue

        if msg.get("reason") != "compiler-message":
            continue

        diag = msg.get("message", {})
        level = diag.get("level", "")

        if level == "error" or (include_warnings and level == "warning"):
            pass
        else:
            continue

        code_obj = diag.get("code")
        code = code_obj.get("code") if isinstance(code_obj, dict) else None
        if code is None and "aborting due to" in diag.get("message", ""):
            continue

        code_str = code or "E????"
        message_text = diag.get("message", "")

        spans = diag.get("spans", [])
        primary = None
        for s in spans:
            if s.get("is_primary"):
                primary = s
                break
        if not primary and spans:
            primary = spans[0]

        if not primary:
            continue

        file_name = primary.get("file_name", "?")
        line_num = primary.get("line_start", 0)
        col = primary.get("column_start", 0)

        suggestion = None
        for child in diag.get("children", []):
            if child.get("level") == "help" and child.get("spans"):
                for cs in child["spans"]:
                    if cs.get("suggested_replacement"):
                        suggestion = cs["suggested_replacement"].strip()
                        break
            if suggestion:
                break
            if child.get("level") == "help" and child.get("message"):
                suggestion = child["message"]

        key = diag_key(code_str, file_name, line_num)
        if key in seen_keys:
            continue
        seen_keys.add(key)

        diagnostics.append({
            "code": code_str,
            "level": level,
            "message": message_text,
            "file": file_name,
            "line": line_num,
            "col": col,
            "suggestion": suggestion,
            "key": key,
        })

    return diagnostics


# ---------------------------------------------------------------------------
# Test output parsing (cucumber-rs + standard harness)
# ---------------------------------------------------------------------------

# Cucumber patterns
_RE_FEATURE = re.compile(r"^\s*Feature:\s*(.+)", re.IGNORECASE)
_RE_SCENARIO = re.compile(r"^\s*Scenario(?:\s+Outline)?:\s*(.+)", re.IGNORECASE)
_RE_STEP_PASS = re.compile(r"^\s*[✔✓]\s+(Given|When|Then|And|But)\s+(.+)")
_RE_STEP_FAIL = re.compile(r"^\s*[✘✗×]\s+(Given|When|Then|And|But)\s+(.+)")
_RE_STEP_SKIP = re.compile(r"^\s*[?\-]\s+(Given|When|Then|And|But)\s+(.+)")
# Also handle the non-unicode markers cucumber uses in some terminals
_RE_STEP_FAIL_ALT = re.compile(
    r"^\s*(Given|When|Then|And|But)\s+(.+)\s+\[failed\]", re.IGNORECASE
)
_RE_CUCUMBER_SUMMARY = re.compile(
    r"(\d+)\s+scenarios?\s*\(([^)]+)\)", re.IGNORECASE
)

# Standard test harness patterns
_RE_RUST_TEST = re.compile(r"^test\s+(\S+)\s+\.\.\.\s+(ok|FAILED|ignored)")
_RE_RUST_SUMMARY = re.compile(
    r"^test result:\s+(ok|FAILED)\.\s+(\d+)\s+passed;\s+(\d+)\s+failed;\s+(\d+)\s+ignored"
)


def parse_test_output(text_lines: list[str], stderr: str = "") -> dict | None:
    """Parse test runtime output (both cucumber and standard harness).

    Returns None if no test output detected, otherwise a dict with:
      - format: "cucumber" | "standard" | "mixed"
      - passed: int
      - failed: int
      - skipped: int
      - failures: list of {name, step, error}
      - summary_line: str (raw summary if found)
    """
    all_lines = text_lines + stderr.splitlines()

    if not all_lines:
        return None

    cucumber_results = _parse_cucumber(all_lines)
    standard_results = _parse_standard(all_lines)

    if not cucumber_results and not standard_results:
        return None

    # Merge results from both parsers
    result = {
        "format": "unknown",
        "passed": 0,
        "failed": 0,
        "skipped": 0,
        "failures": [],
        "summary_line": "",
    }

    if cucumber_results and standard_results:
        result["format"] = "mixed"
        result["passed"] = cucumber_results["passed"] + standard_results["passed"]
        result["failed"] = cucumber_results["failed"] + standard_results["failed"]
        result["skipped"] = cucumber_results["skipped"] + standard_results["skipped"]
        result["failures"] = cucumber_results["failures"] + standard_results["failures"]
    elif cucumber_results:
        result = cucumber_results
    else:
        result = standard_results

    return result


def _parse_cucumber(lines: list[str]) -> dict | None:
    """Parse cucumber-rs output."""
    current_feature = ""
    current_scenario = ""
    current_step = ""
    in_failure = False
    failure_lines: list[str] = []

    passed = 0
    failed = 0
    skipped = 0
    failures: list[dict] = []

    found_any = False

    for line in lines:
        m = _RE_FEATURE.match(line)
        if m:
            current_feature = m.group(1).strip()
            found_any = True
            continue

        m = _RE_SCENARIO.match(line)
        if m:
            # If we were collecting a failure, finalize it
            if in_failure and current_scenario:
                _finalize_failure(
                    failures, current_feature, current_scenario,
                    current_step, failure_lines
                )
                failure_lines = []
                in_failure = False

            current_scenario = m.group(1).strip()
            found_any = True
            continue

        m = _RE_STEP_PASS.match(line)
        if m:
            if in_failure:
                _finalize_failure(
                    failures, current_feature, current_scenario,
                    current_step, failure_lines
                )
                failure_lines = []
                in_failure = False
            current_step = f"{m.group(1)} {m.group(2)}"
            continue

        m = _RE_STEP_FAIL.match(line) or _RE_STEP_FAIL_ALT.match(line)
        if m:
            if in_failure:
                _finalize_failure(
                    failures, current_feature, current_scenario,
                    current_step, failure_lines
                )
                failure_lines = []
            current_step = f"{m.group(1)} {m.group(2)}"
            in_failure = True
            failed += 1
            continue

        m = _RE_STEP_SKIP.match(line)
        if m:
            if in_failure:
                _finalize_failure(
                    failures, current_feature, current_scenario,
                    current_step, failure_lines
                )
                failure_lines = []
                in_failure = False
            skipped += 1
            continue

        # Cucumber summary line overrides our counts
        m = _RE_CUCUMBER_SUMMARY.match(line)
        if m:
            summary_text = m.group(2)
            for part in summary_text.split(","):
                part = part.strip()
                num_m = re.match(r"(\d+)\s+(\w+)", part)
                if num_m:
                    count = int(num_m.group(1))
                    status = num_m.group(2).lower()
                    if status == "passed":
                        passed = count
                    elif status == "failed":
                        failed = count
                    elif status in ("skipped", "pending"):
                        skipped = count
            found_any = True
            continue

        # Collect error lines within a failure
        if in_failure:
            stripped = line.strip()
            if stripped:
                failure_lines.append(stripped)

    # Finalize any trailing failure
    if in_failure and current_scenario:
        _finalize_failure(
            failures, current_feature, current_scenario,
            current_step, failure_lines
        )

    if not found_any:
        return None

    return {
        "format": "cucumber",
        "passed": passed,
        "failed": failed,
        "skipped": skipped,
        "failures": failures,
        "summary_line": "",
    }


def _finalize_failure(
    failures: list[dict], feature: str, scenario: str, step: str, error_lines: list[str]
):
    error_text = "\n".join(error_lines[:5])  # Cap at 5 lines per failure
    if len(error_lines) > 5:
        error_text += f"\n  ... ({len(error_lines) - 5} more lines)"
    failures.append({
        "name": f"[{feature}] {scenario}" if feature else scenario,
        "step": step,
        "error": error_text,
    })


def _parse_standard(lines: list[str]) -> dict | None:
    """Parse standard Rust test harness output."""
    passed = 0
    failed = 0
    ignored = 0
    failed_names: list[str] = []
    found_any = False
    has_summary = False

    # Capture failure stdout sections
    in_failures_section = False
    current_failure_name = ""
    failure_details: dict[str, list[str]] = {}

    for line in lines:
        # Match individual test results (only count if no summary lines found yet)
        m = _RE_RUST_TEST.match(line)
        if m:
            found_any = True
            name = m.group(1)
            status = m.group(2)
            if not has_summary:
                if status == "ok":
                    passed += 1
                elif status == "FAILED":
                    failed += 1
                elif status == "ignored":
                    ignored += 1
            if status == "FAILED":
                failed_names.append(name)
            continue

        # Summary line: accumulate across multiple test binaries
        m = _RE_RUST_SUMMARY.match(line)
        if m:
            found_any = True
            if not has_summary:
                # First summary — switch from individual counting to summary accumulation
                has_summary = True
                passed = int(m.group(2))
                failed = int(m.group(3))
                ignored = int(m.group(4))
            else:
                passed += int(m.group(2))
                failed += int(m.group(3))
                ignored += int(m.group(4))
            continue

        # Track failure details
        if line.strip() == "failures:":
            in_failures_section = True
            continue

        if in_failures_section:
            # "---- test_name stdout ----"
            detail_m = re.match(r"^---- (\S+) stdout ----$", line.strip())
            if detail_m:
                current_failure_name = detail_m.group(1)
                failure_details[current_failure_name] = []
                continue

            if current_failure_name and line.strip() and not line.strip().startswith("----"):
                failure_details[current_failure_name].append(line.strip())

    if not found_any:
        return None

    failures = []
    for name in failed_names:
        details = failure_details.get(name, [])
        error_text = "\n".join(details[:5])
        if len(details) > 5:
            error_text += f"\n  ... ({len(details) - 5} more lines)"
        failures.append({
            "name": name,
            "step": "",
            "error": error_text,
        })

    return {
        "format": "standard",
        "passed": passed,
        "failed": failed,
        "skipped": ignored,
        "failures": failures,
        "summary_line": "",
    }


# ---------------------------------------------------------------------------
# Formatting
# ---------------------------------------------------------------------------

def get_priority(code: str) -> int:
    for tier, codes in PRIORITY_TIERS.items():
        if code in codes:
            return tier
    return 4


def _file_in_scope(file_path: str, compiled_dirs: set[str] | None) -> bool:
    if compiled_dirs is None:
        return True
    parts = Path(file_path).parts
    if len(parts) >= 2:
        if parts[0] == "crates" and len(parts) >= 3:
            prefix = f"{parts[0]}/{parts[1]}"
        else:
            prefix = parts[0]
        return prefix in compiled_dirs
    return True


def update_tracker(
    tracker: dict, new_diags: list[dict], proj: str, compiled_dirs: set[str] | None = None
) -> list[str]:
    """Update tracker with new diagnostics, return list of fixed keys."""
    now = datetime.now(timezone.utc).isoformat()
    tracker["project"] = proj
    tracker["last_run"] = now
    tracker["run_count"] = tracker.get("run_count", 0) + 1

    existing = tracker.get("diagnostics", {})
    new_keys = {d["key"] for d in new_diags}
    fixed = []

    for key, entry in list(existing.items()):
        if entry.get("status") == "pending" and key not in new_keys:
            if _file_in_scope(entry.get("file", ""), compiled_dirs):
                entry["status"] = "fixed"
                entry["fixed_at"] = now
                fixed.append(key)

    for d in new_diags:
        if d["key"] not in existing:
            existing[d["key"]] = {
                "code": d["code"],
                "level": d["level"],
                "message": d["message"],
                "file": d["file"],
                "line": d["line"],
                "suggestion": d["suggestion"],
                "status": "pending",
                "first_seen": now,
            }
        else:
            entry = existing[d["key"]]
            entry["status"] = "pending"
            entry["message"] = d["message"]
            entry["line"] = d["line"]
            entry.pop("fixed_at", None)

    tracker["diagnostics"] = existing
    return fixed


def format_output(
    cmd: str,
    proj: str,
    diagnostics: list[dict],
    fixed_keys: list[str],
    tracker: dict,
    include_warnings: bool,
    raw_log: Path,
    tracker_file: Path,
    show_fixed: bool = False,
    test_results: dict | None = None,
) -> str:
    """Format compact diagnostic output."""
    now = datetime.now().strftime("%Y-%m-%d %H:%M")
    run_num = tracker.get("run_count", 1)

    lines = []
    lines.append(f"=== CARGO DIAGNOSTICS: {cmd} ===")
    lines.append(f"Project: {proj} | Run #{run_num} | {now}")
    lines.append("")

    errors = [d for d in diagnostics if d["level"] == "error"]
    warnings = [d for d in diagnostics if d["level"] == "warning"]

    # Progress section
    lines.append("--- PROGRESS ---")
    if errors:
        fix_msg = f" ({len(fixed_keys)} fixed since last run)" if fixed_keys else ""
        lines.append(f"Errors: {len(errors)} remaining{fix_msg}")
    else:
        fix_msg = f" ({len(fixed_keys)} fixed since last run)" if fixed_keys else ""
        lines.append(f"Errors: 0 remaining{fix_msg} - ALL CLEAR!")

    if include_warnings and warnings:
        lines.append(f"Warnings: {len(warnings)}")

    # Test results summary in progress
    if test_results:
        total = test_results["passed"] + test_results["failed"] + test_results["skipped"]
        if test_results["failed"] > 0:
            lines.append(
                f"Tests: {test_results['failed']} FAILED, "
                f"{test_results['passed']} passed, "
                f"{test_results['skipped']} skipped (total: {total})"
            )
        else:
            lines.append(
                f"Tests: ALL PASSED ({test_results['passed']} passed, "
                f"{test_results['skipped']} skipped, total: {total})"
            )

    lines.append("")

    # Fixed section
    if show_fixed and fixed_keys:
        lines.append(f"--- FIXED ({len(fixed_keys)}) ---")
        for key in fixed_keys:
            parts = key.split("::", 1)
            code = parts[0] if parts else "?"
            loc = parts[1] if len(parts) > 1 else "?"
            lines.append(f"  [FIXED] {code} {loc}")
        lines.append("")

    # Compilation errors
    if errors:
        lines.append(f"--- ERRORS ({len(errors)}) ---")
        lines.append("")
        _format_grouped(lines, errors)

    # Warnings
    if include_warnings and warnings:
        lines.append(f"--- WARNINGS ({len(warnings)}) ---")
        lines.append("")
        _format_grouped(lines, warnings)

    # Fix order recommendation
    error_codes = sorted(set(d["code"] for d in errors), key=lambda c: (get_priority(c), c))
    if len(error_codes) > 1:
        lines.append("--- FIX ORDER ---")
        tier_names = {
            1: "unresolved imports -> fix first, cascading",
            2: "missing types/traits -> often caused by imports",
            3: "missing methods/fields -> depend on type resolution",
            4: "other -> usually standalone",
        }
        for i, code in enumerate(error_codes, 1):
            tier = get_priority(code)
            count = sum(1 for d in errors if d["code"] == code)
            hint = tier_names.get(tier, "")
            lines.append(f"  {i}. {code} ({count} hit{'s' if count > 1 else ''}) -> {hint}")
        lines.append("")

    # Test failures (detailed)
    if test_results and test_results["failures"]:
        lines.append(f"--- FAILED TESTS ({len(test_results['failures'])}) ---")
        lines.append("")
        for i, fail in enumerate(test_results["failures"], 1):
            lines.append(f"  {i}. {fail['name']}")
            if fail.get("step"):
                lines.append(f"     Step: {fail['step']}")
            if fail.get("error"):
                # Indent error, cap line length
                for err_line in fail["error"].split("\n")[:5]:
                    if len(err_line) > 120:
                        err_line = err_line[:117] + "..."
                    lines.append(f"     {err_line}")
            lines.append("")

    # Clean build message
    if not errors and not (include_warnings and warnings) and not (test_results and test_results["failures"]):
        lines.append("No issues found. Build is clean!")
        lines.append("")

    lines.append(f"Raw log: {raw_log}")
    lines.append(f"Tracker: {tracker_file}")

    return "\n".join(lines)


def _collapse_locations(items: list[dict]) -> list[str]:
    """Collapse consecutive lines in the same file into ranges.

    Input:  [{file: "a.rs", line: 5}, {file: "a.rs", line: 6}, {file: "a.rs", line: 7}, {file: "b.rs", line: 10}]
    Output: ["a.rs:5-7", "b.rs:10"]
    """
    if not items:
        return []

    sorted_items = sorted(items, key=lambda d: (d["file"], d["line"]))
    ranges: list[str] = []
    cur_file = sorted_items[0]["file"]
    start = sorted_items[0]["line"]
    end = start

    for item in sorted_items[1:]:
        if item["file"] == cur_file and item["line"] == end + 1:
            end = item["line"]
        else:
            if start == end:
                ranges.append(f"{cur_file}:{start}")
            else:
                ranges.append(f"{cur_file}:{start}-{end}")
            cur_file = item["file"]
            start = item["line"]
            end = start

    if start == end:
        ranges.append(f"{cur_file}:{start}")
    else:
        ranges.append(f"{cur_file}:{start}-{end}")

    return ranges


def _format_grouped(lines: list[str], diags: list[dict]):
    """Group diagnostics by error code and format them compactly.

    Same-message groups: show message once + collapsed locations.
    Different-message groups: show per-item with only the unique detail.
    """
    groups: dict[str, list[dict]] = {}
    for d in diags:
        groups.setdefault(d["code"], []).append(d)

    sorted_codes = sorted(groups.keys(), key=lambda c: (get_priority(c), c))

    counter = 1
    for code in sorted_codes:
        items = groups[code]
        hits = len(items)
        unique_messages = set(d["message"] for d in items)

        if len(unique_messages) == 1:
            # All same message — compact form
            msg = items[0]["message"]
            if len(msg) > 80:
                msg = msg[:77] + "..."
            lines.append(f"## {code}: {msg} [{hits} hit{'s' if hits > 1 else ''}]")

            # Show suggestion once if any (deduplicated, skip trivially short ones)
            suggestions = set(
                d["suggestion"] for d in items
                if d.get("suggestion") and len(d["suggestion"]) > 3
            )
            if len(suggestions) == 1:
                sug = next(iter(suggestions))
                if len(sug) > 100:
                    sug = sug[:97] + "..."
                lines.append(f"  FIX: {sug}")
            elif suggestions:
                for sug in sorted(suggestions):
                    if len(sug) > 100:
                        sug = sug[:97] + "..."
                    lines.append(f"  FIX: {sug}")

            # Collapsed locations
            for loc in _collapse_locations(items):
                lines.append(f"  - {loc}")

            counter += hits
        else:
            # Different messages — show per-item but compact
            short_desc = items[0]["message"]
            if len(short_desc) > 60:
                short_desc = short_desc[:57] + "..."
            lines.append(f"## {code}: {short_desc} [{hits} hit{'s' if hits > 1 else ''}]")

            for item in items:
                msg = item["message"]
                if len(msg) > 100:
                    msg = msg[:97] + "..."
                loc = f"{item['file']}:{item['line']}"
                lines.append(f"  {counter}. {loc} -> {msg}")
                if item.get("suggestion"):
                    sug = item["suggestion"]
                    if len(sug) > 100:
                        sug = sug[:97] + "..."
                    lines.append(f"     FIX: {sug}")
                counter += 1

        lines.append("")


def count_hidden_warnings(raw_output: str) -> int:
    """Count warnings in output without fully parsing."""
    count = 0
    for line in raw_output.splitlines():
        try:
            msg = json.loads(line.strip())
            if msg.get("reason") == "compiler-message":
                if msg.get("message", {}).get("level") == "warning":
                    code_obj = msg["message"].get("code")
                    if code_obj and code_obj.get("code"):
                        count += 1
        except (json.JSONDecodeError, KeyError):
            continue
    return count


def main():
    parser = argparse.ArgumentParser(description="Cargo diagnostics with tracking")
    parser.add_argument("command", choices=["check", "build", "clippy", "test"],
                        help="Cargo command to run")
    parser.add_argument("--include-warnings", action="store_true",
                        help="Include warnings in output")
    parser.add_argument("--package", "-p", type=str, default=None,
                        help="Check specific crate")
    parser.add_argument("--reset-tracker", action="store_true",
                        help="Clear tracker, start fresh")
    parser.add_argument("--show-fixed", action="store_true",
                        help="Include recently fixed items")
    parser.add_argument("--fresh", action="store_true",
                        help="Run cargo clean first")
    parser.add_argument("--compile-only", action="store_true",
                        help="For test command: only compile, don't run tests")
    parser.add_argument("--manifest-path", type=str, default=None,
                        help="Path to Cargo.toml (overrides auto-detection)")

    args = parser.parse_args()

    if args.manifest_path:
        manifest = Path(args.manifest_path).resolve()
        root = manifest.parent
    else:
        root = find_workspace_root()
    proj = project_name(root)
    tpath = tracker_path(proj)

    if args.reset_tracker and tpath.exists():
        tpath.unlink()

    if args.fresh:
        subprocess.run(["cargo", "clean"], cwd=root, capture_output=True)

    # Run cargo
    manifest = Path(args.manifest_path).resolve() if args.manifest_path else None
    raw_output, exit_code, stderr = run_cargo(
        args.command, root, args.package,
        compile_only=args.compile_only, manifest_path=manifest,
    )

    # Save raw log
    log_file = raw_log_path()
    log_file.write_text(raw_output + "\n---STDERR---\n" + stderr)

    # Check for cargo-level failures (bad Cargo.toml, etc.)
    if exit_code != 0 and not raw_output.strip():
        print("=== CARGO FAILED ===")
        print(f"Command: cargo {args.command}")
        print(f"Exit code: {exit_code}")
        print(f"stderr:\n{stderr}")
        sys.exit(exit_code)

    # Parse compilation diagnostics
    diagnostics = parse_diagnostics(raw_output, args.include_warnings)

    # Parse test runtime output (for test command without --compile-only)
    test_results = None
    if args.command == "test" and not args.compile_only:
        _, text_lines = split_output(raw_output)
        test_results = parse_test_output(text_lines, stderr)

    # Scope tracker updates to only compiled packages
    compiled_dirs = extract_compiled_packages(raw_output) if args.package else None

    # Load and update tracker
    tracker = load_tracker(tpath)
    fixed_keys = update_tracker(tracker, diagnostics, proj, compiled_dirs)
    save_tracker(tpath, tracker)

    # Format output
    output = format_output(
        cmd=args.command,
        proj=proj,
        diagnostics=diagnostics,
        fixed_keys=fixed_keys,
        tracker=tracker,
        include_warnings=args.include_warnings,
        raw_log=log_file,
        tracker_file=tpath,
        show_fixed=args.show_fixed or bool(fixed_keys),
        test_results=test_results,
    )

    # Add hidden warning count if not including warnings
    if not args.include_warnings:
        wcount = count_hidden_warnings(raw_output)
        if wcount > 0:
            output += f"\n\n(Hiding {wcount} warnings. Use --include-warnings to see them.)"

    print(output)


if __name__ == "__main__":
    main()
