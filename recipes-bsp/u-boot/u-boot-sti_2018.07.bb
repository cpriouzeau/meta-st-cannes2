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

DEPENDS += " boot-configs-stih410-b2260 "

SRC_URI += "file://0001-CONFIG-disable-usb-check.patch"

UBOOT_LOCALVERSION = "+B2260_2016.09"


UBOOT_CONFIG[b2260] = "stih410-b2260_defconfig"
