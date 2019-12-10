#!/bin/bash

usage() {
	echo "Usage: ./show-attackers.sh [log-file] file
	Display the number of failed logins attemps by IP address and location
       	from a log file" 1>&2;
	exit 1;
}

#Global variables
MAX='10' 
# Make sure a file was supplied as an argument.
if [[ $# -eq 0 ]]
then
        echo "Please supply a file as an argument."
        usage
        exit 1
fi

file "{$1}" >> /dev/null
if [[ $? -ne 0 ]]
then
	echo "Cannot open log file: $1"
        exit 1
fi
# Display the CSV header.
echo "Intentos          IP          Localizacion"
#Declare Array
declare -A array
#Parse file into variable
fichero=$(cat "$1" | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | sort | uniq -c) 
#Internal Field Separator spliting only in \n
IFS=$'\n'
#Populate the array
for linia in $fichero
do
	TRY=$(echo "$linia" | awk '{print $2}')
        IP=$(echo "$linia" | awk '{print $1}')
	array["$IP"]="$TRY"
done
#Main function
for i in "${!array[@]}"
do
        # If the number of failed attempts is greater than the limit, display count, IP, and location
	if [[ "$i" -gt "$MAX" ]]
        then
                location=$(geoiplookup "${array[$i]}" | cut -d ' ' -f4,5)
                echo "$i          ${array[$i]}          $location"
        fi
done | sort -nr -k1
