#!/bin/bash


####################################################################################################
# Color definations
####################################################################################################
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;46m'
LIGHT_RED='\e[1;31m'
LIGHT_BLUE='\033[1;34m'
LIGHT_GREEN='\033[1;32m'
NC='\033[0m' # No Color


####################################################################################################
# DEBUG
####################################################################################################
# set -x

####################################################################################################
# Functions
####################################################################################################
print_help () {
  echo
  echo -e "${CYAN}USB Iso Loader${NC}"
  echo
  echo "Create Syslinux USB"
  echo "Usage: usb-iso-loader.sh -d <DEV> -i <DIR>"
  echo "       usb-iso-loader.sh -h"
  echo
  echo "-d, --device             device"
  echo "-i, --iso-directory      iso path"
  echo "-n, --no-color           no coloring"
  echo "-h, --help               help"
  echo
  echo -e "${RED}Attention:${NC} This script needs to root user privileges."
  echo
  echo -e "${BLUE}Example:${NC}  ./usb-iso-loader.sh -d /dev/sdc -i ./Downloads"
  echo
}

print_help_success () {
  print_help
  exit
}

print_help_fail () {
  print_help
  exit 1
}

print_no_iso_file () {
  echo -e "${LIGHT_RED}There is no iso file!${NC}"
  exit 1
}

print_no_device () {
  echo -e "${LIGHT_RED}There is no device!${NC}"
  exit 1
}

jump_to () {
  LABEL=$1
  CMD=$(sed -n "/$LABEL:/{:a;n;p;ba};" $0 | grep -v ':$')
  eval "$CMD"
  exit
}

umount_partitions () {
  if [[ $# -ne 1 ]] ; then
    echo -e "${LIGHT_RED}umount_partitions: There is no block device${NC}"
  fi

  for PART in ${1}* ;
  do
    if mountpoint -q $PART ; then
      continue
    fi

    echo -e "${LIGHT_BLUE}Unmounting: ${NC}${LIGHT_RED}${PART}${NC}"
    umount -f $PART
  done
}

no_color () {
  RED=''
  GREEN=''
  BLUE=''
  CYAN=''
  LIGHT_RED=''
  LIGHT_BLUE=''
  LIGHT_GREEN=''
  NC=''
}


####################################################################################################
# Check the user whether it is root
####################################################################################################
if [[ $EUID -ne 0 ]]; then
  echo -e "${RED}This script must be run as root${NC}" 1>&2
  exit 1
fi


####################################################################################################
# Parse parameters
####################################################################################################
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
  -h|--help)
    print_help_success
    ;;

  -d|--device)
    DEVICE="$2"
    shift # past argument
    shift # past value
    ;;

  -i|--iso-directory)
    ISO_DIR="$2"
    shift
    shift
    ;;

  -n|--no-color)
    no_color
    shift
    shift
    ;;

  *)      # unknown option
    print_help_fail
    ;;
esac
done


####################################################################################################
# Parameter checks
####################################################################################################
if [[ -z $DEVICE ]]; then
  print_help_fail
fi

ISO_DIR=$(realpath $ISO_DIR)
if [[ -z $ISO_DIR ]]; then
  print_help_fail
fi

if [[ ! -d $ISO_DIR ]]; then
  print_help_fail
fi

ISO_FILES=$(find $ISO_DIR -type f -name "*.iso")
if [[ -z $ISO_FILES ]]; then
  print_no_iso_file
fi

if [[ ! -b $DEVICE ]] ; then
  print_no_device
fi


####################################################################################################
# Parameters
####################################################################################################
BOOT_PARTITION_NUM=1
BOOT_PARTITION=${DEVICE}${BOOT_PARTITION_NUM}
MOUNT_DIR=/mnt
SYSLINUX_DIR_NAME=syslinux
SYSLINUX_INSTALL_DIR=$MOUNT_DIR/$SYSLINUX_DIR_NAME
SYSLINUX_FILES="/usr/lib/syslinux/bios/*.c32"
SYSLINUX_MEMDISK_FILE=/usr/lib/syslinux/bios/memdisk
SYSLINUX_MBR_FILE=/usr/lib/syslinux/bios/gptmbr.bin
SYSLINUX_CONFIG_FILE=$SYSLINUX_INSTALL_DIR/syslinux.cfg

