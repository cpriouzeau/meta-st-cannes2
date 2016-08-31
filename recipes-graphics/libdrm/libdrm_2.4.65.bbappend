#Split for patch overriding.
#bb rule to be removed when 2.4.65 supported by poky

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/2.4.65:"

SRC_URI += " \
		file://0001-modetest-consider-supported-formats-before-selecting.patch \
		file://0002-modetest-use-SMPTE-pattern-as-cursor.patch \
		file://0003-drm-add-DRM_MODE_FB_BFF-flag-definition.patch \
		file://0004-modetest-add-support-of-st.patch \
		file://0005-libdrm-Add-color-map-control.patch \
		"

SRC_URI_remove_sti = "file://0005-libdrm-Add-color-map-control.patch"
