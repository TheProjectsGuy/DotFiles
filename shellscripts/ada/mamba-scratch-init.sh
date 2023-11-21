#!/bin/bash
# Initialize a mamba environment in "/scratch" of the system
# Manage a mamba environment in the '/scratch/$USER'
# Usage
#   mamba-scratch-init.sh [--help]
#   . mamba-scratch-init.sh ARGS

VERSION_MAJOR=1
VERSION_MINOR=1
VERSION="${VERSION_MAJOR}.${VERSION_MINOR}"

# Program properties
ARGS="$@"  # Reset using https://stackoverflow.com/a/4827707
PROGNAME=$(basename $0)
PROGPATH=$(realpath $(dirname $0))
MAMBA_DOWNLOAD="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3"
# Variables that can be changed
scratch_dir="/scratch"
ssub_dir="$USER/mambaforge"
use_os="Linux"
use_arch="x86_64"
force_reinstall="false"
dry_run="false"
shell_name=$(basename $SHELL)
env_name="base"

function usage() {
    cat <<-EOF
A wrapper to handle a mamba installation in the "/scratch/$USER" folder.
This script is intended for maintaining mamba/conda environments in the
scratch folder, primarily in HPC settings.

License: GNU-GPLv3. See: https://www.gnu.org/licenses/gpl-3.0.en.html

Disclosure: The authors do not take any desponsibility of the consequences
    of running this script.

If you have 'tmpreaper' [1] like services, you might want to 'touch' the
contents regularly. Maybe this could help (use at your own risk)

    $ cat untouched.txt && rm $\_
    $ find . -exec touch -h {} \; 2> ./untouched.txt &

What does this script do?
1. It ensures that a valid mambaforge installation exists
    - If it doesn't, it downloads and installs mambaforge in the scratch
        directory. The download is from [2].
    - If it does, it sources the mamba installation

Usage:
    1. [.|source] $PROGNAME -ARG VAL
    2. $PROGNAME [-h|--help|-v|--version]
    3. [.|source] $PROGNAME

    Where "ARG" is a needed argument, "VAL" is a value for the argument,
    "OPTARG" is an optional argument, and "OPTVAL" is an option value.
    You must run the program in the current shell (using 'source') so that
    the changes (like activating the environment) persist.

    Note: Do no run the arguments in method 2 as source. It'll most likely
    exit the current shell.
    Note: Do not run this when mamba is already sourced.

Arguments:
    -d  | --dry-run         Print the commands that would be executed. This
                            doesn't actually execute anything.
    -e  | --env ENV         Activate environment ENV after sourcing.
    -f  | --force           Force reinstallation of mambaforge. Note that
                            this will delete the existing installation.
    -h  | --help            Print this help message
    -p  | --os OS           Set the operating system to "OS" (for link)
                            (default: $use_os)
                            In: "Linux", "MacOSX", and "Windows"
                            Only Linux is supported at the moment.
        | --arch AR         Set the architecture to "AR" (for link)
                            (default: $use_arch)
                            In: "x86_64", "aarch64", "ppc64le", "arm64"
    -s  | --scratch-dir D   Set the scratch directory to 'D'
                            (default $scratch_dir)
        | --sub-dir D       Set the sub-directory (in scratch) where
                            mambaforge installation exists/should exist
                            (default $ssub_dir)
                            - The directory is joined by a "/". Using the
                                defaults above, the directory is actually
                                $scratch_dir/$ssub_dir (by default)
    -v  | --version         Print the version of this script

Other info
- Version: $VERSION
- Script name: $PROGNAME
- Script path: $PROGPATH

Return codes
- 0:    Graceful exit
- 1:    Invalid argument
- 2:    Invalid OS option
- 3:    Invalid shell
- 4:    Mamba already sourced (and command is available)
- 100:  Internal to the program (shouldn't be thrown out)

References:
1. https://manpages.ubuntu.com/manpages/trusty/man8/tmpreaper.8.html
2. https://github.com/conda-forge/miniforge#miniforge3
EOF
}

# ================ Functions ================ 

# Output formatting
debug_msg_fmt="\e[2;90m"
info_msg_fmt="\e[1;37m"
warn_msg_fmt="\e[1;35m"
fatal_msg_fmt="\e[2;31m"
command_msg_fmt="\e[0;36m"
# Wrapper printing functions
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
run_command () {
    echo_command $@
    if [ $dry_run = "false" ]; then
        $@
    else
        echo_debug "Dry run set. Skipping command '$@'"
    fi
}

function parse_options () {
    # Set the passed bash options
    set -- $ARGS
    pos=1
    while (( $# )); do
        arg=$1  # Read option
        echo_debug "Arg: $arg"
        shift   # Shift to the next argument
        case "$arg" in
            # Dry run
            "-d" | "--dry-run")
                dry_run="true"
                echo_debug "Dry run set"
                ;;
            # Environment
            "-e" | "--env")
                env_name=$1
                shift
                echo_debug "Will activate $env_name environment"
                ;;
            # Force reinstallation
            "-f" | "--force")
                force_reinstall="true"
                echo_debug "Force reinstallation set"
                ;;
            # Help message
            "--help" | "-h")
                usage
                return 100
                ;;
            # Operating System (and related)
            "--os" | "-p")
                use_os=$1
                shift
                echo_debug "Using '$use_os' operating system"
                ;;
            # Architecture
            "--arch")
                use_arch=$1
                shift
                echo_debug "Using '$use_arch' architecture"
                ;;
            # Scratch directory
            "-s" | "--scratch-dir")
                scratch_dir=$1
                shift
                echo_debug "Scratch directory set to '$scratch_dir'"
                ;;
            # Sub-directory
            "--sub-dir")
                ssub_dir=$1
                shift
                echo_debug "Sub-directory set to '$ssub_dir'"
                ;;
            # Version
            "--version" | "-v")
                echo_info "Version: $VERSION"
                return 100
                ;;
            # None
            *)
                if [ $pos -eq 1 ]; then # Environment name
                    echo_debug "Using environment $arg"
                    env_name=$arg
                else
                    echo_fatal "Unknown argument: $1, others $ARGS"
                    return 1
                fi
        esac
        pos=$((pos+1))
    done
}


