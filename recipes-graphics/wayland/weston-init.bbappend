FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append_stih410-b2260 = " file://wallpaper_1920x1080.png "

do_install_append_stih410-b2260() {
    install -d ${D}${sysconfdir}/default/
    echo "OPTARGS=--use-pixman" > ${D}${sysconfdir}/default/weston

    install -d ${D}usr/share/weston/
    install -D -p -m0644 ${WORKDIR}/wallpaper_1920x1080.png ${D}/usr/share/weston/wallpaper_1920x1080.png
}

FILES_${PN}_append_stih410-b2260 = " ${datadir}/weston "
