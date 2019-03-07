FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${PV}:"

include recipes-kernel/linux/linux-st.inc
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=bbea815ee2795b2f4230826c0c6b8814"

SRC_URI = "https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.0.tar.xz;name=kernel"
SRC_URI[kernel.md5sum] = "7381ce8aac80a01448e065ce795c19c0"
SRC_URI[kernel.sha256sum] = "437b141a6499159f5a7282d5eb4b2be055f8e862ccce44d7464e8759c31a2e43"

SRC_URI_append_stih410-b2260 = " \
    file://0001-5.0-ST-misc.patch \
    file://0002-5.0-ST-devicetree.patch \
"

S = "${WORKDIR}/linux-5.0"

LINUX_VERSION = "5.0"

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

# with kernel 5.0 oldnoconfig are not more supported
KERNEL_CONFIG_COMMAND = "oe_runmake_call -C ${S} CC="${KERNEL_CC}" O=${B} olddefconfig || oe_runmake -C ${S} O=${B} CC="${KERNEL_CC}" oldnoconfig"

#---------------------------------------
# Kernel Args
#
KERNEL_EXTRA_ARGS += "LOADADDR=${ST_KERNEL_LOADADDR} \
        TEXT_OFFSET=0x00008000 "
