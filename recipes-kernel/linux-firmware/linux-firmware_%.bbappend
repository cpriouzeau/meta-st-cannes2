# This append are made to install the specific firware of rtl8723 for bluetooth part only.
# by default the firmware: rtl_bt/rtl8723b_fw.bin

PACKAGES_prepend_stih410-b2260 = " ${PN}-rtl8723bu "

FILES_${PN}-rtl8723bu = " /lib/firmware/rtl_bt/rtl8723b_fw.bin "
