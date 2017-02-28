FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/2.4.74:"

SRC_URI_append_stih410-b2260 = " \
        file://0001-modetest-consider-supported-formats-before-selecting.patch \
        file://0002-modetest-use-SMPTE-pattern-as-cursor.patch \
        file://0003-drm-add-DRM_MODE_FB_BFF-flag-definition.patch \
        "
