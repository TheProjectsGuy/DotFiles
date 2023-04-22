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


readonly VERSION_MAJOR=1
readonly VERSION_MINOR=2
VERSION="${VERSION_MAJOR}.${VERSION_MINOR}"

# Program properties
readonly ARGS="$@"  # Reset using https://stackoverflow.com/a/4827707
readonly PROGNAME=$(basename $0)
readonly PROGPATH=$(realpath $(dirname $0))
readonly DEF_THRESH=2048    # Default threshold in MB
readonly DEF_LOGFILE=$HOME/proc_kill.logs

function usage () {
    cat <<-EOF
Monitors the RAM utilization of a process and kills it if the RAM utilization is above
a certain threshold.

VERSION: $VERSION

USAGE: $PROGNAME -ARG VAL [-OPTARG [OPTVAL]]

WARNINGS:
1. You could unknowingly kill many processes
    - Runs a grep search for matching processes. The process will be killed (if run by
        the user) if it takes more pss RAM than specified threshold.
2. You could lose unsaved work
3. Tremendous potential for MISUSE. Please use wisely.


Arguments:
    -p | --pattern PAT      Search for processes containing "PAT" in their name

Optional arguments:
    -d | --dry-run          Don't kill, just print processes (if killed). Also enables
                            verbose mode (print utilization and stuff)
    -h | --help             Print the help menu (this output)
    -l | --kill-log LOG_F   A log file for saving the kill logs (time stamped). If ''
                            (blank), then no logs are saved (I sugguest to NOT do this).
                            (Default is: $DEF_LOGFILE)
    -m | --multi-sum        If multiple PIDs are found, use the sum total. By default,
                            it uses the max utilization (for comparison).
    -n | --nofity           If passed, a system GUI notification (popup) is sent.
                            Currently only the following distributions are supported
                            - Linux Mint
    -s | --strict           Throw error even when there is a minor issue (>=127 code)
    -t | --thresh TH_MB     The process should have a maximum of "TH_MB" (in MB) memory
                            on RAM. If it exceeds that, it could get killed. See the
                            kill policy.
                            (Default is: $DEF_THRESH MB)

Kill policy:

1. The program finds PIDs containing the pattern 'PAT'
2. If there are no PIDs, the process exits (code 0 or 127, depending on '-s' option)
3. If there is only one PID found, the RAM utilization is noted. If it uses more
    than TH_MB of RAM, it is killed
4. If there are multiple PIDs found, the RAM utilization of each of the processes is
    found (as well as their total). Depending on the '-m' setting
    - If '-m' is passed: If the total RAM usage exceeds TH_MB, all PIDs are killed
    - If '-m' is not passed: The PID using the max RAM is killed, if it is using more
        RAM than TH_MB

EXAMPLES:
- Kill firefox if it uses more than 5120 MB RAM (combined)
    $PROGNAME -m -p firefox -t 5120
- Kill a firefox process if it uses more than 1024 MB RAM (individual)
    $PROGNAME -p firefox -t 1024
- Kill all barrier processes if they use more than 500 MB RAM (combined)
    $PROGNAME -m -p barrier -t 500

CRON SUGGESTIONS:
You can enable CRON jobs to periodically check for memory utilizations
    - Eg: Limit barrier to only 200 MB RAM (check every 2 minutes)
        */2 * * * * $PROGPATH/$PROGNAME -m -p barrier -t 200
    - Eg: Limit firefox to only 6144 MB (6 GB) RAM (check every 15 minutes)
        */15 * * * * $PROGPATH/$PROGNAME -m -p firefox -t 6144

Exit codes:
    0           Normal exit
    1           Argument error (needed argument missing)
    2           Argument error (not recognized, NaN, etc.)
    127         Minor: No matching processes found

References:
- Types of memory representations: https://stackoverflow.com/q/22372960/5836037
- Periodic CRON jobs: https://www.ibm.com/support/pages/how-run-cron-job-every-5-minutes

EOF
}

