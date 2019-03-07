SUMMARY = "Universal Boot Loader for STI embedded devices"
LICENSE = "GPLv2+"

require recipes-bsp/u-boot/u-boot-common_${PV}.inc
require recipes-bsp/u-boot/u-boot.inc

DEPENDS += "bc-native dtc-native"

COMPATIBLE_MACHINE = "(stih410-b2260)"

# Set u-boot to PROVIDES for compatibility with kernel-fitimage.bbclass
PROVIDES += "u-boot"

# Append 'st' to u-boot version display
UBOOT_LOCALVERSION = '-st'

DEPENDS_append_sticommon = " u-boot-configs-b2260 "

SRC_URI += "file://0001-CONFIG-disable-usb-check.patch"
