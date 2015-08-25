# array_intersect_utils.sh
# By Jason Krone for Curious Learning
# Date: August 14, 2015
# contains utility functions for arrays
#


dummy_file="/home/pi/RaspberryPi-Server/archiver/dummy_file"
source /home/pi/RaspberryPi-Server/counter.sh


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


# purp: outputs the contents of the given directory
# args: $1 - path to directory
function dir_contents() {
	local contents=()

	if [[ $( num_files_in_dir "$1" ) -gt 0 ]]; then
		contents=( "$1"* )	
	fi
		
	echo "${contents[@]}"
}


# purp: outputs true if the given files are contained in the given directory
# args: $1 - list of files, $2 - path to directory, $3 - equality function
function dir_contains() {
	local has_files="true"
	local files=("${!1}")
	local dir_files=($( dir_contents "$2" ))
	
	for f in "${files[@]}"; do
		if [[ $( is_in_list "$f" dir_files[@] "$3" ) == "false" ]]; then
			has_files="false"				
		fi
	done

	echo "$has_files"
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
	local in_list="false"
	local array=("${!2}")

	for item in "${array[@]}"; do
		if [[ $( "$3" "$item" "$1" ) == "true" ]]; then
			in_list="true"	
			break
		fi
	done 

	echo "$in_list"
}


# purp: outputs true if the given file names excluding prefixes
# are equal and false otherwise
# args: two file paths
function file_eq() {
	# pull prefixes off file names
	local file1=${1##*/}
	local file2=${2##*/}

	if [[ "$file1" == "$file2" ]]; then
		echo "true"	
	else
		echo "false"
	fi		
}


# purp: outputs the intersection of the two lists using elements from $1, using the 
# given function to determine equality
# args: $1 - list one, $2 - list two, $3 - equality function
function intersection() {
	local arr1=("${!1}")
	local arr2=("${!2}")
	local intersect=() # empty list

	for i in ${arr1[@]}; do
		for j in ${arr2[@]}; do
			if [[ $( $3 $i $j ) == "true" ]]; then
				# append item from arr1
				intersect+=($i)
			fi
		done
	done	
	echo "${intersect[@]}"
}

