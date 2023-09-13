#!/bin/bash

# kill_user user.name
uname=$1    # Name of the user
# Assert name to be provided
if [[ -z $uname ]]; then
    echo "No username provided"
    echo "Usage: kill_user user.name"
    exit 1
fi
# List processes already running
echo "User $uname is running the following processes"
ps -u $uname -o pid,user,time,tty,cmd 2> /dev/null
ec=$?
if [[ $ec -ne 0 ]]; then
    echo "The 'ps' command failed (are you sure the user exists?)"
    exit 2
fi
# Kill all the above
pids=$(ps -u $uname -o pid | awk '(NR>1) {print $1}' | xargs)
echo "PIDs: $pids"
echo "Giving a 'sudo kill' to all these processes"
sudo kill $pids
