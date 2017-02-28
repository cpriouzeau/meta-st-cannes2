#!/bin/bash -
#===============================================================================
#
#          FILE: run_nfs_via_tftp.sh
#
#         USAGE: ./run_nfs_via_tftp.sh
#
#        AUTHOR: Christophe Priouzeau (), christophe.priouzeau@st.com
#  ORGANIZATION: STMicroelectronics
#       CREATED: 08/29/2013 12:27:12 PM CEST
#      REVISION:  ---
#===============================================================================
TFTP_PATH="/tftpboot"

#---------------------------------------
# verify tftp server
#
verify_tftp() {
if [ ! -d  $TFTP_PATH  ];
then
    echo "[ERROR]: You must install tftp server"
    echo "[ERROR]:   sudo apt install tftpd"
    echo "[ERROR]: and fill the file /etc/xinetd.d/tftp:"
cat << EOF
service tftp
{
protocol        = udp
port            = 69
socket_type     = dgram
wait            = yes
user            = nobody
server          = /usr/sbin/in.tftpd
server_args     = /tftpboot
disable         = no
}
EOF
    echo "[ERROR]:   sudo /etc/init.d/xinetd reload"
    echo "[ERROR]:   sudo /etc/init.d/xinetd restart"
    echo ""
    return 1
else
    return 0
fi
}

#---------------------------------------
# verify environment variable
#
verify_env() {
if [ "X${BUILDDIR}" == "X" ];
then
    echo "[ERROR]: You must init your OpenEmbedded environment"
    echo "[ERROR]:   source openembedded-core/oe-init-build-env"
    echo ""
    echo "[ERROR][RPB]: You must source the setup-environment"
    echo "[ERROR][RPB]:   MACHINE=stih410-b2260 DISTRO=rpb-wayland source ./setup-environment"
    echo ""
    return 1
else
    return 0
fi
}

#------------------------------------------------
# _checklist <LIST> <ELEMENT>
# Return 0 if element is in list, else 1
#
_checklist() {
    for l in $1
    do
        [[ $2 = $l ]] && return 0
    done
    return 1
}

