#!/bin/bash
# test_archiver.sh
# By Jason Krone for Curious Learning
# Date: August 18, 2015
# tests archiver
#

dummy_file="/home/pi/RaspberryPi-Server/archiver/dummy_file"
source /home/pi/RaspberryPi-Server/config.sh
source /home/pi/RaspberryPi-Server/counter.sh
source /home/pi/RaspberryPi-Server/array_intersect_utils.sh


function main() {
	# test_archiver
	# for (( i=1; i<"$1"; i++ )); do
	#	echo "norm test $i success : $( test_normal_operation $i )"
	# done


	# test archiver cleanup (i.e. failure modes) 
	# for (( i=2; i<"$1"; i++ )); do
	#	for (( j=1; j<"$i"; j++ )); do 
	#		echo "partial tar $j of $i success: $( test_partial_tar $j $i )"
	#	done
	# done

	
	# failure in the deletion process, there are files in archive and data base
	# check that they are deleted by cleanup 
	for (( i=1; i<"$1"; i++ )); do
		test_duplication "$i"
	done
}


# TODO: Test that it only removes duplicates!

# purp: archives the given number of files and leaves the given
# number of duplicate files in the data dir, then runs cleanup script
# returning true if cleanup was successful and false otherwise
# args: $1 - files to archive, $2 - duplicates to leave
function test_duplication() {
	local success="true"
	local dbs=($( create_dummy_files $1 ".db" "$data_dir" ))

	# create archive of files
	(cd $data_dir && sudo tar -czf $archive_dir$(date +%s).tar.gz "${files_to_archive[@]##*/}")

	# run cleanup script TODO: use relative path here
	/home/pi/RaspberryPi-Server/archiver/archiver_cleanup.sh

	# check success
	success=$( arch_success dbs[@] )

	# remove archive we created
	sudo rm "$archive_dir"$( ls -t "$archive_dir" | head -1 )	
	
	echo "$success"
}


# purp: creates the given number of .db files in the data dir
# and tars the given number of those files then runs cleanup and 
# outputs true if it was successful and false otherwise
# args: $1 - files to archive, $2 -  files to create
# 
# warning: $1 must be <= $2
#
function test_partial_tar() {
	local success="true"

	local dbs=($( create_dummy_files $2 ".db" "$data_dir" ))

	# take a subset of the .dbs to put in archive
	files_to_archive=("${dbs[@]:0:$1}")
	
	# create tar
	(cd $data_dir && sudo tar -czf $archiver_temp$(date +%s).tar.gz "${files_to_archive[@]##*/}")
	
	# run cleanup script TODO: use relative path here
	/home/pi/RaspberryPi-Server/archiver/archiver_cleanup.sh

	# check that it worked
	success=$( arch_success dbs[@] )

	# remove archive we created
	sudo rm "$archive_dir"$( ls -t "$archive_dir" | head -1 )	
	
	echo "$success"
}


# purp: removes the most recent archive
# args: none
function remove_newest_archive() {
	sudo rm "$archive_dir"$( ls -t "$archive_dir" | head -1 )	
}


# purps: creates the given number of .db files and outputs true if 
# they are properly archived and false otherwise
function test_normal_operation() {
	local success="true"

	# create .db files
	local dbs=($( create_dummy_files $1 ".db" "$data_dir" ))
	
	# create archives
	/home/pi/RaspberryPi-Server/archiver/archiver.sh

	# check that archiver was successful
	success=$( arch_success dbs[@] )

	# remove archive created by test
	remove_newest_archive
	
	echo "$success"
}


# purp: outputs "true" if the given files were successfully archived
# and "false" otherwise
# args: array of files to check for in archive
function arch_success() {
	local success="true"
	local files=("${!1}")

	# check that there is nothing in temp dir
	if [[ $( num_files_in_dir "$archiver_temp" ) -ne 0 ]]; then
		echo "there are files in the temp dir!"
		success="false"
	fi

	# get most recent archive 
	local newest_tar=$( ls -t "$archive_dir" | head -1 )	

	# get array of files in most recent tar
	local tar_files=$( tar -tf "$archive_dir"$newest_tar )

	if [[ $( set_eq tar_files[@] files[@] file_eq ) == "false" ]]; then
		success="false"	
	fi

	# get array of files in data dir
	local data_files=( "$data_dir"* )

	# get intersection 
	local duplicates=($( intersection data_files[@] files[@] file_eq ))

	# check that there is no intersection
	if [[ "${#duplicates[@]}" -ne 0 ]]; then
		echo "there are duplicates!"
		echo "duplicates : ${#duplicates[@]}"
		success="false"
	fi

	echo "$success"	
}


# purp: outputs true if the two given arrays are equal and false otherwise
# args: $1 - array1, $2 - array2, $3 - equality function
function set_eq() {
	equal="true"
	local arr1=("${!1}")
	local arr2=("${!2}")

	# check that they are the same length
	if [[ "${#arr1[@]}" -ne "${#arr2[@]}" ]]; then
		echo "they have different lengths"
		equal="false"
	fi

	# check that every element in arr1 is in arr2
	for elem1 in "${arr1[@]}"; do
		if [[ $( is_in_list "$elem1" "arr2[@]" "$3" ) == "false" ]]; then
			equal="false"	
		fi
	done
		
	echo "$equal"
}


# purp: outputs ture if the given element is in the given list using 
# the given equality function and false otherwise
# args: $1 - element, $2 - list, $3 - equality function
function is_in_list() {
	in_list="false"
	local array=("${!2}")

	for item in "${array[@]}"; do
		if [[ $( "$3" "$item" "$1" ) == "true" ]]; then
			in_list="true"	
			break
		fi
	done 

	echo "$in_list"
}


# purp: creates the given number of dummy files
# with the given extension in the given folder
# args: $1 - the number of dummy files to create, $2 - file extension
# 	$3 - dummy folder
# rets: outputs an array of paths of the files created
function create_dummy_files() {
	local files_created=()
	for (( i=0; i<"$1"; i++ )); do
		cp "$dummy_file" $3$i$2
		files_created+=($3$i$2)
		echo "$i" >> $3$i$2
	done
	echo "${files_created[@]}"
}


main 2 
