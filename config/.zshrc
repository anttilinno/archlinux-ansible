# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

COMPLETION_WAITING_DOTS="true"

HIST_STAMPS="dd.mm.yyyy"

plugins=(git docker docker-compose yarn)

source $ZSH/oh-my-zsh.sh

#################### User configuration

export LANG=en_US.UTF-8
export EDITOR='mvim'

# User aliases
alias vi="nvim"
alias peterpecker="sudo reboot"
alias donthurtme="sudo shutdown now"

# Path modification
export PATH="${PATH}:/home/antti/.yarn/bin"

# Starship
eval "$(starship init zsh)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

source ${HOME}/.local/bin/goto.sh
