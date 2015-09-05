# available_space.py
# By Jason Krone for Curious Learning
# Date: June 16, 2015
# outputs the about of available space in kb on pi
#

import subprocess
import sys
import time

AVAILABLE_SPACE_INDEX = 10

def main():
	# pause for deletions
	time.sleep(.05)
	space = avail_space()	
	print(space)


# purp: returns the amount of available space in GB on the Pi's SD card
# args: none
# rets: float  
def avail_space():
    # run shell command to check space
    output = subprocess.check_output(
        "df -k /dev/root",
        shell=True,
    )

    # use system encoding to decode the output
    decoded_output = output.decode(sys.stdout.encoding)

    # extract available space field as int
    avail_kb = int(decoded_output.split()[AVAILABLE_SPACE_INDEX])
    return avail_kb


main()
