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
  echo -e "${CYAN}USB Iso Loader Cleaner${NC}"
  echo
  echo "Clears the usb"
  echo "Usage: usb-iso-loader-clean.sh -d <DEV>"
  echo
  echo "-d, --device             device"
  echo "-n, --no-color           no coloring"
  echo "-h, --help               help"
  echo
  echo -e "${RED}Attention:${NC} This script needs to root user privileges."
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


####################################################################################################
# Unmounting partitions
####################################################################################################
echo -e "${LIGHT_BLUE}Unmounting Partitions...${NC}"
umount -f ${DEVICE}*


####################################################################################################
# Create partitions
####################################################################################################
echo -e "${LIGHT_GREEN}Creating Partitions...${NC}"
sgdisk       \
  --clear    \
  --mbrtogpt \
  --new 1:: --typecode=1:0700 --change-name=1:'' \
  "${DEVICE}"


####################################################################################################
# List harddisk partition table
####################################################################################################
echo -e "${LIGHT_GREEN}Partitions Created!${NC}"
gdisk -l "${DEVICE}"


####################################################################################################
# Format partitions
####################################################################################################
PARTITION=${DEVICE}1

echo -e "${LIGHT_BLUE}Formatting ${LIGHT_RED}${BOOT_PARTITION}${NC}"
mkfs.vfat $PARTITION

# Finished
echo -e "${LIGHT_GREEN}Finished!${NC}"

