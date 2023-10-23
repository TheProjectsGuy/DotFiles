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
readonly VERSION_MINOR=15
readonly LAST_MDATE="Tuesday 06 June 2023 12:30:45 PM IST"  # Output of `date`
VERSION="$VERSION_MAJOR.$VERSION_MINOR"

readonly ARGS="$@"  # Reset using https://stackoverflow.com/a/4827707
readonly PROGNAME=$(basename $0)
readonly PROGPATH=$(realpath $(dirname $0))
# URL on GitHub Gist (for latest version)
readonly PROG_URL="https://raw.githubusercontent.com/TheProjectsGuy/DotFiles/main/shellscripts/ada/csinteractive.sh"
# Defaults
readonly DEF_NUM_CPUS=2
readonly DEF_PARTITION=long
readonly DEF_ACCOUNT=research
readonly DEF_JOB_NAME=interactive
readonly DEF_NUM_GPUS=0
readonly DEF_NUM_NODES=1
readonly DEF_TIME_PERIOD="6:00:00"
readonly DEF_USER_SHELL=bash
readonly COMNMS="gnode"     # A phrase all nodes share (for grep)

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
# Local binaries (no need for checking)
readonly sacct_bin=$(which sacct 2> /dev/null)

echo_debug "Found $SALLOC_BIN and $SRUN_BIN"
echo_debug "Using shell $SHELL_PATH"
# Parameters for job allocation
NUM_CPUS=$DEF_NUM_CPUS           # Number of CPUs
NUM_GPUS=$DEF_NUM_GPUS           # Number of GPUs
NUM_NODES=$DEF_NUM_NODES         # Number of Nodes on HPC
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
Cool sinteractive (SLURM interactive) script, version $VERSION

Usage: $PROGNAME [-OPTARG VAL ...]


All optional arguments:
    -a | --account          Account name (can also come after -r [1])
                            (Default: $DEF_ACCOUNT)
    -b | --begin            Give a begin time for the job allocation.
                            Eg: "16:00", "now+1hour", "now+60" (sec),
                            "2010-01-20T12:34:00"
    -c | --cpu              Number of CPUs to request
                            (Default: $DEF_NUM_CPUS)
    -g | --gpu              Number of GPUs to request
                            (Default: $DEF_NUM_GPUS)
    -h | --help             Help menu (this menu)
    -i | --node-info        Show information about a single node or a comma
                            separated list of nodes and exit
    -j | --job-info         Job information for a job number
    -J | --name             Job name (no spaces)
                            (Default: $DEF_JOB_NAME)
    -K | --kill-all         Cancels all running SLURM jobs of user. This
                            should be the only argument passed.
    -l | --last-node        Use the gnode which the user used previously
                            Command uses 'sacct' and 'USER' to fetch data
                            User must have some allocation in last 7 days
    -m | --mem-per-cpu      Minimum RAM per CPU. Check configurations using
                            'scontrol show config' and 'seff'
    -M | --queue-me         Print the user 'squeue' information (running 
                            jobs) (User name: $USER)
    -n | --dry-run          Do not get allocation and run; only show output
    -N | --nodes            Number of nodes for 'salloc' allocation
                            (Default: $DEF_NUM_NODES)
    -p | --partition        Partition for node allocation
                            (Default: $DEF_PARTITION)
    -r | --reservation      Reservation (account is also set to same [1])
    -s | --shell            Shell to use (bash, zsh)
    -t | --time             Time limit for the job allocation (0 = inf)
                            (Default: $DEF_TIME_PERIOD)
    -u | --update           Update the csinteractive script
                            Directory: $PROGPATH
                            Program: $PROGNAME
    -v | --version          Show the version information and exit
    -w | --nodelist         Request specific list of hosts
                            Before using this, check QOSMaxNodePerJobLimit
    -x | --exclude          Exclude the list of nodes passed

[1]: Option '-a' can come after '-r' to set different account name
[2]: Use "quotes" for list of nodes. Eg: "gnode[007-008,043]"

Exit codes:
    0           Script executed successfully
    1           Argument error (some wrong option was passed)
    5           Some error happened in the interactive session
    127         Command not found

