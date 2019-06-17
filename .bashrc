# If not running interactively, don't do anything [[ $- != *i* ]] && return
# [[ $TERM != "screen" ]] && exec tmux

alias ls='ls --color=auto'
alias cls='clear'
alias arnoldc='sh /home/daniel/.scripts/arnoldc/run.sh'
alias xup="xrdb ~/.Xresources"
alias trackpad='sh ~/.scripts/mouse/trackpad.sh'
alias mouse='sh ~/.scripts/mouse/mouse.sh'
alias cups="sudo systemctl start org.cups.cupsd.service"
alias restart-xmonad="echo Recompiling and restarting... &&  xmonad --recompile && xmonad --restart"
alias vim="nvim"

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
# work
alias ns="kubectl config set-context \$(kubectl config current-context) --namespace"

PS1='[\u@\h \W]\$ '
