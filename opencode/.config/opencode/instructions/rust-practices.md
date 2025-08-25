# Rust Development Practices

## Cargo Commands & Output Management

- When running `cargo build`, `cargo test`, or `cargo run`, use `--quiet` flag to reduce verbose output
- For errors, use `cargo check` first as it's faster than full compilation
- Use `cargo clippy --quiet` for linting to avoid excessive output
- When showing compilation errors, focus only on the relevant error messages, not the full backtrace
- Use `RUST_LOG=error` environment variable to suppress debug logs when running applications

## Error Handling & Debugging

- When compilation fails, show only the specific error and its location
- Focus on the actual error message, not the note/help suggestions unless specifically requested
- For runtime panics, show only the panic message and relevant stack trace lines
- Use `cargo check --message-format=short` for concise error reporting

## Testing & Benchmarking

- Use `cargo test --quiet` to reduce test output noise
- Only show failed test details, not successful test summaries
- For benchmarks, use `cargo bench --quiet` and focus on performance results
- When running specific tests, use `cargo test test_name --quiet -- --nocapture` only when output is needed

## Build Optimization

- Prefer `cargo check` over `cargo build` for syntax validation
- Use `cargo build --release --quiet` for production builds
- Only show timing information when specifically debugging build performance
- Use incremental compilation settings to speed up development builds

## Dependency Management

- When updating dependencies, use `cargo update --quiet`
- For dependency tree inspection, use `cargo tree --quiet` and focus on relevant branches
- Only show full dependency information when specifically requested

## Code Quality Tools

- Run `cargo fmt --check` to verify formatting without modifying files
- Use `cargo clippy --quiet -- -W clippy::all` for comprehensive but concise linting
- Focus on actionable clippy suggestions, filter out pedantic warnings unless requested
