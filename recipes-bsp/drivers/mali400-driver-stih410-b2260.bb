SUMMARY = "Mali400 kernel driver"
DESCRIPTION = "Mali400 kernel driver"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://LICENSE;md5=6f900d9bafc8f178413b0fb082e76ce5"

inherit module

COMPATIBLE_MACHINE = "stih410-b2260"

DEPENDS = "virtual/kernel"

PV_MALI ="r6p1"
PR_MALI ="01rel0"

MALI_DV="${PV_MALI}-${PR_MALI}"

PV="${PV_MALI}"
PR="${PR_MALI}"

SRC_URI = " \
    https://armkeil.blob.core.windows.net/developer//sitecore/shell/-/media/Files/downloads/mali-drivers/kernel/mali-utgard-gpu/DX910-SW-99002-r6p1-01rel0.tgz \
    file://0001-Add-license.patch \
    file://0002-platform-add-ST-platform-supporting-device-tree.patch \
    file://0003-mali-replace-PAGE_CACHE_-and-page_cache_-get-release.patch \
    file://0004-mali-replace-get_unused_fd-by-get_unused_fd_flags-0.patch \
    file://0005-mali-use-dma_xxx_writecombine-instead-of-dma_attrs_w.patch \
    file://0006-mali-fix-mali_gp_job_create-page-domain-fault.patch \
    \
    file://0007-mali-fix-build-with-linux-kernel-4.10.patch \
    file://0008-mali-replace-asm-uaccess.h-by-linux-uaccess.h.patch \
    file://0009-mali-replace-__GFP_REPEAT-by-__GFP_RETRY_MAYFAIL.patch \
    file://0010-Kernel-4.14-renane-global_page_state-to-global_zone_.patch \
    \
    file://69-mali400-stih410-b2260.rules \
    "


SRC_URI[md5sum] = "86800f52a1a66a435318a7ee5e4801cc"
SRC_URI[sha256sum] = "73c614884ee42b655ff1d033d58f7b121172bb659b959ba62db40473afdd979c"

S = "${WORKDIR}/DX910-SW-99002-r6p1-01rel0/driver/"

# Note: It is possible to use BUILD=debug or BUILD=release
EXTRA_OEMAKE  = "KDIR=${STAGING_KERNEL_BUILDDIR}"
EXTRA_OEMAKE += "MALI_PLATFORM=st"
EXTRA_OEMAKE += "BUILD=release"
EXTRA_OEMAKE += "USING_DT=1"
EXTRA_OEMAKE += "USING_UMP=0"
EXTRA_OEMAKE += "USING_PROFILING=0"
EXTRA_OEMAKE += "USING_DVFS=0"
EXTRA_OEMAKE += "MALI_DMA_BUF_MAP_ON_ATTACH=0"

do_compile() {
  oe_runmake -C ${S}/src/devicedrv/mali
}

do_install() {
  install -d ${D}/lib/modules/${KERNEL_VERSION}
  install -m 0755 ${S}/src/devicedrv/mali/mali.ko ${D}/lib/modules/${KERNEL_VERSION}/mali.ko

  install -d ${D}${sysconfdir}/udev/rules.d/
  install -m 0644 ${WORKDIR}/69-mali400-stih410-b2260.rules ${D}${sysconfdir}/udev/rules.d/
}


FILES_${PN} =+ "${sysconfdir}/udev/rules.d/"