ISO_DIR_NAME=isos
ISO_ABSOLUTE_DIR=$MOUNT_DIR/$ISO_DIR_NAME
ISO_RELATIVE_DIR=../$ISO_DIR_NAME


####################################################################################################
# Unmounting the partitions and mount point
####################################################################################################

# Umounts the mount dir
echo -e "${LIGHT_BLUE}Umounting: ${LIGHT_RED}${MOUNT_DIR}${NC}"
umount -f $MOUNT_DIR

umount_partitions $DEVICE


####################################################################################################
# Create partitions
####################################################################################################
# echo -e "${LIGHT_GREEN}Creating Partitions...${NC}"
# sgdisk       \
  # --clear    \
  # --mbrtogpt \
  # --new 1:: --typecode=1:ef00 --change-name=1:'EFI Partiton' \
  # "${DEVICE}"

echo -e "${LIGHT_GREEN}Creating Partitions...${NC}"
sgdisk       \
  --clear    \
  --mbrtogpt \
  --new 1:: --typecode=1:0700 --change-name=1:'Syslinux' --attributes=1:set:2 \
  "${DEVICE}"


####################################################################################################
# List harddisk partition table
####################################################################################################
echo -e "${LIGHT_GREEN}Partitions Created!${NC}"
gdisk -l "${DEVICE}"


####################################################################################################
# Format partitions
####################################################################################################
# echo -e "${LIGHT_BLUE}Formatting ${LIGHT_RED}${BOOT_PARTITION}${NC}"
# mkfs.fat -F32 $BOOT_PARTITION


####################################################################################################
# Format partitions
####################################################################################################
echo -e "${LIGHT_BLUE}Formatting: ${LIGHT_RED}${BOOT_PARTITION}${NC}"
mkfs.vfat $BOOT_PARTITION


# ####################################################################################################
# # Mounts the partition and copies the files
# ####################################################################################################
#
# # Umounts the mount dir
# echo -e "${LIGHT_BLUE}Umounting ${LIGHT_RED}${MOUNT_DIR}${NC}"
# umount -f $MOUNT_DIR
#
# # Mounts the device
# echo -e "${LIGHT_BLUE}Mounting ${LIGHT_RED}${EFI_PARTITION}${NC}"
# mount $EFI_PARTITION $MOUNT_DIR
#
# # Creates the syslinux directory
# mkdir -p "${MOUNT_DIR}/EFI/syslinux"
#
# # Copies the syslinux files
# cp -r /usr/lib/syslinux/efi64/ "${MOUNT_DIR}/EFI/syslinux/"
#
# # Copies memdisk
# cp /usr/lib/syslinux/bios/memdisk "${MOUNT_DIR}/EFI/syslinux"
#
# # Setup boot entry for syslinux
# efibootmgr -c -d $DEVICE -p $EFI_PARTITION_NUM -l /EFI/syslinux/syslinux.efi -L "Syslinux"


####################################################################################################
# Mounts the partition and copies syslinux files
####################################################################################################

# Umounts the mount dir
echo -e "${LIGHT_BLUE}Umounting: ${LIGHT_RED}${MOUNT_DIR}${NC}"
umount -f $MOUNT_DIR

umount_partitions $DEVICE

# Mounts the device
echo -e "${LIGHT_BLUE}Mounting: ${LIGHT_RED}${BOOT_PARTITION}${NC}"
mount $BOOT_PARTITION $MOUNT_DIR

# Creates the syslinux directory
mkdir -p "${MOUNT_DIR}/syslinux"

# Copies the syslinux files
cp -r $SYSLINUX_FILES $SYSLINUX_INSTALL_DIR

# Copies memdisk
cp $SYSLINUX_MEMDISK_FILE $SYSLINUX_INSTALL_DIR


####################################################################################################
# Creates syslinux configuration file
# Copies the iso files
####################################################################################################

