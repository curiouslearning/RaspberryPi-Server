#!/bin/bash
# test_space_manager.sh
# By Jason Krone for curious learning
# Date: June 16, 2015
# Tests the space manger
#

raspi_base_path=$( cat /usr/RaspberryPi-Server/base_path.txt )
source $raspi_base_path/config.sh
source $raspi_base_path/array_intersect_utils.sh

dummy_file_size=4 # in kb


# warning for this test to work properly the directories used
# must be empty
function main() {
	echo "$( test_space_manager 0 0 3 1 )"
  	for (( i=0; i<$1; i++ )); do
		for (( j=0; j<$1; j++ )); do
			for (( k=0; k<$1; k++ )); do
				for (( d=0; d<=$(($i+$j+$k)); d++)); do
					echo "run with $i dbs $j arch $k backups $d files to delete" >> "test_log.txt"
					output=$( test_space_manager $i $j $k $d )
					echo "result: $output"
					echo "output: $output             oprinted" >> "test_log.txt"
				done
			done
		done
	done

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
	local space_avail=$( python3 available_space.py )

	local files_to_delete=("${files[@]:0:$4}")
	echo "files to delete: ${files_to_delete[@]}" >> "test_log.txt"
	local files_to_keep=("${files[@]:$4}")
	echo "files to keep: ${files_to_keep[@]}" >> "test_log.txt"

	local space_needed=$(( $space_avail + $(( $dummy_file_size * ${#files_to_delete[@]} ))))
	echo "space_needed: $space_needed" >> "test_log.txt"

	local initial_space=$( $raspi_base_path/space_manager/space_manager.sh "$space_needed" )
	echo "inital space from sm: $initial_space" >> test_log.txt
	
	if [[ $initial_space -eq $space_avail ]]; then
		# no erros
		success=$( space_manager_success files_to_keep[@] files_to_delete[@] )

		# cleanup i.e. remove files kept
		if [[ "${#files_to_keep[@]}" -gt 0 ]]; then
			 sudo rm "${files_to_keep[@]}"
		fi
	else
		echo "files b4 check: ${files[@]}" >> test_log.txt
		echo "initial space b4 check: $initial_space" >> test_log.txt
		echo "space_needed b4 check: $space_needed" >> test_log.txt
		success=$( error_check "$initial_space" "$space_needed" files[@] )

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

	echo "inital space: $1" >> test_log.txt
	echo "space_needed; $2" >> test_log.txt
	echo "net_space: $net_space" >> "test_log.txt"
	echo "files: ${files[@]}" >> "test_log.txt"
	echo "num_files $num_files" >> "test_log.txt"

	# this gets rid of negative error
	if [[ $net_space -lt 0 ]]; then
		net_space=0
	fi
	
	# TODO:	dont hardcode size of file
	local num_files_to_delete=$( python -c "from math import ceil; print int(ceil($net_space/4.0))" )
	echo "error num_files_to delete: $num_files_to_delete" >> "test_log.txt"
	
	# the most files that can be deleted is the amount created
	if [[ $num_files_to_delete -gt $num_files ]]; then
		num_files_to_delete=$num_files	
	fi

	echo "error num_files_to delete2: $num_files_to_delete" >> "test_log.txt"

	local files_to_delete=("${files[@]:0:$num_files_to_delete}")
	echo "files to delete: ${files_to_delete[@]}" >> "test_log.txt"
	local files_to_keep=("${files[@]:$num_files_to_delete}")
	echo "files to keep: ${files_to_keep[@]}" >> "test_log.txt"

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
			echo "$f which shouldn't have been deleted isn't there" >> "test_log.txt"
			success="false"
			break
		fi
	done

	# check that all the files that should have been deleted were
	# get array of files in the order they were deleted by sm
	local deletion_log=($( open_file "deleted_files.txt" )) # TODO create tag
	echo "" > deleted_files.txt

	local len="${#deletion_log[@]}"

	if [[ $len -ne "${#deleted_files[@]}" ]]; then
		echo "size of the deletion log isn't the same as the files to be deleted arr" >> "test_log.txt"
		echo "deletion log has $len elements and to_delete has ${#deleted_files[@]}" >> "test_log.txt"
		success="false"
	fi

	for ((i=0; i<"$len"; i++ )); do
		if [[ "${deleted_files[i]}" != "${deletion_log[i]}" ]]; then
			echo "deleted files don't match deletion log" >> "test_log.txt"
			echo "deleted files: ${deleted_files[@]}  , deletion log: ${deletion_log[@]}"
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
