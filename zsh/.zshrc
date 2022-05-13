eval "$(starship init zsh)"

unsetopt BEEP

source ~/.alias

# set history
HISTFILESIZE=1000000000
HISTSIZE=1000000000
HISTFILE=~/.zsh_history
SAVEHIST=1000000000
setopt appendhistory
setopt share_history
setopt autocd

set show-mode-in-prompt on
set vi-cmd-mode-string "\1\e[2 q\2"
set vi-ins-mode-string "\1\e[6 q\2"

export EDITOR='nvim'

[ -f $HOME/.forgit/forgit.plugin.zsh ] && source $HOME/.forgit/forgit.plugin.zsh

export NVM_LAZY_LOAD=true
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
source ~/.zsh/plugins/zsh-vi-mode/zsh-vi-mode.zsh

autoload -U +X compinit && compinit

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

ZVM_VI_INSERT_ESCAPE_BINDKEY=jj

export PATH=$HOME/.local/bin:$PATH
export PATH=/opt/homebrew/bin/:$PATH
export DPRINT_INSTALL="/Users/marc.arbones/.dprint"
export LUA_LANGUAGE_SERVER="$HOME/.local/share/nvim/lsp_servers/sumneko_lua/extension/server/bin"
export PATH="$DPRINT_INSTALL/bin:$PATH"
export PATH="$LUA_LANGUAGE_SERVER:$PATH"

eval "$(zoxide init zsh)"

[ -f $HOME/.config/broot/launcher/bash/br ] && source $HOME/.config/broot/launcher/bash/br

# fnm
export PATH=/Users/marc.arbones/.fnm:$PATH
eval "`fnm env --use-on-cd`"
