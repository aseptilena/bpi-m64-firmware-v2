#!/bin/bash

function pt_error()
{
    echo -e "\033[1;31mERROR: $*\033[0m"
}

function pt_warn()
{
    echo -e "\033[1;31mWARN: $*\033[0m"
}

function pt_info()
{
    echo -e "\033[1;32mINFO: $*\033[0m"
}

function pt_ok()
{
    echo -e "\033[1;33mOK: $*\033[0m"
}

if [ $UID -ne 0 ]
    then
    pt_error "Please run as root."
    exit
fi

pt_info "Umounting eMMC, please wait..."
sync
umount /dev/mmcblk0* >/dev/null 2>&1
sleep 1
sync

sudo partprobe
sleep 2
sync
sudo partprobe ${SDCARD}
sleep 2


set -e
pt_info "Writing to eMMC, please wait..."
dd if=./boot0.bin conv=notrunc bs=1k seek=8 of=/dev/mmcblk0
dd if=./ub-m64-emmc.bin conv=notrunc bs=1k seek=19096 of=/dev/mmcblk0

mkdir -p erootfs
sudo partprobe ${SDCARD}
sleep 4
sudo mount /dev/mmcblk0p2 erootfs
tar -xvpzf rootfs_m64_rc6.tar.gz -C ./erootfs --numeric-ow
sync
sudo umount erootfs
rm -fR erootfs

mkdir eboot
sudo mount /dev/mmcblk0p1 eboot
tar -xvzf boot_m64_rc6.tar.gz -C ./eboot --no-same-owner
sync
sudo umount eboot
rm -fR eboot
sync
pt_info "Finished eMMC, reboot without the SD CARD!"
pt_ok "run: sudo shutdown -h now , remove the SD card and power the board again. Enjoy!"
