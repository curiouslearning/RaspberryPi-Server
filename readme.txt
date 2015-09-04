README
by Jason Krone for Curious Learning


+-----------------------------------------------------------------------------+
|                          MODULE   OVERVIEW                                  |
+-----------------------------------------------------------------------------+

archiver: 
    - archives and compresses tablet data files


webserver: 
    - communicates with tablets. Indexes data from tablets, pushes updates 
    to tablets...etc


space_manager: 
    - determines if there is sufficient free space on the Pi and 
    if there is not, deletes files to make room


file_mover:  
    - Moves archived tablet data to inserted USB stick, then 
    backs up transfered files, and deletes the backed up archives


build.sh:
	- To be run inially to install the server on the pi and create all 
	necessary directories...etc 


config.sh:
	- single point of truth for directories used in multiple scripts


logger.sh
	- contains function to log messages associated with exit status


Note: 
    - setup files in each directory are to be run at build time for the
    purpose of creating the directories/scheduling cron jobs neccessary
    for the given module


+-----------------------------------------------------------------------------+
|                         TECHNICAL   NOTES                                   |
+-----------------------------------------------------------------------------+

- Build script must be run from inside the build directory

- usb_id file in file_mover directory must be on usb inserted into
  raspberry pi if you want files to be moved to that usb

- Directories used by tests must be empty when tests are run

- Run .sh scripts with ./ if in directory or path to script NOT with sh 

- Use python3 to run python scripts. Everything should be backwards compatable,
  but the scripts have only been tested using python3

- Syntax for passing array to function 		array[@]
  Syntax for getting array param		param=("{!1}") # replace 1 with param number



        

