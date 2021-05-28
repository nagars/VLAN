# VLAN Configuration Script

## Project Summary
This project involves a bash script designed to implement VLAN's. The script can create, remove and show VLAN's on a specific ethernet port.

## Feature List
1. Can list all defined VLAN's
2. Can show properties/status of specified VLAN by name
3. Can show properties/status of all VLAN's defined
4. Prints usage to terminal upon mistakes in usage by user
5. Ensures Ethernet Port and VLAN ID are provided to define a new VLAN
6. Allows the user to define the name for a new VLAN
7. Allows the user to assign an ingress priority map
8. Allows the user to assign an egress priority map
9. Can remove a particular VLAN by name
10. Prints confirmation once VLAN creation/removal
12. Can assign an IPV4 address for specific VLAN
13. Can make the VLAN available on boot

## Software Used
1. OS:      Ubuntu 20.04
2. Editor:  VIM 8.2

## Pre-requisites
Requirements to set up a successful VLAN.

### Hardware
1. 802.1q supported NIC (Network Interface Card)
2. 802.1q support network switch

### Software
1. Vlan package is installed: `sudo apt install vlan`
2. 8021q module is loaded into the kernel: `sudo modprobe 8021q`. Alternatively, if you want the VLAN to be available permanently, you can set the module to be loaded on bootup: `sudo su -c 'echo "8021q" >> /etc/modules'`

## References
### VLAN Configuration
1. [ip-link(8) — Linux manual page](https://man7.org/linux/man-pages/man8/ip-link.8.html)
2. [VLAN - Ubuntu Wiki](https://wiki.ubuntu.com/vlan)
3. [VLAN - archlinux (Updated 2021)](https://wiki.archlinux.org/title/VLAN)
4. [How to configure a VLAN in Linux by Anthony Critelli (2019)](https://www.redhat.com/sysadmin/vlans-configuration)
5. [VLANs on Linux by Paul Frieden (2004)](https://www.linuxjournal.com/article/7268)
6. [HowTo: Configure Linux Virtual Local Area Network (VLAN) by Vivek Gite (2006)](https://www.cyberciti.biz/tips/howto-configure-linux-virtual-local-area-network-vlan.html)

### Command Line Options and Arguments
1. [getopts(1p) — Linux manual page](https://man7.org/linux/man-pages/man1/getopts.1p.html)
2. [getopts](https://www.mkssoftware.com/docs/man1/getopts.1.asp)
