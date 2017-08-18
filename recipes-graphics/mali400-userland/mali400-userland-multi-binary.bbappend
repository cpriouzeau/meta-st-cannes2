do_install_append() {
	if [ -e ${D}/${libdir}/pkgconfig/gbm.pc ];
	then
		sed -e "s/Version: 10.4.4/Version: 13.0/g" -i ${D}/${libdir}/pkgconfig/gbm.pc
	fi
	sed -e "s/Version: 10.4.4/Version: 13.0/g" -i ${D}/${libdir}/pkgconfig/egl.pc
	sed -e "s/Version: 10.4.4/Version: 13.0/g" -i ${D}/${libdir}/pkgconfig/glesv1_cm.pc
	sed -e "s/Version: 10.4.4/Version: 13.0/g" -i ${D}/${libdir}/pkgconfig/glesv2.pc
	if [ -e ${D}/${libdir}/pkgconfig/vg.pc ];
	then
		sed -e "s/Version: 10.4.4/Version: 13.0/g" -i ${D}/${libdir}/pkgconfig/vg.pc
	fi
	if [ -e ${D}/${libdir}/pkgconfig/wayland-egl.pc ];
	then
		sed -e "s/Version: 10.4.4/Version: 13.0/g" -i ${D}/${libdir}/pkgconfig/wayland-egl.pc
	fi
}
