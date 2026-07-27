# alias
alias ls='eza'
alias lsa='eza -a'
alias ll='eza -lbF --time-style=full-iso --git'
alias lla='eza -lbFa --time-style=full-iso --git'
alias cat='bat --paging=never'

# aws
aws-login() {
  if [[ -z "$1" ]]; then
    echo "usage: aws-login <profile>" >&2
    return 1
  fi
  local profile="$1"
  aws login --profile "$profile" &&
  echo "aws login done" &&
  eval "$(aws configure export-credentials --profile "$profile" --format env)" &&
  echo "credentials exported"
}

# curl
export PATH="/opt/homebrew/opt/curl/bin:$PATH"

# mise
eval "$(mise activate zsh)"

# zshrc
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# Source Prezto.
# Prompt (kylewest), completion, homebrew completion, and autosuggestions
# are all handled by the pmodules configured in ~/.zpreztorc.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi
