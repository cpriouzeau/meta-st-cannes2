SUMMARY = "RTL8723 kernel driver (wifi + bluetooth)"
DESCRIPTION = "RTL8723 kernel driver"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://Kconfig;md5=ce4c7adf40ddcf6cfca7ee2b333165f0"

SRC_URI = "git://github.com/lwfinger/rtl8723bu.git;protocol=https"
SRCREV = "80916328932fa763bf4e37979aae70bd5e62da59"

S = "${WORKDIR}/git"

PV = "1.0-git-${SRCPV}"

# add support for ARM platform
SRC_URI =+ "file://0001-ARM-Support.patch \
            file://0002-realtek-Disable-IPS-mode.patch \
            "

DEPENDS = "virtual/kernel"
COMPATIBLE_MACHINE = "stih410-b2260"

inherit module

# do_make_script generate error on kernel
# extract-cert.c:21:25: fatal error: openssl/bio.h:
DEPENDS += "openssl-native"
KERNEL_HOST_EXTRACFLAGS += "-I${STAGING_INCDIR_NATIVE} -L${STAGING_LIBDIR_NATIVE}"
export HOST_EXTRACFLAGS = "${KERNEL_HOST_EXTRACFLAGS}"

EXTRA_OEMAKE  = "ARCH=arm"
EXTRA_OEMAKE += "KSRC=${STAGING_KERNEL_BUILDDIR}"

do_compile () {
    oe_runmake
}

do_install () {
    install -d ${D}/lib/modules/${KERNEL_VERSION}
    install -m 0755 ${B}/8723bu.ko ${D}/lib/modules/${KERNEL_VERSION}/8723bu.ko
}

