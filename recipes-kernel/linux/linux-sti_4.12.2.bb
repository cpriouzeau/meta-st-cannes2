FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${PV}:"

include recipes-kernel/linux/linux-st.inc

SRC_URI = "https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.12.2.tar.xz;name=kernel"
SRC_URI[kernel.md5sum] = "a61922df59b3ff54fcf418d2b8a0ab70"
SRC_URI[kernel.sha256sum] = "0a7a852eba28293e6d9bc9e09d4541d8f6ffe46f7ac632c54a7d85b597f185e2"

SRC_URI_append_stih410-b2260 = " \
    file://0001-4.12.2-ST-DRM.patch \
    file://0002-4.12.2-ST-BDISP-V4l2.patch \
    file://0003-4.12.2-ST-misc.patch \
    file://0004-4.12.2-ST-devicetree.patch \
    file://0005-4.12.2-ST-configuration.patch \
"

S = "${WORKDIR}/linux-4.12.2"
B = "${WORKDIR}/linux-${MACHINE}-standard-build"

LINUX_VERSION = "4.12.2"

PR = "r0"
PV = "${LINUX_VERSION}"

COMPATIBLE_MACHINE = "stih410-b2260"

#---------------------------------------
# Defconfig
#
KERNEL_DEFCONFIG         = "multi_v7_defconfig"
KERNEL_CONFIG_FRAGMENTS  = "${THISDIR}/${PN}/${PV}/systemd.config"
KERNEL_CONFIG_FRAGMENTS  = "${WORKDIR}/systemd.config"
SRC_URI_append_stih410-b2260 = " file://systemd.config "

#---------------------------------------
# Kernel Args
#
KERNEL_EXTRA_ARGS += "LOADADDR=${ST_KERNEL_LOADADDR} \
        TEXT_OFFSET=0x00008000 "
