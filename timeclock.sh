#!/bin/bash

DEFAULT_FILE="$(date '+%a-%b-%d-%Y').timesheet"
NOW=`date` 

##### HELPER FUNCTIONS #####

function clockIn {
	echo "IN  | $NOW | $1" >> $DEFAULT_FILE
	printf "Clocked IN $NOW"
	exit 0
}

function clockOut {
	echo "OUT | $NOW | $1" >> $DEFAULT_FILE
	printf "Clocked OUT $NOW"
	exit 0
}

function displayHelp {
	echo "Nothing Happened"
	printf "Usage: ./timeclock.sh <in|out> <tags/notes>"
	exit 0
}

function handleOptions {
	shift
	# local OPTIND
	local TAG
	TAG=""
	while getopts ":t:" opt; do
		case ${opt} in
			t )
				TAG="$OPTARG"
				;;
			\? )
				echo "Invalid Option: -$OPTARG" 1>&2
				exit 1
				;;
			: )
				echo "Invalid Option: -$OPTARG requires an argument" 1>&2
				exit 1
				;;
		esac
	done
	shift $((OPTIND -1))

	echo "$TAG"
}

##### BUSINESS #####

COMMAND=$1;

case "$COMMAND" in
	in )
		clockIn "$(handleOptions $*)"
		;;
	out )
		clockOut "$(handleOptions $*)"
		;;
	* )
		displayHelp
esac
