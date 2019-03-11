SUMMARY = "Boot Loader configuration scripts"

LICENSE = "LGPLv2+"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/LGPL-2.0;md5=9427b8ccf5cf3df47c29110424c9641a"

# u-bootrom script templates
SRC_URI = "file://b2260"
SRC_URI += " file://extlinux.conf "

PV = "st-2018"

S = "${WORKDIR}"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit deploy

# ---------------------------------------------------------------------
do_install () {
    install -d ${D}/boot/extlinux

    install -m 0644 ${S}/extlinux.conf ${D}/boot/extlinux/

    install -d ${D}/boot/b2260
    install -m 0644 ${S}/b2260/* ${D}/boot/b2260/
}

FILES_${PN} = "/boot"

# ---------------------------------------------------------------------
do_deploy () {
    install -d ${DEPLOYDIR}/boot/extlinux

    install -d ${DEPLOYDIR}/boot/extlinux
    install -m 0644 ${S}/extlinux.conf ${DEPLOYDIR}/boot/extlinux/

    install -d ${DEPLOYDIR}/boot/b2260
    install -m 0644 ${S}/b2260/* ${DEPLOYDIR}/boot/b2260/
}

addtask deploy before do_build after do_compile
