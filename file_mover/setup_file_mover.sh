# !/bin/bash
# setup_file_mover.sh
# By Jason Krone for Curious Learning
# Date: June 18, 2015
# creates a backup directory and sets the Pi to run
# the file mover script on insertion of USB stick
#
# Acknowledgement: method for getting script to run on insertion of usb
# taken from Satish's answer on Raspberry Pi forum topic titled
# "Detecting USB Pen being plugged in"
#

source /home/pi/RaspberryPi-Server/config.sh

success=0


sudo mkdir "$backup_dir"
success=$(($success|$?))
sudo chmod 777 "$backup_dir"
success=$(($success|$?))


# create mounting point for usb 
sudo mkdir "$usb_mnt_point" 
success=$(($success|$?))
sudo chmod 777 "$usb_mnt_point" 
success=$(($success|$?))


# new rules for usb node 
sudo mv 10-usbstick.rules /etc/udev/rules.d/
success=$(($success|$?))


# store/setup script to be run on insertion of usb 
sudo mkdir /usr/lib/udev/
success=$(($success|$?))
sudo mv usbkey /usr/lib/udev/
success=$(($success|$?))
sudo chmod 777 /usr/lib/udev/usbkey
success=$(($success|$?))


# map the usb symlink to the directory /mnt/usb
sudo chmod 777 /etc/fstab
success=$(($success|$?))
sudo echo "/dev/usbkey	$usb_mnt_point	vfat	rw,noauto,user,exec	0	0" >> /etc/fstab
success=$(($success|$?))

echo "$success"
exit "$success"
