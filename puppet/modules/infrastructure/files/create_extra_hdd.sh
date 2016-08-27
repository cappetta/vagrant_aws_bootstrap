#!/usr/bin/env bash
set -e
set -x

if [ -f /etc/disk_added_date ]
then
   echo "disk already added so exiting."
   exit 0
fi


sudo fdisk -u /dev/sdb <<EOF
n
p
1
t
8e
w
EOF
# had to customize for centos7, windows 7 & virtualbox - not sure why.
pvcreate /dev/sdb1
vgextend centos /dev/sdb1
lvextend -r /dev/centos/root /dev/sdb1
#resize2fs /dev/centos/lv_root

date > /etc/disk_added_date