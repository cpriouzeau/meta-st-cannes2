# suppress of drm-gl which are not supported by mali400-userland
PACKAGECONFIG_stih410-b2260 = "${@bb.utils.contains('DISTRO_FEATURES', 'x11 opengl', 'x11-gles2', '', d)} \
                  ${@bb.utils.contains('DISTRO_FEATURES', 'wayland opengl', 'wayland-gles2', '', d)} \
                  drm-gles2"

