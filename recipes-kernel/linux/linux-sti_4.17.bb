FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${PV}:"

include recipes-kernel/linux/linux-st.inc

SRC_URI = "https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.17.2.tar.xz;name=kernel"
SRC_URI[kernel.md5sum] = "dfe836c521c754a3f54f5f535f2ea588"
SRC_URI[kernel.sha256sum] = "4cebcd6f4ddc49e68543a6d920582d9e0eca431be89f9c1b85fd4ecf1dd87b9c"

SRC_URI_append_stih410-b2260 = " \
    file://0001-4.17-ST-BDISP-V4l2.patch \
    file://0002-4.17-ST-misc.patch \
    file://0003-4.17-ST-devicetree.patch \
    file://0004-4.17-ST-devicetree-fixup-IRQ_TYPE_NONE.patch \
    file://0005-4.17-ST-defconfig.patch \
"

S = "${WORKDIR}/linux-4.17.2"

LINUX_VERSION = "4.17"

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
