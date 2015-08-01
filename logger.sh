# logger.sh
# by Jason Krone for Curious Learning
# Date: July 31, 2015
# contains function for logging description of success/failure
# of function call
#



# purp: appends message with body given in arg2 to the given file
# with the prefix success if arg1 is 0 and the prefix failure if
# arg1 is non-zero
# args: arg1 - exit_value, arg2 - body of message, arg3 - file path
# rets: nothing
function log_status() {
	if [[ $1 -eq 0 ]]; then
		echo "success $2" >> "$3" 
	else
		echo "failure $2" >> "$3"
	fi
}

