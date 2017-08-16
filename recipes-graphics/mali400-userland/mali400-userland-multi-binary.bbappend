do_install_append() {
	sed -e "s/Version: 10.4.4/Version: 13.0/g" -i ${D}/${libdir}/pkgconfig/gbm.pc
	sed -e "s/Version: 10.4.4/Version: 13.0/g" -i ${D}/${libdir}/pkgconfig/egl.pc
	sed -e "s/Version: 10.4.4/Version: 13.0/g" -i ${D}/${libdir}/pkgconfig/glesv1_cm.pc
	sed -e "s/Version: 10.4.4/Version: 13.0/g" -i ${D}/${libdir}/pkgconfig/glesv2.pc
	sed -e "s/Version: 10.4.4/Version: 13.0/g" -i ${D}/${libdir}/pkgconfig/vg.pc
	sed -e "s/Version: 10.4.4/Version: 13.0/g" -i ${D}/${libdir}/pkgconfig/wayland-egl.pc
}
