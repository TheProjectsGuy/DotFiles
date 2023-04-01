#!/bin/bash
# Folder name
db_folder="/mnt/Dropbox/"

# Unmount using fusermount
#fusermount -u /mnt/Dropbox

# Mount the dropbox drive
if [ -z "$(ls -A ${db_folder})" ]; then
    rclone mount Personal-Dropbox:/ ${db_folder} --daemon
else
    echo "Mount directory ${db_folder} not empty"
fi

