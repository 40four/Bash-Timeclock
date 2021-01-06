#!/bin/bash

DEFAULT_FILE="$(date '+%a-%b-%d-%Y').timesheet"
NOW=`date` 

##### HELPER FUNCTIONS #####

function clockIn {
	echo "IN  | $NOW | $1" >> $DEFAULT_FILE
	echo "Clocked IN $NOW"
	exit 0
}

function clockOut {
	echo "OUT | $NOW | $1" >> $DEFAULT_FILE
	echo "Clocked OUT $NOW"
	exit 0
}

function displayHelp {
	echo "Nothing Happened"
	echo "Usage: ./timeclock.sh <in|out> <tags/notes>"
	exit 0
}

function getTags {
	shift
	local tag
	tag=""
	while getopts ":t:" opt; do
		case ${opt} in
			t )
				tag="$OPTARG"
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

	echo "$tag"
}

function getLastStatus {
	local status
	status=""
	if [[ -e $DEFAULT_FILE ]]; then
		status=$(tail -n 1 $DEFAULT_FILE | awk '{print $1}')
	fi
	echo $status
}

##### BUSINESS #####

command=$1;
clockStatus=$(getLastStatus)

case "$command" in
	in )
		if [[ $clockStatus == 'OUT' || -z $clockStatus ]]; then
			clockIn "$(getTags "$@")"
		fi
		echo "Nothing happened, you are already clocked in!"
		;;
	out )
		if [[ $clockStatus == 'IN' || -z $clockStatus ]]; then
			clockOut "$(getTags "$@")"
		fi
		echo "Nothing happened, you are already clocked out!"
		;;
	* )
		displayHelp
esac
