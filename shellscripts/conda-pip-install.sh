#!/bin/bash

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

# Check if conda is installed
conda_ext=`which conda`
if [ $? -ne 0 ]; then
    echo_fatal "Installation of conda not found, initialize/source it first!"
    exit 1
fi

env=$CONDA_DEFAULT_ENV
echo_debug "Using environment: $env"
fname=$CONDA_PREFIX
fname="$fname/setup_scripts"
# If not directory create it
if [ ! -d $fname ]; then
    echo_warn "Creating directory: $fname"
    mkdir $fname
fi
fname="$fname/$env.sh"
echo_debug "Scripts will be stored in $fname"
# If file does not exist, create it
if [ ! -f $fname ]; then
    echo_warn "Creating file: $fname"
    touch $fname
fi

# Insert the lines
args="$@"
conda_cmd="pip install $args"
save_cmd="echo '# Run on: $(date)' >> $fname"
echo_command $save_cmd
eval $save_cmd
save_cmd="echo '$conda_cmd' >> $fname"
echo_command $save_cmd
eval $save_cmd
echo_command $conda_cmd
$conda_cmd
echo_info "Installation completed!"
