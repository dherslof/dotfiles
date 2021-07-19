#!/bin/bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Filename: install.sh
# File Description: Basic installation/set up script for my own (@dherslof)
#                   dotfiles, environment tools and programs.
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Global variables
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
SCRIPT_VERSION="1.0.0"

# Directories
HOME_PATH="/home/${USER}"
CWD=$(pwd)
FILES_DIR="$CWD/files"

# Config files
OLD_SUFFIX=".old"
VIM_RC=".vimrc"
ZSH_RC=".zshrc"
TMUX_CONF=".tmux.conf"
STARSHIP_TOML="starship.toml"
CONFIG_PATH=".config/"

# Programs
VIM="vim"
TMUX="tmux"
ZSH="zsh"
CARGO_TOOLS_LIST=("fd-find" "ripgrep" "bat" "exa" "hyperfine" "hexyl" "tokei" "goto-rs" "starship")
PREREQUISITES=("curl" "git" "clang" "pkg-config")
EXTRA_LIST=("make" "cmake" "shellcheck" "feh" "pycodestyle" "gitk" "minicom" "progress" "htop" "gthumb")

# Flags
FULL_ENV=true

# Support
RED='\e[31m'
GREEN='\e[32m'
YELLOW="\e[93m"
NC='\e[0m'

#TODO: add pip install func (pip3 install --user advance-touch)
##                          (sudo pip3 install thefuck)

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Support functions
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

