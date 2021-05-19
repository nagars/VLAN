#!/bin/bash

#Description: Creates a VLAN with provided user options. 

#sets flag to exit upon failure of any command
set -e

#Accept options with script

#Note- Single colon implies a required argument, and no colon
#implies no argument
while getopts 'lsr:h' option
do
	case $option in
		(l)
			FLAG='l'
			shift
			;;
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

if [ "$FLAG" = 'l' ]
then
	cat /proc/net/vlan/config
	exit 1
fi

if [ "$FLAG" = 's' ]
then 
	if [ -z "$1" ]					#Checks if an argument was given
	then
		#If no argument, display properties of all VLAN's. Ignores the config file
		echo "All Defined VLAN's:"	
		find /proc/net/vlan/ -type f ! -name 'config' -exec cat {} \;		

	elif [ "${1:0:3}" = "eth" ] && [ "${1:3:2}" -ge 0 ] &>/dev/null	#Checks if an ethernet port was given. Type Warning suppressed.
	then	
		#Finds all files associated with the port provided and displays them. Ignore the config file
		find /proc/net/vlan -type f ! -name 'config' -exec grep -w "Device: $1" {} \; -exec cat {} \;

	elif [ "$1" -ge 0 ] &>/dev/null && [ "$1" -le 4094 ]	#Checks if a VLAN ID was provided. Error suppressed due to type conflict warning 
	then
		#Finds all files associated with the VLAN ID provided and displays them. Ignore the config file.
		find /proc/net/vlan -type f ! -name 'config' -exec grep -w "VID: $1" {} \; -exec cat {} \;
	
	else							#Assumed that VLAN Name was provided 
		#Finds all files associated with the VLAN Name provided and display them
		find /proc/net/vlan -type f ! -name 'config' -exec grep -w "$1" {} \; -exec cat {} \;
	
	fi

	exit 1
fi

if [ "$FLAG" = 'r' ]
then
	if [ -z "$1" ]				#Ensures a VLAN name was provided
	then
		echo "Error: No VLAN Name Given"
		exit 0
	else
		ip link delete $1
	fi
	exit 1
fi

if [ "$FLAG" = 'h' ]
then
	echo "VLAN Configuration Script"
	echo "Brief: Implements a VLAN on the provided Ethernet Port with ID. Automatically names VLAN [PORT].[VLAN ID]"
	echo -e "Usage: ./vlan.sh [Flags] [PORT] [VLAN ID] [PRIORITY]\n"

	echo "[FLAGS]:"
	echo "	-h,-help			: Help"
	echo -e "					Prints help information regarding usage of the script\n"
	echo "	-l,list				: List all VLAN's"
	echo -e "					Lists all defined VLAN's in a table by NAME|ID|PORT\n"
	echo "	-s,-show			: Show all VLAN's"
	echo -e "					Prints information of all VLAN's\n"
	echo "	-s,-show [VLAN ID]		: Show VLAN"
	echo -e "					Prints information of VLAN's by ID\n"	
	echo " 	-s.-show [PORT]			: Show VLAN"
	echo -e "					Prints information of VLAN's by port\n"
	echo " 	-s.-show [NAME]			: Show VLAN"
	echo -e "					Prints information of VLAN by name\n"
	echo "	-r,-remove [NAME]		: Remove VLAN"
	echo -e " 					Removes the specified VLAN by Name\n"
	
	exit 1
fi

PORT=${1?Error: No Ethernet Port Provided}
ID=${2?Error: No VLAN ID Provided}
PRIORITY=${3}

# Ensures script is used to create a VLAN on Ethernet only
if [ ${PORT:0:3} != "eth" ]
then
	echo "Error: Ethernet Interface not provided"
	exit 0
fi

#Checks if priority was provided as an argument
if [ -z "$PRIORITY" ]
then	
	ip link add link $PORT name "$PORT.$ID" type vlan id $ID 	#Creates new VLAN on assigned ethernet device
	echo -e "VLAN created successfully. Details below:\n"
	ip -d link show dev "$PORT.$ID" 				#Prints details of new VLAN	
	
#else
#	if [ $PRIORITY -ge 0 ] && [ $PRIORITY -le 7 ]
#	then
#		ip link add link $PORT name "$PORT.$ID" type vlan id $ID egress-qos-map  
fi

exit 1
