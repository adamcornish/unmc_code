#!/usr/bin/bash

pvcreate /dev/sdg
vgcreate -s 128M lvm-faster /dev/sdg
vgdisplay lvm-faster-raid
lvcreate -l __TOTAL_PE__ lvm-faster -n lvm_faster
mkfs.xfs -b size=4096 -d sunit=2056,swidth=30840 -L faster /dev/lvm-faster-raid/lvm_faster
mount -o inode64 /dev/lvm-faster-raid/lvm_faster /faster 
df -h
echo "LABEL=faster   /faster xfs largeio,inode64,sunit=2056,swidth=30840,nobarrier   0 0" >> /etc/fstab
