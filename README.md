# add_vm_usb
## ʹ��˵����

1����usb_passthroughĿ¼�ϴ�������USB���ܹ��ļ���ڵ�/optĿ¼�¡�

2����ʹ��USBֱͨ������������ʱ������ڵ�nova-compute������driver.py����
   �������̣�
a)����ԭdriver.py,driver.pyc,driver.pyo�ļ�
  �ļ�λ��Ŀ¼��/usr/lib/python2.7/site-packages/nova/virt/libvirt/
  �磺
  ```
      mv /usr/lib/python2.7/site-packages/nova/virt/libvirt/driver.py /usr/lib/python2.7/site-packages/nova/virt/libvirt/driver.py_20171122
      mv /usr/lib/python2.7/site-packages/nova/virt/libvirt/driver.pyc /usr/lib/python2.7/site-packages/nova/virt/libvirt/driver.pyc_20171122
      mv /usr/lib/python2.7/site-packages/nova/virt/libvirt/driver.pyo /usr/lib/python2.7/site-packages/nova/virt/libvirt/driver.pyo_20171122
   ```
b)��usb_passthroughĿ¼��driver.py �ļ����Ƶ�Ŀ¼�� /usr/lib/python2.7/site-packages/nova/virt/libvirt/
  �磺
  ```
  cp /opt/usb_passthrough/driver.py /usr/lib/python2.7/site-packages/nova/virt/libvirt/
  ```
c)����nova-compute����systemctl restart openstack-nova-compute
  
3����ICPƽ̨�д���������
   �������������飬ȷ�����������ڵļ���ڵ㣬�������������ơ�
   ע�⣺����������ӦΨһ���ű��������ô����Ʋ�ѯ��VM��UUID��Ϣ��
4����ѯUSB���ܹ���Ϣ(��Ļ���ͬʱ���浽usb_devices_list�ļ�)
   ִ�У�
   ```
   sh /opt/usb_passthrough/find_usb.sh
   ���������
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
  ���ݳ�����Ϣ,ȷ��ҪֱͨUSB��vendorid:productid
  ��Ҫֱͨ��USB�豸Ϊ��8564:1000

5��ִ�й���USB�豸
  inotify_usb.sh �ű���4������:
  ����1������3������������,��:testvm1117
  ����2��attach-device (����)�� detach-device (ж��)
  ����3:����4��vendorid  �磺8564
  ����4:����4��productid �磺1000
  ִ�й��ؽű�,�磺
  ```
  sh /opt/usb_passthrough/inotify_usb.sh testvm1117 attach-device  8564 1000
  ```
  ִ�н��
  ```
  inotifywait is not running
  The vm testvm1117 uuid is 708f0b90-6710-4e63-874d-bacb9d95361a
  Device attached successfully
  ```
  [root@Host-172-23-4-83 usb_passthrough]# Setting up watches. 
  Watches established. ##������س�
  
  ִ��ж�ؽű�,�磺
  ```
  sh /opt/usb_passthrough/inotify_usb.sh testvm1117 detach-device  8564 1000
  ```