eval "$(starship init zsh)"

unsetopt BEEP

source ~/.alias
source ~/.profile

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
export KUBE_EDITOR='nvim'

source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
source ~/.zsh/plugins/zsh-vi-mode/zsh-vi-mode.zsh

autoload -U +X compinit && compinit
zstyle ':completion:*' menu select

autoload -Uz bashcompinit && bashcompinit
complete -C aws_completer aws
complete -C aws_completer sudo
complete -C aws_completer aws-vault

command -v flux >/dev/null 2>&1 && . <(flux completion zsh)

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

ZVM_VI_INSERT_ESCAPE_BINDKEY=jj

export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=/opt/homebrew/bin/:$PATH
export DPRINT_INSTALL="/Users/marc.arbones/.dprint"
export LUA_LANGUAGE_SERVER="$HOME/.local/share/nvim/lsp_servers/sumneko_lua/extension/server/bin"
export PATH="$DPRINT_INSTALL/bin:$PATH"
export PATH="$LUA_LANGUAGE_SERVER:$PATH"

export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/go/bin
export PATH="$GO_BIN_FOLDER:$PATH"

# tmuxp for sessions
export DISABLE_AUTO_TITLE='true'

eval "$(zoxide init zsh)"

[ -f $HOME/.config/broot/launcher/bash/br ] && source $HOME/.config/broot/launcher/bash/br

# fnm
export PATH=/Users/marc.arbones/.fnm:$PATH

# WSL
export WINHOME=/mnt/c/Users/marbo/
export APPDATA=/mnt/c/Users/marbo/AppData/Roaming
if [ -d WINHOME ]; then
  alias winhome='$WINHOME'
fi

# Gradle
export PATH=$PATH:/opt/gradle/gradle-7.4.2/bin

# Ruby
export GEM_HOME="$HOME/.gem/"
export PATH=$PATH:"$GEM_HOME/bin"

eval "$(rbenv init - zsh)" 
# eval "$(frum init)"

export SAM_CLI_TELEMETRY=0 

eval "`fnm env --use-on-cd`"

[ -d /home/linuxbrew/.linuxbrew ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
export PATH="/opt/homebrew/opt/postgresql@12/bin:$PATH"
