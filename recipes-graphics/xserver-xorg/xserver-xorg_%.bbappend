FILESEXTRAPATHS_append := ":${THISDIR}/${PN}"

SRC_URI_append = " file://11-evdev.conf "

do_install_append() {
    install -d ${D}/usr/share/X11/xorg.conf.d/
	install -m 0644 ${WORKDIR}/11-evdev.conf ${D}/usr/share/X11/xorg.conf.d/11-evdev-video-modesetting.conf
}
