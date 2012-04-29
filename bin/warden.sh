#!/bin/bash

# Load RVM into a shell session *as a function*
if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then

  # First try to load from a user install
  source "$HOME/.rvm/scripts/rvm"

elif [[ -s "/usr/local/rvm/scripts/rvm" ]] ; then

  # Then try to load from a root install
  source "/usr/local/rvm/scripts/rvm"

else

  printf "ERROR: An RVM installation was not found.\n"

fi

unset BUNDLE_GEMFILE
source $WARDEN_HOME/.rvmrc

env
cd $WARDEN_HOME
$WARDEN_HOME/bin/warden.rb $@
exit_code=$?
cd -
exit $exit_code
