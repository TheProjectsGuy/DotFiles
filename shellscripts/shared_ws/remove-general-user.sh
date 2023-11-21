#!/bin/bash
# Remove a general user
#   remove-general-user.sh username

uname=$1
echo "Removing user $uname"

readonly SHARE_DIR="/share2"    # Directory where share files exist

sudo rm -rf $SHARE_DIR/$uname
echo "Removed $SHARE_DIR/$uname"
sudo userdel -r $uname
echo "User $uname has been removed"
