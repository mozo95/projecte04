#!/bin/bash

usage() {
	echo "Usage: ./disable-local-user.sh [-dra] USER [USERN]
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
# Loop through the list of failed attempts and corresponding IP addresses.
cat "$1" | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | sort | uniq -c | sort -nr | while read TRYS IP
do
# If the number of failed attempts is greater than the limit, display count, IP, and location.
	if [[ $TRYS -gt "$MAX" ]]
	then
		location=$(geoiplookup "$IP" | cut -d ' ' -f4,5) 
		echo "$TRYS          $IP          $location"
	fi
done
