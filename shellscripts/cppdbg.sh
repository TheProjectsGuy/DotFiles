#!/bin/bash
# Build and debug a C++ source code file

fname="${1:-main.cpp}"

# Check if fname is "clean" or "clear"
if [[ "$fname" = "clean" || "$fname" = "clear" ]]; then
    echo "Clearing temporary build files"
    echo '> find . -type f -regextype posix-extended -regex ".*(\.(ii|o|s|out)|out)" -exec rm -vf {} \;'
    find . -type f -regextype posix-extended -regex ".*(\.(ii|o|s|out)|out)" -exec rm -vf {} \;
    exit 0
fi

# Real file (to be built)
fname=$(realpath $fname)
echo "File name: $fname"
if [ ! -f "$fname" ]; then
    echo "File not found: $fname"
    exit 1
fi

# Run build
echo "> g++ -Wall -save-temps -g $fname -o a.out"
g++ -Wall -save-temps -g $fname -o a.out

# Run debug
echo "> gdb a.out"
gdb a.out
