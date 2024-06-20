#/bin/env/sh
tmux list-sessions -F '#{?session_attached,,#{session_name}}' | sed '/^$/d' | fzf --header 'jump-to-session' | xargs tmux switch-client -t
