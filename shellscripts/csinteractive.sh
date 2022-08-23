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

# Obtain an allocation using `salloc` and run an interactive session on it
# using `srun`. Check usage using [-h|--help].

readonly VERSION_MAJOR=1
readonly VERSION_MINOR=5
VERSION="$VERSION_MAJOR.$VERSION_MINOR"

readonly ARGS="$@"  # Reset using https://stackoverflow.com/a/4827707
readonly PROGNAME=$(basename $0)
readonly PROGPATH=$(realpath $(dirname $0))
# Defaults
readonly DEF_NUM_CPUS=2
readonly DEF_PARTITION=long
readonly DEF_ACCOUNT=research
readonly DEF_JOB_NAME=interactive
readonly DEF_NUM_GPUS=0
readonly DEF_TIME_PERIOD="6:00:00"
readonly DEF_USER_SHELL=bash

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

# ==== Script variables ====
# Binaries
readonly SALLOC_BIN=$(which salloc 2> /dev/null)
if [[ -z $SALLOC_BIN ]]; then
    echo_fatal "Could not find salloc"
    exit 127
fi
readonly SRUN_BIN=$(which srun 2> /dev/null)
if [[ -z $SRUN_BIN ]]; then
    echo_fatal "Could not find srun"
    exit 127
fi
SHELL_PATH="$(which $DEF_USER_SHELL 2> /dev/null)"
if [[ -z $SHELL_PATH ]]; then
    echo_fatal "Could not find shell: $DEF_USER_SHELL"
    exit 127
fi

echo_debug "Found $SALLOC_BIN and $SRUN_BIN"
echo_debug "Using shell $SHELL_PATH"
# Parameters for job allocation
NUM_CPUS=$DEF_NUM_CPUS           # Number of CPUs
NUM_GPUS=$DEF_NUM_GPUS           # Number of GPUs
TIME_PERIOD=$DEF_TIME_PERIOD     # Time for the script
JOB_NAME=$DEF_JOB_NAME           # Job name
PARTITION=$DEF_PARTITION         # Partition
ACCOUNT=$DEF_ACCOUNT             # Account (for script)
# Options for the scripts
SALLOC_OPTS=""      # Will be set in create_salloc_opts
SRUN_OPTS=""        # Will be set in create_srun_opts
SRUN_EXEC=""        # Will be set in create_srun_opts
EXEC_SCRIPT=true    # By default, execute the script (no dry run)


# ==== Utility functions ====
function usage () {
    cat <<-EOF
Cool sinteractive script, version $VERSION

Usage: $PROGNAME [-h] [-c N] [-g N] [-r S] [-a S] [-J S] [-x L] [-w L]

    Where N is a number, S is a string (no spaces), and L is a list of 
    nodes (list, or file with newline separator).
    - Use "quotes" for list of nodes in L. Eg: "gnode[007-008,043]"
    - Pass full path if L is a file
    - Do not use space in the value for any argument
    - Pass either '-w' or '-l' (but not both). Not passing either will
        give a random node.

All optional arguments:
    -h | --help             Help menu (this menu)
    -c | --cpu              Number of CPUs to request
                            (Default: $DEF_NUM_CPUS)
    -g | --gpu              Number of GPUs to request
                            (Default: $DEF_NUM_GPUS)
    -r | --reservation      Reservation (account is also set to same name)
    -a | --account          Account name (can also come after -r)
                            (Default: $DEF_ACCOUNT)
    -J | --name             Job name (no spaces)
                            (Default: $DEF_JOB_NAME)
    -x | --exclude          Exclude the list of nodes passed
    -w | --nodelist         Request specific list of hosts
                            Before using this, check QOSMaxNodePerJobLimit
    -l | --last-node        Use the gnode which the user used previously
                            Command uses 'sacct' and 'USER' to fetch data
                            User must have some allocation in last 7 days
    -s | --shell            Shell to use (bash, zsh)
    -n | --dry-run          Do not get allocation and run; only show output
    -v | --version          Show the version information and exit
    -b | --begin            Give a begin time for the job allocation.
                            Eg: "16:00", "now+1hour", "now+60" (sec),
                            "2010-01-20T12:34:00"
    -m | --mem-per-cpu      Minimum RAM per CPU. Check configurations using
                            'scontrol show config' and 'seff'
    -i | --node-info        Show information about a single node or a comma
                            separated list of nodes and exit


Exit codes:
    0           Script executed successfully
    1           Argument error (some wrong option was passed)
    5           Some error happened in the interactive session
    127         Command not found

References:
- salloc: https://slurm.schedmd.com/salloc.html
- srun: https://slurm.schedmd.com/srun.html
EOF
}

