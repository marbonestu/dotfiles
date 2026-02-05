# ============================================================================
# Powerlevel10k Instant Prompt
# ============================================================================
# Must stay close to the top of ~/.zshrc
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ============================================================================
# Environment Variables
# ============================================================================
export EDITOR='nvim'
export SUDO_EDITOR='nvim'
export HELIX_RUNTIME=~/projects/helix/runtime

# ============================================================================
# Directories & Aliases
# ============================================================================
[[ -d ~/.zsh ]] || mkdir -p ~/.zsh
source ~/.alias

# ============================================================================
# History Configuration
# ============================================================================
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY

# ============================================================================
# Completion System
# ============================================================================
# Optimized: only rebuild dump once per day
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# Completion styling
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# ============================================================================
# Vi Mode & Keybindings
# ============================================================================
bindkey -v
bindkey -M viins 'jj' vi-cmd-mode

# Cursor shapes for vi modes
function zle-keymap-select {
    case $KEYMAP in
        vicmd)      print -n '\e[1 q';;  # Block cursor
        viins|main) print -n '\e[5 q';;  # Beam cursor
    esac
}

function zle-line-init {
    echo -ne '\e[5 q'  # Beam cursor on startup
}

preexec() {
    echo -ne '\e[5 q'  # Beam cursor before command
}

zle -N zle-keymap-select
zle -N zle-line-init

# ============================================================================
# Zinit Plugin Manager
# ============================================================================
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# ============================================================================
# Plugins (Lazy-loaded)
# ============================================================================
# Load fzf-tab first (must be before other completions)
zinit light Aloxaf/fzf-tab

# Autosuggestions (deferred loading for faster startup)
zinit ice wait lucid atload'_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

# Syntax highlighting (load after autosuggestions)
zinit ice wait lucid
zinit light zsh-users/zsh-syntax-highlighting

# Autosuggestions configuration
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# ============================================================================
# FZF Integration
# ============================================================================
# Modern fzf integration (replaces history-substring-search with better fuzzy search)
eval "$(fzf --zsh)"

# fzf-tab configuration
zstyle ':fzf-tab:*' fzf-command fzf
zstyle ':fzf-tab:*' fzf-flags --height=40%
zstyle ':completion:*:descriptions' format '[%d]'

# Note: Use Ctrl-R for fuzzy history search (more powerful than substring search)

# ============================================================================
# External Tools
# ============================================================================
eval "$(zoxide init zsh)"

# ============================================================================
# PATH Configuration
# ============================================================================
export PATH="$HOME/.local/bin:$HOME/.local/scripts:$HOME/.opencode/bin:$PATH"
export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin"

# ============================================================================
# Language & Runtime Managers (Optimized with lazy-loading)
# ============================================================================
# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Lazy-load fnm (Node version manager) - loads only when first used
fnm() {
  unfunction fnm
  eval "$(command fnm env --use-on-cd --shell zsh)"
  fnm "$@"
}

# Lazy-load SDKMAN (Java version manager) - loads only when first used
export SDKMAN_DIR="$HOME/.sdkman"
sdk() {
  unfunction sdk
  [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
  sdk "$@"
}

# ============================================================================
# OS-Specific Configuration
# ============================================================================
if [[ "$OSTYPE" == "darwin"* ]]; then
    [[ -f ~/.zshrc.macos ]] && source ~/.zshrc.macos
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    [[ -f ~/.zshrc.linux ]] && source ~/.zshrc.linux
fi

# ============================================================================
# Prompt Theme (Powerlevel10k)
# ============================================================================
if [[ ! -d "$HOME/powerlevel10k" ]]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/powerlevel10k"
fi
source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
