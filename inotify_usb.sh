#!/bin/bash
######author:by song.w
######date:2017-11-22
######function:the virtual machine attach or detach usb devices
LOG_DIR="/var/log/usb_monitor"
## log info
function log_info ()
{
    if [ ! -d "/var/log/usb_monitor/" ]; then
        mkdir -p $LOG_DIR
    fi

    DATE_N=`date "+%Y-%m-%d %H:%M:%S"`
    DATE_D=`date "+%Y-%m-%d"`
    USER_N=`whoami`
    echo "${DATE_N},$@" >> $LOG_DIR/usb_monitor.log.${DATE_D}
    
}

function usb_control ()
{
command=$1
vm_instances=$2
vendorid=$3
productid=$4

log_info  "virsh ${command} ${vm_instances}"

virsh ${command} ${vm_instances} /dev/stdin <<_SW_
<hostdev mode='subsystem' type='usb' managed='yes'>
 <source>
  <vendor id='0x${vendorid}'/>
  <product id='0x${productid}'/>
 </source>
</hostdev>
_SW_
}

##Determine whether the virtual machine has USB devices
function vm_has_usb ()
{
 vm_instances=$1
 vm_usb_result=$(virsh qemu-monitor-command ${vm_instances} --hmp 'info usb'|grep -Ev '^$|QEMU USB Tablet'|wc -l)
 echo ${vm_usb_result}
}

function obtain_vmuuid ()
{
 vm_novaname=$1
 if [ -z $(grep -w "${vm_novaname}" /etc/libvirt/qemu/*.xml|awk -F':' '{print$1}') ]
  then
    echo ""
  else  
    vm_uuid=$(cat $(grep -w "${vm_novaname}" /etc/libvirt/qemu/*.xml|awk -F':' '{print$1}') |sed -n '10p'|awk -F'>' '{print$2}'|awk -F'<' '{print$1}')
    echo ${vm_uuid} 
 fi   
}
#check inotify process if already exists
function check_process ()
{
 instance_uuid=$1
 pid_info=$(ps -ef|grep inotifywait|grep -v "grep"|grep ${instance_uuid}|awk '{print $2" "$3}')
 if [ -z "${pid_info}" ]
   then
     echo "inotifywait is not running"
   else
     echo -e "inotifywait progress pid:${pid_info}"
     echo "inotifywait is  running,will be killed"
     kill -9 ${pid_info}
 fi    
}

function main()
{ 
   if [ $# -lt 4 ] 
    then 
        echo -e "Warning:The script must have four parameters."
        echo "#########################################################################"
        echo "Usage: sh $0 vmname attach-device/detach-device vendorid productid" 
        echo  -e "Example: sh $0 testvm1117 attach-device 8564 1000\n"
        echo "USB device vendorid productid obtain:lsusb tools,usbutils-007-5.el7.x86_64"
        echo "lsusb output:"
        echo -e "Bus 001 Device 003: ID 8564:1000 Transcend Information, Inc. JetFlash\n"
        echo -e "The USB device vendorid:8564,productid:1000\n"
        echo "#########################################################################"

        exit 1
   fi  
   
   novaname=$1
   cmd=$2  
   vendorid=$3
   productid=$4
   
   
   vms_name=$(obtain_vmuuid ${novaname})
   if [ -z ${vms_name} ]
     then
      echo "Obtain VM uuid failure:Please verify that the cloud host name is correct"
      log_info "Obtain VM uuid failure:Please verify that the cloud host name is correct"
      exit 1
     else
      check_process ${vms_name} 
   fi 
   echo "The vm ${novaname} uuid is ${vms_name}"
   
   usb_result=$(vm_has_usb ${vms_name})
   
   if [ ${cmd} = "attach-device" ]
   then
     if [ ${usb_result} -ge 1 ]
       then
         echo "The vm ${novaname}:${vms_name} already attached usb device"
         log_info "The vm ${novaname}:${vms_name} already attached usb device"
         
       else
         usb_control attach-device ${vms_name} ${vendorid} ${productid}
         log_info "The vm ${novaname}:${vms_name} attached usb device successful"
     fi  
###inotify vm hard reboot
     {
     while inotifywait -e modify /var/lib/nova/instances/${vms_name}/libvirt.xml; do
       log_info "vm:${novaname}:${vms_name} libvirt.xml modify"
       usb_control attach-device ${vms_name} ${vendorid} ${productid}
       log_info "The vm ${novaname}:${vms_name} attached usb device successful"
     done
     } &
     
   elif [ ${cmd} = "detach-device" ]
     then
      if [ ${usb_result} -ge 1 ]
       then
         echo "The vm ${novaname}:${vms_name} already attached usb device,will detaching "
         log_info "The ${novaname}:vm ${vms_name} already attached usb device,will detaching"
         usb_control detach-device ${vms_name} ${vendorid} ${productid}
       else
         echo "The vm ${novaname}:${vms_name} no attached usb device"
         log_info "The vm ${novaname}:${vms_name} no attached usb device"
      fi   
   fi
}

main $@