function parse_options () {
    # Set the passed bash options
    set -- $ARGS
    while (( $# )) ; do
        arg=$1  # Read option
        shift   # Shift to next argument
        case "$arg" in
            # Help options
            "--help" | "-h")
                usage
                exit 0
                ;;
            # CPUs
            "--cpu" | "-c")
                num_cpus=$1
                shift
                echo_debug "Using $num_cpus CPUs"
                NUM_CPUS=$num_cpus
                ;;
            # GPUs
            "--gpu" | "-g")
                num_gpus=$1
                shift
                echo_debug "Using $num_gpus GPUs"
                NUM_GPUS=$num_gpus
                ;;
            # Reservation
            "--reservation" | "-r")
                reserv_name=$1
                shift
                echo_debug "Using '$reserv_name' reservation"
                ACCOUNT=$reserv_name
                RESERVATION=$reserv_name
                ;;
            # Account name
            "--account" | "-a")
                acc_name=$1
                shift
                echo_debug "Account name set to '$acc_name'"
                ACCOUNT=$acc_name
                ;;
            # Job name
            "--name" | "-J")
                job_name=$1
                shift
                echo_debug "Job name set to '$job_name'"
                JOB_NAME=$job_name
                ;;
            # Exclude the list of nodes
            "--exclude" | "-x")
                exclude_nodes=$1
                shift
                echo_debug "Excluding nodes in '$exclude_nodes'"
                EXCLUDE_NODES=$exclude_nodes
                ;;
            # Node list
            "--nodelist" | "-w")
                use_nodes=$1
                shift
                echo_debug "Using nodes in '$use_nodes'"
                NODE_LIST=$use_nodes
                ;;
            # Shell
            "--shell" | "-s")
                custom_shell=$1
                shift
                echo_debug "Using shell $custom_shell"
                shell_path="$(which $custom_shell 2> /dev/null)"
                if [[ -z $shell_path ]]; then
                    echo_warn "Shell $custom_shell not found, using bash"
                else
                    echo_debug "Fount shell at $shell_path"
                    SHELL_PATH=$shell_path
                fi
                ;;
            # Dry run
            "--dry-run" | "-n")
                echo_info "Dry run mode detected"
                EXEC_SCRIPT=false
                ;;
            # Previous node
            "--last-node" | "-l")
                readonly sacct_bin=$(which sacct 2> /dev/null)
                if [[ -z $sacct_bin ]]; then
                    echo_fatal "Could not find sacct"
                    exit 127
                fi
                echo_debug "Found $sacct_bin"
                # Check if user exists
                qry_cmd="sacct -u "$USER" -o NodeList -S now-7days"
                echo_command $qry_cmd
                $qry_cmd &> /dev/null
                ec=$?
                if [[ $ec -ne 0 ]]; then
                    echo_fatal "sacct could not run (maybe user not found)"
                fi
                gn=$($qry_cmd | tail -n 1 | sed "s/ //g")
                echo_debug "$USER last used '$gn' NodeList"
                NODE_LIST=$gn
                ;;
            # Begin time
            "--begin" | "-b")
                begin_shell=$1
                shift
                echo_debug "Begin time: '$begin_shell'"
                START_TIME=$begin_shell
                ;;
            # Show version
            "--version" | "-v")
                echo_info "Version: $VERSION"
                exit 0
                ;;
            # RAM per CPU
            "--mem-per-cpu" | "-m")
                ram_cpu=$1
                shift
                echo_debug "RAM per CPU: $ram_cpu"
                MEM_PER_CPU=$ram_cpu
                ;;
            # Node information
            "--node-info" | "-i")
                nodelist=$1
                shift
                echo_debug "Printing information on nodes: $nodelist"
                # Show the queue through squeue
                readonly squeue_bin=$(which squeue 2> /dev/null)
                if [[ -z $squeue_bin ]]; then
                    echo_fatal "Could not find squeue"
                    exit 127
                fi
                squeue_cmd="$squeue_bin -w $nodelist"
                echo_command $squeue_cmd
                $squeue_cmd
                echo ""
                # Show the pestat output
                readonly pestat_bin=$(which pestat 2> /dev/null)
                if [[ -z $pestat_bin ]]; then
                    echo_fatal "Could not find pestat"
                    exit 127
                fi
                pestat_cmd="$pestat_bin -w $nodelist"
                echo_command $pestat_cmd
                $pestat_cmd
                echo ""
                # Show the sinfo output
                readonly sinfo_bin=$(which sinfo 2> /dev/null)
                if [[ -z $sinfo_bin ]]; then
                    echo_fatal "Could not find sinfo"
                    exit 127
                fi
                of="Partition:12,Time:12,StateCompact:8,Gres:8,\
                    GresUsed:10,CPUsState:.15"
                of=$(echo $of | tr -d '[:space:]')
                sinfo_cmd="$sinfo_bin -n $nodelist -O $of"
                echo_command $sinfo_cmd
                $sinfo_cmd
                echo ""
                # Exit
                echo_debug "Information display completed"
                exit 0
                ;;
            *)
                echo_warn "Unrecognized option: $arg"
                echo_info "Pass --help to get options and help"
                exit 1
                ;;
        esac
    done
}


