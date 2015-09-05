#!/bin/bash
# test_file_mover.sh
# By Jason Krone for Curious Learning
# Date: August 18, 2015
# tests file_mover
#

raspi_base_path=$( cat /usr/RaspberryPi-Server/base_path.txt )
source $raspi_base_path/config.sh
source $raspi_base_path/counter.sh
source $raspi_base_path/array_intersect_utils.sh


# Warning: directories used must be empty and
# usb must be mounted for these tests to work
function main() {
	echo "testing normal functiionality"
	# test normal oporation
	for (( i=1; i<"$1"; i++ )); do
		if [[ $( test_mover_norm  $i ) != "true" ]]; then
			echo "norm test: $i failed"
		fi
	done

	echo "testing partial copoy to temp"
	# test partial copy to temp
	for (( i=1; i<"$1"; i++ )); do
		for (( j=1; j<"$i"; j++ )); do 
			if [[ $( test_partial_copy_temp $i $j ) != "true" ]]; then
				echo "partial temp: $i $j failed"
			fi
		done
	done

	echo "testing partial copy usb"
	# test partial copy from temp to usb
	for (( i=1; i<"$1"; i++ )); do
		for (( j=1; j<"$i"; j++ )); do 
			if [[ $( test_partial_copy_usb $i $j ) != "true" ]]; then
				echo "partial usb $i $j failed"
			fi
		done
	done


	# test failure to backup moved files from temp
	echo "testing partial backup"
	for (( i=1; i<"$1"; i++ )); do
		for (( j=1; j<"$i"; j++ )); do 
			if [[ $( test_partial_backup $i $j ) != "true" ]]; then
				echo "partial backup: $i $j failed"
			fi
		done
	done

	echo "testing duplicates"
	# failure to remove backedup files from archive
	for (( i=1; i<"$1"; i++ )); do
		for (( j=1; j<="$i"; j++ )); do
			for (( k=0; k<"$1"; k++ )); do
				if [[ $( test_duplicates $i $j $k ) != "true" ]]; then
					echo "duplicates $i $j $k failed"
				fi
			done
		done
	done

	exit
}


# purp: creates the given number of duplicate backedup archives out of the
# given number of archive files, leaving the given number of non-duplicate archives
# args: $1 - archives to move, $2 - duplicates to create, $3 - non-duplicates
function test_duplicates() {
	local success=""
	
	# create archives + non-duplicates
	local archives=($( create_dummy_files "(($1+$3))" ".tar.gz" "$archive_dir" ))
	local arcs_to_move=("${archives[@]:0:$1}")
	local non_dup_arcs=("${archives[@]:$1:$3}")

	# put duplicates on usb and in backup
	sudo cp "${arcs_to_move[@]}" $usb_mnt_point
	sudo cp "${arcs_to_move[@]}" $backup_dir

	# simulate partial removal process
	for ((i=0; i<$(($1-$2)); i++)); do
		rm "${arcs_to_move[i]}"
	done
	
	$raspi_base_path/file_mover/file_mover_cleanup.sh
	
	success=$( file_mover_success arcs_to_move[@] )
	
	# check that non-duplicates are still there
	# TODO: can use the directory contains method for this
	if [[ "$3" -gt 0 && "$success" == "true" ]]; then
		local arcs_leftover=( "$archive_dir"* )	
		
		if [[ $( set_eq non_dup_arcs[@] arcs_leftover[@] file_eq ) == "true" ]]; then
			success="true"
		else
			echo "files are not still there"
			success="false"
		fi
		# remove leftover files
		sudo rm "${arcs_leftover[@]}"
	fi
	
	# remove test files from backups and archive
	# TODO: might want to change method more flexible 
	local names=("${arcs_to_move[@]##*/}")
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

	$raspi_base_path/file_mover/file_mover_cleanup.sh

	# check if it was successful
	success=$( file_mover_success archives[@] )

	local names=("${archives[@]##*/}")
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

	$raspi_base_path/file_mover/file_mover_cleanup.sh

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

	# run cleanup
	$raspi_base_path/file_mover/file_mover_cleanup.sh

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

	$raspi_base_path/file_mover/file_mover.sh

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



main 5