# Environment variables
PROC=""
THRESH_USAGE="$DEF_THRESH"
STRICT_EXEC="false"         # "true" | "false"
LOGFILE=$DEF_LOGFILE
MULTI_KILLSTYLE="single"    # "single" | "all"
DRY_RUN="false"             # "true" | "false"
NOTIFY_GUI="false"          # "true" | "false"

# ================ Functions ================ 

function parse_options () {
    # Set the passed bash options
    set -- $ARGS
    while (( $# )); do
        arg=$1  # Read option
        shift   # Shift to the next argument
        case "$arg" in
            # Help options
            "--help" | "-h")
                usage
                exit 0
                ;;
            # Process name (pattern)
            "--pattern" | "-p")
                pattern=$1
                shift
                PROC=$pattern
                ;;
            # Threshold usage
            "--thresh" | "-t")
                thresh=$1
                # From: https://stackoverflow.com/a/806923/5836037
                re='^[+-]?[0-9]+([.][0-9]+)?$'
                if ! [[ $thresh =~ $re ]]; then
                    echo "Not a number: $thresh"
                    exit 2
                fi
                shift
                THRESH_USAGE=$thresh
                ;;
            # Strict usage
            "--strict" | "-s")
                STRICT_EXEC="true"
                ;;
            # Log file
            "--kill-log" | "-l")
                log_file=$1
                shift
                LOGFILE=$log_file
                ;;
            # Kill strategy for multiple processes
            "--multi-sum" | "-m")
                MULTI_KILLSTYLE="all"
                ;;
            # Dry run
            "--dry-run" | "-d")
                DRY_RUN="true"
                ;;
            # Notify GUI
            "--notify" | "-n")
                NOTIFY_GUI="true"
                ;;
            *)
                echo "Unrecognized option: $1"
                exit 2
                ;;
        esac
    done
}

function proc_util() {
    # Given a PID as argument, return (echo) the process usage on RAM (in MB)
    #   From: https://www.golinuxcloud.com/check-memory-usage-per-process-linux/
    pid=$1
    proc_usage=$(cat /proc/$pid/smaps | grep -i pss | awk '{Total+=$2} END {print Total/1024}')
    echo $proc_usage
}

