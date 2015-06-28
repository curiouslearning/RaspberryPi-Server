README

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


Note: 
    - setup files in each directory are to be run at build time for the
    purpose of creating the directories/scheduling cron jobs neccessary
    for the given module


+-----------------------------------------------------------------------------+
|                         TECHNICAL   NOTES                                   |
+-----------------------------------------------------------------------------+

- Run .sh scripts with ./ if in directory or path to script NOT with sh 

- Use python3 to run python scripts. Everything should be backwards compatable,
but the scripts have only been tested using python3
        

