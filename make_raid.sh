#!/bin/bash

mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh
yum install -y mdadm smartmontools hdparm gdisk
mdadm --zero-superblock --force /dev/sd{b,c,d,e}
wipefs --all --force /dev/sd{b,c,d,e}
mdadm --create --verbose /dev/md0 -l 10 -n 4 /dev/sd{b,c,d,e}
mkdir /etc/mdadm/
sh -c 'echo "DEVICE partitions" > /etc/mdadm/mdadm.conf'
mdadm --detail --scan --verbose | sh -c "awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf"
parted -s /dev/md0 mklabel gpt
parted /dev/md0 mkpart primary ext4 0% 20%
parted /dev/md0 mkpart primary ext4 20% 40%
parted /dev/md0 mkpart primary ext4 40% 60%
parted /dev/md0 mkpart primary ext4 60% 80%
parted /dev/md0 mkpart primary ext4 80% 100%
mkfs.ext4 /dev/md0p1
mkfs.ext4 /dev/md0p2
mkfs.ext4 /dev/md0p3
mkfs.ext4 /dev/md0p4
mkfs.ext4 /dev/md0p5
mkdir --parent /mnt/soft_raid/part_{1,2,3,4,5}
sh -c "echo '/dev/md0p1  /mnt/soft_raid/part_1  ext4  defaults  0  2' >> /etc/fstab"
sh -c "echo '/dev/md0p2  /mnt/soft_raid/part_2  ext4  defaults  0  2' >> /etc/fstab"
sh -c "echo '/dev/md0p3  /mnt/soft_raid/part_3  ext4  defaults  0  2' >> /etc/fstab"
sh -c "echo '/dev/md0p4  /mnt/soft_raid/part_4  ext4  defaults  0  2' >> /etc/fstab"
mount -a
