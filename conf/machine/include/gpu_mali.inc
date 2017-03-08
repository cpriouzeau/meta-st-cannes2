# =========================================================================
# GPU
# =========================================================================
GPU_USERLAND_LIBRARIES_WAYLAND ?= "mali400-userland-multi-binary"

# Helper function for overloading the default EGL/GLES implementation.
# The Mali libraries provided by ARM are compatible with the Mesa headers
# but we can have several backend available following the distro configuration:
#  - wayland
#  - x11
#  - wayland + x11
#  - framebuffer
#  - drm

def get_gpu_mali_handler(d):
    """  Overloading the default EGL/GLES/mesa implementation."""
    machine_features = d.getVar('MACHINE_FEATURES', True).split()
    distro_features = d.getVar('DISTRO_FEATURES', True).split()

    gpu_lib_wayland = d.getVar('GPU_USERLAND_LIBRARIES_WAYLAND', True).split()

    if 'gpu' in machine_features:
        if 'wayland' in distro_features:
            provider = gpu_lib_wayland[0]
        else:
            if 'x11' in distro_features:
                provider = "mesa"
            else:
                '''no wayland, no X11 -> choose DRM for eglfs'''
                provider = gpu_lib_wayland[0]
    else:
        provider = "mesa"

    return provider;

GPU_USERLAND_LIBRARIES_INSTALL = "${@get_gpu_mali_handler(d)}"

PREFERRED_PROVIDER_virtual/egl_stih410-b2260 = "${@get_gpu_mali_handler(d)}"
PREFERRED_PROVIDER_virtual/libgles1_stih410-b2260 = "${@get_gpu_mali_handler(d)}"
PREFERRED_PROVIDER_virtual/libgles2_stih410-b2260 = "${@get_gpu_mali_handler(d)}"
PREFERRED_PROVIDER_virtual/mesa_stih410-b2260 = "${@bb.utils.contains('PREFERRED_PROVIDER_virtual/egl','${GPU_USERLAND_LIBRARIES_WAYLAND}','mesa-gl','mesa',d)}"
PREFERRED_PROVIDER_virtual/libgl_stih410-b2260 = "${@bb.utils.contains('PREFERRED_PROVIDER_virtual/egl','${GPU_USERLAND_LIBRARIES_WAYLAND}','mesa-gl','mesa',d)}"
