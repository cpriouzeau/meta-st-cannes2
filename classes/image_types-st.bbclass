inherit image_types

#
# Create an image that can by written onto a SD card or USB key using dd.
#
# The disk layout used is:
#
#    0                      -> TOOLS_ALIGNMENT  - alignment size proposed by parted
#    TOOLS_ALIGNMENT        -> BOOT_SPACE       - bootloader and kernel
#    BOOT_SPACE             -> STIMG_SIZE       - rootfs
#
#            aligment          50MiB        ROOTFS
# <-----------------------> <----------> <--------------------->
#  ------------------------ ------------ -----------------------
# | TOOLS_ALIGNMENT        | BOOT_SPACE | ROOTFS_SIZE         |
#  ------------------------ ------------ ------------------------
# ^                        ^            ^                     ^
# |                        |            |                     |
# 0           ~1MiB             50MiB       ROOTFS_SIZE

IMAGE_DEPENDS_stimg = " \
        parted-native \
        mtools-native \
        u-boot-mkimage-native \
        e2fsprogs-native \
        dosfstools-native \
        virtual/kernel:do_deploy \
        virtual/bootloader:do_deploy \
        boot-configs-stih410-b2260:do_deploy \
        "
# This image depends on the rootfs image
IMAGE_TYPEDEP_stimg_append = "ext4"

STIMG ?= "${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.stimg"

#size on MB: 2GB
STIMG_SIZE ??= "2048"
#boot size on KB: 50MB
BOOT_IMG_SIZE_KB ??= "51200"

st_populate_BOOT() {
    cd ${DEPLOY_DIR_IMAGE};
    #copy kernel
    mcopy -i ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.bootimg -s ${DEPLOY_DIR_IMAGE}/uImage ::uImage
    #copy devicetree
    mcopy -i ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.bootimg -s ${DEPLOY_DIR_IMAGE}/sti*.dtb ::/

    #copy boot script
    mcopy -i ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.bootimg -s ${DEPLOY_DIR_IMAGE}/boot/* ::/

    #copy u-boot
    for conf in "${UBOOT_CONFIG}";
    do
        mcopy -i ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.bootimg -s ${DEPLOY_DIR_IMAGE}/u-boot.bin-$conf ::/$conf/u-boot.bin
    done
}


IMAGE_CMD_stimg () {
    rm -f ${STIMG}

    # calculate the size of new image (truncated)
    _FINAL_SIZE_KB=8192
    # add boot size
    _FINAL_SIZE_KB=$(expr $_FINAL_SIZE_KB + ${BOOT_IMG_SIZE_KB})
    # add rootfs image size
    # $ROOTFS_SIZE are the size of rootfs on KB
    _FINAL_SIZE_KB=$(expr $_FINAL_SIZE_KB + $ROOTFS_SIZE)

    # Initialize image file (due to bs we force seek on K)
    dd if=/dev/zero of=${STIMG} bs=1024 count=0 seek=${STIMG_SIZE}K

    # Create partition table
    parted -s ${STIMG} mklabel msdos

    # create boot partition
    parted -s ${STIMG} -a optimal unit KB mkpart primary fat32 0% ${BOOT_IMG_SIZE_KB}

    # create rootfs partition
    offset=$(LC_ALL=C parted -s ${STIMG} unit MB print | grep "^ 1" | awk '{ print substr($3, 1, length($3 -1)) }')
    parted -s ${STIMG} -- unit MB mkpart primary ext4 $offset -1s

    # create boot filesystem and burn it
    offset=$(LC_ALL=C parted -s ${STIMG} unit b print | grep "^ 1" | awk '{ print substr($2, 1, length($2 -1)) }' | sed "s/B//" )
    BLOCKS=$(LC_ALL=C parted -s ${STIMG} unit b print | grep "^ 1" | awk '{ print substr($4, 1, length($4 -1)) / 512 /2 }' | sed "s/B//" )
    mkfs.vfat -n BOOT -S 512 -C ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.bootimg $BLOCKS
    #populate boot image
    st_populate_BOOT
    # Burn Partitions
    dd if=${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.bootimg of=${STIMG} conv=notrunc seek=1 bs=$offset && sync && sync
    # Rename boot image with OpenEmbedded naming
    cd ${DEPLOY_DIR_IMAGE}; ln -sf ${IMAGE_NAME}.bootimg ${IMAGE_LINK_NAME}.bootimg

    # burn rootfs
    offset=$(LC_ALL=C parted -s ${STIMG} unit b print | grep "^ 2" | awk '{ print substr($2, 1, length($2 -1)) }' | sed "s/B//" )
    e2label ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.rootfs.ext4 rootfs
    dd if=${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.rootfs.ext4 of=${STIMG} conv=notrunc seek=1 bs=$offset && sync && sync

    # reduce the size of image
    truncate --size=${_FINAL_SIZE_KB}K ${STIMG}
    cd ${DEPLOY_DIR_IMAGE};ln -sf ${IMAGE_NAME}.stimg ${IMAGE_LINK_NAME}.stimg
}
