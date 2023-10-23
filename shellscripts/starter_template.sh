#!/bin/bash
# Initialize a mamba environment in "/scratch" of the system
#
# Manage a mamba environment in the '/scratch/$USER'
#

readonly VERSION_MAJOR=1
readonly VERSION_MINOR=0
VERSION="${VERSION_MAJOR}.${VERSION_MINOR}"

# Program properties
readonly ARGS="$@"  # Reset using https://stackoverflow.com/a/4827707
readonly PROGNAME=$(basename $0)
readonly PROGPATH=$(realpath $(dirname $0))

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

Usage:
    $ $PROGNAME -ARG VAL [-OPTARG [OPTVAL]]

    Where "ARG" is a needed argument, "VAL" is a value for the argument,
    "OPTARG" is an optional argument, and "OPTVAL" is an option value.

Arguments:
    -h  | --help        Print this help message


Other info
- Version: $VERSION
- Script name: $PROGNAME
- Script path: $PROGPATH

Exit codes
- 0:    Graceful exit

References:
1. https://manpages.ubuntu.com/manpages/trusty/man8/tmpreaper.8.html
EOF
}

# ================ Functions ================ 

function parse_options () {
    # Set the passed bash options
    set -- $ARGS
    while (( $# )); do
        arg=$1  # Read option
        shift   # Shift to the next argument
        case "$arg" in
            "--help" | "-h")
                usage
                exit 0
                ;;
        esac
    done
}

# ===================== Main entrypoint ===================== 
parse_options
# Your code here...
