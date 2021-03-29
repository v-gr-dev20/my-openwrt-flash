#!/bin/bash
echo "https://openwrt.org/toh/d-link/dir-320"
echo "=================================================================="
echo "This script will upload the router firmware (firmware.bin)"
echo "in the current directory to 192.168.0.1 "
echo "during the router's bootup. "
echo ""
echo "* Set your ethernet card's settings to: "
echo "     IP:      192.168.0.10 "
echo "     Mask:    255.255.255.0 "
echo "     Gateway: 192.168.0.1 "
echo "* Unplug the router's power cable. "
echo ""
echo "Press Ctrl+C to abort or any other key to continue... "

read

echo ""
echo "* Re-plug the router's power cable. "
echo ""
echo "=================================================================="
echo "Waiting for the router... Press Ctrl+C to abort. "
echo ""

firmwarePath=${1:-firmware.bin}

try(){
ping -w 1 192.168.0.1
}
try
while [ "$?" != "0" ] ;
do
try
done
echo "*** Start Flashing **** "
atftp --verbose -p -l $firmwarePath 192.168.0.1
result=$?
[[ 0 -eq $result ]] \
	&& echo "Firmware successfully loaded!" \
	|| echo "Firmware load failed!"
exit $result