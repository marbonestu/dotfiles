#!/usr/bin/env bash

PROJECTS_PATHS=(
  ~/projects
  ~/projects/fermyon
  ~/projects/diligent
  ~/projects/pact-foundation
  ~/projects/flux
  ~/projects/wasmcloud
  ~/projects/nvim-configs/
)

EXISTING_PROJECTS_PATHS=()

for dir in "${PROJECTS_PATHS[@]}"; do
  if [ -d "$dir" ]; then
    EXISTING_PROJECTS_PATHS+=("$dir")
  fi
done

# Show fzf to select a project
PROJECT=$(find "${EXISTING_PROJECTS_PATHS[@]}" -mindepth 1 -maxdepth 1 -type d | fzf)

if [[ -n "$PROJECT" ]]; then
  SESSION_NAME=$(basename "$PROJECT")

  # # Close the floating window
  zellij action close-pane
  #
  # # Wait briefly to ensure the floating window is closed
  sleep 0.1  

  # Start a new Zellij session (ensuring it's not inside the floating window)
  # nohup zellij attach --create "$SESSION_NAME" > /dev/null 2>&1 &
  nohup zellij --session "$SESSION_NAME" --new-session-with-layout default options --default-cwd "$PROJECT"
fi
