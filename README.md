# add_vm_usb
## 使用说明：

1、把usb_passthrough目录上传至插有USB加密狗的计算节点/opt目录下。

2、在使用USB直通给云主机功能时，计算节点nova-compute须升级driver.py程序
   升级过程：
a)备份原driver.py,driver.pyc,driver.pyo文件
  文件位置目录：/usr/lib/python2.7/site-packages/nova/virt/libvirt/
  如：
  ```
      mv /usr/lib/python2.7/site-packages/nova/virt/libvirt/driver.py /usr/lib/python2.7/site-packages/nova/virt/libvirt/driver.py_20171122
      mv /usr/lib/python2.7/site-packages/nova/virt/libvirt/driver.pyc /usr/lib/python2.7/site-packages/nova/virt/libvirt/driver.pyc_20171122
      mv /usr/lib/python2.7/site-packages/nova/virt/libvirt/driver.pyo /usr/lib/python2.7/site-packages/nova/virt/libvirt/driver.pyo_20171122
   ```
b)把usb_passthrough目录下driver.py 文件复制到目录： /usr/lib/python2.7/site-packages/nova/virt/libvirt/
  如：
  ```
  cp /opt/usb_passthrough/driver.py /usr/lib/python2.7/site-packages/nova/virt/libvirt/
  ```
c)重启nova-compute服务：systemctl restart openstack-nova-compute
  
3、在ICP平台中创建云主机
   根据云主机详情，确定云主机所在的计算节点，及云主机的名称。
   注意：云主机名称应唯一，脚本程序须用此名称查询出VM的UUID信息。
4、查询USB加密狗信息(屏幕输出同时保存到usb_devices_list文件)
   执行：
   ```
   sh /opt/usb_passthrough/find_usb.sh
   如下输出：
   ####################################################
 The compute node USB devices: 

Bus 002 Device 004: ID 046b:ff10 American Megatrends, Inc. Virtual Keyboard and Mouse
Bus 002 Device 003: ID 046b:ff01 American Megatrends, Inc. 
Bus 002 Device 002: ID 8087:0024 Intel Corp. Integrated Rate Matching Hub
Bus 002 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 001 Device 004: ID 8564:1000 Transcend Information, Inc. JetFlash
Bus 001 Device 002: ID 8087:0024 Intel Corp. Integrated Rate Matching Hub
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
 The output usb devices info:vendorid:productid 
vendorid:productid,desc
    046b:ff10     ,American Megatrends, Inc. Mouse
    046b:ff01     ,American Megatrends, Inc. Inc.
    8087:0024     ,Intel Corp. Integrated Hub
    1d6b:0002     ,Linux Foundation 2.0 hub
    8564:1000     ,Transcend Information, Inc. JetFlash
    8087:0024     ,Intel Corp. Integrated Hub
    1d6b:0002     ,Linux Foundation 2.0 hub
 The usb_monitor scripts will use vendorid:productid    
 ```
  根据厂商信息,确定要直通USB的vendorid:productid
  如要直通的USB设备为：8564:1000

5、执行挂载USB设备
  inotify_usb.sh 脚本须4个参数:
  参数1：步骤3的云主机名称,如:testvm1117
  参数2：attach-device (挂载)或 detach-device (卸载)
  参数3:步骤4的vendorid  如：8564
  参数4:步骤4的productid 如：1000
  执行挂载脚本,如：
  ```
  sh /opt/usb_passthrough/inotify_usb.sh testvm1117 attach-device  8564 1000
  ```
  执行结果
  ```
  inotifywait is not running
  The vm testvm1117 uuid is 708f0b90-6710-4e63-874d-bacb9d95361a
  Device attached successfully
  ```
  [root@Host-172-23-4-83 usb_passthrough]# Setting up watches. 
  Watches established. ##请输入回车
  
  执行卸载脚本,如：
  ```
  sh /opt/usb_passthrough/inotify_usb.sh testvm1117 detach-device  8564 1000
  ```