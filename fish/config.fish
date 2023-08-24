source ~/.asdf/asdf.fish
fish_add_path /opt/homebrew/bin

# Alias
alias k=kubectl
alias ns="kubectl ns"
alias ctx="kubectl ctx"

alias tf="terraform"
alias asdf-add-plugin="cut -d' ' -f1 .tool-versions|xargs -I P asdf plugin add \"P\""
alias whoseport="lsof -i -n -P | grep $1"

alias docker-stop-all="docker stop (docker ps -a -1)"

alias ls='ls -G'
alias vim="nvim"

alias gist="gh gist create"

set -gx VISUAL nvim
set -gx EDITOR "$VISUAL"
set -gx KUBECTL_EXTERNAL_DIFF "dyff between --omit-header --set-exit-code"

set -gx GOPATH $HOME/go
set -gx GOBIN $HOME/go/bin

fish_add_path -m $GOBIN

fish_add_path /Users/daniel/.local/bin

# set -gx PATH $PATH $HOME/.krew/bin
fish_add_path /Users/daniel/.krew/bin

source "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.fish.inc"
