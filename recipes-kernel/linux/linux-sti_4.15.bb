FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${PV}:"

include recipes-kernel/linux/linux-st.inc

SRC_URI = "https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.15.3.tar.xz;name=kernel"
SRC_URI[kernel.md5sum] = "c74d30ec13491aeb24c237d703eace3e"
SRC_URI[kernel.sha256sum] = "8fb86ea1b7144ed6c86542b74159e3cd8b9009943330987e49322760a300b714"

SRC_URI_append_stih410-b2260 = " \
    file://0001-4.15-ST-BDISP-V4l2.patch \
    file://0002-4.15-ST-misc.patch \
    file://0003-4.15-ST-devicetree.patch \
    file://0004-4.15-ST-configuration.patch \
"

S = "${WORKDIR}/linux-4.15.3"

LINUX_VERSION = "4.15"

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
