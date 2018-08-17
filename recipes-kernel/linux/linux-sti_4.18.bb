FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${PV}:"

include recipes-kernel/linux/linux-st.inc

SRC_URI = "https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.18.1.tar.xz;name=kernel"
SRC_URI[kernel.md5sum] = "70b08b4bb5bfe1783d79cd41e2303970"
SRC_URI[kernel.sha256sum] = "725fadc6e9d5a1ad6d7269bb75b256bccac5372927995ad0408c059d110cfa42"

SRC_URI_append_stih410-b2260 = " \
    file://0001-4.18-ST-BDISP-V4l2.patch \
    file://0002-4.18-ST-misc.patch \
    file://0003-4.18-ST-devicetree.patch \
"

S = "${WORKDIR}/linux-4.18.1"

LINUX_VERSION = "4.18"

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
