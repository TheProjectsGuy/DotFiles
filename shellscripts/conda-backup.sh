#!/bin/bash

# Copyright (C) 2022 Avneesh Mishra - GNU GPLv3
#
# This program is free software: you can redistribute it and/or modify it 
# under the terms of the GNU General Public License as published by the 
# Free Software Foundation, either version 3 of the License, or (at your 
# option) any later version.
#
# This program is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.
#
# You should have received a copy of the GNU General Public License along 
# with this program.  If not, see <http://www.gnu.org/licenses/>.

# Exit codes
# 0 - All good
# 1 - Invalid parameters

readonly DEFAULT_BACKUP_FOLDER="$HOME/conda_env_backups"
readonly DEFAULT_CONDA_BIN="$HOME/anaconda3/bin"

readonly VERSION_MAJOR=1
readonly VERSION_MINOR=5
VERSION="$VERSION_MAJOR.$VERSION_MINOR"

# ---- Output formats ----
# Rules:
# - Debug: No problems, ignore this output
# - Info: Information for user
# - Warn: Something unusual, but can be handled by this script
# - Fatal: Some problem lead to failure (check the exit code)
#
# Check out: https://en.wikipedia.org/wiki/ANSI_escape_code#Colors

# Declare text formats for printing different log messages
debug_msg_fmt="\e[2;90m"
info_msg_fmt="\e[1;37m"
warn_msg_fmt="\e[1;35m"
fatal_msg_fmt="\e[2;31m"
command_msg_fmt="\e[0;36m"

# Wrapper functions
echo_debug () {
    echo -ne $debug_msg_fmt
    echo $@
    echo -ne "\e[0m"
}
echo_info () {
    echo -ne $info_msg_fmt
    echo $@
    echo -ne "\e[0m"
}
echo_warn () {
    echo -ne $warn_msg_fmt
    echo $@
    echo -ne "\e[0m"
}
echo_fatal () {
    echo -ne $fatal_msg_fmt
    echo $@
    echo -ne "\e[0m"
}
echo_command () {
    echo -ne $command_msg_fmt
    echo $@
    echo -ne "\e[0m"
}


# ===== Script variables =====
# Conda installation
conda_bin=$(which conda 2> /dev/null)
if [[ -z $conda_bin ]]; then
    if [[ -d $DEFAULT_CONDA_BIN ]]; then
        conda_bin=$DEFAULT_CONDA_BIN
    else
        echo_fatal "Unable to determine conda installation"
        exit 1
    fi
fi
echo_debug "Using conda: $conda_bin"
# Conda environment
if [[ -n "$1" ]]; then
    conda_env="$1"
else
    if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
        conda_env="$CONDA_DEFAULT_ENV"
    else
        echo_fatal "Unable to determine the conda environment"
        echo_fatal "Pass conda environment name or activate one"
        exit 1
    fi
fi
echo_debug "Backing up conda environment - $conda_env"
# Backup folder
backup_folder=${DEFAULT_BACKUP_FOLDER}/${conda_env}
if [[ ! -d $backup_folder ]]; then
    echo_warn "Creating empty backup folder: $backup_folder"
    mkdir -p $backup_folder
fi
echo_debug "Backing up in folder - $backup_folder"
cd $backup_folder
backup_file=backup_$(date +"%d_%b_%Y_%k_%M_%S").yml
echo_info "Using file name $backup_file"

# ===== Main backup =====
backup_cmd="$conda_bin env export -n $conda_env > $backup_file"
echo_command $backup_cmd
eval $backup_cmd
echo_debug "Backup complete"

