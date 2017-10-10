# Copyright (C) 2017 STMicroelectronics - All Rights Reserve
# Released under the MIT license (see COPYING.MIT for the terms)

require recipes-bsp/u-boot/u-boot.inc

DESCRIPTION = "U-Boot provided by STMicroelectronics for STih410b2260 board"

LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = " \
    file://Licenses/gpl-2.0.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263 \
"

SRC_URI = "git://github.com/cpriouzeau/STi-U-Boot.git;protocol=https"
SRCREV = "e8f93c5c6ecf700f8e6d22312598788ffd79967d"

SRC_URI_append_stih410-b2260 = " file://st_b2260_stxh410_sdusb_defconfig "
SRC_URI_append_stih410-b2260 = " file://0001-Increase-the-size-of-kernel-loadable.patch "

UBOOT_LOCALVERSION = "+B2260_2016.09"

S = "${WORKDIR}/git"

PROVIDES += "u-boot"

UBOOT_CONFIG[b2260] = "st_b2260_stxh410_sdusb_defconfig"

do_configure_prepend() {
    cp ${WORKDIR}/st_b2260_stxh410_sdusb_defconfig ${S}/configs/
}
