eval "$(starship init zsh)"

# Ensure needed directories exist
mkdir -p ~/.zsh
source ~/.alias

# Plugin directory
ZSH_PLUGIN_DIR="${ZDOTDIR:-$HOME}/.zsh"

# Autosuggestions setup with persistent history
if [[ ! -d "$ZSH_PLUGIN_DIR/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_PLUGIN_DIR/zsh-autosuggestions"
fi

# History substring search setup
if [[ ! -d "$ZSH_PLUGIN_DIR/zsh-history-substring-search" ]]; then
    git clone https://github.com/zsh-users/zsh-history-substring-search "$ZSH_PLUGIN_DIR/zsh-history-substring-search"
fi

# Persistent history configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt EXTENDED_HISTORY      # Write the history file in the ":start:elapsed;command" format
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicate entries first when trimming history
setopt HIST_IGNORE_DUPS      # Don't record an entry that was just recorded again
setopt HIST_IGNORE_ALL_DUPS  # Delete old recorded entry if new entry is a duplicate
setopt HIST_FIND_NO_DUPS     # Do not display a line previously found
setopt HIST_SAVE_NO_DUPS     # Don't write duplicate entries in the history file
setopt HIST_REDUCE_BLANKS    # Remove superfluous blanks before recording entry
setopt SHARE_HISTORY         # Share history between all sessions

# Enable vi mode
bindkey -v

# Custom keybinding to exit INSERT mode by pressing 'jj'
bindkey -M viins 'jj' vi-cmd-mode
#
# Cursor shape change function for different vi modes
function zle-keymap-select {
    case $KEYMAP in
        vicmd)      print -n '\e[1 q';;      # Block cursor for normal mode
        viins|main) print -n '\e[5 q';;      # Beam cursor for insert mode
    esac
}

function zle-line-init {
    echo -ne '\e[5 q'  # Beam cursor on startup
}

zle -N zle-keymap-select
zle -N zle-line-init

# Cursor shape persistence after each command
preexec() { 
    echo -ne '\e[5 q'  # Beam cursor before executing a command
}

# Custom keybinding to exit INSERT mode by pressing 'jj'
bindkey -M viins 'jj' vi-cmd-mode

# History substring search keybindings (vim-style)
source "$ZSH_PLUGIN_DIR/zsh-history-substring-search/zsh-history-substring-search.zsh"
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# # Efficient vi mode indicator
# function zsh_vi_mode_prompt() {
#     case $KEYMAP in
#         vicmd) echo "%F{red}[N]%f" ;;
#         viins|main) echo "%F{green}[I]%f" ;;
#         *) echo "%F{yellow}[?]%f" ;;
#     esac
# }
# # Lightweight git branch function
#
# function git_prompt() {
#     git branch 2>/dev/null | grep '^*' | cut -d' ' -f2- | sed 's/^/ (/;s/$/)/;s/^( /(/'
# }
#
# function dev_env_prompt() {
#     local env_info=""
#
#     # Python version detection
#     if [[ -f "pyproject.toml" || -f "setup.py" || -f "requirements.txt" ]]; then
#         local py_version=$(python --version 2>&1 | cut -d' ' -f2)
#         if [[ -n "$py_version" ]]; then
#             env_info+="%F{blue}(py:$py_version)%f"
#         fi
#
#         # Virtual environment detection
#         if [[ -n "$VIRTUAL_ENV" ]]; then
#             env_info+="%F{cyan}(venv)%f"
#         fi
#     fi
#
#     # Node.js version detection
#     if [[ -f "package.json" ]]; then
#         local node_version=$(node --version 2>&1 | sed 's/^v//')
#         if [[ -n "$node_version" ]]; then
#             env_info+="%F{green}(node:$node_version)%f"
#         fi
#     fi
#
#     # Rust version detection
#     if [[ -f "Cargo.toml" ]]; then
#         local rust_version=$(rustc --version | cut -d' ' -f2)
#         if [[ -n "$rust_version" ]]; then
#             env_info+="%F{red}(rust:$rust_version)%f"
#         fi
#     fi
#
#     echo "$env_info"
# }
# # Current directory shortening
# function short_path() {
#     local full_path=$(pwd)
#     local home_path=$(echo $HOME)
#
#     # Replace home directory with ~
#     full_path=${full_path/#$home_path/\~}
#
#     # If path is too long, show only last two directories
#     if [[ ${#full_path} -gt 40 ]]; then
#         full_path=$(echo $full_path | awk -F'/' '{print $(NF-1)"/"$NF}')
#     fi
#
#     echo $full_path
# }
#
# # # Prompt setup
# # setopt PROMPT_SUBST
# # export PROMPT='%F{magenta}%n%f@%F{yellow}%m%f:%F{cyan}%~%f$(git_prompt)$(dev_env_prompt)$(zsh_vi_mode_prompt) $ '
#
# # Prompt setup
# setopt PROMPT_SUBST
# PROMPT="%F{green}$(short_path)%f %F{yellow}$(dev_env_prompt)$(git_prompt)%f %F{242}%*%f
# %(?.%F{blue}❯%f.%F{red}❯%f) "
#
# # Directory change reload prompt function
# function reload_prompt_on_cd() {
#     # Force Zsh to refresh the prompt without altering the prompt variables
#     PROMPT=$PROMPT
#     zle reset-prompt
# }
#
# # Attach to the chpwd hook to reload the prompt on directory change
# autoload -Uz add-zle-hook-widget
# autoload -Uz add-zsh-hook
# autoload -Uz add-zle 
# add-zsh-hook chpwd reload_prompt_on_cd

# Autosuggestions configuration
source "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_USE_ASYNC=true

# Tab completion
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# Performance optimization for completion
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case-insensitive completion
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

eval "$(zoxide init zsh)"

export PATH=$HOME/.local/bin:$PATH
export PATH=/opt/homebrew/bin/:$PATH
export DPRINT_INSTALL="/Users/marc.arbones/.dprint"
export LUA_LANGUAGE_SERVER="$HOME/.local/share/nvim/lsp_servers/sumneko_lua/extension/server/bin"
export PATH="$DPRINT_INSTALL/bin:$PATH"
export PATH="$LUA_LANGUAGE_SERVER:$PATH"

export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/go/bin
export PATH="$GO_BIN_FOLDER:$PATH"
export PATH=$PATH:/mnt/c/Users/marbo/AppData/Local/Programs/Microsoft\ VS\ Code/bin

# bun completions
[ -s "/home/marbones/.bun/_bun" ] && source "/home/marbones/.bun/_bun"

eval "$(fnm env --use-on-cd --shell zsh)"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# java
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# pnpm
export PNPM_HOME="/home/marbones/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

eval "$(fnm env --use-on-cd --shell zsh)"
