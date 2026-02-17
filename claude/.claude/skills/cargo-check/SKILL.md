---
name: cargo-check
description: Run cargo check/build/clippy/test with token-efficient error tracking, test result summaries (cucumber-rs + standard harness), and fix-order recommendations. Use this skill instead of running cargo directly via Bash. Invoke whenever you need to compile, type-check, lint, or test Rust code.
argument-hint: "<check|build|clippy|test> [--include-warnings] [--package <name>] [--reset-tracker] [--show-fixed] [--fresh] [--compile-only]"
context: fork
model: haiku
allowed-tools: Bash(python3 *), Read
---

# Cargo Diagnostics

Run the diagnostics script and return its output verbatim. Do NOT summarize, rephrase, or add commentary.

## Steps

1. Run the script:
```bash
python3 ~/.claude/skills/cargo-check/scripts/cargo-diagnostics.py $ARGUMENTS
```

2. Return the COMPLETE stdout output as-is. The script output is already formatted for the main model to consume.

3. If the script exits with a non-zero code, still return all output (it contains the error details).

## Subcommands

- `check` — fast type-checking (errors only by default)
- `build` — full compilation
- `clippy` — linter (promotes warnings to errors by default)
- `test` — compile AND run tests, parse results from both cucumber-rs and standard harness
- `test --compile-only` — only compile test targets, don't execute them

## Key flags

- `--include-warnings` — show warnings alongside errors
- `--package <name>` / `-p <name>` — scope to a single crate
- `--reset-tracker` — clear fix-tracking state, start fresh
- `--show-fixed` — include recently fixed items in output
- `--fresh` — run cargo clean first (full recompile)
- `--compile-only` — for test: only compile, skip execution
