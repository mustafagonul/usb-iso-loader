# USB Iso Loader

## Description

The project aims to create bootable USB loading iso files. 

## Usage

- To access help:

      ./usb-iso-loader.sh --help
    
      ./usb-iso-loader-clean.sh --help

    **Output:**

      USB Iso Loader
  
      Create Syslinux USB to load iso files
      Usage: usb-iso-loader.sh -d <DEV> -i <DIR>
             usb-iso-loader.sh -h

      -d, --device             device
      -i, --iso-directory      iso path
      -n, --no-color           no coloring
      -h, --help               help
  
      Attention: This script needs to root user privileges.

      Example:  ./usb-iso-loader.sh -d /dev/sdc -i ./Downloads

- To create bootable USB on **/dev/sdc** loading iso files in **Downloads** directory

      ./usb-iso-loader.sh -d /dev/sdc -i ./Downloads

- **Hint:** Scripts must be used with root priviledges. You can use sudo for this.

## Scripts

- **usb-iso-loader.sh** Main script
- **usb-iso-loader-clean-sh** Clears the usb. This script can be used to clear the usb after using the main script.

## Parameters

- **--device** The device scripts will work on.
- **--iso-directory** The directory scripts will search for the iso files.
- **--no-color** Coloring is disabled with this parameter
- **--help** This parameter is used to dump the help

## TODO

- UEFI support
- Grub research
- Message generalization
- No direct call to **umount**
- Test on several distos should be done
- Minimum dependency on commands
