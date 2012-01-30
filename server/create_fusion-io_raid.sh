#!/bin/bash
mdadm --create /dev/md0 --chunk=256 --level=0 --raid-devices=4 /dev/fioa /dev/fiob /dev/fioc /dev/fiod
#pvcreate /dev/md0
# for -s, 1,300,000MiB (total size of arrray) / 64,000MiB = 20; then round up to nearest power of 2: 32MiB
#vgcreate -s 32M lvm-fusion-io-raid /dev/md0
#vgdisplay lvm-fusion-io-raid
#              --- Volume group ---
#          VG Name               lvm-fusionio-raid
#          System ID
#          Format                lvm2
#          Metadata Areas        1
#          Metadata Sequence No  1
#          VG Access             read/write
#          VG Status             resizable
#          MAX LV                0
#          Cur LV                0
#          Open LV               0
#          Max PV                0
#          Cur PV                1
#          Act PV                1
#          VG Size               1.17 TiB
#          PE Size               32.00 MiB
#          Total PE              38451
#          Alloc PE / Size       0 / 0
#          Free  PE / Size       38451 / 1.17 TiB
#          VG UUID               OCX7cN-wSM1-ZpUT-Ehb9-7fDw-L04c-xShyb7
#
#lvcreate -l 38451 lvm-fusion-io-raid -n lvm_fusion-io
#lvdisplay /dev/lvm-fusion-io-raid/lvm_fusion-io
mkfs.xfs -f -b size=4096 -d sunit=512,swidth=2048 -L fusion-io /dev/md0
#mkfs.ext4 /dev/lvm-fusion-io-raid/lvm_fusion-io
mkdir /fusion-io
echo "LABEL=fusion-io   /fusion-io   xfs largeio,inode64,sunit=512,swidth=2048,nobarrier   1 2" >> /etc/fstab
mount -a
df -h /fusion-io

