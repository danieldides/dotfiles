fish_add_path /opt/homebrew/bin

# Podman-backed Docker on macOS
# `podman machine start` exposes the Docker-compatible API at /var/run/docker.sock.
if test (uname) = Darwin; and type -q podman
    set -gx DOCKER_HOST unix:///var/run/docker.sock
    set -gx DOCKER_CONTEXT default
    set -gx TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE /var/run/docker.sock
end

# Alias
alias k=kubectl
alias ns="kubectl ns"
alias ctx="kubectl ctx"
alias kubectx="kubie ctx"
alias kubens="kubie ns"

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

set -gx GOPATH $HOME/go
set -gx GOBIN $HOME/go/bin

set -gx XDG_CONFIG_HOME $HOME/.config

if type -q k9s
    if not set -q K9S_CONFIG_DIR
        if set -q XDG_CONFIG_HOME
            set -gx K9S_CONFIG_DIR "$XDG_CONFIG_HOME/k9s"
        else
            set -gx K9S_CONFIG_DIR "$HOME/.config/k9s"
        end
    end
end

fish_add_path -m $GOBIN

set -x GPG_TTY (tty)

# Load system-specific configuration (create secret.fish from secret.example.fish)
if test -f (dirname (status --current-filename))/secret.fish
    source (dirname (status --current-filename))/secret.fish
end

# kubectl krew (loaded after secret to respect KUBECONFIG if set)
fish_add_path $HOME/.krew/bin

# mise (loaded last so project tools take precedence over Homebrew tools)
if type -q mise
    mise activate fish | source
    mise env -s fish | source
end
