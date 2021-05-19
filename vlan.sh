#!/bin/bash

#Description: Creates a VLAN with provided user options. 

#sets flag to exit upon failure of any command
set -e

#Accept options with script

#Note- Single colon implies a required argument, and no colon
#implies no argument
while getopts 'sr:h' option
do
	case $option in
		(s)
			FLAG='s'	
			shift
			;;
		(r)
			FLAG='r'
			shift
			;;
		(h)
			FLAG='h'
			shift
			;;
		(*)
			echo "Error: Invalid Option Provided"
			exit 0
			;;
	esac
done

if [ "$FLAG" = 's' ]
then 
	if [ -z "$1" ]					#Checks if an argument was given
	then
		echo "All Active VLAN's:"
	
	elif [ "${1:0:3}" = "eth" ]		#Checks if an ethernet port was given
	then	
		echo "PORT: ${1:0:4}"
	
	elif [ "$1" -ge 0 ] &> /dev/null && [ "$1" -le 4094 ]	#Ensures a valid VLAN ID was given. Error message suppressed.
	then
		echo "VLAN ID: $1"
	else 
		echo "Invald VLAN-ID/PORT provided"
		exit 0
	fi

	exit 1
fi

if [ "$FLAG" = 'h' ]
then
	echo "VLAN Configuration Script"
	echo -e "Usage: ./vlan.sh [Flags] [PORT] [VLAN ID] [PRIORITY]\n"

	echo "[FLAGS]:"
	echo "	-h,-help		: Help"
	echo -e "				Prints help information regarding usage of the script\n"
	echo "	-s,-show		: Show all VLAN's"
	echo -e "				Prints properties of all VLAN's currently defined\n"
	echo "	-s,-show [VLAN ID]	: Show VLAN"
	echo -e "				Prints properties of specified VLAN\n"	
	echo " 	-s.-show [PORT]		: Show VLAN"
	echo -e "				Prints properties of VLAN on specified port\n"
	echo "	-r,-remove [VLAN ID]	: Remove VLAN"
	echo -e " 				Removes the specified VLAN\n"
	echo "	-r,-remove [PORT]	: Remove VLAN"
	echo -e " 				Removes the VLAN from the specified PORT\n"
	
	exit 1
fi

exit 1
