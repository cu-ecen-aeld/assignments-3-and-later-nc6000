#!/bin/sh

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: Both arguments must be provided."
    exit 1
fi

filedir=$1
searchstr=$2

if [ ! -d "$filedir" ]; then
    echo "Directory not found or misspelled: $filedir"
    exit 1
fi

echo "Search directory found: $filedir"
echo "Searching for: $searchstr"

X=$(grep -r -l "$searchstr" "$filedir" | wc -l)
Y=$(grep -r "$searchstr" "$filedir" | wc -l)

echo "The number of files are $X and the number of matching lines are $Y"

