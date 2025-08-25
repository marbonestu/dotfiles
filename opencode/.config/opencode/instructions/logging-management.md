# Logging & Output Management

## General Principles

- Use quiet/silent flags when available (`--quiet`, `-q`, `--silent`)
- Suppress verbose output unless specifically requested
- Focus on errors and warnings, filter out info/debug messages
- Show only relevant parts of large outputs
- Truncate repetitive or excessive log messages

## Command Line Tools

- Use environment variables to control log levels (e.g., `LOG_LEVEL=error`)
- Pipe output through `head`, `tail`, or `grep` to show relevant portions
- Use `2>/dev/null` to suppress stderr when not needed for debugging
- Combine commands efficiently to reduce overall output

## Error Reporting

- Show only the first occurrence of repeated errors
- Focus on actionable error messages
- Include file paths and line numbers for errors
- Exclude stack traces unless debugging specific issues

## Build Systems & CI

- Use build system quiet modes (e.g., `make -s`, `ninja -v 0`)
- Show progress indicators instead of verbose output
- Only display failed builds/tests in detail
- Use summary formats when available

## Development Workflow

- Check for quiet modes in package managers (`npm install --silent`, `pip install -q`)
- Use formatter/linter quiet modes unless specific output is needed
- Prefer fast check commands over full builds for validation
- Show only changed/affected files in diff outputs
