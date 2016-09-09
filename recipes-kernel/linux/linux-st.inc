DESCRIPTION = "Linux STI Kernel"
SECTION = "kernel"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=d7810fab7487fb0aad327b76f1be7cd7"

inherit kernel

LINUX_VERSION ?= "4.6"
B = "${WORKDIR}/linux-${MACHINE}-standard-build"

# -------------------------------------------------------------
# DTB
do_compile_kerneldtb() {
    unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS MACHINE
    bbnote "Kernel customized: compilation of device tree file"
    if [ ! -z ${DTC_FLAGS} ]; then
        oe_runmake ${PARALLEL_MAKE} -C ${S} O=${B} CC="${KERNEL_CC}" LD="${KERNEL_LD}" DTC_FLAGS="${DTC_FLAGS}" dtbs V=1
    else
        oe_runmake ${PARALLEL_MAKE} -C ${S} O=${B} CC="${KERNEL_CC}" LD="${KERNEL_LD}" dtbs V=1
    fi
    if test -n "${KERNEL_DEVICETREE}"; then
        for DTB in ${KERNEL_DEVICETREE}; do
            if echo ${DTB} | grep -q '/dts/'; then
                bbwarn "${DTB} contains the full path to the dts file, but only the dtb name should be used."
                DTB=`basename ${DTB} | sed 's,\.dts$,.dtb,g'`
            fi
            if [ ! -f ${B}/arch/${ARCH}/boot/dts/${DTB} ]; then
                bberror "Cannot find ${DTB} file from ${B}/arch/${ARCH}/boot/dts/."
            else
                cp -f ${B}/arch/${ARCH}/boot/dts/${DTB} ${B}/arch/${ARCH}/boot/
            fi
        done
    else
        bbnote "no dtb file to copy into ${B}/arch/${ARCH}/boot/"
    fi
}
addtask compile_kerneldtb after do_compile_kernelmodules before do_install

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
    if test -n "${KERNEL_DEVICETREE}"; then
        for DTB in ${KERNEL_DEVICETREE}; do
            if echo ${DTB} | grep -q '/dts/'; then
                bbwarn "${DTB} contains the full path to the dts file, but only the dtb name should be used."
                DTB=`basename ${DTB} | sed 's,\.dts$,.dtb,g'`
            fi
            DTB_NAME=`echo ${DTB} | sed "s/\.dtb//g"`
            DTB_PATH="${B}/arch/${ARCH}/boot/${DTB}"
            install -d ${D}/${KERNEL_IMAGEDEST}
            install -m 0644 ${DTB_PATH} ${D}/${KERNEL_IMAGEDEST}/devicetree-${DTB_NAME}.dtb
            cd ${D}/${KERNEL_IMAGEDEST}
            ln -sf devicetree-${DTB_NAME}.dtb ${DTB_NAME}.dtb
            rm -f devicetree-uImage-${DTB_NAME}.dtb
            cd -
        done
    else
        bbwarn "KERNEL_DEVICETREE is empty: no dtb file installed in folder ${D}/${KERNEL_IMAGEDEST}"
    fi
    cmdline_install
}

# ---------------------------------------------------------------------
do_deploy_append() {
    if test -n "${KERNEL_DEVICETREE}"; then
        for DTB in ${KERNEL_DEVICETREE}; do
            if echo ${DTB} | grep -q '/dts/'; then
                bbwarn "${DTB} contains the full path to the dts file, but only the dtb name should be used."
                DTB=`basename ${DTB} | sed 's,\.dts$,.dtb,g'`
            fi
            DTB_BASE_NAME=`basename ${DTB} .dtb`
            DTB_NAME=`echo ${KERNEL_IMAGE_BASE_NAME} | sed "s/${MACHINE}/${DTB_BASE_NAME}/g"`
            DTB_PATH="${B}/arch/${ARCH}/boot/${DTB}"
            install -d ${DEPLOYDIR}
            install -m 0644 ${DTB_PATH} ${DEPLOYDIR}/${DTB_NAME}.dtb
            cd ${DEPLOYDIR}
            ln -sf ${DTB_NAME}.dtb ${DTB_BASE_NAME}.dtb
            cd -
        done
    else
        bbwarn "KERNEL_DEVICETREE is empty: no dtb file installed in folder ${DEPLOYDIR}"
    fi
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
    if not d.getVar('STM_KERNEL_LOADADDR'):
        bb.fatal('Missing STM_KERNEL_LOADADDR value for STM kernel build: please define it in your machine.')
}

PACKAGES =+ "kernel-headers"
FILES_kernel-headers = "${exec_prefix}/src/linux*"
FILES_kernel-image  += "boot/ ${KERNEL_IMAGEDEST}"
