FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${PV}:"

include recipes-kernel/linux/linux-st.inc

SRC_URI = "https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.6.4.tar.xz;name=kernel"
SRC_URI[kernel.md5sum] = "b9f8183fa26621f9951ae522556c12d3"
SRC_URI[kernel.sha256sum] = "8568d41c7104e941989b14a380d167129f83db42c04e950d8d9337fe6012ff7e"

SRC_URI_append_stih410-b2260 = " \
    file://0001-V4l2-bdisp-hva-delta.patch \
    file://0002-SMAF.patch \
    file://0003-ST-FDMA.patch \
    file://0004-CLOCK.patch \
    file://0005-SOUND.patch \
    file://0006-DRM-KMS.patch \
    file://0007-REMOTEPROC-RPMSG.patch \
    file://0008-SECURITY.patch \
    file://0009-V4L2-CORE.patch \
    file://0010-Devicetree.patch \
    file://0011-Others.patch \
    file://0012-DEFCONFIG.patch \
    "

S = "${WORKDIR}/linux-4.6.4"
B = "${WORKDIR}/linux-${MACHINE}-standard-build"

LINUX_VERSION = "4.6"

PR = "r0"
PV = "${LINUX_VERSION}"

COMPATIBLE_MACHINE = "stih410-b2260"

#---------------------------------------
# Defconfig
#
KERNEL_DEFCONFIG         = "multi_v7_defconfig"
KERNEL_CONFIG_FRAGMENTS  = "${THISDIR}/${PN}/${PV}/systemd.config"

#---------------------------------------
# Kernel Args
#
KERNEL_EXTRA_ARGS += "LOADADDR=${ST_KERNEL_LOADADDR} \
        TEXT_OFFSET=0x00008000 "

#---------------------------------------
# Mali400
#
SRC_URI_append_stih410-b2260 = " \
    http://malideveloper.arm.com/downloads/drivers/DX910/r6p0-01rel0/DX910-SW-99002-r6p0-01rel0.tgz;name=mali \
    file://END_USER_LICENCE_AGREEMENT.txt \
    file://0001-MALI400-platform-add-ST-platform-supporting-device-t.patch \
    file://0002-MALI400-mali-replace-PAGE_CACHE_-and-page_cache_-get.patch \
    file://0003-MALI400-mali-replace-get_unused_fd-by-get_unused_fd_.patch \
    file://0004-MALI400-drivers-gpu-arm-utgard-Fix-build-issue.patch \
    file://0005-MALI400-drivers-gpu-Add-ARM-Mali-Utgard-r6p0-driver.patch \
    "

SRC_URI[mali.md5sum] = "49a03a4e765cfe5e87cccfdef97f9208"
SRC_URI[mali.sha256sum] = "15813d964cb9308c236a7c71f8e2d8f346b13fa8ff6c8b3bd7e521ef123c1254"


# Mali 400/450 GPU kernel device drivers license is GPLv2
LIC_FILES_CHKSUM_stih410-b2260 = "file://END_USER_LICENCE_AGREEMENT.txt;md5=450d710cd9d21c5ea5c4ac4217362b7e"

KERNEL_CONFIG_FRAGMENTS_append_stih410-b2260 = " ${THISDIR}/${PN}/${PV}/mali400.conf "

do_unpack_append_stih410-b2260() {
    bb.build.exec_func('do_unpack_mali_drv', d)
}

do_unpack_mali_drv() {
    if [ -d ${WORKDIR}/DX910-SW-99002-r6p0-01rel0/ ]; then
        cp ${WORKDIR}/END_USER_LICENCE_AGREEMENT.txt ${S}/
        mkdir -p ${S}/drivers/gpu/arm
        mv ${WORKDIR}/DX910-SW-99002-r6p0-01rel0/driver/src/devicedrv/mali \
            ${S}/drivers/gpu/arm/utgard
    fi
}