function notify_kill() {
    # Gives a GUI notification (if enabled). Pass the process IDs as argument
    # Also uses the process name PROC
    if [[ "$NOTIFY_GUI" = "false" ]]; then
        return 0
    fi
    distro_id=$(cat /etc/*-release 2> /dev/null | awk '/^DISTRIB_ID/ {print $1}' | sed "s/DISTRIB_ID\=//")
    if [[ $distro_id == "LinuxMint" ]]; then
        notify-send -u critical "Process $PROC killed" "Was consuming more than $THRESH_USAGE MB RAM"
    fi
}

function kill_pid() {
    # Function handles killing (even dry run) and notification
    kpid=$1
    if [[ $DRY_RUN = "true" ]]; then
        echo "Would kill PID: $kpid (but in dry run)"
    else
        kill -9 $kpid
    fi
    notify_kill
}

# ===================== Main entrypoint ===================== 
parse_options
# Check if mandatory arguments are set
if [[ -z $PROC ]]; then
    echo "Process pattern not passed (-p)"
    exit 1
fi
if [[ -z $THRESH_USAGE ]]; then
    echo "RAM threshold not specified"
    exit 1
fi
# Get process ID(s)
self_pids=$(ps aux | egrep "$0" | awk 'BEGIN {ORS=" "} {print $2}')
pid_uf=$(pgrep -i ".*$PROC.*" -d ' ' --full)
for pid_self in $self_pids; do  # Do not kill self
    pid_uf=$(echo $pid_uf | sed "s/$pid_self//" | xargs)
done
pid=$pid_uf
# Verbose
if [[ "$DRY_RUN" = "true" ]]; then
    echo "Date: `date`"
    echo "PID(s) after filtering self: $pid"
fi
if [[ $(wc -w <<< $pid) == 0 ]]; then   # If no processes found
    # Verbose
    if [[ "$DRY_RUN" = "true" ]]; then
        echo "No process found to kill"
    fi
    if [[ "$STRICT_EXEC" = "true" ]]; then
        exit 127
    else
        exit 0
    fi
elif [[ $(wc -w <<< $pid) == 1 ]]; then # If a single matching process is found
    ps_util=$(proc_util $pid)
    # Verbose
    if [[ "$DRY_RUN" = "true" ]]; then
        echo "Process $PROC (pid: $pid) uses $ps_util MB RAM, threshold is $THRESH_USAGE MB"
    fi
    if (( $(echo "$ps_util > $THRESH_USAGE" | bc -l) )); then
        if [[ ( ! -z $LOGFILE ) && ( "$DRY_RUN" = "false" ) ]]; then
            date >> $LOGFILE
            echo "Process '$PROC' (PID: $pid) using $ps_util (> $THRESH_USAGE) MB RAM! I'm closing it" >> $LOGFILE
            echo "-----------------------------------------------------------------------------" >> $LOGFILE
        elif [[ "$DRY_RUN" = "true" ]]; then
            echo "No logs since dry run"
        fi
        kill_pid "$pid"
    fi
else                                    # If multiple matching processes are found
    pidArray=($pid)
    # Verbose
    if [[ "$DRY_RUN" = "true" ]]; then
        echo "Process $PROC has the following processes (PID: Usage in MB)"
    fi
    # Maximum utilization process
    max_pid="0"
    max_mem="0"
    total_util="0"  # Total RAM utilization
    for i_pid in ${pidArray[*]}; do
        usage_ipid=$(proc_util $i_pid)
        total_util=$(echo "$total_util + $usage_ipid" | bc -l)
        # Verbose
        if [[ "$DRY_RUN" = "true" ]]; then
            echo -e " - $i_pid: $usage_ipid MB"
        fi
        if (( $(echo "$usage_ipid > $max_mem" | bc -l) )); then
            max_mem=$usage_ipid
            max_pid=$i_pid
        fi
    done
    # Verbose
    if [[ "$DRY_RUN" = "true" ]]; then
        echo "Total: $total_util MB"
        echo "Multi-kill style: $MULTI_KILLSTYLE, threshold: $THRESH_USAGE MB"
    fi
    # Kill strategy for multiple PIDs
    if [[ "$MULTI_KILLSTYLE" = "all" ]]; then
        if (( $(echo "$total_util > $THRESH_USAGE" | bc -l) )); then    # Kill all pid
            if [[ ( ! -z $LOGFILE ) && ( "$DRY_RUN" = "false" ) ]]; then
                date >> $LOGFILE
                echo "Processes matching '$PROC': $pid" >> $LOGFILE
                echo "Total RAM usage is $total_util (> $THRESH_USAGE) MB! I'm killing all of them" >> $LOGFILE
                echo "-----------------------------------------------------------------------------" >> $LOGFILE
            elif [[ "$DRY_RUN" = "true" ]]; then
                echo "No logs since dry run"
            fi
            kill_pid "$pid"
        fi
    elif [[ "$MULTI_KILLSTYLE" = "single" ]]; then
        if (( $(echo "$max_mem > $THRESH_USAGE" | bc -l) )); then       # Kill max usage PID
            if [[ ( ! -z $LOGFILE ) && ( "$DRY_RUN" = "false" ) ]]; then
                date >> $LOGFILE
                echo "Processes matching '$PROC': $pid" >> $LOGFILE
                echo "Max utilization is by PID $max_pid, which is $max_mem (> $THRESH_USAGE) MB! I'm killing it" >> $LOGFILE
                echo "-----------------------------------------------------------------------------" >> $LOGFILE
            elif [[ "$DRY_RUN" = "true" ]]; then
                echo "No logs since dry run"
            fi
            kill_pid "$max_pid"
        fi
    fi
fi


