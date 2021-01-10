#!/bin/bash

DELIM=" | "
DEFAULT_FILE="$(date '+%a-%b-%d-%Y').timesheet"
NOW=`date` 

########################################
# Clock in action, write new line to file
# give user a success messasge
# Globals:
#   DELIM
#   DEFAULT_FILE
#   NOW
# Arguments:
#   Tags, if any given
########################################
function clockIn {
	local this_line="IN$DELIM"
	this_line+="$NOW$DELIM"
	this_line+="$1"
	echo $this_line >> $DEFAULT_FILE
	echo "Clocked IN $NOW"
	exit 0
}

########################################
# Clock out action. Write new line to file,
# give user a success messge
# Globals:
#	DELIM
#	DEFAULT_FILE
#	NOW
# Arguments:
#	Tags, if any given
########################################
function clockOut {
	local this_line="OUT$DELIM"
	this_line+="$NOW$DELIM"
	this_line+="$1"
	echo $this_line >> $DEFAULT_FILE
	echo "Clocked OUT $NOW"
	exit 0
}

########################################
# Display a message with usage instructions
########################################
function displayHelp {
	echo "Nothing Happened"
	echo "Usage: ./timeclock.sh <in|out> <tags/notes>"
	exit 0
}

########################################
# Look for a -t option flag and assign tag values if it exists
# Arguments:
#   $1 - All arguments $@
########################################
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

########################################
# Read the last line from the file and echo the action (in/out)
# Globals:
#   DEFAULT_FILE
########################################
function getLastAction {
	local status
	status=""
	if [[ -e $DEFAULT_FILE ]]; then
		local last_line=$(tail -n 1 $DEFAULT_FILE)
		status=$(getAction "$last_line")
	fi

	echo $status
}

########################################
# Get the action from a single line
# Arguments:
#   $1 - one line from a timesheet file
########################################
function getAction {
	local this_line
	this_line=$1

	echo $this_line | awk -F "$DELIM" '{print $1}'
}

########################################
# Get the datetime from a single line
# Arguments:
#   $1 - one line from a timesheet file
########################################
function getDateTime {
	local this_line
	this_line=$1

	echo $this_line | awk -v delim="$DELIM" -f csv.awk
}

########################################
# Check that the given action is 'IN', call a true or false command
# Arguments:
#   $1 - An action
########################################
function actionIsIn {
	local this_action
	this_action=$1

	if [[ $this_action == 'IN' ]]; then
		true
	else
		false
	fi
}

########################################
# Read the input file into an array, sum the total time worked, echo a 
# human readable messasge.
# Globals:
#   DEFAULT_FILE
########################################
function calcHours {
	local file_array
	mapfile file_array < $DEFAULT_FILE
	local total_seconds
	total_seconds=$(sumOneSheet file_array)
	local readable_time
	readable_time=$(makeSecondsReadable $total_seconds)

	echo "Total time for $DEFAULT_FILE = $readable_time"
}

########################################
# Read the input file into an array, sum the total time worked, echo a 
# human readable messasge.
# Globals:
#   DEFAULT_FILE
########################################
function sumOneSheet {
	local -n input_arr
	input_arr=$1
	local total_seconds
	total_seconds=0
	for (( i = 0; i < ${#input_arr[@]}; i++ )); do
		local cur_line
		cur_line=${input_arr[$i]}
		if actionIsIn "$(getAction "$cur_line")"; then
			local next_line
			next_line=${input_arr[$(( $i + 1 ))]}
			epoch_one=$(date -d "$(getDateTime "$cur_line")" +"%s")
			epoch_two=$(date -d "$(getDateTime "$next_line")" +"%s")
			time_delta=$(( $epoch_two - $epoch_one ))
			total_seconds=$(( $total_seconds + $time_delta ))
		fi
	done
	
	echo $total_seconds
}

########################################
# Determine number of hours, minutes from the given number of seconds.
# Echo a readable messasge.
# Arguments:
#   $1 - Int - total seconds
########################################
function makeSecondsReadable {
	local seconds
	seconds=$1

	hours=$(( $seconds / 3600 ))
	total_minutes=$(( $seconds / 60 ))
	minutes_remainder=$(( $total_minutes % 60 ))
	seconds_remainder=$(( $seconds % 60 ))
	readable_time="$hours hours and $minutes_remainder minutes"

	echo $readable_time
}

########################################
# Show error messasge to user when consecutive in/ out action is attempted
# Arguments:
#   Action to display (in or out)
########################################
function actionErrMessage {
	local this_action
	this_action=$1

	echo "Nothing happened, you are already clocked $this_action!"
}

########################################
# Check that the last recorded action is not the same as the current action. 
# Does allow empty string. Call the appropriate true or false command. 
# Arguments:
#   $1 - Last action from file
#   $2 - Action to check against (in or out)

########################################
function actionIsDifferent {
	local last_action
	last_action=$1
	local current_action
	current_action=$2
	if [[  $last_action != $current_action || -z $last_action ]]; then
		echo true
	else
		echo false
	fi
}
