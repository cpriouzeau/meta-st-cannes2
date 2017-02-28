FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append_stih410-b2260 = " \
    file://wallpaper_1920x1080.png \
    file://weston.ini \
    "

do_install_append_stih410-b2260() {
    install -d ${D}${sysconfdir}/default/
    if ${@bb.utils.contains('MACHINE_FEATURES', 'gpu', 'false', 'true', d)}; then
        echo "OPTARGS=--use-pixman" > ${D}${sysconfdir}/default/weston
    fi

    install -d ${D}usr/share/weston/
    install -D -p -m0644 ${WORKDIR}/wallpaper_1920x1080.png ${D}/usr/share/weston/wallpaper_1920x1080.png

    install -d ${D}${sysconfdir}/xdg/weston/
    install -D -p -m0644 ${WORKDIR}/weston.ini ${D}${sysconfdir}/xdg/weston/weston.ini
}

FILES_${PN}_append_stih410-b2260 = " ${datadir}/weston "
CONFFILES_${PN} += "${sysconfdir}/xdg/weston/weston.ini"

