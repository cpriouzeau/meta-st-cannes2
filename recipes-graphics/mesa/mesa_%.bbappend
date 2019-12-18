FILESEXTRAPATHS_prepend_stih410-b2260 := "${THISDIR}/files:"

SRC_URI_append_stih410-b2260 = " file://0001-LIMA-enable-for-sti-drm.patch "
# Enable lima for stih410-b2260
PACKAGECONFIG_append_stih410-b2260 = " gallium"
PACKAGECONFIG_remove_stih410-b2260 = " vulkan"
GALLIUMDRIVERS_stih410-b2260 = "lima,kmsro,swrast"
DRIDRIVERS_stih410-b2260 = ""
