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

## Tested Distros

- Arch Linux

## Dependencies

### Arch Linux

## TODO

- Better project name :)
- Working isos
  - [Arch Linux](https://www.archlinux.org/download/)
- Not working isos
  - [GParted](https://sourceforge.net/projects/gparted/)
  - [Debian Iso DVD](https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/)
- Support for large iso files
- Using trap
- UEFI support
- Grub research
- Message generalization
- No direct call to **umount**
- Checking command return values, making rollback if necessary
- Test on several distos should be done
- Dependency analysis necessary
- Minimum dependency on commands

## Notes

- https://wiki.archlinux.org/index.php/Multiboot_USB_drive

