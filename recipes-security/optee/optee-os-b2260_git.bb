FILESEXTRAPATHS_prepend := "${THISDIR}/optee-os:"

include optee-os.inc
include optee-os-config-b2260.inc

inherit pythonnative

SRCREV = "28fcee179fc908ee2001a135179366d794af7878"

PV = "2.3.0"
PR = "git${SRCPV}.r0"

COMPATIBLE_MACHINE = "stih410-b2260"

PROVIDES += "optee-os"

#only if meta-linaro/meta-optee are present
DEPENDS =+ "python-wand-native python-pycrypto-native"


do_install_append_stih410-b2260() {
    install -d ${D}${base_libdir}/firmware/optee
    install -m 644 ${B}/out/${TARGET_ARCH}-plat-${OPTEE_PLATFORM}/core/tee.bin ${D}${base_libdir}/firmware/optee/tee-${OPTEE_BOARD_NAME}.bin

    #install TA devkit
    install -d ${D}${includedir}/optee/export-user_ta/
    for f in  ${B}/out/arm-plat-${OPTEE_PLATFORM}/export-ta_${OPTEE_ARCH}/* ; do
        cp -aR  $f ${D}${includedir}/optee/export-user_ta/
    done
}

# deploy image according to our needs
do_deploy_append_stih410-b2260() {
    install -d ${DEPLOYDIR}/${OPTEE_DEPLOY_PATH}
    if [ -f ${DEPLOYDIR}/${OPTEE_DEPLOY_PATH}/optee-${OPTEE_BOARD_NAME}.bin ];
    then
        rm -f ${DEPLOYDIR}/${OPTEE_DEPLOY_PATH}/optee-${OPTEE_BOARD_NAME}.bin
    fi
    install -m 644 ${B}/out/${TARGET_ARCH}-plat-${OPTEE_PLATFORM}/core/tee.bin ${DEPLOYDIR}/${OPTEE_DEPLOY_PATH}/optee.bin
}
