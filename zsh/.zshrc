# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH=/Users/alejandro.huertas/.oh-my-zsh

plugins=(colorize fzf-zsh-plugin wd)

ZSH_THEME='powerlevel10k/powerlevel10k'

DEFAULT_USER=$USER
source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# google-cloud-sdk brew caveat
# source "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
# source "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"

# BEGIN ANSIBLE MANAGED BLOCK
# Add homebrew binaries to the path.
export PATH="/opt/homebrew/bin:${PATH?}"
export PATH="/Users/alejandro.huertas/.local/bin:${PATH}"
export PATH="/Users/alejandro.huertas/bin:${PATH}"
export PATH="/Users/alejandro.huertas/.cargo/bin:${PATH}"

# Force certain more-secure behaviours from homebrew
export HOMEBREW_NO_INSECURE_REDIRECT=1
export HOMEBREW_CASK_OPTS=--require-sha
export HOMEBREW_DIR=/opt/homebrew
export HOMEBREW_BIN=/opt/homebrew/bin

# Load python shims
eval "$(pyenv init -)"

# Load ruby shims
eval "$(rbenv init -)"

# Prefer GNU binaries to Macintosh binaries.
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:${PATH}"

# Add AWS CLI to PATH
export PATH="/opt/homebrew/opt/awscli@1/bin:$PATH"

# Add datadog devtools binaries to the PATH
export PATH="${HOME?}/dd/devtools/bin:${PATH?}"

# Point GOPATH to our go sources
export GOPATH="${HOME?}/go"

# Add binaries that are go install-ed to PATH
export PATH="${GOPATH?}/bin:${PATH?}"

# Point DATADOG_ROOT to ~/dd symlink
export DATADOG_ROOT="${HOME?}/dd"

# Tell the devenv vm to mount $GOPATH/src rather than just dd-go
export MOUNT_ALL_GO_SRC=1

# store key in the login keychain instead of aws-vault managing a hidden keychain
export AWS_VAULT_KEYCHAIN_NAME=login

# tweak session times so you don't have to re-enter passwords every 5min
export AWS_SESSION_TTL=24h
export AWS_ASSUME_ROLE_TTL=1h

# Helm switch from storing objects in kubernetes configmaps to
# secrets by default, but we still use the old default.
export HELM_DRIVER=configmap

# Go 1.16+ sets GO111MODULE to off by default with the intention to
# remove it in Go 1.18, which breaks projects using the dep tool.
# https://blog.golang.org/go116-module-changes
export GO111MODULE=auto
export GOPRIVATE=github.com/DataDog
# END ANSIBLE MANAGED BLOCK
export GITLAB_TOKEN=$(security find-generic-password -a ${USER} -s gitlab_token -w)

#export USE_BAZEL_VERSION=5.4.0

export KUBECONFIG=~/.kube/config

# K8S alias
alias kc='dctx'
alias kn='kubens'
alias k='kubectl'
alias ku='kubectx --unset'
alias kb='func _kbash(){kubectl exec -ti $@ -- bash}; _kbash'
alias kdd='func _k2dd(){kubectl $@ | k2dd}; _k2dd'
alias kdda='func _k2dda(){kubectl $@ | k2dd --audit}; _k2dda'
alias kdogq='kubectl exec -n dogq $(kubectl get -n dogq pod -l app=dogq -o=name --field-selector status.phase=Running) -it -- /bin/bash'

# K8S autocomplete
[[ $commands[kubectl] ]] && source <(kubectl completion zsh)

# Misc alias
alias ls='ls --color=auto'
alias tctl='tctx exec -- tctl'
alias gofmt='wd source && bzl run @go_sdk//:bin/gofmt -- -w domains/adp/elasticsearch/apps/workers/elasticsearch/worker'
alias codefmt='bzl run @go_sdk//:bin/gofmt -- -w'
alias snap='wd source && bzl run //:snapshot -- //domains/mars/apps/geminio/...'
alias gaz='wd source && bzl run //:gazelle'
alias wfpr='gaz && snap && gofmt'
alias trainctl='wd source && tctx exec -- bzl run //domains/eee/apps/sdp/cmd/trainctl:trainctl'
alias g='LANG=en_US.UTF git'
#alias cd='z'

source /Users/alejandro.huertas/.k8s_aliases.sh

eval "$(zoxide init zsh)"
#compdef gt
###-begin-gt-completions-###
#
# yargs command completion script
#
# Installation: /opt/homebrew/bin/gt completion >> ~/.zshrc
#    or /opt/homebrew/bin/gt completion >> ~/.zprofile on OSX.
#
_gt_yargs_completions()
{
  local reply
  local si=$IFS
  IFS=$'
' reply=($(COMP_CWORD="$((CURRENT-1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" /opt/homebrew/bin/gt --get-yargs-completions "${words[@]}"))
  IFS=$si
  _describe 'values' reply
}
compdef _gt_yargs_completions gt
###-end-gt-completions-###

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

export GPG_TTY=$(tty)
# source /Users/alejandro.huertas/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
  autoload -Uz compinit
  compinit
fi

# Set SSH_AUTH_SOCK to the launchd-managed ssh-agent socket (com.openssh.ssh-agent).
export SSH_AUTH_SOCK=$(launchctl asuser $(id -u) launchctl getenv SSH_AUTH_SOCK)

# Load SSH keys from the keychain if keychain is empty.
ssh-add -l > /dev/null || ssh-add --apple-load-keychain 2> /dev/null

# Apache Maven
export M2_HOME="/Users/alejandro.huertas/bin/apache-maven-3.6.0"
export PATH="${M2_HOME}/bin:${PATH}"

# Employer-specific k8s aliases/functions are intentionally kept out of this
# public repo and live in an untracked, machine-local file instead.
[[ -f ~/.zshrc.work ]] && source ~/.zshrc.work

# Rapid aliases
eval "$(direnv hook zsh)"

export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

export JAVA_HOME=`/usr/libexec/java_home -v 17.0.12`
