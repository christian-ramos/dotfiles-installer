#!/usr/bin/env bash

set -euo pipefail

unset HAVE_SUDO_ACCESS # unset this from the environment

abort() {
  printf "%s\n" "$@" >&2
  exit 1
}

log() {
  printf "%s\n" "$@"
}

log_step() {
  local step_decorator="===================================================="
  local step_title="*** $@ ***"
  local fill_len=$(((${#step_decorator}-${#step_title})/2+${#step_title}))

  log
  log "$step_decorator"
  printf "%${fill_len}s\n" "$step_title"
  log "$step_decorator"
}

log_action() {
  log
  printf "%b\n" "\033[1m===> $@\033[0m"
}

ask() {
  read -rp "$1: " "$2";
}
# PREREQUISITES
log_step " Prerequisites "

# PREREQUISITES -> COMMAND LINE TOOLS
log_action "Checking if Command Line Tools are installed️"
set +eo pipefail
xcode-select --install 2>&1 | grep installed >/dev/null
if [[ $? -ne 0 ]]; then
  log "Installing Command Line Tools..."
  ask "Press enter key after command line tools has finished to continue..." "CLT_INSTALLED"
else
  log "Command Line Tools already installed"
fi
set -eo pipefail

# PREREQUISITES -> SUDO ACCESS
log_action 'Checking for `sudo` access (which may request your password)...'
/usr/bin/sudo -v && /usr/bin/sudo -l mkdir &>/dev/null
if [[ $? -ne 0 ]]
then
  abort "Need sudo access on macOS (e.g. the user ${USER} needs to be an Administrator)!"
fi

# PREREQUISITES -> HOMEBREW
which -s brew
if [[ $? != 0 ]] ; then
  # Install homebrew
  log_action "Installing homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  # Update homebrew
  log_action "Updating homebrew..."
  brew update
fi



# DOTFILES
log_step " Installing dotfiles "
export DOTFILES_PATH="$HOME/.dotfiles"
log "Cloning into: '$DOTFILES_PATH'"

git --version
# git clone https://github.com/christian-ramos/dotfiles.git "$DOTFILES_PATH"
