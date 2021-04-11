booty is a scripts complex for creating bootable GNU/Linux images.

![booty](https://github.com/sp00f1ng/booty/blob/htdocs/booty.jpg?raw=true)

- [booty](#booty)
    - [Quick Start](#quick-start)
    - [Interface](#Interface)
        - [import / export](#import--export)
    - [Boot Options](#boot-options)
        - [booty.use-shmfs](#booty.use-shmfs)
        - [booty.use-overlayfs](#booty.use-overlayfs)
        - [booty.search-rootfs](#booty.search-rootfs)
        - [booty.copy-to-ram](#booty.copy-to-ram)
        - [booty.rootfs-changes](#booty.rootfs-changes)
    - [Known Issues](#known-issues)
        - [init as symlink](#init-as-symlink)

## Quick Start

```sh
# make install
# booty build DIRECTORY/
# qemu-system-x86_64 -cdrom BOOT-x86_64.ISO
```

## Interface

### booty build

### booty linux

### booty ramdisk

### booty image

### booty run

### Import / Export

For saving and loading features you can run "exportroot" and "importroot".

Well you have installed a "chroot" and you want to save the system state
for future use, so run:

```sh
# booty export linux-chroot/ > vanilla-system-state.img
```

And then, when you want to setup another system from this linux-chroot/, run:

```sh
# booty import linux-chroot/ < vanilla-system-state.img
```

It's usable when you only have one system state and many configurations.

## Boot Options

booty's /init script can handle some kernel options ("cheats") while system boots.

### booty.use-shmfs

All system data will be extracted to the pure "tmpfs" filesystem and then continue booting.

This action may require a lot of RAM.

Example, you have rootfs.cpio image with 1GB system stored in initrd image, and before
system will be loaded completly they needed a 2GB of RAM: 1GB for rootfs.cpio and
one more 1GB for extracted data. Use this with carefully. But if your image stores on
ISO (not in initrd) you need only 1GB free of RAM.

### booty.use-overlayfs

All system data will be mounted as overlays.

### booty.search-rootfs

Option required argument: `booty.search-rootfs=file` or `booty.search-rootfs=directory`.

Search selected file or the directory with overlays on storage devices while booting.

By default all created overlays stores in /system/overlays directory, but you can create
own overlay with naming "filesystem.squashfs", put in root of your HDD and set this option:

```sh
booty.search-rootfs=/filesystem.squashfs
```

### booty.copy-to-ram

Will copy overlays to the RAM before mounting.

For example, you can boot with USB and unplug your USB-stick after system boots.

### booty.rootfs-changes

While using Overlay FS all your data stores in SHMFS (tmpfs, ramffs) by default, but you can
create a empty file on your storage device, then create any supported by kernel filesystem on
this file (image) and use it as storage for your data, instead of storing data in temporarely SHMFS.

Example `booty.rootfs-changes=/dev/sda1` for using whole /dev/sda1 as storage for any changes.
While reboots cache-data is keep. Storage (file with filesystem) must be created manually.

## Known Issues

### init as symlink
