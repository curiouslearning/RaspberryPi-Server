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


sudo mkdir "$backup_dir"
sudo chmod 777 "$backup_dir"


# create mounting point for usb 
sudo mkdir "$usb_mnt_dir" 
sudo chmod 777 "$usb_mnt_dir" 


# new rules for usb node 
sudo mv 10-usbstick.rules /etc/udev/rules.d/


# store/setup script to be run on insertion of usb 
sudo mkdir /usr/lib/udev/
sudo mv usbkey /usr/lib/udev/
sudo chmod 777 /usr/lib/udev/usbkey


# map the usb symlink to the directory /mnt/usb
sudo chmod 777 /etc/fstab
sudo echo "/dev/usbkey	$usb_mnt_dir	vfat	rw,noauto,user,exec	0	0" >> /etc/fstab

exit
