# How to enable netboot via u-boot


## 1. with yocto build
- source yocto setup: **MACHINE=stih410-b2260 DISTRO=rpb-wayland source ./setup-environment**
- call the run script for nfs: **../layers/meta-st-cannes2/script/run_nfs_via_tftp.sh**

## 2. with sdcard or usb key
- mount boot partition on /media/$USER/BOOT/
- chnage type of boot to netboot: **./update_default_boot.sh netboot**

# How to clean nfs export and directory exported
- source yocto setup: **MACHINE=stih410-b2260 DISTRO=rpb-wayland source ./setup-environment**
- call the run script for nfs: **../layers/meta-st-cannes2/script/cleanup-rootfs.sh**

