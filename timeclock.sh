#!/bin/bash

DEFAULT_FILE="$(date '+%a-%b-%d-%Y').timesheet"
NOW=`date` 

function clockIn {
	echo "$NOW | IN | $1" >> $DEFAULT_FILE
	printf "Clocked IN $NOW"
}

function clockOut {
	echo "$NOW | OUT | $1" >> $DEFAULT_FILE
	printf "Clocked OUT $NOW"
}

function displayHelp {
	echo "Nothing Happened"
	printf "Usage: ./timeclock.sh <in|out> <tags/notes>"
}

if [ -z "$1" ]; then
	displayHelp
elif [ $1 == 'in' ]; then
	clockIn "$2"
elif [ $1 == 'out' ]; then
	clockOut "$2"
fi
