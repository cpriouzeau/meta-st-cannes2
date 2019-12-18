FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${PV}:"

include recipes-kernel/linux/linux-st.inc
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=bbea815ee2795b2f4230826c0c6b8814"

SRC_URI = "https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.4.3.tar.xz;name=kernel"
SRC_URI[kernel.md5sum] = "d4aa766f1d02e89e599428032d0925e9"
SRC_URI[kernel.sha256sum] = "6731682f32e1b1ee53b0e7f66b8dc263d25a0e809e78e2139cb0ed77c378ee51"

SRC_URI_append_stih410-b2260 = " \
    file://0001-5.4-ST-misc.patch \
    file://0002-5.4-ST-devicetree.patch \
"

S = "${WORKDIR}/linux-5.4.3"

LINUX_VERSION = "5.4"

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
