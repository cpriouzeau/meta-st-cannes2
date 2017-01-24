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
BUILD_TMP_DIR="${BUILDDIR}/tmp-rpb_wayland-glibc"

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
    echo "[ST]: You must install tftp server"
    echo "[ST]:   sudo apt instal st-tftp"
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
if [ "X$BUILDDIR" == "X" ];
then
    echo "[ERROR]: You must source the setup-environment"
    echo "[ERROR]:   MACHINE=stih410-b2260 DISTRO=rpb-wayland source ./setup-environment"
    echo ""
    return 1
else
    return 0
fi
}

#----------------------------------------------
# Choice Kernel
# --
#
choice_kernel() {
    if [[ -d ${BUILD_TMP_DIR} ]]; then
        unset LUNCH_KERNEL_MENU_CHOICES
        local i=1
        LIST=`find ${BUILD_TMP_DIR}/work/ -maxdepth 4 -name "linux-st*-standard-build" | sed -e "s#${BUILD_TMP_DIR}/work/##" | sort`
        echo ""
        NUMBER=`find ${BUILD_TMP_DIR}/work/ -maxdepth 4 -name "linux-st*-standard-build" | wc -l`
        if [ $NUMBER -eq 1 ];
        then
            selection=$LIST
            echo "Kernel: $selection"
        else
            echo "Kernel are:"
            for l in $LIST;
            do
                if [ ! -z $l ];
                then
                    printf "%3.3s. %s\n" $i $l
                    LUNCH_KERNEL_MENU_CHOICES=(${LUNCH_KERNEL_MENU_CHOICES[@]} $l)
                    i=$(($i+1))
                fi
            done
            echo -n "Which one would you like? [1] "
            read answer

            if [ -z "$answer" ]
            then
                answer=1
                selection=${LUNCH_KERNEL_MENU_CHOICES[$(($answer-1))]}
            elif (echo -n $answer | grep -q -e "^[0-9][0-9]*$")
            then
                if [ $answer -le ${#LUNCH_KERNEL_MENU_CHOICES[@]} ]
                then
                    selection=${LUNCH_KERNEL_MENU_CHOICES[$(($answer-1))]}
                fi
            elif (echo -n $answer | grep -q -e "^[^\-][^\-]*-[^\-][^\-]*$")
            then
                selection=$answer
            fi

            if [ -z "$selection" ]
            then
                echo
                echo "Invalid choice: $answer"
                return 1
            fi
            echo "Your choice: $selection"
        fi
    else
        echo "ERROR: you must have launched the compilation of kernel before."
        read
        return 1;
    fi

    OUT_KERNEL=${BUILD_TMP_DIR}/work/$selection/
    return 0
}

#------------------------------------------------
# Choice BOARD to put it on environment variable
# --
#
choice_board() {
    if [[ -d $OUT_KERNEL ]]; then
        unset LUNCH_BOARD_MENU_CHOICES
        local i=1
        LIST=`find $OUT_KERNEL/arch/arm/boot -maxdepth 1 -name "*.dtb" -exec basename {} \; | sed "s/\.dtb//" | sort`
        echo ""
        echo "Targets are:"
        for l in $LIST;
        do
            printf "%3.3s. %s\n" $i $l
            LUNCH_BOARD_MENU_CHOICES=(${LUNCH_BOARD_MENU_CHOICES[@]} $l)
            i=$(($i+1))
        done
        if [ $i -gt 0 ];
        then
            SELECTED_BOARD=1
        fi
        echo -n "Which one would you like? [$SELECTED_BOARD] "
        read answer
        selection=$line

        if [ -z "$answer" ]
        then
            selection=$SELECTED_BOARD
        elif (echo -n $answer | grep -q -e "^[0-9][0-9]*$")
        then
            if [ $answer -le ${#LUNCH_BOARD_MENU_CHOICES[@]} ]
            then
                selection=${LUNCH_BOARD_MENU_CHOICES[$(($answer-1))]}
            fi
        elif (echo -n $answer | grep -q -e "^[^\-][^\-]*-[^\-][^\-]*$")
        then
            if [ -f $ST_OE_ROOT_DIR/sources/platform/target/$answer.config ];
            then
                selection=$answer
            fi
        fi

        if [ -z "$selection" ]
        then
            echo
            echo "Invalid choice: $answer"
            return 1
        fi
        echo "Your choice: $selection"
    else
        echo "ERROR: platform sources are not available."
        read
        return 1
    fi
    TARGET_BOARD=$selection
    BOARD_NAME=`echo $TARGET_BOARD | sed "s/stih[0-9][0-9][0-9]-//"`
    return 0
}
#----------------------------------------------
# Choice rootfs
# --
#
choice_rootfs() {
    if [[ -d ${BUILDDIR} ]]; then
        unset LUNCH_IMAGES_MENU_CHOICES
        local i=1
        LIST=`find ${BUILD_TMP_DIR}/deploy/images/ -maxdepth 2 -lname "*.tar.gz" | sed 's#.*/\(.*\)\.tar\.gz#\1#' | sort`
        echo ""
        NUMBER=`find ${BUILD_TMP_DIR}/deploy/images/ -maxdepth 2 -lname "*.tar.gz" | wc -l`
        if [ $NUMBER -eq 1 ];
        then
            selection=$LIST
            echo "Image: $selection"
        else
            echo "Image are:"
            for l in $LIST;
            do
                if [ ! -z $l ];
                then
                    printf "%3.3s. %s\n" $i $l
                    LUNCH_IMAGES_MENU_CHOICES=(${LUNCH_IMAGES_MENU_CHOICES[@]} $l)
                    i=$(($i+1))
                fi
            done
            echo -n "Which one would you like? [1] "
            read answer

            if [ -z "$answer" ]
            then
                answer=1
                selection=${LUNCH_IMAGES_MENU_CHOICES[$(($answer-1))]}
            elif (echo -n $answer | grep -q -e "^[0-9][0-9]*$")
            then
                if [ $answer -le ${#LUNCH_IMAGES_MENU_CHOICES[@]} ]
                then
                    selection=${LUNCH_IMAGES_MENU_CHOICES[$(($answer-1))]}
                fi
            elif (echo -n $answer | grep -q -e "^[^\-][^\-]*-[^\-][^\-]*$")
            then
                selection=$answer
            fi

            if [ -z "$selection" ]
            then
                echo
                echo "Invalid choice: $answer"
                return 1
            fi
            echo "Your choice: $selection"
        fi
    else
        echo "ERROR: you must have launched the compilation of image before."
        read
        return 1;
    fi
    # Extract selected rootfs

    # Init path to ROOTFS
    OUT_ROOTFS_PATH=${BUILDDIR}/rootfs_$selection/
    # Init path to TARBALL
    ROOTFS_TARBALL_PATH=`find ${BUILD_TMP_DIR}/deploy/images/ -maxdepth 2 -lname "*.tar.gz" | grep /$selection.tar.gz`

    if ! [ -e ${OUT_ROOTFS_PATH} ]; then
        mkdir ${OUT_ROOTFS_PATH}
    else
        echo
        echo "***************************************"
        echo "***************************************"
        echo "                WARNING"
        echo "***************************************"
        echo "***************************************"
        echo "Folder '${OUT_ROOTFS_PATH}' already exists."
        echo -n "    Do you want to override its content [y/N] ? "
        read answer
        if [[ "$answer" =~ ^[Yy]+[ESes]* ]]; then
            echo
            echo "Overriding content of '${OUT_ROOTFS_PATH}' folder !!!"
            echo
        else
            echo
            echo "***************************************"
            echo "***************************************"
            echo "                WARNING"
            echo "***************************************"
            echo "***************************************"
            echo "Keeping existing '${OUT_ROOTFS_PATH}' folder WITHOUT any modifications"
            echo
            return 0
        fi
    fi
    echo
    echo "[INFO] Extracting ${ROOTFS_TARBALL_PATH} to ${OUT_ROOTFS_PATH}"
    sudo tar xzf ${ROOTFS_TARBALL_PATH} -C ${OUT_ROOTFS_PATH} --overwrite --checkpoint=.1000
    echo ">>> Done"
    return 0
}

#----------------------------------------------
# export NFS root directory
# --
#
export_nfs_root() {
    sudo /usr/sbin/exportfs -o rw,no_root_squash,async,no_subtree_check *:$OUT_ROOTFS_PATH
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
# Choice rootfs
# --
#
create_script() {
    SCRIPT_NAME=$TFTP_PATH/boot_network_$BOARD_NAME.txt
    SCRIPT_BOOT=$TFTP_PATH/boot_network_$BOARD_NAME.scr
    CMDLINE=$(cat $DEPLOY_DIR/$MACHINE/cmdline/cmdline_nfs.txt)

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

    mkimage -A arm -T script -C none -n "Open SDK Boot Script" -d $SCRIPT_NAME $SCRIPT_BOOT
}

######################################################
# Main
# --
#

verify_env
if [ $? -eq 1 ];
then
    exit 1
fi

verify_tftp
if [ $? -eq 1 ];
then
    exit 1
fi

# Options parsing
#
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
[[ -z ${BUILDDIR} ]] || DEPLOY_DIR=`find ${BUILDDIR}/* -maxdepth 2 -type d -wholename '*/deploy/images'`
# Get MACHINE from config files
MACHINE=$(grep "^[ \t]*MACHINE[ \t]*=" ${BUILDDIR}/conf/*.conf | head -n 1 | sed 's/^.*"\(.*\)"/\1/')

#choice Kernel
choice_kernel
if [ $? -eq 1 ];
then
    exit 1
fi

#choice the target
echo "[board choice]"
choice_board
ret_choice=$?
if [ $ret_choice -eq 1 ];
then
    exit 1
fi


#choice rootfs
choice_rootfs
if [ $? -eq 1 ];
then
    exit 1
fi

#copy file to tftp boot

#copy kernel
cp -f $OUT_KERNEL/arch/arm/boot/uImage $TFTP_PATH/

#copy devicetree
cp -f $OUT_KERNEL/arch/arm/boot/$TARGET_BOARD.dtb $TFTP_PATH/

export_nfs_root

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
