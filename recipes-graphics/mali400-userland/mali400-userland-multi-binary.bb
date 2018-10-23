# Recipe for installing mali400-userland binaries (multi backends such as drm/gbm and wayland)
SUMMARY = "ARM Mali400 libraries OpenGL ES, OpenVG and EGL (multi backends such as drm/gbm and wayland)"
DESCRIPTION  = "STMicrolectronics port of the EGL, GLESv1_CM, GLES_v2 waylandegl libraries from ARM for the mali400 3D core."

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${TAR_PATH_NAME}/LICENSE;md5=b1772c0bd3da4c0a84e514bcaf9d39c6"

DEPENDS += " mali400-driver-stih410-b2260 libdrm wayland "

BACKEND="multi"

PV_MALI ="r6p1"
PR_MALI ="01rel0"

COMPATIBLE_MACHINE = "stih410-b2260"
PACKAGE_ARCH = "${MACHINE_ARCH}"

PROVIDES += "mali400-userland virtual/libgles1 virtual/libgles2 virtual/egl virtual/libvg virtual/libgbm"

PV="${PV_MALI}"
PR="${PR_MALI}+binary${SRCPV}"

SRC_URI= "git://github.com/STMicroelectronics/Mali-400-ST-build-for-B2260.git;protocol=https;branch=master"
SRCREV = "d4f89159849807e1753a2ce76d76bc68c2085896"

# for include file
SRC_URI += "https://mesa.freedesktop.org/archive/mesa-17.3.8.tar.xz;name=mesa"
SRC_URI[mesa.md5sum] = "203d1a79156ab6926f2d253b377e9d9d"
SRC_URI[mesa.sha256sum] = "8f9d9bf281c48e4a8f5228816577263b4c655248dc7666e75034ab422951a6b1"
MESA_S = "${WORKDIR}/mesa-17.3.8"

S = "${WORKDIR}/git"

# -----------------------------------
TAR_FILENAME_WAYLAND="mali400-userland-multi-DRM-WAYLAND-STiH410-B2260-${PV_MALI}-${PR_MALI}-20170831"
TAR_PATH_NAME_WAYLAND="mali400-userland-multi-wayland-drm-${PV_MALI}-${PR_MALI}-20170831"

TAR_FILENAME_FBDEV="mali400-userland-multi-DRM-FBDEV-STiH410-B2260-${PV_MALI}-${PR_MALI}-20170831"
TAR_PATH_NAME_FBDEV="mali400-userland-multi-drm-fbdev-${PV_MALI}-${PR_MALI}-20170831"

def get_gpu_mali_config_handler_for_tar_filename(d):
    distro_features = d.getVar('DISTRO_FEATURES', True).split()

    if 'wayland' in distro_features:
        return d.getVar('TAR_FILENAME_WAYLAND', True)
    else:
        return d.getVar('TAR_FILENAME_FBDEV', True)

def get_gpu_mali_config_handler_for_tar_path(d):
    distro_features = d.getVar('DISTRO_FEATURES', True).split()

    if 'wayland' in distro_features:
        return d.getVar('TAR_PATH_NAME_WAYLAND', True)
    else:
        return d.getVar('TAR_PATH_NAME_FBDEV', True)

TAR_FILENAME = "${@get_gpu_mali_config_handler_for_tar_filename(d)}"
TAR_PATH_NAME = "${@get_gpu_mali_config_handler_for_tar_path(d)}"

MALI_TARBALL_NAME="${TAR_FILENAME}.tar.xz"

#------------------------------------------
# Override do_unpack to manage EULA
#
python do_unpack() {
    eula = d.getVar('ACCEPT_EULA_'+d.getVar('MACHINE', True), True)
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
# Overwrite of do_patch to untar the tarball
do_patch[depends] += "xz-native:do_populate_sysroot"
do_patch() {
    cd ${S}
    tar xfJ ${MALI_TARBALL_NAME}
}


#------------------------------------------
#
do_install() {
    install -m 755 -d ${D}/usr/
    cp -R ${S}/${TAR_PATH_NAME}/usr ${D}/

    # Do not use the include provided by mali400-userland tarball
    for d in EGL GLES GLES2 KHR;
    do
        rm -rf ${D}/usr/include/$d
    done

    # install mesa include instead of mali400-userland include
    for d in EGL GLES GLES2 KHR;
    do
        install -d ${D}/usr/include/$d
        install -m 644 ${MESA_S}/include/$d/* ${D}/usr/include/$d/
    done
    # disable X11
    sed -i -e 's|^#if defined(MESA_EGL_NO_X11_HEADERS)$|#if 1 /*defined(MESA_EGL_NO_X11_HEADERS)*/ |' ${D}${includedir}/EGL/eglplatform.h

}

# Cannot split or strip last added libraries
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INHIBIT_PACKAGE_STRIP = "1"

# Avoid QA Issue: non -dev/-dbg/nativesdk- package contains symlink .so
INSANE_SKIP_${PN} += "dev-so"

# Monolitic configuration
RPROVIDES_${PN}  = "libegl libegl1 libgles1 libglesv1-cm1 libgles2 libglesv2-2 libvg libgbm"
RREPLACES_${PN}  = "libegl libegl1 libgles1 libglesv1-cm1 libgles2 libglesv2-2 libvg libgbm"
RCONFLICTS_${PN} = "libegl libegl1 libgles1 libglesv1-cm1 libgles2 libglesv2-2 libvg libgbm"

PACKAGES = "${PN} ${PN}-dev ${PN}-debug"

SUMMARY_${PN} = "${SUMMARY}"
FILES_${PN}   =+ "${libdir}/*.so"

SUMMARY_${PN}-dev  = "${SUMMARY_${PN}} - Development files"

FILES_${PN}-debug   = " ${libdir}/libMali*.debug.so ${libdir}/libMali*.instrumented.so "

