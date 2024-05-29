#!/bin/bash
# Folder name
dropbox_folder="/home/avneesh/Dropbox"

# Unmount using fusermount
#fusermount -u /home/avneesh/Dropbox

# Mount the rclone remote
if [ -z "$(ls -A ${dropbox_folder})" ]; then
    rclone mount "Personal-Dropbox":/ ${dropbox_folder} --daemon
else
    echo "Mount directory ${dropbox_folder} not empty"
fi