References:
- sacct: https://slurm.schedmd.com/sacct.html
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
            # Number of nodes
            "--nodes" | "-N")
                num_nodes=$1
                shift
                echo_debug "Using $num_nodes nodes on HPC"
                NUM_NODES=$num_nodes
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
                    echo_debug "Found shell at $shell_path"
                    SHELL_PATH=$shell_path
                fi
                ;;
            # Time limit for allocation
            "--time" | "-t")
                new_time=$1
                shift
                echo_debug "Setting time limit from $TIME_PERIOD to $new_time"
                TIME_PERIOD=$new_time
                ;;
            # Dry run
            "--dry-run" | "-n")
                echo_info "Dry run mode detected"
                EXEC_SCRIPT=false
                ;;
            # Previous node
            "--last-node" | "-l")
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
                gn=$($qry_cmd | grep $COMNMS | tail -n 1 | sed "s/ //g")
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
                echo_debug "Last Modified: $LAST_MDATE"
                exit 0
                ;;
            # RAM per CPU
            "--mem-per-cpu" | "-m")
                ram_cpu=$1
                shift
                echo_debug "RAM per CPU: $ram_cpu"
                MEM_PER_CPU=$ram_cpu
                ;;
            # User queue
            "--queue-me" | "-M")
                sq_cmd="squeue -u $USER -o \"%.10i %.15j %.3t %.10M %.4C  %20S %9g %.8a %.7m  %N(%r)\""
                echo_command $sq_cmd
                eval $sq_cmd
                echo_debug "Queue information display completed"
                exit 0
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
                squeue_cmd="$squeue_cmd -o \"%.10i %.15j %.3t %.10M %.4C  %20S %9g %.7m  %N(%r)\""
                echo_command $squeue_cmd
                eval $squeue_cmd
                echo ""
                # Show the pestat output
                readonly pestat_bin=$(which pestat 2> /dev/null)
                if [[ -z $pestat_bin ]]; then
                    echo_warn "Could not find pestat"
                else
                    pestat_cmd="$pestat_bin -w $nodelist"
                    echo_command $pestat_cmd
                    eval $pestat_cmd
                    echo ""
                fi
                # Show the sinfo output
                readonly sinfo_bin=$(which sinfo 2> /dev/null)
                if [[ -z $sinfo_bin ]]; then
                    echo_fatal "Could not find sinfo"
                    exit 127
                fi
                of="Partition:12,Time:12,StateCompact:8,Gres:8,\
                    GresUsed:10,CPUsState:.15,NodeList:.20"
                of=$(echo $of | tr -d '[:space:]')
                sinfo_cmd="$sinfo_bin -n $nodelist -O $of"
                echo_command $sinfo_cmd
                eval $sinfo_cmd
                echo ""
                # Exit
                echo_debug "Information display completed"
                exit 0
                ;;
            # Job (number) information
            "--job-info" | "-j")
                job_num=$1
                shift
                echo_debug "Getting information on job number: $job_num"
                # Scontrol information
                readonly scontrol_bin=$(which scontrol 2> /dev/null)
                if [[ -z $scontrol_bin ]]; then
                    echo_fatal "Could not find scontrol"
                    exit 127
                fi
                scontrol_cmd="$scontrol_bin show job -d $job_num"
                echo_command $scontrol_cmd
                eval $scontrol_cmd
                # Account information
                if [[ -z $sacct_bin ]]; then
                    echo_fatal "Could not find sacct"
                    exit 127
                fi
                sacct_cmd="$sacct_bin -j $job_num"
                echo_command $sacct_cmd
                eval $sacct_cmd
                echo ""
                # Job efficiency information
                readonly seff_bin="$(which seff 2> /dev/null)"
                if [[ -z $seff_bin ]]; then
                    echo_fatal "Could not find seff"
                    exit 127
                fi
                seff_cmd="$seff_bin $job_num"
                echo_command $seff_cmd
                eval $seff_cmd
                echo ""
                # Exit
                echo_debug "Information display completed"
                exit 0
                ;;
            # Partition
            "--partition" | "-p")
                partition=$1
                shift
                echo_debug "Using partition: $partition"
                PARTITION=$partition
                ;;
            # Update the script
            "--update" | "-u")
                echo_debug "Updating from URL ${PROG_URL}"
                cd $PROGPATH
                wget_cmd="wget $PROG_URL -O - > $PROGNAME.new"
                echo_command $wget_cmd
                eval $wget_cmd
                chmod u+x ./$PROGNAME.new
                mv ./$PROGNAME.new ./$PROGNAME
                echo_info "Update completed"
                exit 0
                ;;
            # Kill all SLURM jobs
            "--kill-all" | "-K")
                echo_info "Going to kill all tasks run by SLURM account"
                jbs=$(squeue --me -O JOBID | awk '(NR>1) {print $0}' | xargs)
                if [[ -z $job ]]; then
                    echo_info "User has no jobs"
                    exit 0
                fi
                echo_debug "Job IDs: $jbs"
                # Find scancel
                readonly scancel_bin="$(which scancel 2> /dev/null)"
                if [[ -z $scancel_bin ]]; then
                    echo_fatal "Could not find scancel"
                    exit 127
                fi
                kill_cmd="$scancel_bin $jbs"
                echo_command $kill_cmd
                eval $kill_cmd
                exit_code=$?
                if [[ ! $exit_code -eq 0 ]]; then
                    echo_warn "Exit code: $exit_code"
                    exit $exit_code
                fi
                # Exit
                echo_debug "All SLURM jobs have been terminated"
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
    # Number of nodes
    SALLOC_OPTS="$SALLOC_OPTS -N $NUM_NODES"
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

sess_start_time=$(date)
echo_info -e "Starting time: $sess_start_time"
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
sess_end_time=$(date)
echo_info -e "Ending time: $sess_end_time"
echo_debug -e "Started at: $sess_start_time"
sess_dur=$(echo $(date -d "$sess_end_time" +%s) - $(date -d "$sess_start_time" +%s) | bc -l)
echo_info -e "Duration (HH:MM:SS format): `date -d@$sess_dur -u +%H:%M:%S`"
exit $EXIT_STATUS

# The below command works:
# $SALLOC_BIN -n 10 -J interactive -p long -A research --gres=gpu:1 \
#     -t 6:00:00 $SRUN_BIN -n 10 --pty --cpu_bind=no bash -l
