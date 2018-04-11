FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${PV}:"

include recipes-kernel/linux/linux-st.inc

SRC_URI = "https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.16.1.tar.xz;name=kernel"
SRC_URI[kernel.md5sum] = "16123b843ad2efa394a060d8f72c91c2"
SRC_URI[kernel.sha256sum] = "5ba1c270ca6bc7927ad5f4698e0d61e558cce1a62249156a7aa44a6b4e0060c3"

SRC_URI_append_stih410-b2260 = " \
    file://0001-4.16-ST-BDISP-V4l2.patch \
    file://0002-4.16-ST-misc.patch \
    file://0003-4.16-ST-devicetree.patch \
    file://0004-4.16-ST-configuration.patch \
"

S = "${WORKDIR}/linux-4.16.1"

LINUX_VERSION = "4.16"

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
