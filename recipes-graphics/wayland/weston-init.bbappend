FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append_stih410-b2260 = " \
    file://wallpaper_1920x1080.png \
    file://weston.ini \
    file://71-weston-drm.rules \
    file://weston@.service \
    "

inherit systemd

do_install_append_stih410-b2260() {
    install -d ${D}${sysconfdir}/default/
    if ${@bb.utils.contains('MACHINE_FEATURES', 'gpu', 'false', 'true', d)}; then
        echo "OPTARGS=--use-pixman" > ${D}${sysconfdir}/default/weston
    fi

    install -d ${D}usr/share/weston/
    install -D -p -m0644 ${WORKDIR}/wallpaper_1920x1080.png ${D}/usr/share/weston/wallpaper_1920x1080.png

    install -d ${D}${sysconfdir}/xdg/weston/
    install -D -p -m0644 ${WORKDIR}/weston.ini ${D}${sysconfdir}/xdg/weston/weston.ini

    # due to a bug on allocation of buffer on Mali GPU implementation (userland),
    # it's not possible to launch weston with a user different of root.
    install -D -p -m0644 ${WORKDIR}/71-weston-drm.rules \
        ${D}${sysconfdir}/udev/rules.d/71-weston-drm.rules

    # Remove upstream weston.service
    if [ -f ${D}${systemd_unitdir}/system/weston.service ]; then
        rm ${D}${systemd_unitdir}/system/weston.service
    fi

    # Install Weston systemd service and accompanying udev rule
    install -D -p -m0644 ${WORKDIR}/weston@.service ${D}${systemd_unitdir}/system/weston@.service
    sed -i -e s:/etc:${sysconfdir}:g \
           -e s:/usr/bin:${bindir}:g \
           -e s:/var:${localstatedir}:g \
              ${D}${systemd_unitdir}/system/weston@.service
}

FILES_${PN}_append_stih410-b2260 = " ${datadir}/weston "
CONFFILES_${PN} += "${sysconfdir}/xdg/weston/weston.ini"

SYSTEMD_SERVICE_${PN} = "weston@%i.service"
SYSTEMD_AUTO_ENABLE = "disable"
