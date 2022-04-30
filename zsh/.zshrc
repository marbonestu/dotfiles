eval "$(starship init zsh)"

source ~/.alias

# set history
HISTFILESIZE=1000000000
HISTSIZE=1000000000
HISTFILE=~/.zsh_history
SAVEHIST=1000000000
setopt appendhistory
setopt share_history

set show-mode-in-prompt on
set vi-cmd-mode-string "\1\e[2 q\2"
set vi-ins-mode-string "\1\e[6 q\2"

export EDITOR='lvim'

[ -f ~/.forgit/forgit.plugin.zsh ] && source ~/.forgit/forgit.plugin.zsh

export NVM_LAZY_LOAD=true
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
source ~/.zsh/plugins/zsh-nvm/zsh-nvm.plugin.zsh
source ~/.zsh/plugins/zsh-vi-mode/zsh-vi-mode.zsh

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

ZVM_VI_INSERT_ESCAPE_BINDKEY=jj

export PATH=$HOME/.local/bin:$PATH
export DPRINT_INSTALL="/Users/marc.arbones/.dprint"
export PATH="$DPRINT_INSTALL/bin:$PATH"

eval "$(zoxide init zsh)"

source /Users/marc.arbones/.config/broot/launcher/bash/br
