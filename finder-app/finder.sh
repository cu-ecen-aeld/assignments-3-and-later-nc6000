#!/bin/bash

if [ -z "$1" ]
then
	echo "Both arguments are not provided"
	exit 1
else echo 
fi

if [ -z "$2" ]
then
	echo "One of the arguments is not provided"
	exit 1
else echo 
fi

if [ -d "$1" ] 
then
	filedir=$1
	searchstr=$2
	echo "Search directory found: $filedir"
	echo "search in files and directories:"
	ls "$1"
	echo "search for: $searchstr"
else
	filedir=$1
	echo "Directory not found or misspelled: $filedir"
	exit 1
fi


files_found="$(grep -r -l  "$searchstr"  "$filedir" | wc -l )"
X=$files_found
lines_found="$(grep -r  "$searchstr"  "$filedir" | wc -l)"
Y=$lines_found
echo
echo "The number of files are $X and the number of matching lines are $Y"
echo


echo
echo "files found:"
grep -r -l  "$searchstr" * "$filedir" | wc -l
grep -r -l  "$searchstr" * "$filedir" | wc -l | $filesfound
echo

grep -r -l "$searchstr" * "$filedir" 
echo
echo "occurances found:"
grep -r  "$searchstr" * "$filedir" | wc -l
echo
grep -r  "$searchstr" * "$filedir" 
echo
WIP_and_tests='
echo "ANY CASE occurances found:"
grep -r -i "$searchstr" * "$filedir" | wc -l
echo
grep -r -i "$searchstr" * "$filedir"
echo
echo "COUNT LINES FOR EACH FILE"
echo
grep -r -c "$searchstr" * "$filedir"
echo'



