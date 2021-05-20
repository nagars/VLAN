#!/bin/bash

#Description: Creates a VLAN with provided user options. 

#sets flag to exit upon failure of any command
set -e

#Function Definitions#

#Prints usage information to terminal
function func_print_usage {

	echo "USAGE: VLAN Configuration Script"
	echo "Brief: Implements a VLAN on the provided Ethernet Port with ID. Automatically names VLAN [PORT].[VLAN ID]"
	echo "Default Usage: 		./vlan.sh [PORT] [VLAN ID] -optional arguments- [-n VLAN_NAME] [-i INGRESS_PRIORITY] [-e EGRESS PRIORITY] [-a IP_ADDRESS] [-p]"
	echo "			./vlan.sh [-h] [-l] [-s]"
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
	echo -e "					Assigns a gateway address to the VLAN for inter VLAN communication\n"	
	echo "	-p				: Makes the VLAN permanent"
	echo -e "					Edits the network config file to make the VLAN enabled on Boot\n"
	echo "	-n [VLAN_NAME]				: Sets a custom VLAN name"
	echo -e "					Instead of the default [PORT].[VLAN_ID] name, user provided name is used for the VLAN\n"
}

function func_show_vlan {

	#Checks if an argument was provided
	if [ -z "$1" ]			
	then
		#If no argument, display properties of all VLAN's. Ignores the config file
		echo "All Defined VLAN's:"	
		find /proc/net/vlan/ -type f ! -name 'config' -exec cat {} \; -exec echo"" \;			
	else	
		#Assumed that VLAN Name was provided 
		#Finds file associated with the VLAN Name provided and display its information
		find /proc/net/vlan -type f ! -name 'config' -exec grep -w "$1" {} \; -exec cat {} \; -exec echo "" \;
		ip -d link show "$1"
			
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
		echo "$1 Removed Successfully."
		#Confirms removal
		ip link show $1
	fi
}

function func_essential_arguments_valid {

	#Ensures that valid PORT name is provided when no option is given or when options that require a port name and vlan id are used
	if [ -z "$PORT" ] || [ "$PORT" = '-r' ] || [ "$PORT" = '-n' ] || [ "$PORT" = '-p' ] || [ "$PORT" = '-i' ] || [ "$PORT" = '-e' ] || [ "$PORT" = '-a' ]
	then
		echo "Error: Essential Arguments not provided"
		func_print_usage
		exit 0

	#Checks if the first argument is an option that does not require a valid port name and vlan id
	elif [ "$PORT" = '-l' ] || [ "$PORT" = '-s' ] || [ "$PORT" = '-h' ]
	then
		echo 0
	fi

	# Ensures script is used to create a VLAN on Ethernet only
	if [ ${PORT:0:3} != "eth" ]
	then
		echo "Error: Ethernet Interface not provided"
		func_print_usage
		exit 0
	fi

	echo 1

}

###########

#Accepts arguments
PORT=${1}
ID=${2}

#Checks if required arguments have been provided and are valid
ARG_VALID=$(func_essential_arguments_valid)

#If port name and VLAN ID are provided, shift argument index by 2
if [ "$ARG_VALID" = "1" ]
then
	shift
	shift
fi

#Accept options with script
#Note- Single colon implies a required argument, OPTARG will be valid.
#No colon implies no argument needed, OPTARG will be null
while getopts 'lshpn:r:i:e:a:' option
do
	case $option in
		(l)
			cat /proc/net/vlan/config
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
		(n)
			NAME=$OPTARG
			shift
			;;
		(i)
			INGRESS_PRIORITY_FLAG='i'
			set -f 		#Disable GLOB
			IFS=' '		#Split on space character
			INGRESS_MAP=($OPTARG)
			shift
			;;
		(e)
			EGRESS_PRIORITY_FLAG='e'
			set -f 		#Disable GLOB
			IFS=' '		#Split on space character
			EGRESS_MAP=($OPTARG)
			shift
			;;
		(a)
			IP_ADDRESS_FLAG='a'	
			set -f 		#Disable GLOB
			IP_ADDRESS=($OPTARG)
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

#If a name for the VLAN was not provided by the user, create default name
if [ -z "$NAME"	]
then
	NAME="$PORT.$ID"
fi

#Creates new VLAN
#If both egress and ingress parameters are provided
if [ "$EGRESS_PRIORITY_FLAG" = 'e' ] && [ "$INGRESS_PRIORITY_FLAG" = 'i' ]
then
	ip link add link $PORT name $NAME type vlan id $ID egress-qos-map "$EGRESS_MAP" ingress-qos-map "$INGRESS_MAP"
#If only egress parameters are provided
elif [ "$EGRESS_PRIORITY_FLAG" = 'e' ]
then
	ip link add link $PORT name $NAME type vlan id $ID egress-qos-map "$EGRESS_MAP" 
#If only ingress parameters are provided
elif [ "$INGRESS_PRIORITY_FLAG" = 'i' ]
then
	ip link add link $PORT name $NAME type vlan id $ID ingress-qos-map "$INGRESS_MAP" 
#If no ingress/egress parameters are provided
else
	ip link add link $PORT name $NAME type vlan id $ID

fi

#If an IP Address was provided, assign it to this the VLAN as a gateway address
if [ "$IP_ADDRESS_FLAG" = 'a' ]
then
	ip addr add "$IP_ADDRESS/24" brd 192.168.1.255 dev $NAME
fi

#Enable VLAN
(ip link set dev $NAME up)

echo -e "VLAN created successfully. Details below:\n"	
#Finds all files associated with the VLAN Name provided and display them
find /proc/net/vlan -type f ! -name 'config' -exec grep -w "$NAME" {} \; -exec cat {} \; -exec echo "" \;
#Show status
ip -d link show "$NAME"

#Configure network file to make the VLAN enabled on boot if required

exit 1
