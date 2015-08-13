!/bin/bash
#### BEGIN INIT INFO
# Provides:          file_mover_cleanup.sh 
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: cleans up archived unmoved archive files
# Description: checks that the file mover moved the files it copied to usb stick
### END INIT INFO

# By Jason Krone for Curious Learning
# Date: July 31, 2015

source /home/pi/RaspberryPi-Server/config.sh


function main() {
	# duplicates in backup dir and archive dir -> removal incomplete
	backup_files=( "$backup_dir" )
	archive_files=( "$archive_dir" )
	duplicates=$( intersection "$archive_files" "$backup_files" file_eq )
	for file in $duplicates; do
		sudo rm "$file"
	done
}


# purp: returns 0 if the files not including prefixes are equal and 1 otherwise
# args: two file paths
function file_eq() {
	# pull prefixes off file names
	local file1="${$1##*/}
	local file2="${$2##*/}

	if [[ "$file1" = "$file2" ]]; then
		return 0	
	else
		return 1
	fi		
}


# purp: outputs the intersection of the two lists using elements from $1, using the 
# given function to determine equality
# args: $1 - list one, $2 - list two, $3 - equality function
function intersection() {
	local intersect=() # empty list
	for arc in $1; do
		for backup in $2; do
			if [[ $( $3 "$arc" "$backup" ) -eq 0 ]]; then
				intersect+=("$arc")
			fi
		done
	done	
	echo "$intersect"
} 


main
