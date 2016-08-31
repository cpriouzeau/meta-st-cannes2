FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${PV}:"
include recipes-kernel/linux/linux-stm.inc


SRC_URI = "https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.6.4.tar.xz"
SRC_URI[md5sum] = "b9f8183fa26621f9951ae522556c12d3"
SRC_URI[sha256sum] = "8568d41c7104e941989b14a380d167129f83db42c04e950d8d9337fe6012ff7e"

SRC_URI += "file://0001-V4l2-bdisp-hva-delta.patch"
SRC_URI += "file://0002-SMAF.patch"
SRC_URI += "file://0003-ST-FDMA.patch"
SRC_URI += "file://0004-CLOCK.patch"
SRC_URI += "file://0005-SOUND.patch"
SRC_URI += "file://0006-DRM-KMS.patch"
SRC_URI += "file://0007-REMOTEPROC-RPMSG.patch"
SRC_URI += "file://0008-SECURITY.patch"
SRC_URI += "file://0009-V4L2-CORE.patch"
SRC_URI += "file://0010-Devicetree.patch"
SRC_URI += "file://0011-Others.patch"
SRC_URI += "file://0012-DEFCONFIG.patch"

#ST_GIT_SERVER_URI ?= "git://gerrit.st.com:29418/"
#ST_GIT_SERVER_PROTOCOL ?= ";protocol=ssh"
#
#SRCBRANCH = "INT/oe_sti_v4.6_1.2"
#SRC_URI = "${ST_GIT_SERVER_URI}/oeivi/oe/st/linux-sti-4.6${ST_GIT_SERVER_PROTOCOL};branch=${SRCBRANCH}"
#SRCREV = "e469f32b3701697bab5236ac47ee2575b48555ee"

S = "${WORKDIR}/linux-4.6.4"
B = "${WORKDIR}/linux-${MACHINE}-standard-build"
# for devtool usage you need to specify the next line for externel source build dir
EXTERNALSRC_BUILD_pn-${PN} = "${WORKDIR}/linux-${MACHINE}-standard-build"

LINUX_VERSION = "4.6"

PR = "r0"
PV = "${LINUX_VERSION}"

#---------------------------------------
# Defconfig
#
KERNEL_DEFCONFIG         = "multi_v7_defconfig"
KERNEL_CONFIG_FRAGMENTS += "${THISDIR}/${PN}/${PV}/opensdk.config"

#---------------------------------------
# Kernel Args
#
KERNEL_EXTRA_ARGS += "LOADADDR=${STM_KERNEL_LOADADDR}"
KERNEL_EXTRA_ARGS += " TEXT_OFFSET=0x00008000 "

#Enable loadaddrcheck task
#addtask loadaddrcheck after do_configure before do_compile
