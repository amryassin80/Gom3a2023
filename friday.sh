#!/bin/bash
# This script will check the local prayers DB file for daily prayers time,
# and add the commands to crontab. The commands will use VLC to play the
# Azan files on prayers time.
#
# Script created by "Amr Amin" on 09-Apr-2023
#
# Usage: ./friday.sh
#
# Don't forget to run "chmod +x friday.sh" to allow the file execution,
# and edit this myfolder="/home/pi/Documents" with the path were you will
# put the script in. Run the script once and it will add itself to crontab
# for continues execution.
# ------------------------------------------------------------------------------

#Location
city=Dublin

# Location of azan files and script, edit and put your script and file location
myfolder="/home/gom3a/Documents/Gom3a2023"

# Temp file used to prepare the commands which will be added to crontab
myfile="$myfolder/prepcron"

# Get todays date for db year
year=$(date +%Y)
db=$city$year.db

# Location of prayers timetable file
dbloc="$myfolder/PrayerTimetable/$db"

# Script location to be added in the commands
scriptloc="$myfolder/friday.sh"

# Azan files
azanfajr="$myfolder/azanfajr.mp3"
azangen="$myfolder/azangen.mp3"

# Get todays date and then use it to get today's prayers time
today=$(date +%d-%b-%Y)
prayers=$(grep -a $today $dbloc)

# Pull timetables from Git
git -C $myfolder/PrayerTimetable/ pull

# Clean the results to spearate each prayer time in a variable
IFS=','
read day fajr sunrise dhur asr maghrib isha <<<$prayers

# The commands that will ensure the script loop of execution through crontab
echo "10 00 * * * /bin/bash $scriptloc" > $myfile
echo "00 03 * * * /bin/bash $scriptloc" >> $myfile

# Git refresh
echo "50 23 * * * git -C $myfolder/PrayerTimetable/ pull" >> $myfile

# Separate the hour and minutes for each prayer and prepare/add commands to the temp file
IFS=':'
read hour minute <<<$fajr
echo "$minute $hour * * * vlc -I dummy $azanfajr vlc://quit" >> $myfile
read hour minute <<<$dhur
echo "$minute $hour * * * vlc -I dummy $azangen vlc://quit" >> $myfile
read hour minute <<<$asr
echo "$minute $hour * * * vlc -I dummy $azangen vlc://quit" >> $myfile
read hour minute <<<$maghrib
echo "$minute $hour * * * vlc -I dummy $azangen vlc://quit" >> $myfile
read hour minute <<<$isha
echo "$minute $hour * * * vlc -I dummy $azangen vlc://quit" >> $myfile

# Clear the previous crontab entries
crontab -r

# Add the new entries with today prayers time
crontab $myfile
