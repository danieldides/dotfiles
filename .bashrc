parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

alias ls='ls --color=auto'
alias cls='clear'
alias xup="xrdb ~/.Xresources"
alias vim="nvim"
alias pass="gopass"

export VISUAL=vim
export EDITOR="$VISUAL"
export TERM="screen-256color"
export TerminalEmulator="termite"

export KUBECONFIG=~/.kube/config:~/.kube/k3s-config

if [ -f ~/usr/lib/python3.5/site-packages/powerline/bindings/bash/powerline.sh ]; then
	    source ~/usr/lib/python3.5/site-packages/powerline/bindings/bash/powerline.sh
fi

export GOPATH=$HOME/go
export GOBIN=$HOME/go/bin
export PATH=$PATH:$GOBIN

export PATH=$PATH:/home/daniel/.local/bin
export PATH=$PATH:/home/daniel/Applications

source $HOME/.poetry/env

# work
alias ns="kubectl config set-context \$(kubectl config current-context) --namespace"

export PS1="\u@\h \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "
