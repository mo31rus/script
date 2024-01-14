#!/usr/bin/env sh
#OR !/bin/sh

# Colour variables
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
GREY='\033[0;37m'
DARKGREY='\033[1;30m'
BRIGHTRED='\033[1;31m'
BRIGHTGREEN='\033[1;32m'
BRIGHTYELLOW='\033[1;33m'
BRIGHTBLUE='\033[1;34m'
BRIGHTPURPLE='\033[1;35m'
BRIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'
RESET='\033[0m'


echo -e "${BRIGHTCYAN}──────────────────────────────${RESET}"
echo -e "${BRIGHTCYAN}  Alpine Linux Config Script  ${RESET}"
echo -e "${BRIGHTGREEN}  Installing RAID support ${RESET}"
echo -e "${BRIGHTCYAN}──────────────────────────────${RESET}"

apk add parted mdadm 

modprobe raid1
echo raid1 >> /etc/modules-load.d/raid1.conf

# lsblk
# mdadm --zero-superblock --force /dev/sd{b,c}

echo -e "${BRIGHTCYAN}──────────────────────────────${RESET}"
echo -e "${BRIGHTGREEN}  Prepare partitions${RESET}"
echo -e "${BRIGHTCYAN}──────────────────────────────${RESET}"

parted /dev/sdb mklabel msdos
parted /dev/sdc mklabel msdos
parted /dev/sdb mkpart primary ext4 2048 33Gb
parted /dev/sdc mkpart primary ext4 2048 33Gb

echo -e "${BRIGHTCYAN}──────────────────────────────${RESET}"
echo -e "${BRIGHTGREEN}  Create RAID${RESET}"
echo -e "${BRIGHTCYAN}──────────────────────────────${RESET}"

mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sdb1 /dev/sdc1
mdadm --detail --scan | tee -a /etc/mdadm.conf

echo -e "${BRIGHTCYAN}──────────────────────────────${RESET}"
echo -e "${BRIGHTGREEN}  Update rc-service${RESET}"
echo -e "${BRIGHTCYAN}──────────────────────────────${RESET}"

rc-update add mdadm-raid
rc-update add mdadm boot
rc-update add mdadm-raid boot

echo -e "${BRIGHTCYAN}──────────────────────────────${RESET}"
echo -e "${BRIGHTGREEN}  Mount RAID to /mo${RESET}"
echo -e "${BRIGHTCYAN}──────────────────────────────${RESET}"

mkdir /mo
mkfs.ext4 /dev/md0
mount /dev/md0 /mo

# cat /proc/mdstat
# mdadm --detail --scan --verbose
# lsblk
# blkid
# blkid /dev/md0 
#
# nano /etc/fstab #add# UUID=9ad4ff80-d611-412e-b5bd-cc26ae9d21bd       /mo     ext4    defaults        0 0
# umount /mo
# mount -a
# nano /etc/mdadm.conf 

# reboot


echo -e "${BRIGHTCYAN}──────────────────────────────${RESET}"
echo -e "${BRIGHTGREEN}  Done!${RESET}"
echo -e "${BRIGHTCYAN}──────────────────────────────${RESET}"

# https://wiki.alpinelinux.org/wiki/Setting_up_a_software_RAID_array
# https://www.dmosk.ru/miniinstruktions.php?mini=mdadm#conf
# https://dzen.ru/a/YcEFjEtGwByn0z3p?experiment=942707
# https://losst.pro/programmnyj-raid-v-linux
