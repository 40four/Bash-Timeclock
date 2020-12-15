#!/bin/bash

DEFAULT_FILE="$(date '+%a-%b-%d-%Y').timesheet"
NOW=`date` 

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

function validateCommand {
	POSSIBLE_COMMANDS=('in' 'out') 
	if [[ ! "${POSSIBLE_COMMANDS[@]}" =~ "$1" ]]; then
		displayHelp	
	elif [[ $1 == "" ]]; then
		displayHelp
	fi
}

COMMAND=$1;
validateCommand $COMMAND

case "$COMMAND" in
	\in )
		shift
		TAG=''
		while getopts ":t:" opt; do
			case ${opt} in
				t )
					TAG=$OPTARG
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
		clockIn "$TAG"
		;;

	\out )
		shift
		TAG=''
		while getopts ":t:" opt; do
			case ${opt} in
				t )
					TAG=$OPTARG
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
		clockOut "$TAG"
		;;

	#"" )
		#displayHelp
esac
