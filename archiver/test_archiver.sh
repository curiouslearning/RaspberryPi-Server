#!/bin/bash
# test_archiver.sh
# By Jason Krone for Curious Learning
# Date: August 18, 2015
# tests archiver
#

raspi_base_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )

source "$raspi_base_path"/config.sh
source "$raspi_base_path"/counter.sh
source "$raspi_base_path"/array_intersect_utils.sh


# Warning: these tests need to be run in a clean environment
# archiver_temp , data_dir, and archive_dir must be empty
function main() {

	echo "testing normal archiving functionality"

	# test_archiver normal behavior
	for (( i=1; i<"$1"; i++ )); do
		if [[ $( test_normal_operation $i ) == "false" ]]; then
			echo "norm test with $i files failed"
		fi
	done

	echo "testing cleanup of partial tar"
	
	for (( i=2; i<"$1"; i++ )); do
		for (( j=1; j<"$i"; j++ )); do 
			if [[ "$( test_partial_tar $j $i )" == "false" ]]; then
				echo "testing partial tar $j of $i files failed"
			fi
		done
	done

	echo "testing cleanup of duplicates"
	
	for (( i=1; i<"$1"; i++ )); do
		for (( j=1; j<="$i"; j++ )); do
			for (( k=0; k<"$1"; k++ )); do
				if [[ "$( test_duplication $i $j $k )" == "false" ]]; then
					echo "testing duplication with $i files to archive, $j duplicates, and $k extra files failed"
				fi
			done
		done
	done

	echo "archiver testing complete"

	exit
}


# purp: creates an archive with the given number of files and leaves
# the given number of duplicate files in the data dir as well as the
# given number of un-archived data files , returns true if successfully
# cleaned up and false otherwise   
# args: $1 - files to archive, $2 - duplicates to leave, $3 - extra dbs
#
# warning: $2 must be <= $1
function test_duplication() {
	local success="true"

	local dbs=($( create_dummy_files "$(($1+$3))" ".db" "$data_dir" ))
	local files_to_archive=("${dbs[@]:0:$1}")
	local extra_dbs=("${dbs[@]:$1:$3}") # files not to be deleted

	# create archive of files
	(cd $data_dir && sudo tar -czf $archive_dir$(date +%s).tar.gz "${files_to_archive[@]##*/}")

	# simulate partial removal process 
	for ((i=0; i<$(($1-$2)); i++)); do
		rm "${files_to_archive[i]}"
	done

	# run cleanup adn check if it is successful. TODO: relative
	"$raspi_base_path"/archiver/archiver_cleanup.sh
	success=$( arch_success files_to_archive[@] )

	if [[ "$3" -gt 0 && "$success" == "true" ]]; then
		# check that leftover files are still in the data dir
		local files_leftover=( "$data_dir"* )

		if [[ $( set_eq extra_dbs[@] files_leftover[@] file_eq ) == "true" ]]; then 
			success="true"
		else
			# problem the extra db files aren't there
			success="false"
		fi
		# remove extra db files
		sudo rm "${files_leftover[@]}"
	fi

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
	
	"$raspi_base_path"/archiver/archiver_cleanup.sh

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
	"$raspi_base_path"/archiver/archiver.sh

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


main 5 