# Removes old configuration file - Not necessary
rm -f $SYSLINUX_CONFIG_FILE

# Makes the iso directory
mkdir -p $ISO_ABSOLUTE_DIR

# touch $SYSLINUX_CONFIG_FILE
# echo "" >> $SYSLINUX_CONFIG_FILE

# Creates the header 
tee $SYSLINUX_CONFIG_FILE > /dev/null <<EOF

UI vesamenu.c32
DEFAULT arch
PROMPT 0
MENU TITLE Boot Menu
# MENU BACKGROUND splash.png
TIMEOUT 50

MENU WIDTH 78
MENU MARGIN 4
MENU ROWS 5
MENU VSHIFT 10
MENU TIMEOUTROW 13
MENU TABMSGROW 11
MENU CMDLINEROW 11
MENU HELPMSGROW 16
MENU HELPMSGENDROW 29

# Refer to https://www.syslinux.org/wiki/index.php/Comboot/menu.c32

MENU COLOR border       30;44   #40ffffff #a0000000 std
MENU COLOR title        1;36;44 #9033ccff #a0000000 std
MENU COLOR sel          7;37;40 #e0ffffff #20ffffff all
MENU COLOR unsel        37;44   #50ffffff #a0000000 std
MENU COLOR help         37;40   #c0ffffff #a0000000 std
MENU COLOR timeout_msg  37;40   #80ffffff #00000000 std
MENU COLOR timeout      1;37;40 #c0ffffff #00000000 std
MENU COLOR msg07        37;40   #90ffffff #a0000000 std
MENU COLOR tabmsg       31;40   #30ffffff #00000000 std

EOF


# Traverses the iso files
for ISO_FILE in $ISO_FILES; do
  if [[ ! -f $ISO_FILE ]]; then
    continue;
  fi

  # Copies the iso file
  echo -e "${LIGHT_BLUE}Copying: ${LIGHT_RED}${ISO_FILE}${NC}"
  cp $ISO_FILE $ISO_ABSOLUTE_DIR
  # rsync --progress $ISO_FILE $ISO_ABSOLUTE_DIR
  sync

  # Basename
  ISO_FILE_BASE=$(basename $ISO_FILE)

  # Adding the iso file to configuration file
  echo -e "${LIGHT_GREEN}Adding syslinux.cfg entry.${NC}"

  echo "LABEL $ISO_FILE_BASE"                      >> $SYSLINUX_CONFIG_FILE
  echo "  MENU LABEL $ISO_FILE_BASE"               >> $SYSLINUX_CONFIG_FILE
  echo "  LINUX memdisk"                           >> $SYSLINUX_CONFIG_FILE
  echo "  INITRD $ISO_RELATIVE_DIR/$ISO_FILE_BASE" >> $SYSLINUX_CONFIG_FILE
  echo "  APPEND iso raw"                          >> $SYSLINUX_CONFIG_FILE
  echo ""                                          >> $SYSLINUX_CONFIG_FILE
  echo ""                                          >> $SYSLINUX_CONFIG_FILE

done


####################################################################################################
# Umounts the partition
###################################################################################################

# Umounts the mount dir and device
echo -e "${LIGHT_BLUE}Umounting ${LIGHT_RED}${MOUNT_DIR}${NC}"
umount -f $MOUNT_DIR

umount_partitions ${DEVICE}


####################################################################################################
# Syslinux stuff
####################################################################################################

# Setup boot entry for syslinux
# extlinux --install $SYSLINUX_INSTALL_DIR

echo -e "${LIGHT_BLUE}Installing: ${LIGHT_RED}Syslinux${NC}"
syslinux --directory $SYSLINUX_DIR_NAME --install $BOOT_PARTITION

# Install MBR
echo -e "${LIGHT_BLUE}Installing: ${LIGHT_RED}MBR${NC}"
dd bs=440 count=1 conv=notrunc if=$SYSLINUX_MBR_FILE of=$DEVICE

# Finished
echo -e "${LIGHT_GREEN}Finished!${NC}"

