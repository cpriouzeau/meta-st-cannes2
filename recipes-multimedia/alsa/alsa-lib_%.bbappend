FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += " file://asound.conf  \
            file://sti_audio_card.conf"

do_install_append() {
   install -d  ${D}/etc/
   install -m 0644 ${WORKDIR}/asound.conf ${D}/etc/

   install -d ${D}/usr -d ${D}/usr/share
   install -d ${D}/usr/share/alsa -d ${D}/usr/share/alsa/cards
   install -m 0644 ${WORKDIR}/sti_audio_card.conf ${D}/usr/share/alsa/cards/
}
FILES_alsa-conf-base += " /etc/asound.conf /usr/share/alsa/cards/sti_audio_card.conf"

