DESCRIPTION = "Linux STI Kernel"
SECTION = "kernel"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=bbea815ee2795b2f4230826c0c6b8814"

inherit kernel

LINUX_VERSION ?= "4.17"
B = "${WORKDIR}/linux-${MACHINE}-standard-build"

# ---------------------------------------------------------------------
# Defconfig
#
#If the defconfig is contained on the kernel tree (arch/${ARCH}/configs)
#you must use the following line
do_configure_prepend() {
    unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS MACHINE
    if [ ! -z ${KERNEL_DEFCONFIG} ];
    then
        bbnote "Kernel customized: configuration of linux STI by using DEFCONFIG: ${KERNEL_DEFCONFIG}"
        oe_runmake ${PARALLEL_MAKE} -C ${S} O=${B} CC="${KERNEL_CC}" LD="${KERNEL_LD}" ${KERNEL_DEFCONFIG}
    else
        if [ ! -z ${KERNEL_EXTERNAL_DEFCONFIG} ];
        then
            bbnote "Kernel customized: configuration of linux STI by using external DEFCONFIG"
            install -m 0644 ${WORKDIR}/${KERNEL_EXTERNAL_DEFCONFIG} ${B}/.config
            oe_runmake -C ${S} O=${B} CC="${KERNEL_CC}" LD="${KERNEL_LD}" oldconfig
        else
            bbwarn "You must specify KERNEL_DEFCONFIG or KERNEL_EXTERNAL_DEFCONFIG"
            die "NO DEFCONFIG SPECIFIED"
        fi
    fi

    if [ ! -z "${KERNEL_CONFIG_FRAGMENTS}" ]
    then
        for f in ${KERNEL_CONFIG_FRAGMENTS}
        do
            # Check if the config fragment was copied into the WORKDIR from
            # the OE meta data
            if [ ! -e "$f" ]
            then
                echo "Could not find kernel config fragment $f"
                exit 1
            fi
        done

        # Now that all the fragments are located merge them.
        (${S}/scripts/kconfig/merge_config.sh -m -r -O ${B} ${B}/.config ${KERNEL_CONFIG_FRAGMENTS} 1>&2 )
    fi

    yes '' | oe_runmake -C ${S} O=${B} CC="${KERNEL_CC}" LD="${KERNEL_LD}" oldconfig
}

# ---------------------------------------------------------------------
do_install_append() {
    cmdline_install
}

# ---------------------------------------------------------------------
do_deploy_append() {
    cmdline_deploy
}

# ---------------------------------------------------------------------
# Kernel COMMAND LINE
#
cmdline_install() {
    STI_CMDLINE_SD=`echo "${KERNEL_CMDLINE}" | sed "s;##ROOT##;/dev/mmcblk0p2;"`
    STI_CMDLINE_USB=`echo "${KERNEL_CMDLINE}" | sed "s;##ROOT##;/dev/sda2;"`
    install -d ${D}/boot
    echo "$STI_CMDLINE_SD" > ${D}/boot/cmdline_sdcard.txt
    echo "$STI_CMDLINE_SD ${KERNEL_CMDLINE_DEV_APPEND}" > ${D}/boot/cmdline_dev_sdcard.txt
    echo "$STI_CMDLINE_USB" > ${D}/boot/cmdline_usbkey.txt
    echo "$STI_CMDLINE_USB" > ${D}/boot/cmdline_dev_usbkey.txt
}
cmdline_deploy() {
    if [ -f ${D}/boot/cmdline_sdcard.txt ];
    then
        install -d ${DEPLOYDIR}/
        install -m 0644 ${D}/boot/cmdline_sdcard.txt ${DEPLOYDIR}/
        install -m 0644 ${D}/boot/cmdline_dev_sdcard.txt ${DEPLOYDIR}/
        install -m 0644 ${D}/boot/cmdline_usbkey.txt ${DEPLOYDIR}/
        install -m 0644 ${D}/boot/cmdline_dev_usbkey.txt ${DEPLOYDIR}/
    fi
}

# ---------------------------------------------------------------------
# Support checking the kernel load address parameter: expecting proper value for STM kernel.
#
python do_loadaddrcheck() {
    if not d.getVar('ST_KERNEL_LOADADDR', True):
        bb.fatal('Missing ST_KERNEL_LOADADDR value for ST kernel build: please define it in your machine.')
}

PACKAGES =+ "${KERNEL_PACKAGE_NAME}-headers"
FILES_${KERNEL_PACKAGE_NAME}-headers = "${exec_prefix}/src/linux*"
FILES_${KERNEL_PACKAGE_NAME}-image  += "boot/ ${KERNEL_IMAGEDEST}"
