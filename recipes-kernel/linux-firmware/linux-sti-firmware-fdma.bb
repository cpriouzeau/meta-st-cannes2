SUMMARY = "ST STI firmware"
DESCRIPTION = "FDMA firmware for STI platform"
SECTION = "kernel"
LICENSE = "Firmware-st-fdma"
LIC_FILES_CHKSUM = "file://LICENSE;md5=c7a646e9358d43a28b831a578e0d8815"

COMPATIBLE_MACHINE = "(stih410-b2260)"

PACKAGE_ARCH = "${MACHINE_ARCH}"

SRC_URI = "https://raw.githubusercontent.com/STMicroelectronics/ST-Firmware-for-B2260/master/linux-sti-firmware-fdma_20170406.tar.xz"
SRC_URI[md5sum] = "43baeda35b790c66ce419644d39c51d8"
SRC_URI[sha256sum] = "9922e11c17df2470433d832cf5cb7fc6150460319e16f44855d281d67391246c"

S = "${WORKDIR}/linux-sti-firmware-fdma_20170406"

PV = "1.0"
PR = "binary-20170406"

#------------------------------------------
# Override do_unpack to manage EULA
#
python do_unpack() {
    eula = d.getVar('ACCEPT_EULA_'+ d.getVar('MACHINE', True), True)
    eula_file = d.getVar('EULA_FILE_ST', True)
    pkg = d.getVar('PN', True)
    if eula == None:
        bb.fatal("To use '%s' you need to accept the STMicroelectronics EULA at '%s'. "
                 "Please read it and in case you accept it, write: "
                 "ACCEPT_EULA_%s = \"1\" in your local.conf." % (pkg, eula_file, d.getVar('MACHINE', True)))
    elif eula == '0':
        bb.fatal("To use '%s' you need to accept the STMicroelectronics EULA." % pkg)
    else:
        bb.note("STMicroelectronics EULA has been accepted for '%s'" % pkg)

    try:
        bb.build.exec_func('base_do_unpack', d)
    except:
        raise
}


#------------------------------------------
#
do_install () {
    install -d ${D}${base_libdir}/firmware
    install -m 0644 ${S}/*.elf ${D}${base_libdir}/firmware
}

# We can't have sanity checks on the architecture, since the firmware is a different one:
# ERROR: QA Issue: Architecture did not match (Unknown (102), expected ARM) on .../lib/firmware/fdma_STiH407_0.elf [arch]
INSANE_SKIP_${PN} = "arch"

FILES_${PN} += "${base_libdir}/firmware"
MAINTAINER_${PN} = "STMicroelectronics"
NO_GENERIC_LICENSE[Firmware-st-fdma] = "LICENSE"
LICENSE_${PN} = "Firmware-st-fdma"

