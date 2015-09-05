# logger.sh
# by Jason Krone for Curious Learning
# Date: July 31, 2015
# contains function for logging description of success/failure
# of function call
#

# grab path to RaspberryPi-Server dir
raspi_base_path=$( cat /usr/RaspberryPi-Server/base_path.txt )


# purp: appends message with the given body to the given file
# with the prefix success if arg1 is 0 and the prefix failure if
# arg1 is non-zero
# args: arg1 - exit_value, arg2 - body of message, arg3 - file path from base path
# rets: nothing
function log_status() {
	#echo "writing to $raspi_base_path/$3"
	if [[ $1 -eq 0 ]]; then
		echo "success $2" >> "$raspi_base_path/$3" 
	else
		echo "failure $2" >> "$raspi_base_path/$3"
	fi
}

