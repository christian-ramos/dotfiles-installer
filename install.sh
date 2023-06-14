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
  read -rp "$1 " "$2";
}
# PREREQUISITES
log_step " Prerequisites "

# PREREQUISITES -> COMMAND LINE TOOLS
log_action "Checking if Command Line Tools are installed️"
set +eo pipefail
xcode-select --install 2>&1 | grep installed >/dev/null
if [[ $? -ne 0 ]]; then
  log "Installing Command Line Tools..."
  ask "Press enter key after command line tools installation has finished to continue..." "CLT_INSTALLED"
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
export DOTFILES="$HOME/.dotfiles"
log "Cloning into: '$DOTFILES'"

git --version
# git clone https://github.com/christian-ramos/dotfiles.git "$DOTFILES"

# CONFIGURE SHELL
log_step " Configuring shell "

# CONFIGURE SHELL -> SET ZSH AS DEFAULT SHELL
log_action "Change default shell to zsh"
sudo chsh -s /bin/zsh $USER

# INSTALL ZIMFW
log_action "Install zimfw"
export ZIM_HOME="$HOME/.zim"
if [[ ! -d  $ZIM_HOME ]] ; then
  # Install zimfw
  log "Installing zimfw..."
  /bin/zsh -i -c "curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh"
else
  # Upgrade zimfw
  log "Zimfw already installed. Upgrading zimfw..."
  /bin/zsh -i -c "zimfw upgrade"
fi

# Link theme
# check if exist
export MYMINIMAL="$ZIM_HOME/modules/myminimal"
if [[ -L $MYMINIMAL ]] || [[ -f $MYMINIMAL ]] ; then
  rm $MYMINIMAL
elif [[ -d $MYMINIMAL ]] ; then
  rm -rf $MYMINIMAL
fi
# ln $HOME/.zim/modules/myminimal $DOTFILES/shell/zsh/zim/myminimal

# Link shell dotfiles
# rm $HOME/.zshenv
# ln $DOTFILES/shell/zsh/.zshrc $HOME/.zshenv
# rm $HOME/.zshrc
# ln $DOTFILES/shell/zsh/.zshrc $HOME/.zshrc
# rm $HOME/.zimrc
# ln $DOTFILES/shell/zsh/.zimrc $HOME/.zimrc

# Install zimfw modules
/bin/zsh -i -c "zimfw uninstall -q && zimfw install -q"


# CONFIGURE APPS
log_step " Configure Apps "

# CONFIGURE APPS -> CONFIGURE ITERM
log_action "Configuring iterm2"
log "Import iterm2 preferences from $DOTFILES/apps/iterm2"
ask "Press enter key after import iterm2 preferences to continue..." "ITRM_CONFIGURED"