function create_salloc_opts () {
    # CPUs
    SALLOC_OPTS="-n $NUM_CPUS"
    # Job name
    SALLOC_OPTS="$SALLOC_OPTS -J $JOB_NAME"
    # Partition
    SALLOC_OPTS="$SALLOC_OPTS -p $PARTITION"
    # Account
    SALLOC_OPTS="$SALLOC_OPTS -A $ACCOUNT"
    # If there is a reservation
    if [[ -n $RESERVATION ]]; then
        SALLOC_OPTS="$SALLOC_OPTS --reservation=$RESERVATION"
    fi
    # GRES (GPUs)
    SALLOC_OPTS="$SALLOC_OPTS --gres=gpu:$NUM_GPUS"
    # If there's a start time given
    if [[ -n $START_TIME ]]; then
        SALLOC_OPTS="$SALLOC_OPTS --begin=$START_TIME"
    fi
    # If there's a RAM per CPU requirement
    if [[ -n $MEM_PER_CPU ]]; then
        SALLOC_OPTS="$SALLOC_OPTS --mem-per-cpu=$MEM_PER_CPU"
    fi
    # Time
    SALLOC_OPTS="$SALLOC_OPTS -t $TIME_PERIOD"
    # If some nodes must be excluded
    if [[ -n $EXCLUDE_NODES ]]; then
        SALLOC_OPTS="$SALLOC_OPTS -x $EXCLUDE_NODES"
    fi
    # If specific nodes must be used (distributed probably)
    if [[ -n $NODE_LIST ]]; then
        SALLOC_OPTS="$SALLOC_OPTS -w $NODE_LIST"
        SALLOC_OPTS="$SALLOC_OPTS --ntasks-per-node=$NUM_CPUS"
    fi

    echo_info "SALLOC $SALLOC_OPTS"
}

function create_srun_opts () {
    # CPUs
    SRUN_OPTS="-n $NUM_CPUS"
    # Pseudoterminal
    SRUN_OPTS="$SRUN_OPTS --pty"
    # Do not bind tasks to CPUs (they may be different!)
    SRUN_OPTS="$SRUN_OPTS --cpu-bind=no"
    
    # Shell executable (login shell)
    SRUN_EXEC="$SHELL_PATH -l"

    echo_info "SRUN $SRUN_OPTS $SRUN_EXEC"
}

function env_check () {
    # Check if display forwarding exists
    if [[ -n $DISPLAY ]]; then
        # Display exists
        echo_debug "Display found at: $DISPLAY"
    else
        echo_warn "No display found, X11 forwarding may not work"
    fi
}


# ==== Main program entrypoint ====
parse_options
create_salloc_opts
create_srun_opts
env_check

echo_info -e "Starting time: `date`"
# Main command
echo_command "$SALLOC_BIN $SALLOC_OPTS $SRUN_BIN $SRUN_OPTS $SRUN_EXEC"
if [[ "$EXEC_SCRIPT" = true ]]; then
    $SALLOC_BIN $SALLOC_OPTS $SRUN_BIN $SRUN_OPTS $SRUN_EXEC
else
    echo_debug "Not running command (dry run)"
fi
# Interactive session ended
exit_code=$?
EXIT_STATUS=0
if [[ $exit_code -eq 0 ]]; then
    echo_debug "Script ended with no error (zero exit code)"
else
    echo_warn "Exit status of session was $exit_code"
    echo_warn "Something might have gone wrong"
    EXIT_STATUS=5
fi
echo_info -e "Ending time: `date`"
exit $EXIT_STATUS

# The below command works:
# $SALLOC_BIN -n 10 -J interactive -p long -A research --gres=gpu:1 \
#     -t 6:00:00 $SRUN_BIN -n 10 --pty --cpu_bind=no bash -l
