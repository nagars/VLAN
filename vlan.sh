#!/bin/bash

#Description: Creates a VLAN with provided user options. 

#sets flag to exit upon failure of any command
set -e

#Function Definitions#

#Prints usage information to terminal
function func_print_usage {

	echo "USAGE: VLAN Configuration Script"
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

function func_show_vlan {

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
}

function func_remove_vlan {
	#Ensures VLAN name was provided
	if [ -z "$1" ]
	then
		echo "Error: No VLAN Name Given"
		func_print_usage
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
}

function func_essential_arguments_valid {
	
	#Ensures first 2 arguments are given
	if [ -z "$PORT" ] && [ -z "$ID" ]
	then
		echo "Error: Essential Arguments not provided"
		func_print_usage
		exit 0
	fi

	# Ensures script is used to create a VLAN on Ethernet only
	if [ ${PORT:0:3} != "eth" ]
	then
		echo "Error: Ethernet Interface not provided"
		func_print_usage
		exit 0
	fi

	# Ensures VLAN ID is valid
	if [ $ID -lt 0 ] || [ $ID -gt 4094 ]
	then
		echo "Error: VLAN ID is not valid"
		func_print_usage
		exit 0
	fi
}
###########

#Accept options with script
#Note- Single colon implies a required argument, OPTARG will be valid.
#No colon implies no argument needed, OPTARG will be null
while getopts 'lshpr:i:e:a:' option
do
	case $option in
		(l)
			cat /proc/net/vlan/config
			shift
			exit 1
			;;
		(s)
			SHOW_VLAN='s'
			shift
			;;
		(r)
			func_remove_vlan $OPTARG
			exit 1
			;;
		(h)
			func_print_usage
			exit 1
			;;
		(p)
			MAKE_PERMANENT_FLAG='p'
			shift
			;;
		(i)
			INGRESS_PRIORITY_FLAG='i'
			shift
			;;
		(e)
			EGRESS_PRIORITY_FLAG='e'
			shift
			;;
		(a)
			IP_ADDRESS_FLAG='a'
			shift
			;;
		(*)
			echo -e "Error: Invalid Option Provided / Missing Argument\n"
			func_print_usage
			exit 0
			;;
	esac
done

#Show VLAN's currently defined
#Called after getopts since arguments with '-s' flag are optional, $OPTARGS will always be null 
#and $1 will not be valid until after the loop
if [ "$SHOW_VLAN" = 's' ]
then
	#Calls function with first argument as VLAN Name if given
	func_show_vlan $1
	exit 1
fi

#Accepts arguments
PORT=${1}
ID=${2}

#Checks if required arguments are valid
func_essential_arguments_valid


#Checks if priority was provided as an argument
#if [ -z "$PRIORITY" ]
#then	
	#If not given
	#Creates new VLAN on assigned ethernet device with default priority
#	ip link add link $PORT name "$PORT.$ID" type vlan id $IDi 		
	#Enable VLAN
#	(ip link set dev "$PORT.$ID" up)
#	echo -e "VLAN created successfully. Details below:\n"
	
	#Finds all files associated with the VLAN Name provided and display them
#	find /proc/net/vlan -type f ! -name 'config' -exec grep -w "$PORT.$ID" {} \; -exec cat {} \;

#else
#	if [ $PRIORITY -ge 0 ] && [ $PRIORITY -le 7 ]
#	then
#		ip link add link $PORT name "$PORT.$ID" type vlan id $ID egress-qos-map  
#fi

exit 1
