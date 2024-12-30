#!/bin/bash
# Build and debug a C++ source code file

ind_files=("${@:-main.cpp}")

# Check if fname is "clean" or "clear"
if [[ "${ind_files[0]}" = "clean" || "${ind_files[0]}" = "clear" ]]; then
    echo "Clearing temporary build files"
    echo '> find . -type f -regextype posix-extended -regex ".*(\.(ii|o|s|out)|out)" -exec rm -vf {} \;'
    find . -type f -regextype posix-extended -regex ".*(\.(ii|o|s|out)|out)" -exec rm -vf {} \;
    exit 0
fi

# fname="${1:-main.cpp}"
fname=""
for file in "${ind_files[@]}"; do
    # Individual filename
    ifname=$(realpath $file)
    if [ ! -f "$ifname" ]; then
        echo "File not found: $ifname"
        exit 1
    fi
    fname+="$ifname "
done

# Real file (to be built)
echo "Source file name(s): $fname"

# Run build
build_command="g++ -Wall -save-temps -g $fname -o a.out"
echo "> $build_command"
$build_command
ec=$?
if [ $ec != "0" ]; then
    echo "Some error happened when running the previous command"
    echo "Exit code: $ec"
    exit 1
fi

# Run debug
run_command="gdb a.out"
echo "> $run_command"
$run_command
ec=$?
if [ $ec != 0 ]; then
    echo "Some error happened when running the previous command"
    echo "Exit code: $ec"
    exit 1
fi