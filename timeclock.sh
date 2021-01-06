#!/bin/bash

DELIM=" | "
DEFAULT_FILE="$(date '+%a-%b-%d-%Y').timesheet"
NOW=`date` 

function clockIn {
	local this_line="IN$DELIM"
	this_line+="$NOW$DELIM"
	this_line+="$1"
	echo $this_line >> $DEFAULT_FILE
	echo "Clocked IN $NOW"
	exit 0
}

function clockOut {
	local this_line="OUT$DELIM"
	this_line+="$NOW$DELIM"
	this_line+="$1"
	echo $this_line >> $DEFAULT_FILE
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

	echo $tag
}

function getLastStatus {
	local status
	status=""
	if [[ -e $DEFAULT_FILE ]]; then
		local last_line=$(tail -n 1 $DEFAULT_FILE)
		status=$(checkOneAction "$last_line")
	fi

	echo $status
}

function checkOneAction {
	local this_line
	this_line=$1

	echo $this_line | awk -F "$DELIM" '{print $1}'
}
