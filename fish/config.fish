# source ~/.asdf/asdf.fish
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

alias sed=gsed

# Fix pyenv
alias brew="env PATH=(string replace (pyenv root)/shims '' \"\$PATH\") brew"

set -gx VISUAL nvim
set -gx EDITOR "$VISUAL"
set -gx KUBECTL_EXTERNAL_DIFF "dyff between --omit-header --set-exit-code"
set -gx PATH $PATH $HOME/.krew/bin

set -gx GOPATH $HOME/go
set -gx GOBIN $HOME/go/bin

set -x GPG_TTY (tty)

fish_add_path -m $GOBIN
fish_add_path /Users/daniel/.local/bin
# source "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.fish.inc"

pyenv init - fish | source

function open-webui
    if test -z "$VIRTUAL_ENV"
        pyenv activate open-webui-env
    end
    command open-webui
end

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /Users/daniel/.lmstudio/bin
# End of LM Studio CLI section

