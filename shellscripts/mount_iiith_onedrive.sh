#!/bin/bash
# Folder name
iiith_folder="/home/avneesh/IIITH-OneDrive"

# Unmount using fusermount
#fusermount -u /home/avneesh/IIITH-OneDrive

# Mount the IIIT Hyderabad OneDrive
if [ -z "$(ls -A ${iiith_folder})" ]; then
    rclone mount "IIITH OneDrive":/ ${iiith_folder} --vfs-cache-mode writes --daemon
else
    echo "Mount directory ${iiith_folder} not empty"
fi
