#!/bin/bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Filename: setup_pwr_line.sh.sh
# File Description: Set up script for downloading and installing powerline for TMUX
# Author: Dherslof <daniel.herslof@hotmail.com>
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Variables
CWD=$(pwd)
SYMBOLS_CONF_FILE="$CWD/files/pwr_line/10-powerline-symbols.conf"
SYMBOLS_OTF_FILE="$CWD/files/pwr_line/PowerlineSymbols.otf"

RED='\e[31m'
GREEN='\e[32m'
NC='\e[0m'
YELLOW="\e[93m"

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Help functions

usage()
{
   cat <<EOF
Description:
Script for Downloading and installing powerline for use in TMUX.

EOF
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

note_print()
{
   echo -e "[$YELLOW NOTE $NC] - $1 "
}

error_print()
{
   echo -e "[$RED ERROR $NC] - $1 "
}

success_print()
{
   echo -e "[$GREEN SUCCESSFULLY $NC] - $1 "
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# main

# Check if help argument provided
if [[ $1 == "-h" || $1 == "h" || $1 == "--help" ]]; then
   usage
   exit
fi

# Check if symbols conf file exists in repo - abort if not existing
if [ ! -f "${SYMBOLS_CONF_FILE}" ]; then
   error_print "${SYMBOLS_CONF_FILE} dont exists, unable to continue, aborting"
   exit
fi
success_print "Found ${SYMBOLS_CONF_FILE}"

# Check the symbols otf file exists in repo - abort if not existing
if [ ! -f "${SYMBOLS_OTF_FILE}" ]; then
   error_print "${SYMBOLS_OTF_FILE} dont exists, unable to continue, aborting"
fi
success_print "Found ${SYMBOLS_OTF_FILE}"

# Verify if pip3 is installed, otherwise promt for installation - abort if not found
PIP3_INSTALLED=$(which pip3)
if [ -z "${PIP3_INSTALLED}" ]; then
   read -p "${YELLOW}Note${NC}: Did not find pip3, do you want to install? [Y/n]: " -n 1 -r
   if [[ $REPLY =~ ^[Yy]$ ]] || [ -z $REPLY ]; then
         echo "fetching..."
         sudo apt install python3-pip
         verify=$(which pip3)
         if [ -z "${verify}" ]; then
            error_print "Unable to verify pip3 installation, aborting..."
            exit
         fi
   else
      success_print "pip3 installed"
   fi

else
   success_print "Found pip3 at: ${PIP3_INSTALLED}"
fi

# Install powerline if not existing
pwr_line_installed=$(which powerline)
if [ -z "$pwr_line_installed" ]; then 
   sudo pip3 install git+git://github.com/Lokaltog/powerline || { error_print "Failed to pip install powerline, aborting..."; exit;}
fi

while read line; do # Show status of powerline in order to get the path
   if [[ $line == *"Location: "* ]]; then # if the line contains 'Location'
      location_path=$(echo "${line}" | cut -d ':' -f2) # split on delimiter
   fi
done <<< $(pip3 show powerline-status) 

if [ -z "${location_path}" ]; then
   error_print "Failed to find powerline install location, aborting..."
   exit 
fi

# copy fonts and symbols file to correct location
sudo cp "${SYMBOLS_OTF_FILE}" /usr/share/fonts/ 
if [ $? -eq 0 ]; then
   success_print "copied ${SYMBOLS_OTF_FILE} to '/usr/share/fonts'"
else 
   error_print "failed to copy ${SYMBOLS_OTF_FILE} to '/usr/share/fonts, aborting..."
   exit
fi

sudo cp "${SYMBOLS_CONF_FILE}" /etc/fonts/conf.d/
if [ $? -eq 0 ]; then
   success_print "copied ${SYMBOLS_CONF_FILE} to '/etc/fonts/conf.d/'"
else 
   error_print "failed to copy ${SYMBOLS_CONF_FILE} to '/etc/fonts/conf.d/', aborting..."
   exit
fi

note_print "Reloading fc cache"
fc-cache -vf /usr/share/fonts/
if [ $? -eq 0 ]; then
   success_print "Cache reload"
else 
   error_print "failed to reload cache, aborting..."
   exit
fi

success_print "Powerline installed! A restart of the computer might be needed for it take effect\n -For tmux, add '${location_path}/powerline/bindings/tmux/powerline.conf' in tmux conf\n"

