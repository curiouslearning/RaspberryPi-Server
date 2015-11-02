#!/bin/bash
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

raspi_base_path=$( cat /usr/RaspberryPi-Server/base_path.txt )
source $raspi_base_path/config.sh

fm_cleanup="$raspi_base_path/file_mover/file_mover_cleanup.sh"
fm_cleanup_boot="/etc/init.d/file_mover_cleanup.sh"
usb_rules="$raspi_base_path/file_mover/10-usbstick.rules"
usb_key="$raspi_base_path/file_mover/usbkey.sh"

success=0


# dir to hold backups of tars transfered to usb
sudo mkdir "$backup_dir"
success=$(($success|$?))
sudo chmod 777 "$backup_dir"
success=$(($success|$?))


# create temp dir
sudo mkdir "$file_mover_temp"
success=$(($success|$?))
sudo chmod 777 "$file_mover_temp"
success=$(($success|$?))


# create mounting point for usb 
sudo mkdir "$usb_mnt_point" 
success=$(($success|$?))
sudo chmod 777 "$usb_mnt_point" 
success=$(($success|$?))


# new rules for usb node 
sudo mv "$usb_rules" /etc/udev/rules.d/
success=$(($success|$?))


# set script to be run on insertion of usb 
sudo mkdir /usr/lib/udev/
success=$(($success|$?))
sudo mv "$usb_key" /usr/lib/udev/
success=$(($success|$?))
sudo chmod 777 /usr/lib/udev/usbkey.sh
success=$(($success|$?))


# map the usb symlink to the directory /mnt/usb
sudo chmod 777 /etc/fstab
success=$(($success|$?))
sudo echo "/dev/usbkey	$usb_mnt_point	vfat	rw,noauto,user,exec	0	0" >> /etc/fstab
success=$(($success|$?))


# set file_mover_cleanup.sh to be run on boot
sudo cp "$fm_cleanup" "$fm_cleanup_boot" 
success=$(($success|$?))
sudo chmod 777 "$fm_cleanup_boot"
success=$(($success|$?))
sudo update-rc.d file_mover_cleanup.sh defaults
success=$(($success|$?))


exit "$success"
