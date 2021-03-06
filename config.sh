# config.sh
# By Jason Krone for Curious Learning
# config file to hold paths to directories referenced in multiple files


# webserver
tablet_dir="/mnt/s3/"
data_dir="/mnt/s3/globallit-tabletdata/" 


# archiver.sh 
archive_dir="/mnt/s3/tabletdata_archive/"
archiver_temp="/mnt/s3/archiver_temp/"


# file_mover.sh
usb_mnt_point="/mnt/usb/"
file_mover_temp="/mnt/s3/file_mover_temp/"
backup_dir="/mnt/s3/tabletdata_backups/"
# name of script that will be run if on usb
tablet_update_script="/mnt/usb/globallit_tablet_updates.sh"

# space manager
min_required_space=1000000 # in kb = 1GB


# cron manager
max_failures=5
