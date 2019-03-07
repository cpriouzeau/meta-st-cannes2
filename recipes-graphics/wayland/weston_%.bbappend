PACKAGECONFIG_stih410-b2260 = "${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'kms fbdev wayland egl', '', d)} \
                 ${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'x11', '', d)} \
                 ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'xwayland', '', d)} \
                 ${@bb.utils.contains('DISTRO_FEATURES', 'pam', 'launch', '', d)} \
                 ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd', '', d)} \
                 ${@bb.utils.contains('DISTRO_FEATURES', 'opengl', 'egl', '', d)} \
                 clients"
