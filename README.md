# Meta-st-cannes2

**Meta-st-cannes2** is a layer containing the ST bsp metadata.

This layer relies on OpenEmbedded build system that is provided through
Bitbake and OpenEmbedded-Core layers or Poky layer; all part of the Yocto Project.

The Yocto Project has extensive documentation about OE including a reference manual
which can be found at:
    http://yoctoproject.org/documentation

For information about OpenEmbedded, see the OpenEmbedded website:
    http://www.openembedded.org/

***

# Configuration via Openembedded

Layer depends:

    URI: git://git.openembedded.org/openembedded-core
    layers: meta
    branch: krogoth

    URI: git://git.openembedded.org/meta-openembedded
    layers: meta-oe
    branch: krogoth

    URI: git://git.openembedded.org/bitbake
    branch: 1.30

Machine to be used with Meta-st-cannes2 layer:
    stih410-b2260

***

# Configuration via Linaro

#### To download the software:
> mkdir stih410-b2260

> cd stih410-b2260

> repo init -u https://github.com/96boards/oe-rpb-manifest.git -b krogoth

> repo sync

#### To compile the software:

> cd stih410-b2260

> source ./setup-environment

-> for Machine choose: stih410-b2260

-> for Distributions choose: rpb-wayland
> bitbake rpb-weston-image

Generated tar.gz is stored in stih410-b2260/build-rpb-wayland/tmp-rpb_wayland-glibc/deploy/images/stih410-b2260/

**Warning:** if you run the environment set for the second time and you want to force the Machine and Distro selection, clean up your environment  by following commands :
> unset MACHINE

> unset DISTRO

> unset DISTROLAYERS

### To Populate SDCard or Usb Key
The RPB build for stih410-b2260 machine generate a raw image which contains an image ready to flash on sdcard or USB key for b2260.

The image generated have the extension stimg and contains two partitions:
* BOOT: fat32 parition which contains kernel, devicetree and boot script
* rootfs: ext4 partition which contains rootfs

#### To flash a SDCard:
> dd if=stih410-b2260/build-rpb-wayland/tmp-rpb_wayland-glibc/deploy/images/stih410-b2260/image.stimg of=/dev/mmcblkX bs=1M conv=fdatasync

where "image.stimg" can be :
* rpb-weston-image-stih410-b2260.stimg
* rpb-console-image-stih410-b2260.stimg

where ""/dev/mmcblkX" correspond to your sdcard kernel device entry on your linux PC (ex.: /dev/mmcblk0)

#### To flash a Usb Key:
> dd if=stih410-b2260/build-rpb-wayland/tmp-rpb_wayland-glibc/deploy/images/stih410-b2260/<image>.stimg of=/dev/sdX bs=1M conv=fdatasync

where "image.stimg" can be :
* rpb-weston-image-stih410-b2260.stimg
* rpb-console-image-stih410-b2260.stimg

where ""/dev/mmcblkX" correspond to your sdcard kernel device entry on your linux PC (ex.: /dev/mmcblk0)

### To boot from SDCard

1-Insert SDCard in your board.

2-Connect your board to Linux PC via the serial cable.

3- Supply your board

4- Launch minicom on serial port connected to the board from the Linux PC

> minicom -D /dev/ttyUSB0

5- wait the end of boot
login is requested : type root

### To boot from Usb Key

1- Insert Usb Key in your board (without SDCard plugged).

2- Connect your board to Linux PC via the serial cable.

3- Supply your board

4- Launch minicom on serial port connected to the board from the Linux PC

> minicom -D /dev/ttyUSB0

5- wait the end of boot
        login is requested : type root


# Known limitations

### Command 'systemctl Start/Stop Weston' do not work properly:
One should use:

> kill -9 'Weston process id' => to stop weston

> weston --tty=1 --use-pixman & => to start weston

### Keyboard connected to 96Board is configured in QWERTY by default:
to have the AZERTY configuration:
'./etc/xdg/weston/weston.ini' file must be modified by uncommenting 2 lines below line '# for azerty keyboard'
> [keyboard]

> keymap_layout=fr
