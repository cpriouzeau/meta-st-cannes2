FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/2.4.99:"

SRC_URI_append_stih410-b2260 = " \
        file://0101-modetest-consider-supported-formats-before-selecting.patch \
        file://0102-modetest-use-SMPTE-pattern-as-cursor.patch \
        file://0103-drm-add-DRM_MODE_FB_BFF-flag-definition.patch \
        "
