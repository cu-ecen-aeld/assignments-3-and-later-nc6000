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


	writefile=$1
	echo "Creating: $writefile"
	echo > $writefile
	cat $writefile
		

if [ -w "$2" ]
then
	echo "File $writefile cant be created"
	exit 1
else 
	echo "File $writefile created with content:"
	cat $writefile
fi

echo "$2" >> "$writefile"
	
