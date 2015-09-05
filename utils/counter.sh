# counter.sh
# By Jason Krone for Curious Learning 
# Date: August 14, 2015
# counts the number of files in given dir
#


# purp: ouputs the number of files in the given directory
# args: path to the directory
function num_files_in_dir() {
	local num_files=$( ls -c "$1" | wc -l )
	echo "$num_files"
}


