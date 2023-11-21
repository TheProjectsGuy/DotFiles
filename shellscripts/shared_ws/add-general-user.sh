#!/bin/bash
# Add a general (non-root, regular) user to the system
# Run as
#   add-general-user.sh username

uname=$1
echo "Creating user $uname"

readonly BASE_DIR="/home2"      # Directory where user homes exist
readonly SHARE_DIR="/share2"    # Shared directory
readonly BASE_UID=10000         # UID numbers (to distinguish regular people)
readonly BASE_GROUP="public"    # Primary group for the user
readonly HOME_QUOTA="25G 27G 500k 550k"     # Quota for home
readonly SHARE_QUOTA="100G 105G 3000 3100"  # Quota for share space


# ----------- Create user -----------
# Check if user exists
id $uname &> /dev/null
if [ $? -eq 0 ]; then
    echo "User $uname already exists"
    exit 1
fi
# Get the UID
n=$(awk -F ':' -v a=$BASE_UID '$3 >= a && $3 < 65000 {print}' /etc/passwd | wc -l)
uid=$((BASE_UID+n))
echo "UID is $uid"
# Add user
sudo useradd --shell /bin/bash --base-dir $BASE_DIR --create-home \
    --no-user-group --uid $uid -g $BASE_GROUP $uname
echo "Created user $uname"
# Add a password
rpass=$(head /dev/urandom | md5sum -b | awk '{print substr($1,0,10)}')
(echo $rpass; echo $rpass) | sudo passwd $uname &> /dev/null
echo "First time login password: $rpass"
# Create folder in shared directory
sudo mkdir -p $SHARE_DIR/$uname
sudo chown $uname:$BASE_GROUP $SHARE_DIR/$uname

# ----------- Quota -----------
sudo setquota -u $uname $HOME_QUOTA $BASE_DIR
sudo setquota -u $uname $SHARE_QUOTA $SHARE_DIR
echo "Quotas set for the user"
