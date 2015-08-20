# array_intersect_utils.sh
# By Jason Krone for Curious Learning
# Date: August 14, 2015
# contains utility functions for arrays
#


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
	array_return=("${intersect[@]}")
	echo "${intersect[@]}"
}