# ===================== Main entrypoint ===================== 
parse_options
ec=$?
if [ $ec -eq 100 ]; then  # Help message (or graceful exit)
    exit 0
elif [ $ec -ne 0 ]; then  # Throw it in the shell (some error)
    return $ec
fi
# Assert options
if [ $use_os != "Linux" ]; then
    echo_fatal "Only Linux is supported at the moment (not $use_os)"
    return 2
fi
if [ $shell_name != "bash" ] && [ $shell_name != "zsh" ]; then
    echo_fatal "Only bash and zsh are supported (not $shell_name)"
    return 3
fi
# If mamba is already sourced, don't do anything
if [ "$(command -v mamba)" ]; then
    echo_fatal "Mamba already sourced and found. Skipping source."
    run_command which mamba
    run_command whereis mamba
    run_command mamba env list
    return 4
fi
mamba_install_path="$scratch_dir/$ssub_dir"
mamba_wget_link="$MAMBA_DOWNLOAD-$use_os-$use_arch.sh"
# If force reinstalling, remove existing installation
if [ $force_reinstall = "true" ]; then
    echo_info "Force reinstallation set. Deleting existing installation..."
    run_command rm -rf $mamba_install_path
fi
# Check if directory exists
if [ ! -d $mamba_install_path ]; then
    echo_info "Installation directory doesn't exist. Installing..."
    echo_debug "Download link: $mamba_wget_link"
    p=$(pwd)
    run_command cd $scratch_dir
    run_command wget $mamba_wget_link -O Miniforge3-Linux-$use_arch.sh
    run_command bash ./Miniforge3-Linux-$use_arch.sh -b \
            -p /scratch/$USER/mambaforge
    run_command cd $p
fi
# Source it (in current shell)
if [ $dry_run = "false" ]; then
    p=$(pwd)
    run_command cd $mamba_install_path
    if [ $shell_name = "bash" ]; then
        __conda_setup="$('./bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
        ec=$?
    elif [ $shell_name = "zsh" ]; then
        __conda_setup="$('./bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
        ec=$?
    else
        echo_fatal "Unknown shell: $shell_name"
        return 3
    fi
    echo_info "Sourcing the mamba installation"
    if [ $ec -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "$mamba_install_path/etc/profile.d/conda.sh" ]; then
            . "$mamba_install_path/etc/profile.d/conda.sh"
        else
            export PATH="$mamba_install_path/bin:$PATH"
        fi
    fi
    unset __conda_setup
    if [ -f "$mamba_install_path/etc/profile.d/mamba.sh" ]; then
        . "$mamba_install_path/etc/profile.d/mamba.sh"
    fi
    run_command cd $p
else
    echo_info "Dry run set. Skipping source."
fi
# Activate it (if environment passed)
if [ $dry_run = "false" ]; then
    run_command mamba activate $env_name
else
    echo_info "Dry run set. Skipping $env_name activation."
fi
