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

| S. No. | Script name | Description |
| :----- | :---------- | :---------- |
| 1 | [csinteractive.sh](./csinteractive.sh) | A cool version of `sinteractive`. Check the [gist](https://gist.github.com/TheProjectsGuy/de328d8c6f9dd46a4785bb299575bc47). |
| 2 | [conda-backup.sh](./conda-backup.sh) | Bachup an anaconda environment |
| 3 | [mount_iiith_onedrive.sh](./mount_iiith_onedrive.sh) | Mount IIIT-Hyderabad OneDrive. See [rclone docs](https://rclone.org/onedrive/). |
| 4 | [proc_see_kill.sh](./proc_see_kill.sh) | Monitor processes by name and kill them if they take more than specified space on RAM. |
| 5 | [mamba-install.sh](./mamba-install.sh) | A wrapper for `mamba install` that logs whatever you install (with timestamp). |
| 6 | [conda-install.sh](./conda-install.sh) | A wrapper for `conda install` that logs whatever you install (with timestamp). |
| 7 | [mamba-pip-install.sh](./mamba-pip-install.sh) | A wrapper for `pip install` in a mamba environment that logs whatever you install (with timestamp). |
| 8 | [conda-pip-install.sh](./conda-pip-install.sh) | A wrapper for `pip install` in a conda environment that logs whatever you install (with timestamp). |
| 9 | [kill_user.sh](./kill_user.sh) | Kill all processes of a user |

The following is deprecated

| S. No. | Script name | Description |
| :----- | :---------- | :---------- |
| 1 | [mount_personal_dropbox.sh](./mount_personal_dropbox.sh) | ~~Mount personal DropBox. See [rclone docs](https://rclone.org/dropbox/).~~ Use the [official Dropbox installer for Linux](https://www.dropbox.com/install) |
