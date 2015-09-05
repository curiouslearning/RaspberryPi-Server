#!/bin/bash
# test_space_manager.sh
# By Jason Krone for curious learning
# Date: June 16, 2015
# Tests the space manger
#

raspi_base_path=$( cat /usr/RaspberryPi-Server/base_path.txt )
source $raspi_base_path/config.sh
source $raspi_base_path/array_intersect_utils.sh


removed_log="$raspi_base_path/space_manager/deleted_files.txt"
dummy_file_size=4 # in kb
avail_space_diff="false"


# warning for this test to work properly the directories used
# must be empty
function main() {
	local passed="true"
	local t=0

  	for (( i=0; i<$1; i++ )); do
		for (( j=0; j<$1; j++ )); do
			for (( k=0; k<$1; k++ )); do
				for (( d=0; d<=$(($i+$j+$k)); d++)); do
					passed=$( test_space_manager $i $j $k $d )
					t=$(( $t + 1 )) 

					if [[ "$passed" != "true" ]]; then
						echo "FAILED with $i dbs, $j archives, $k backups , $d files to delete"
						echo "passed: $passed"
					fi

					if [[ $(( $t % 100 )) -eq  0 ]]; then
						echo "$t tests run so far"	
					fi
				done
			done
		done
	done

	echo "testing complete"
}



# purp: test the normal functionality of the space manger 
# creating the given number of input filesa;sdjkfas
# args: $1 - dbs, $2 - archives, $3 - backups, $4 - num files to delete
# $4 must be <= $1 + $2 + $3
function test_space_manager() {
	# get space	
	local success="never_set"
		
	# the order of the following lines matters
	local files=()
	files+=($( create_dummy_files "$3" ".tar.gz" "$backup_dir" ))
	files+=($( create_dummy_files "$2" ".tar.gz" "$archive_dir" ))
	files+=($( create_dummy_files "$1" ".db" "$data_dir" ))
	
	# get space after files are created	
	local space_avail=$( python3 $raspi_base_path/space_manager/available_space.py )

	local files_to_delete=("${files[@]:0:$4}")
	local files_to_keep=("${files[@]:$4}")

	local space_needed=$(( $space_avail + $(( $dummy_file_size * ${#files_to_delete[@]} ))))
	local initial_space=$( $raspi_base_path/space_manager/space_manager.sh "$space_needed" )
	
	if [[ $initial_space -eq $space_avail ]]; then
		# no erros
		success=$( space_manager_success files_to_keep[@] files_to_delete[@] )

		# cleanup i.e. remove files kept
		if [[ "${#files_to_keep[@]}" -gt 0 ]]; then
			 sudo rm "${files_to_keep[@]}"
		fi
	else
		
		success=$( error_check "$initial_space" "$space_needed" files[@] )
		avail_space_diff="true"
	fi
	
	echo "$success"
}

# purp: returns true if the space manager corretly handled the space
# discrepency and false otherwise
# args: $1 - inital space available, $2 - space needed, $3 - files created
function error_check() {
	local success="not_set"
	local net_space=$(( $2 - $1 ))
	local files=("${!3}")
	local num_files="${#files[@]}"

	# this gets rid of negative error
	if [[ $net_space -lt 0 ]]; then
		net_space=0
	fi
	
	# TODO:	dont hardcode size of file
	local num_files_to_delete=$( python -c "from math import ceil; print int(ceil($net_space/4.0))" )
	
	# the most files that can be deleted is the amount created
	if [[ $num_files_to_delete -gt $num_files ]]; then
		num_files_to_delete=$num_files	
	fi

	local files_to_delete=("${files[@]:0:$num_files_to_delete}")
	local files_to_keep=("${files[@]:$num_files_to_delete}")

	success=$( space_manager_success files_to_keep[@] files_to_delete[@] )

	if [[ "${#files_to_keep[@]}" -gt 0 ]]; then
		 sudo rm "${files_to_keep[@]}"
	fi

	echo "$success"
}


function space_manager_success() {
	local success="true"
	local kept_files=("${!1}")
	local deleted_files=("${!2}")

	# check that none of the kept files were deleted
	for f in "${kept_files[@]}"; do
		# if file does not exist then there was a problem
		if [[ ! -e "$f" ]]; then
			echo "$f which shouldn't have been deleted isn't there"
			success="false"
			break
		fi
	done

	# check that all the files that should have been deleted were
	# get array of files in the order they were deleted by sm
	local deletion_log=($( open_file "$removed_log" )) # TODO create tag
	echo "" > "$removed_log"

	local len="${#deletion_log[@]}"

	if [[ $len -ne "${#deleted_files[@]}" ]]; then
		echo "log has $len elements but to_delete has ${#deleted_files[@]}"
		success="false"
	fi

	for ((i=0; i<"$len"; i++ )); do
		if [[ "${deleted_files[i]}" != "${deletion_log[i]}" ]]; then
			echo "deleted files don't match deletion log"
			success="false"
			break
		fi
	done 

	echo "$success"
}


# purp: outputs an array containing the lines in the given file
# args: $1 - file path
function open_file() {
	local i=0
	local array=()

	while read line; do
		array[i]=$line
		i=$(($i + 1))
	done < $1

	echo "${array[@]}"
} 


main 4
