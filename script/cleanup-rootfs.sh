#!/bin/bash - 
#===============================================================================
#
#          FILE: cleanup-rootfs.sh
#
#         USAGE: ./cleanup-rootfs.sh
#
#   DESCRIPTION: Change rights permission on rootfs
#
#        AUTHOR: Priouzeau Christophe (christophe.priouzeau@st.com)
#  ORGANIZATION: STMicroelectronics
#       CREATED: 10/14/2013 10:40:02 AM CEST
#      REVISION:  ---
#===============================================================================

######################################################
# Choice rootfs
#
choice_rootfs() {
    if [[ -d ${BUILDDIR} ]]; then
        unset LUNCH_IMAGES_MENU_CHOICES
        local i=1
        LIST=`find ${BUILDDIR}/ -maxdepth 1 -name rootfs_* | sed -e 's#'"${BUILDDIR}"'/rootfs_##'`
        echo ""
        echo "From ${BUILDDIR}/"
        echo "Images rootfs are:"
        for l in $LIST;
        do
            if [ ! -z $l ];
            then
                echo "   $i. $l"
                LUNCH_IMAGES_MENU_CHOICES=(${LUNCH_IMAGES_MENU_CHOICES[@]} $l)
                i=$(($i+1))
            fi
        done
        if [ $(echo $LIST | wc -w) -eq 1 ]; then
            answer=1
        else
            echo -n "Which one would you like? [1] "
            read answer
        fi
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
    else
        echo "WARNING: ${BUILDDIR} is empty"
        echo "WARNING: Nothing to clean..."
        read
        return 1;
    fi

    OUT_ROOTFS_PATH=${BUILDDIR}/rootfs_$selection
    return 0
}

######################################################
# Verify environment variable
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


######################################################
# Main
# --
#

verify_env
if [ $? -eq 1 ];
then
    exit 1
fi

choice_rootfs
if [ $? -eq 1 ];
then
    exit 1
fi

echo
echo "Clean up for ${OUT_ROOTFS_PATH#$(dirname $BUILDDIR)/} folder:"
echo "[Remove rootfs folder]"
sudo rm -rf $OUT_ROOTFS_PATH
echo "[Remove NFS export]"
sudo /usr/sbin/exportfs -u *:$OUT_ROOTFS_PATH

