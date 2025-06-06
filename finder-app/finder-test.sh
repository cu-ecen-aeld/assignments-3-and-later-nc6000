#!/bin/sh
# Modified finder-test.sh for Assignment 4 requirements

set -e
set -u

NUMFILES=10
WRITESTR=AELD_IS_FUN
WRITEDIR=/tmp/aeld-data
CONFIG_DIR=/etc/finder-app/conf

username=$(cat ${CONFIG_DIR}/username.txt)

if [ $# -lt 3 ]
then
    echo "Using default value ${WRITESTR} for string to write"
    if [ $# -lt 1 ]
    then
        echo "Using default value ${NUMFILES} for number of files to write"
    else
        NUMFILES=$1
    fi 
else
    NUMFILES=$1
    WRITESTR=$2
    WRITEDIR=/tmp/aeld-data/$3
fi

MATCHSTR="The number of files are ${NUMFILES} and the number of matching lines are ${NUMFILES}"

# Check if writer executable is available in PATH
if ! command -v writer > /dev/null; then
  echo "ERROR: writer binary not found in PATH!"
  exit 1
fi

# Run the writer application
writer ${NUMFILES} ${WRITESTR} ${WRITEDIR}

# Run finder and save output to /tmp/assignment4-result.txt
if ! command -v finder > /dev/null; then
  echo "ERROR: finder binary not found in PATH!"
  exit 1
fi

finder > /tmp/assignment4-result.txt

# Optionally, you can print confirmation
echo "Finder output saved to /tmp/assignment4-result.txt"

