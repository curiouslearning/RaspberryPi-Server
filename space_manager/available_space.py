# available_space.py
# By Jason Krone for Curious Learning
# Date: June 16, 2015
# prints 0 stdout if there is sufficient available space on the Pi's SD card
# otherwise, prints 1 to stdout
#

import subprocess
import sys


AVAILABLE_SPACE_INDEX = 10
# amount of available space that must be on Pi. TODO: put this in config
SPACE_NEEDED_GB = 1
KB_PER_GB = 1000000


def main():
    avail_gb = avail_space_SD()
    if avail_gb >= SPACE_NEEDED_GB:
        sys.stdout.write("0")
    else:
        sys.stdout.write("1")
        

# TODO: pull /dev/root (i.e. file path to sd card from config)
# purp: returns the amount of available space in GB on the Pi's SD card
# args: none
# rets: float  
def avail_space_SD():
    # run shell command to check space
    output = subprocess.check_output(
        "df -k /dev/root",
        shell=True,
    )

    # use system encoding to decode the output
    decoded_output = output.decode(sys.stdout.encoding)

    # extract available space field as int
    avail_kb = int(decoded_output.split()[AVAILABLE_SPACE_INDEX])
    # force avail_gb to be a float
    avail_gb = avail_kb / float(KB_PER_GB)
    return avail_gb

main()