#------------------------------------------------
# _choice <CHOICE> <LIST-FOR-CHOICE>
#
_choice() {
    unset LUNCH_BOARD_MENU_CHOICES

    local __SELECTED_CHOICE=$1
    local LIST=$2

    local default_choice="$(echo ${LIST} | cut -d' ' -f1)"
    local i=1
    local selection=""

    if [ $(echo "${LIST}" | wc -w) -eq 1 ]; then
        selection=${LIST}
    else
        for l in ${LIST};
        do
            printf "%3.3s. %s\n" $i $l
            LUNCH_BOARD_MENU_CHOICES=(${LUNCH_BOARD_MENU_CHOICES[@]} $l)
            i=$(($i+1))
        done
        echo -n "Which one would you like? [${default_choice}] "
        read answer
        if [ -z "$answer" ]
        then
            selection=${default_choice}
        elif (echo -n $answer | grep -q -e "^[0-9][0-9]*$")
        then
            if [ $answer -le ${#LUNCH_BOARD_MENU_CHOICES[@]} ]
            then
                selection=${LUNCH_BOARD_MENU_CHOICES[$(($answer-1))]}
            fi
        elif (_checklist "${LIST}" $answer)
        then
            selection=$answer
        fi
        if [ -z "$selection" ]
        then
            echo
            echo "Invalid choice: $answer"
            return 1
        fi
    fi
    echo "Your choice: $selection"
    #return selection to external var
    eval $__SELECTED_CHOICE=$selection
    return 0
}

#------------------------------------------------
# Choice BOARD to put it on environment variable
# --
#
choice_board() {
    if [ -d $OUT_KERNEL ]; then
        if [ "$OUT_KERNEL" = "$(dirname ${ROOTFS_TARBALL_PATH})" ]; then
            LIST=`find $OUT_KERNEL -maxdepth 1 -lname "*.dtb" -exec basename {} \; | sed "s/\.dtb//" | sort`
        else
            LIST=`find $OUT_KERNEL -maxdepth 1 -name "*.dtb" -exec basename {} \; | sed "s/\.dtb//" | sort`
        fi
        echo ""
        echo "Targets are:"
        _choice TARGET_BOARD "$LIST"
        #check and forward error return code
        [[ $? -eq 1 ]] && return 1
    else
        echo "ERROR: you must have launched the compilation of kernel before."
        read
        return 1
    fi
    BOARD_NAME=`echo ${TARGET_BOARD} | sed "s/stih[0-9][0-9][0-9]-//"`
    return 0
}

#------------------------------------------------
# Choice Kernel
# --
#
choice_kernel() {
    if [ -d ${BUILD_TMP_DIR} ]; then
        LIST=`find ${BUILD_TMP_DIR}/work/ -maxdepth 4 -name "linux-st*-standard-build" | sed -e "s#${BUILD_TMP_DIR}/work/##" | sort`
        echo ""
        echo "Kernels are:"
        _choice TARGET_KERNEL "$LIST"
        #check and forward error return code
        [[ $? -eq 1 ]] && return 1
    else
        echo "ERROR: you must have launched the compilation of kernel before."
        read
        return 1;
    fi
    # Init OUT_KERNEL with correct value
    if [ -d ${BUILD_TMP_DIR}/work/${TARGET_KERNEL}/arch/arm/boot ]; then
        OUT_KERNEL=${BUILD_TMP_DIR}/work/${TARGET_KERNEL}/arch/arm/boot
    else
        OUT_KERNEL=$(dirname ${ROOTFS_TARBALL_PATH})
    fi
    return 0
}

#----------------------------------------------
# Choice rootfs
# --
#
choice_rootfs() {
    if [ -d ${DEPLOY_DIR} ]; then
        LIST=`find ${DEPLOY_DIR}/images/ -maxdepth 2 -lname "*.tar.bz2" | sed 's#.*/\(.*\)\.tar\.bz2#\1#' | sort`
        echo ""
        echo "Images are:"
        _choice TARGET_ROOTFS "$LIST"
        #check and forward error return code
        [[ $? -eq 1 ]] && return 1
    else
        echo "ERROR: you must have launched the compilation of image before."
        read
        return 1;
    fi

    # Extract selected rootfs

    # Init path to ROOTFS
    OUT_ROOTFS_PATH=${BUILDDIR}/rootfs_${TARGET_ROOTFS}/
    # Init path to TARBALL
    ROOTFS_TARBALL_PATH=`find ${DEPLOY_DIR}/images/ -maxdepth 2 -lname "*.tar.bz2" | grep /${TARGET_ROOTFS}.tar.bz2`

    if ! [ -e ${OUT_ROOTFS_PATH} ]; then
        mkdir ${OUT_ROOTFS_PATH}
    else
        echo
        echo "***************************************"
        echo "***************************************"
        echo "                WARNING"
        echo "***************************************"
        echo "***************************************"
        echo "Folder '${OUT_ROOTFS_PATH#$(dirname $BUILDDIR)/}' already exists."
        echo -n "    Do you want to override its content [y/N] ? "
        read answer
        if [[ "$answer" =~ ^[Yy]+[ESes]* ]]; then
            echo
            echo "Overriding content of '${OUT_ROOTFS_PATH#$(dirname $BUILDDIR)/}' folder !!!"
        else
            echo
            echo "***************************************"
            echo "***************************************"
            echo "                WARNING"
            echo "***************************************"
            echo "***************************************"
            echo "Keeping existing '${OUT_ROOTFS_PATH#$(dirname $BUILDDIR)/}' folder WITHOUT any modifications"
            return 0
        fi
    fi
    echo
    echo "[INFO] Extracting ${ROOTFS_TARBALL_PATH#$(dirname $BUILDDIR)/} to ${OUT_ROOTFS_PATH#$(dirname $BUILDDIR)/}"
    sudo tar xjf ${ROOTFS_TARBALL_PATH} -C ${OUT_ROOTFS_PATH} --overwrite --checkpoint=.1000
    echo
    echo ">>> Done"
    return 0
}

#----------------------------------------------
# export NFS root directory
# --
#
export_nfs_root() {
    if [ -f /usr/local/sbin/sudo-exportfs ];
    then
        sudo-exportfs -o rw,no_root_squash,async,no_subtree_check *:$OUT_ROOTFS_PATH
    else
        sudo /usr/sbin/exportfs -o rw,no_root_squash,async,no_subtree_check *:$OUT_ROOTFS_PATH
    fi
    if `ifconfig eth0 2> /dev/null` ;
    then
        ETH0_IPADDR=$(ifconfig eth0 | awk '/inet addr/{print substr($2,6)}')
    else
        INTERFACE_NAME=$(udevadm info -e | grep ID_NET_NAME_PATH | cut -d'=' -f2 | grep ^enp)
        ETH0_IPADDR=$(ifconfig $INTERFACE_NAME | awk '/inet addr/{print substr($2,6)}')
    fi
    NFSROOT="$ETH0_IPADDR:$OUT_ROOTFS_PATH,v3,tcp"
}

#----------------------------------------------
# Create u-boot script
# --
#
create_script() {
    SCRIPT_NAME=$TFTP_PATH/boot_network_$BOARD_NAME.txt
    SCRIPT_BOOT=$TFTP_PATH/boot_network_$BOARD_NAME.scr
    CMDLINE=$(cat ${DEPLOY_DIR}/images/$MACHINE/cmdline/cmdline_nfs.txt)

    #patch for b2260
    if [ "$TARGET_BOARD" == "stih410-b2260" ];
    then
        TMP_CMDLINE=$(echo $CMDLINE | sed "s/ttyAS0/ttyAS1/g")
        CMDLINE=$TMP_CMDLINE
        TMP_CMDLINE=$(echo $CMDLINE | sed "s/2048/1024/g")
        CMDLINE=$TMP_CMDLINE
    fi
    TMP_CMDLINE=$(echo $CMDLINE | sed "s#dev/nfs#dev/nfs ip=dhcp nfsroot=$NFSROOT#g")
    CMDLINE=$TMP_CMDLINE
    echo "setenv fdt_high \"0xFFFFFFFF\"" > $SCRIPT_NAME
    echo "setenv bootargs \"$CMDLINE\"" >> $SCRIPT_NAME
    echo "setenv bootrom_data \"dcache flush;hpen prepare 0x094100A4;hpen kick hpen;\"" >> $SCRIPT_NAME
    echo "setenv bootcmd \"tftp 0x60000000 uImage; tftp 0x47000000 $TARGET_BOARD.dtb; run bootrom_data; bootm 0x60000000 - 0x47000000\" " >> $SCRIPT_NAME
    echo "boot"  >> $SCRIPT_NAME

    ${STAGING_BINDIR_NATIVE}/mkimage -A arm -T script -C none -n "ST cannes2 Boot Script" -d $SCRIPT_NAME $SCRIPT_BOOT
}

######################################################
# Main
# --
#

verify_env
[[ $? -eq 1 ]] && exit 1

verify_tftp
[[ $? -eq 1 ]] && exit 1

# Options parsing
while test $# != 0
do
    case "$1" in
        --help|-h)
            echo "run_nfs_via_tftp.sh [-h|--help] [--env]"
            echo " env: print u-boot environment variable needed:"
            echo " help: this help"
            echo ""
            exit 1
            ;;
    esac
done

# Get DEPLOY_DIR path from OpenEmbedded BUILDDIR var
DEPLOY_DIR=$(find ${BUILDDIR}/* -maxdepth 1 -type d -wholename '*/deploy')
# Init BUILD_TMP_DIR path from DEPLOY_DIR
BUILD_TMP_DIR=$(dirname ${DEPLOY_DIR})
# Init STAGING_BINDIR_NATIVE path from BUILD_TMP_DIR
STAGING_BINDIR_NATIVE=$(find ${BUILD_TMP_DIR}/sysroots/ -maxdepth 3 -type d -wholename "${BUILD_TMP_DIR}/sysroots/$(uname -m)*/usr/bin")
# Get MACHINE from config files
MACHINE=$(grep "^[ \t]*MACHINE[ \t]*=" ${BUILDDIR}/conf/*.conf | head -n 1 | sed 's/^.*"\(.*\)"/\1/')

echo ""
echo "[rootfs choice]"
choice_rootfs
[[ $? -eq 1 ]] && exit 1

echo ""
echo "[kernel choice]"
choice_kernel
[[ $? -eq 1 ]] && exit 1

echo ""
echo "[board choice]"
choice_board
[[ $? -eq 1 ]] && exit 1

#copy file to tftp boot

#copy kernel
cp -f $OUT_KERNEL/uImage $TFTP_PATH/
#copy devicetree
cp -f $OUT_KERNEL/$TARGET_BOARD.dtb $TFTP_PATH/

export_nfs_root

echo ""
echo "[create script]"
create_script

echo ""
echo "Information passed to script:"
echo "      OUT_KERNEL=$OUT_KERNEL"
echo "      OUT_ROOTFS_PATH=$OUT_ROOTFS_PATH"
echo "      TARGET_BOARD=$TARGET_BOARD"
echo ""
echo "----------------------------------------"
echo "On u-boot if netboot are not set"
echo "please use the script \"update_default_boot.sh\" to enable netboot "
echo " /media/\$USER/BOOT/> bash update_default_boot.sh netboot"
