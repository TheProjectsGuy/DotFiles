#!/bin/bash
# Needs gpustat
#   - https://pypi.org/project/gpustat/

# gpustat -a --force-color -i 10
watch --color gpustat --force-color -p --show-fan -P
