# Ada (HPC-like) Scripts

Some scripts I run on HPC-like environments

> **Disclaimer**: Use everything here at your own risk.

You might want to download scripts in `~/bin`, add `~/bin` to `PATH`, and `chmod u+x ~/bin/*.sh`.

## Table of contents

- [Ada (HPC-like) Scripts](#ada-hpc-like-scripts)
    - [Table of contents](#table-of-contents)
    - [Contents](#contents)
    - [Snippets](#snippets)
        - [Touch files and update time](#touch-files-and-update-time)

## Contents

The contents of this folder are as follows

| S. No. | Script name | Description |
| :----- | :---------- | :---------- |
| 1 | [csinteractive.sh](./csinteractive.sh) | A cool version of `sinteractive`. Check the [gist](https://gist.github.com/TheProjectsGuy/de328d8c6f9dd46a4785bb299575bc47). |
| 2 | [conda-backup.sh](./conda-backup.sh) | Bachup an anaconda environment |
| 3 | [conda-install.sh](./conda-install.sh) | Install something in an anaconda environment |
| 4 | [conda-pip-install.sh](./conda-pip-install.sh) | Install something using `pip` in a conda environment |
| 5 | [mamba-install.sh](./mamba-install.sh) | Install something in a mamba environment |
| 6 | [mamba-pip-install.sh](./mamba-pip-install.sh) | Install something using `pip` in a mamba environment |
| 7 | [move_slurm_res.sh](./move_slurm_res.sh) | Move a SLURM result file (I usually zip the results like checkpoints and move it to permanent non-scratch storage) from permanent storage and unzip it in `pwd` |
| 8 | [watch_gpus.sh](./watch_gpus.sh) | Watch utilization of GPUs (live monitoring on CLI) |
| 9 | [watch_sq.sh](./watch_sq.sh) | Watch your SLURM job queue |
| 10 | [who_ps.sh](./who_ps.sh) | Check out who else is running processes on your node |
| 11 | [mamba-scratch-init.sh](./mamba-scratch-init.sh) | Initialize `mamba` (in scratch), and install it if it doesn't exist |

## Snippets

### Touch files and update time

If your HPC uses [tmpreaper](https://manpages.ubuntu.com/manpages/trusty/man8/tmpreaper.8.html)-like things, and you don't want your files to be deleted after a while, you could do this

```bash
# Run this in the appropriate folder (that you want to preserve)
cd /scratch/$USER
# Maintain a list of untouched files (remove for the next step)
cat ./untouched.txt && rm $_
# Touch all files
#   - '-h' for symlinks: https://unix.stackexchange.com/a/63877
find . -exec touch -h {} \; 2> /scratch/$USER/untouched.txt &
```
