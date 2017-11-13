FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${PV}:"

include recipes-kernel/linux/linux-st.inc

SRC_URI = "https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.14.tar.xz;name=kernel"
SRC_URI[kernel.md5sum] = "bacdb9ffdcd922aa069a5e1520160e24"
SRC_URI[kernel.sha256sum] = "f81d59477e90a130857ce18dc02f4fbe5725854911db1e7ba770c7cd350f96a7"

SRC_URI_append_stih410-b2260 = " \
    file://0001-4.14-ST-BDISP-V4l2.patch \
    file://0002-4.14-ST-misc.patch \
    file://0003-4.14-ST-devicetree.patch \
    file://0004-4.14-ST-configuration.patch \
"

S = "${WORKDIR}/linux-4.14"
B = "${WORKDIR}/linux-${MACHINE}-standard-build"

LINUX_VERSION = "4.14"

PR = "r0"
PV = "${LINUX_VERSION}"

COMPATIBLE_MACHINE = "stih410-b2260"

#---------------------------------------
# Defconfig
#
KERNEL_DEFCONFIG         = "multi_v7_defconfig"
#KERNEL_CONFIG_FRAGMENTS  = "${THISDIR}/${PN}/${PV}/systemd.config"
KERNEL_CONFIG_FRAGMENTS  = "${WORKDIR}/systemd.config"
SRC_URI_append_stih410-b2260 = " file://systemd.config "

#---------------------------------------
# Kernel Args
#
KERNEL_EXTRA_ARGS += "LOADADDR=${ST_KERNEL_LOADADDR} \
        TEXT_OFFSET=0x00008000 "
