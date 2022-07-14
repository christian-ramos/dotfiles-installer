#!/usr/bin/env bash

set -eu pipefail

unset HAVE_SUDO_ACCESS # unset this from the environment

abort() {
  printf "%s\n" "$@" >&2
  exit 1
}

log() {
  printf "%s\n" "$@"
}

ask() {
  read -rp "$1: " "$2";
}

# COMMAND LINE TOOLS

log "Checking if Command Line Tools are installed️"
set +eo pipefail
xcode-select --install 2>&1 | grep installed >/dev/null
if [[ $? -ne 0 ]]; then
  log "Installing Command Line Tools..."
  ask "Press enter key after command line tools has finished to continue..." "CLT_INSTALLED"
fi
set -eo pipefail

# SUDO ACCESS

log 'Checking for `sudo` access (which may request your password)...'
/usr/bin/sudo -v && /usr/bin/sudo -l mkdir &>/dev/null
if [[ $? -ne 0 ]]
then
  abort "Need sudo access on macOS (e.g. the user ${USER} needs to be an Administrator)!"
fi


# DOTFILES
log
log "====================="
log " Installing dotfiles "
log "====================="
log
export DOTFILES_PATH="$HOME/.dotfiles"
log "Cloning into: '$DOTFILES_PATH'"

# To test that git is installed (if not macOS will prompt an installer)
git --version

# git clone https://github.com/christian-ramos/dotfiles.git "$DOTFILES_PATH"

# HOMBREW
log
log "===================="
log " Installing hombrew "
log "===================="
log
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
