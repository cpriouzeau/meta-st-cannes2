FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${PV}:"

include recipes-kernel/linux/linux-st.inc
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=bbea815ee2795b2f4230826c0c6b8814"

SRC_URI = "https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.19.tar.xz;name=kernel"
SRC_URI[kernel.md5sum] = "740a90cf810c2105df8ee12e5d0bb900"
SRC_URI[kernel.sha256sum] = "0c68f5655528aed4f99dae71a5b259edc93239fa899e2df79c055275c21749a1"

SRC_URI_append_stih410-b2260 = " \
    file://0002-4.19-ST-misc.patch \
    file://0003-4.19-ST-devicetree.patch \
"

S = "${WORKDIR}/linux-4.19"

LINUX_VERSION = "4.19"

PR = "r0"
PV = "${LINUX_VERSION}"

COMPATIBLE_MACHINE = "stih410-b2260"

#---------------------------------------
# Defconfig
#
KERNEL_DEFCONFIG         = "multi_v7_defconfig"
KERNEL_CONFIG_FRAGMENTS  = "${WORKDIR}/b2260.config"
#KERNEL_CONFIG_FRAGMENTS  = "${THISDIR}/${PN}/${PV}/systemd.config"
KERNEL_CONFIG_FRAGMENTS  += "${WORKDIR}/systemd.config"
SRC_URI_append_stih410-b2260 = " file://systemd.config "
SRC_URI_append_stih410-b2260 = " file://b2260.config "

#---------------------------------------
# Kernel Args
#
KERNEL_EXTRA_ARGS += "LOADADDR=${ST_KERNEL_LOADADDR} \
        TEXT_OFFSET=0x00008000 "
