# !/bin/bash
# file_mover_setup.sh
# By Jason Krone for Curious Learning
# Date: June 18, 2015
# creates a backup directory and sets the Pi to run
# the file mover script on insertion of USB stick
#

# created /mnt/usb dir

# put this line into /ect/fstab to map the usb to the directory /mnt/usb, which I created
#/dev/sda1	/mnt/usb	vfat	uid=pi,gid=pi,umask=0022,sync,auto,nosuid,rw,nouser	0	0

