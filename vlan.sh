#!/bin/bash

#Description: Creates a VLAN with provided user options. 

#sets flag to exit upon failure of any command
set -e

#Function Definitions#

#Prints usage information to terminal
function print_usage {

	echo "VLAN Configuration Script"
	echo "Brief: Implements a VLAN on the provided Ethernet Port with ID. Automatically names VLAN [PORT].[VLAN ID]"
	echo "Default Usage: 		./vlan.sh [PORT] [VLAN ID] -optional arguments- [-i INGRESS_PRIORITY] [-e EGRESS PRIORITY] [-a IP_ADDRESS] [-p]"
	echo "			./vlan.sh [-hls]"
	echo "			./vlan.sh [-s VLAN_NAME]"
	echo "			./vlan.sh [-r VLAN_NAME]"

	echo "[Optional Flags]:"
	echo "	-h				: Help"
	echo -e "					Prints help information regarding usage of the script\n"
	echo "	-l				: List all VLAN's"
	echo -e "					Lists all defined VLAN's in a table by NAME|ID|PORT\n"
	echo "	-s				: Show all VLAN's"
	echo -e "					Prints information of all VLAN's\n"
	echo "	-s [VLAN_NAME]			: Show VLAN"
	echo -e "					Prints information of specified VLAN by name\n"
	echo "	-r [VLAN_NAME]			: Remove VLAN"
	echo -e " 					Removes the specified VLAN by Name\n"
	echo "	-i [INGRESS_PRIORITY]		: Sets ingress priority"
	echo -e "					Assigns the VLAN header prio field to the linux internal packet priority for incoming frames\n"	
	echo "	-e [EGRESS_PRIORITY]		: Sets egress priority"
	echo -e "					Assigns the VLAN header prio field to the linux internal packet priority for outgoing frames\n"	
	echo "	-a [IP_ADDRESS]			: Assigns an IP Address"
	echo -e "					Assigns an IP address to the VLAN for inter VLAN communication\n"	
	echo "	-p				: Makes the VLAN permanent"
	echo -e "					Edits the network config file to make the VLAN enabled on Boot\n"
}

###########

#Accept options with script
#Note- Single colon implies a required argument, and no colon
#implies no argument needed
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
		(p)
			FLAG='p'

		(*)
			echo "Error: Invalid Option Provided"
			print_usage
			exit 0
			;;
	esac
done

#Lists all VLAN's
if [ "$FLAG" = 'l' ]
then
	cat /proc/net/vlan/config
	exit 1
fi

#Prints VLAN information
if [ "$FLAG" = 's' ]
then 
	#Checks if an argument was provided
	if [ -z "$1" ]			
	then
		#If no argument, display properties of all VLAN's. Ignores the config file
		echo "All Defined VLAN's:"	
		find /proc/net/vlan/ -type f ! -name 'config' -exec cat {} \;			
	else	
		#Assumed that VLAN Name was provided 
		#Finds file associated with the VLAN Name provided and display its information
		find /proc/net/vlan -type f ! -name 'config' -exec grep -w "$1" {} \; -exec cat {} \;
	
	fi

	exit 1
fi

#Removes a VLAN
if [ "$FLAG" = 'r' ]
then
	#Ensures VLAN name was provided
	if [ -z "$1" ]
	then
		echo "Error: No VLAN Name Given"
		print_usage
		exit 0
	else
		#Disable VLAN
		(ip link set dev $1 down)
		#Delete VLAN
		ip link delete $1
		echo "$1 removed successfully."
		#Confirms removal
		ip link show $1
	fi
	exit 1
fi

#Prints help information
if [ "$FLAG" = 'h' ]
then
	print_usage				
	exit 1
fi

#Accepts arguments
PORT=${1}
ID=${2}
PRIORITY=${3}

#Ensures first 2 arguments are given
if [ -z "$PORT" ] && [ -z "$ID" ]
then
	echo "Error: Essential Arguments not provided"
	print_usage
	exit 0
fi

# Ensures script is used to create a VLAN on Ethernet only
if [ ${PORT:0:3} != "eth" ]
then
	echo "Error: Ethernet Interface not provided"
	print_usage
	exit 0
fi

#Checks if priority was provided as an argument
if [ -z "$PRIORITY" ]
then	
	#If not given
	#Creates new VLAN on assigned ethernet device with default priority
	ip link add link $PORT name "$PORT.$ID" type vlan id $IDi 		
	#Enable VLAN
	(ip link set dev "$PORT.$ID" up)
	echo -e "VLAN created successfully. Details below:\n"
	
	#Finds all files associated with the VLAN Name provided and display them
	find /proc/net/vlan -type f ! -name 'config' -exec grep -w "$PORT.$ID" {} \; -exec cat {} \;

#else
#	if [ $PRIORITY -ge 0 ] && [ $PRIORITY -le 7 ]
#	then
#		ip link add link $PORT name "$PORT.$ID" type vlan id $ID egress-qos-map  
fi

exit 1
