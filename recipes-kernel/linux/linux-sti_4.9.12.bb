FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${PV}:"

include recipes-kernel/linux/linux-st.inc

SRC_URI = "https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.9.12.tar.xz;name=kernel"
SRC_URI[kernel.md5sum] = "073dfb3a13bf5836ef2d66e24ccf2ceb"
SRC_URI[kernel.sha256sum] = "fcad54878e98638a2a95d32059ed14a5ef296296d6e408bce6932b80d61b783b"

SRC_URI_append_stih410-b2260 = " \
    file://0001-4.9.12-ST-DRM.patch \
    file://0002-4.9.12-ST-BDISP-HVA-V4l2.patch \
    file://0003-4.9.12-ST-misc.patch \
    file://0004-4.9.12-ST-devicetree.patch \
    file://0005-ARM-dts-STiH407-family-set-snps-dis_u3_susphy_quirk.patch \
    file://0006-ARM-dts-STiH407-family-Add-missing-pwm-irq.patch \
    file://0007-4.9.12-ST-configuration.patch \
"

S = "${WORKDIR}/linux-4.9.12"
B = "${WORKDIR}/linux-${MACHINE}-standard-build"

LINUX_VERSION = "4.9.12"

PR = "r0"
PV = "${LINUX_VERSION}"

COMPATIBLE_MACHINE = "stih410-b2260"

#---------------------------------------
# Defconfig
#
KERNEL_DEFCONFIG         = "multi_v7_defconfig"
#KERNEL_CONFIG_FRAGMENTS  = "${THISDIR}/${PN}/${PV}/systemd.config"
KERNEL_CONFIG_FRAGMENTS  = "${WORKDIR}/systemd.config"
SRC_URI_append_stih410-b2260 = "file://systemd.config"

#---------------------------------------
# Kernel Args
#
KERNEL_EXTRA_ARGS += "LOADADDR=${ST_KERNEL_LOADADDR} \
        TEXT_OFFSET=0x00008000 "

