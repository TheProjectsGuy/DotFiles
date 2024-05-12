# Shell scripts

Some shell scripts I find useful

## Table of contents

- [Shell scripts](#shell-scripts)
    - [Table of contents](#table-of-contents)
    - [Usage](#usage)
    - [Contents](#contents)

## Usage

Move the script to a folder in `$PATH` and `chmod u+x` it.

## Contents

This folder has the following files

| S. No. | Script name | Description |
| :----- | :---------- | :---------- |
| 1 | [mount_iiith_onedrive.sh](./mount_iiith_onedrive.sh) | Mount IIIT-Hyderabad OneDrive. See [rclone docs](https://rclone.org/onedrive/). |
| 2 | [proc_see_kill.sh](./proc_see_kill.sh) | Monitor processes by name and kill them if they take more than specified space on RAM. Use like a fail-safe for programs that could have a memory leak issue. |
| 3 | [kill_user.sh](./kill_user.sh) | Kill all processes of a user |
| 4 | [env_setup.sh](./env_setup.sh) | A python environment setup starter script, mainly for python projects using mamba, conda, and/or pip. |
| 5 | [starter_template.sh](./starter_template.sh) | A starter script for writing shell scripts |
| 6 | [myip.sh](./myip.sh) | A simple shell script to get IP address using [icanhazip](https://blog.apnic.net/2021/06/17/how-a-small-free-ip-tool-survived/) |
| 7 | [myip.py](./myip.py) | A better wrapper around `myip` script to get IP addresses (both public and system/private). |
| 8 | [password_generator.py](./password_generator.py) | Generate a random password (uses system python) |

This folder has the following folders

| S. No. | Folder name | Description |
| :----- | :---------- | :---------- |
| 1 | [ada](./ada) | Contains a collection of scripts that I usually put in `~/bin`. More useful for HPC-like environments. |
| 2 | [shared_ws](./shared_ws) | Contains a collection of scripts for administering shared workstations. |

The following is deprecated

| S. No. | Script name | Description |
| :----- | :---------- | :---------- |
| 1 | [mount_personal_dropbox.sh](./mount_personal_dropbox.sh) | ~~Mount personal DropBox. See [rclone docs](https://rclone.org/dropbox/).~~ Use the [official Dropbox installer for Linux](https://www.dropbox.com/install) |
