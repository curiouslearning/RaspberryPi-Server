#!/bin/bash
# test_file_mover.sh
# By Jason Krone for Curious Learning
# Date: August 18, 2015
# tests file_mover
#

# todo change all this to relative imports
source /home/pi/RaspberryPi-Server/config.sh
source /home/pi/RaspberryPi-Server/counter.sh
source /home/pi/RaspberryPi-Server/array_intersect_utils.sh


# Warning: directories used must be empty and
# usb must be mounted for these tests to work
function main() {
	
	#echo "testing normal functiionality"
	# test normal oporation
	#for (( i=1; i<"$1"; i++ )); do
	#	echo "norm test: $( test_mover_norm  $i )"
	#done

	# test partial copy to temp
	#for (( i=1; i<"$1"; i++ )); do
	#	for (( j=1; j<"$i"; j++ )); do 
	#		echo "partial temp: $( test_partial_copy_temp $i $j )"
	#	done
	#done


	echo "testing partial copy usb"
	# test partial copy from temp to usb
	# for (( i=1; i<"$1"; i++ )); do
	#	for (( j=1; j<"$i"; j++ )); do 
	#		echo "partial usb: $( test_partial_copy_usb $i $j )"
	#	done
	# done

	# test failure to backup moved files from temp
	echo "testing partial backup"
	for (( i=1; i<"$1"; i++ )); do
		for (( j=1; j<"$i"; j++ )); do 
			echo "called with $i -files and $j backups"
			echo "partial backup: $( test_partial_backup $i $j )"
		done
	done


	# failure to remove backedup files from archive

}



function test_duplicates() {
	local archives=($( create_dummy_files "$1" ".tar.gz" "$archive_dir" ))
	sudo cp "${archives[@]}" $file_mover_temp
	sudo cp "${archives[@]}" $usb_mnt_point
	sudo mv "${archives[@]}" $backup_dir


	# here is where we see how many duplicates we have
	sudo rm "${archive[@]:0:$2}"

	# probably want some extra newly archived files that are supposed to be
	# removed coming in as well



	# run cleanup TODO: math path rfelative
	/home/pi/RaspberryPi-Server/file_mover/file_mover_cleanup.sh

	# check if it was successful
	success=$( file_mover_success archives[@] )

	echo "names: ${names[@]}"
	remove_test_files names[@]

	echo "$success"


}


# TODO: think through failure with order of cleanup
# purp: creates a partial backup of the given number of files
# args: $1 - archives to make , $2 - archives to backup 
#
# warning: $2 should be < $1
function test_partial_backup() {
	# create files to move
	local archives=($( create_dummy_files "$1" ".tar.gz" "$archive_dir" ))
	sudo cp "${archives[@]}" $file_mover_temp
	sudo cp "${archives[@]}" $usb_mnt_point
	sudo mv "${archives[@]:0:$2}" $backup_dir

	# run cleanup TODO: math path rfelative
	/home/pi/RaspberryPi-Server/file_mover/file_mover_cleanup.sh

	# check if it was successful
	success=$( file_mover_success archives[@] )

	echo "names: ${names[@]}"
	remove_test_files names[@]

	echo "$success"
}


# purp: creates a partial coppy of the given number of files into the usb dir
# args: $1 - archives to make , $2 - copies to put in usb 
#
# warning: $2 should be <= $1
function test_partial_copy_usb() {
	local success=""
	
	# create files to move
	local archives=($( create_dummy_files "$1" ".tar.gz" "$archive_dir" ))
	sudo cp "${archives[@]}" $file_mover_temp
	sudo cp "${archives[@]:0:$2}" $usb_mnt_point

	# run cleanup TODO: math path rfelative
	/home/pi/RaspberryPi-Server/file_mover/file_mover_cleanup.sh

	# check if it was successful
	success=$( file_mover_success archives[@] )

	local names=("${archives[@]##*/}")
	remove_test_files names[@]

	echo "$success"
}



# purp: creates the given number of archives and copies the
# given number of those archives to the temp folder then runs
# file_mover_cleanup and return true if it was successful and false otherwise 
# args: $1 - archives to make , $2 - copies to put in temp
#
# warning: $2 should be <= $1
function test_partial_copy_temp() {
	local success=""
	
	# create files to move
	local archives=($( create_dummy_files "$1" ".tar.gz" "$archive_dir" ))
	sudo cp "${archives[@]}" $file_mover_temp

	# run cleanup TODO: math path rfelative
	/home/pi/RaspberryPi-Server/file_mover/file_mover_cleanup.sh

	# check if it was successful
	success=$( file_mover_success archives[@] )

	local names=("${archives[@]##*/}")
	remove_test_files names[@]

	echo "$success"
}


# purp: removes the given test files from the usb and from backups
# args: $1 - files to remove 
function remove_test_files() {
	local files=("${!1}")

	# removed moved dummy archives from usb and from backups
	for f in "${files[@]}"; do
		sudo rm "$backup_dir"$f
		sudo rm "$usb_mnt_point"$f
	done
}

# purp: creates the given number of archives then runs file_mover.sh
# and outputs true if it was successful and false otherwise
function test_mover_norm() {
	local success=""

	# create files to move
	local archives=($( create_dummy_files "$1" ".tar.gz" "$archive_dir" ))

	# run file mover TODO: 	make path relative
	/home/pi/RaspberryPi-Server/file_mover/file_mover.sh

	success=$( file_mover_success archives[@] )

	local names=("${archives[@]##*/}")
	remove_test_files names[@]
		
	echo "$success"
}


# purp: outputs true if the file mover was successful and false otherwise
# args: $1 - list of files that were moved
function file_mover_success() {
	local success="true"
	local moved_files=("${!1}")
	local backups=($( dir_contents $backup_dir ))
	local archives=($( dir_contents $archive_dir ))
	local duplicates=($( intersection backups[@] archives[@] file_eq ))
	
	# check that moved files are in usb dir
	if [[ $( dir_contains moved_files[@] "$usb_mnt_point" file_eq ) == "false" ]]; then
		echo "moved files arent there"
		success="false"
	fi
		
	# temp not empty -> problem
	if [[ $( num_files_in_dir "$file_mover_temp" ) -gt 0 ]]; then 
		echo "temp is not empty"
		success="false"	
	fi

	# - files in backup dir
	if [[ $( dir_contains moved_files[@] $backup_dir file_eq ) == "false" ]]; then
		echo "files not in backup dir"
		success="false"
	fi	
	
	# - backedup files removed from archive
	if [[ "${#duplicates[@]}" -gt 0 ]]; then
		echo "duplicates in archive"
		success="false"	
	fi

	echo "$success"
}



main 3
