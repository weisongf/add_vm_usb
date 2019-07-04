#!/bin/bash
######date:2017-11-22
######function:Found the compute node usb devices info
function check_rpm ()
{
rpm_name=$1
rpm_pkg=$2

if [ -z $(rpm -qa|grep ${rpm_name}) ]
then
   echo "The ${rpm_name} is not installed"
   echo "Begin install ${rpm_name} tools:"
   rpm -ivh ./rpm/${rpm_pkg}
   if [ $? -eq 0 ]
     then
       echo "install ${rpm_name} tools successful"
     else
       echo "install ${rpm_name} tools failure"
       exit 1  
   fi
else
   echo "${rpm_name} is installed"
fi
}

##usb:libusbx,libusbx-1.0.20-1.el7.x86_64 usbutils,usbutils-007-5.el7.x86_64.rpm
#check libusbx
check_rpm libusbx libusbx-1.0.20-1.el7.x86_64

#check usbutils
check_rpm usbutils usbutils-007-5.el7.x86_64.rpm

#check inotify-tools
check_rpm inotify-tools inotify-tools-3.14-8.el7.x86_64.rpm

#obtain node usb device lists
echo "####################################################"
echo -e "\033[42;37m The compute node USB devices: \033[0m"
echo ""

lsusb |tee ./usb_devices_list

echo -e "\033[42;37m The output usb devices info:vendorid:productid \033[0m"

lsusb|awk 'BEGIN{ print "vendorid:productid,desc" } { print"    "$6"     ,"$7" "$8" "$9" "$NF }'

echo -e "\033[42;37m The usb_monitor scripts will use vendorid:productid\033[0m"