usage()
{
   cat <<EOF
Description:
Script for setting up dotfiles and useful environment tools.

Usage: [hVvtcz]
-v   Setup vimrc
-z   Setup zsh
-t   Setup tmux
-c   Setup cargo
-e   Setup extra 'apt' tools
-p   Setup prerequisites


-V   Show script version
-h   Print this help

Note:
Default behavior if no flags are provided is to do a complete setup, which includes all above choices

EOF
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

error_print()
{
   echo -e "[$RED ERROR $NC] - $1 "
}

note_print()
{
   echo -e "[$YELLOW NOTE $NC] - $1 "
}

success_print()
{
   echo -e "[$GREEN GOOD $NC] - $1 "
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# File operations
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Function for verifying needed prerequisites
verify_prerequisites()
{
   for e in "${PREREQUISITES[@]}"; do
      #if [ ! command -v $e &> /dev/null ]; then
      local bin_path=`which $e`
      if [ -z $bin_path ]; then
         echo "'$e' could not be found, please run: $ sudo apt install $e, or this script with the '-p' flag"
         exit 1
      fi
   done
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Function for installing prerequisites
apt_install()
{
   local list=("$@")
   for e in "${list[@]}"; do
      note_print "Fetching: $e"

      local bin_path=`which $e`
      if [ -z $bin_path ]; then
         sudo apt install $e
      fi

      bin_path=`which $e`
      if [ -z $bin_path ]; then
         error_print "Unable to install: $e, please install manually!"
      fi
   done
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Function for verifying installation of program
program_installed()
{
   local bin_path=`which $1`
   #if [ ! command -v $1 &> /dev/null ]; then
   if [ -z $bin_path ]; then
      note_print "Didn't find $1, probably not installed"
      read -p "Do you want to install? [Y/n]: " -n 1 -r
      if [[ $REPLY =~ ^[Yy]$ ]] || [ -z $REPLY ]; then
         echo "fetching..."
         sudo apt install $1
         apt_result=`$?`
         if [ ! apt_result == 0 ]; then
            error_print "Failed to install: $1"
            return
         fi
         local verify=`which $1`
         if [ -z $verify ]; then
            error_print "ABORTING - Unable to verify installation"
            exit 1
         fi
         success_print "Installed $1"
      else
         note_print "$1 needs to be installed later!"
         return
      fi
   fi

   success_print "Found $1 installed"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Function for using new config
install_config()
{
   if [ ! -d "$FILES_DIR" ]; then
      error_print "ABORTING - Unable to find expected file directory path: $FILES_DIR" && exit 1
   fi

   local new_conf_file="$FILES_DIR/$1"
   if [ ! -f $new_conf_file ]; then
      error_print "ABORTING - Unable to find file: $1 in: $FILES_DIR" && exit 1
   fi

   local link_cmd
   local link_path
   if [ -z "$2" ]; then
      link_path=$HOME_PATH/$1
   else
      link_path=$HOME_PATH/$2$1
   fi

   test -h $link_path || link_cmd=$(ln -s $new_conf_file $link_path) && note_print "Not recreating symbolic link: $new_conf_file"
   local cmd_status=$?

   if [ ! $cmd_status == 0 ]; then
      error_print "ABORTING - Failed to create: $HOME_PATH/$1" && exit 1
   fi

   success_print "Created: $link_path"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Function for storing existing .file if existing
store_existing_file()
{
   local existing_file="$HOME_PATH/$1"

   if [ -f "$existing_file" ]; then
      local file_type=`file $existing_file`
      if [[ $file_type == *"symbolic link"* ]];then
         success_print "Symbolic link already exists($file_type). If path not correct, move manually"
         return
      else
         note_print "File: $1 exists, creating backup file: $existing_file$OLD_SUFFIX"
         local backup_file_name="$HOME_PATH/$1$OLD_SUFFIX"

         mv $existing_file $backup_file_name || { error_print " ABORTING - Failed to backup $existing_file"; exit 1;  }
      fi
   fi
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Function for setting up vim
setup_vim()
{
   note_print "Setting up vim"
   program_installed $VIM
   store_existing_file $VIM_RC
   install_config $VIM_RC

   if [ ! -d $HOME_PATH/.vim/bundle ]; then
      note_print "Installing vim plugin manager (Vundle)"
      git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
      local clone_status=$?
      if [ $clone_status == 0 ]; then
         success_print "Vim plugin manager installed, don't forget to install used plugins!"
      else
         error_print "Clone of vim plugin manager returned: $clone_status, Vundle is needed for vim plugins!"
      fi
   fi

   success_print "Vim setup done! Launch VIM and run ':PluginInstall' to fetch plugins!"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Fucntion for setting up tmux
setup_tmux()
{
   note_print "Setting up tmux"

   program_installed $TMUX
   store_existing_file $TMUX_CONF
   install_config $TMUX_CONF

   if [ ! -d $HOME_PATH/.tmux/plugins/tpm ]; then
      note_print "Installing tmux plugin manager"
      git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
      local clone_status=$?
      if [ $clone_status == 0 ]; then
         success_print "tmux plugin manager installed"
      else
         error_print "Clone of tmux plugin manager returned: $clone_status, tpm is needed for tmux plugins!"
      fi
   fi

   success_print "tmux setup done! Run 'prefix + I' to fetch plugins!"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Function for setting up cargo tools
setup_cargo()
{
   note_print "Setting up cargo"
   local cargo_bin=`which cargo`
   if [ -z $cargo_bin ]; then
   #if [ ! command -v cargo &> /dev/null ]; then
      note_print "Didn't find cargo, probably not installed"
      read -p "Do you want to install cargo? [Y/n]: " -n 1 -r
      if [[ $REPLY =~ ^[Yy]$ ]] || [ -z $REPLY ]; then
         curl https://sh.rustup.rs -sSf | sh
            note_print "Trying to source env!"
            source $HOME/.cargo/env || { error_print "ABORTING - Unable to source cargo environment"; exit 1; }
      else
         error_print "Unable to install cargo-based tools without cargo..." && return
      fi
   fi

   success_print "Cargo found - Updating"
   rustup update
   if [ ! $? == 0 ]; then
      error_print "Cargo update failed, this may lead to failed installation of rust programs"
   fi

   success_print "Installing cargo programs"

   local tools=("$@")
   for t in "${tools[@]}"; do
      local t_installed=`cargo install --list | grep $t`

      case $t_installed in
         *"$t"*)
            note_print "$t is already installed: $t_installed"
            continue
            ;;
         *)
            echo -e "$t Installing..."
            local install_tool=`cargo install $t`
            local install_status=$?
            if [ $install_status == 0 ]; then
               success_print "Successfully handled installation, check cargo log for status $t"
            else
               error_print "Failed to install $t"
               continue
            fi
            ;;
      esac
   done

   success_print "All cargo tools are installed"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Function for setting up zsh
setup_zsh()
{
   note_print "Setting up ZSH"

   program_installed "$ZSH"
   store_existing_file "$ZSH_RC"
   install_config "$ZSH_RC"

   # Verify starship
   #if [ ! command -v starship &> /dev/null ]; then
   local starship_path=`which starship`
   if [ -z $starship_path ]; then
      note_print "Could not find starship - probably not installed, this will effect the zsh experience!" && return
   fi

   success_print "Found starship! Setting up configuration"

   local starship_conf=$CONFIG_PATH$STARSHIP_TOML
   store_existing_file "$starship_conf"
   install_config "$STARSHIP_TOML" "$CONFIG_PATH"

   success_print "ZSH with startship setup done"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Main
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

verify_prerequisites

while getopts 'hVvtczpe' OPT; do
   case $OPT in
      v)
         FULL_ENV=false
         setup_vim
         ;;

      t)
         FULL_ENV=false
         setup_tmux
         ;;

      c)
         FULL_ENV=false
         setup_cargo "${CARGO_TOOLS_LIST[@]}"
         ;;

      z)
         FULL_ENV=false
         setup_zsh
         ;;

      p)
         FULL_ENV=false
         apt_install "${PREREQUISITES[@]}"
         ;;
      e)
         FULL_ENV=false
         apt_install "${EXTRA_LIST[@]}"
         ;;
      h)
         usage
         exit 0
         ;;

      V)
         echo "$0 - version: $SCRIPT_VERSION"
         exit 0
         ;;

      \?)
         usage
         exit 0
         ;;

      *)
         usage
         exit 0
         ;;
   esac
done
shift $((OPTIND-1))

if [ "$FULL_ENV" = false ]; then
   exit
fi

read -p "You are about to run a full environment setup, continue? [Y/n]: " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]] || [ -z $REPLY ]; then
   echo " "
   success_print "Setting upp environment!"
   setup_vim
   setup_tmux
   setup_cargo
   setup_zsh

   success_print "All done - Don't forget to run apt update + apt upgrade to be fully updated. Also remember that some configuration parameters might be dependent on a local path, which might need update!"

else
   echo " "
   note_print "Aborting"
   exit
fi

exit 0
