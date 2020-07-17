GL HF

# booty

booty is a scripts complex for creating bootable GNU/Linux images.

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [booty](#booty)
    - [Installation](#installation)
    - [Quick start](#quick-start)
    - [Boot options](#boot-options)
        - [boobs.use-shmfs](#boobs.use-shmfs)
        - [boobs.use-overlayfs](#boobs.use-overlayfs)
        - [boobs.search-rootfs](#boobs.search-rootfs)
        - [boobs.copy-to-ram](#boobs.copy-to-ram)
        - [boobs.rootfs-changes](#boobs.rootfs-changes)
    - [Utilities](#utilities)
        - [mkbootstrap](#mkbootstrap)
        - [mkinitramfs](#mkinitramfs)
        - [mkbootisofs](#mkbootisofs)
        - [mkoverlayfs](#mkoverlayfs)
        - [exportroot / importroot](#exportroot--importroot)
    - [Use cases](#use-cases)
    - [Examples](#Examples)
        - [initrd as standalone linux system](#initrd-as-standalone-linux-system)
        - [boot to any linux from the storage device](#boot-to-any-linux-from-the-storage-device)
        - [MOAR](#moar)
    - [Friendly Asked Questions](#friendly-asked-questions)

<!-- markdown-toc end -->


So what booty can do?

1. Installs "chroots" into the directory, it have native CRUX GNU/Linux
support but for other distros booty just switching to using external
bootstrap-wrappers like pacstrap, debootstrap, so you need to have it
installed. For CRUX GNU/Linux its a simple pkgadd implementation using "tar"
and my pkgadd can only installing packages into the "chroot/", nothing else.

2. Creates INITRD images for boot using the host-system environment or can
using standalone directory as INITRD "chroot". INITRD images can including the
full system as directory, SquashFS-compressed image and so on... Then you
can share INITRD image via PXE or put it on any device. Also INITRD can
boots to plain SHMFS (TMPFS, RAMFS) or using Overlay FS with SquashFS.
booty can use busybox but only if you have one, its optional feature.

Aaaaaand...

3. Creating BIOS and UEFI compatible bootable ISO images. Thats it. Simple.

So...

Just take 3 (three) simple steps and you'll get own bootable GNU/Linux distro!
And then you will be able to boot it via a network (PXE) or CD-ROM / USB (bootable ISO).

**Written in the pure POSIX shell. Confirmed by "Dash".**

Personally, I am living in tmpfs forever. All my "enterprises" are living in tmpfs.
For example, personally, I use GNU/Linux on my home PC-router with 2GB of RAM.
Yes, my "enterprise" is a PC-router with 2GB RAM running in tmpfs. HA-HA.

* That's cool -- your system is in the tmpfs.
* That's fast -- tmpfs means RAM.
* That's smart -- set up only once, use forever.
* That's secure -- if your system breaks, just push the "RESET" button.
* That's NO backups -- back up only your data, not the system.

* Don't be afraid to use "root".
* Don't be afraid to break the system.
* Don't be afraid to run shell-exploits.
* Don't be afraid to do "rm -rf /".

When my system breaks I push the "RESET" button and the system boots again.
-- via PXE or from a USB-flash (ISO).

Software included:

* mkbootstrap -- Install "chroot" with any distro.
* mkinitramfs -- Create an initrd / initramfs image.
* mkbootisofs -- Create a bootable ISO from a directory.
* mkoverlayfs -- Creates images for using with Overlay FS.
* exportroot -- Creates archive from the "chroot" directory.
* importroot -- Restores "chroot" directory from the archive.

Software dependencies:

* cpio
* grub
* grub-efi
* dosfstools
* squashfs-tools (optional)
* xorriso

Also if you want to use SquashFS / OverlayFS, enable the following in your kernel:

	CONFIG_OVERLAY_FS=y

and

	CONFIG_SQUASHFS=y
	CONFIG_SQUASHFS_XZ=y

But its optional. You can just use SHMFS if you have enough RAM for your system.


## Installation

* Generic GNU/Linux
```sh
git clone https://github.com/sp00f1ng/booty.git
cd booty
make install
```

* ArchLinux

There is an AUR package `booty-git`. Install it with your preferred tool, `pacaur` just for example.
```sh
pacaur -S booty-git
```

## Quick start

Quick Start (just run a test):

```sh
# booty/tests/crux_gnulinux-download-and-build
# qemu-system-x86_64 -enable-kvm -m 1G -cdrom tmp.*/install.iso
```

## Boot options

booty's /init script can handle some kernel options ("cheats") while system boots.

### boobs.use-shmfs

All system data will be extracted to the pure "tmpfs" filesystem and then continue booting.

This action may require a lot of RAM.

Example, you have rootfs.cpio image with 1GB system stored in initrd image, and before
system will be loaded completly they needed a 2GB of RAM: 1GB for rootfs.cpio and
one more 1GB for extracted data. Use this with carefully. But if your image stores on
ISO (not in initrd) you need only 1GB free of RAM.

### boobs.use-overlayfs

All system data will be mounted as overlays. This is recommended usage option, but you
should enable the CONFIG_OVERLAY_FS=y in your kernel config.

### boobs.search-rootfs

Option required argument: `boobs.search-rootfs=file` or `boobs.search-rootfs=directory`.

Search selected file or the directory with overlays on storage devices while booting.

By default all created overlays stores in /system/overlays directory, but you can create
own overlay with naming "filesystem.squashfs", put in root of your HDD and set this option:

```sh
boobs.search-rootfs=/filesystem.squashfs
```

### boobs.copy-to-ram

Will copy overlays to the RAM before mounting.

For example, you can boot with USB and unplug your USB-stick after system boots.

### boobs.rootfs-changes

While using Overlay FS all your data stores in SHMFS (tmpfs, ramffs) by default, but you can
create a empty file on your storage device, then create any supported by kernel filesystem on
this file (image) and use it as storage for your data, instead of storing data in temporarely SHMFS.

Example `boobs.rootfs-changes=/dev/sda1` for using whole /dev/sda1 as storage for any changes.
While reboots cache-data is keep. Storage (file with filesystem) must be created manually.

## Utilities

Now, let's talk about framework utilities.

### mkbootstrap

```
# mkbootstrap <system> <directory> [options] [packages]
```

This command installs a "chroot" with the specified distro into a directory.

Where <system> can be:

* crux\_gnulinux (internal)
* archlinux\_gnulinux (external!!!)
* manjaro\_gnulinux (external!!!)
* debian\_gnulinux (external!!!)
* fedora\_gnulinux (external!!!)
* redhat\_gnulinux (external!!!)
* centos\_gnulinux (external!!!)


> !!! Note: I wrote only crux_gnulinux wrapper, for other distros you must have
> pacstrap, basestrap, debootstrap, and other *straps installed.

crux_gnulinux options:

```
--ports-dir <directory> -- specify directory for search CRUX packages.

[any packages] -- specify packages to install.
```

Example usage:

1. Download a CRUX iso.
2. Mount it to the "./cruxmedia/"

"./cruxmedia/" contains directories with packages:

"./cruxmedia/crux/core"
"./cruxmedia/crux/opt"
"./cruxmedia/crux/xorg"

Let's install a full "core".

```
# mkbootstrap crux_gnulinux $(mktemp -d) \
    --ports-dir "./cruxmedia/crux/core"
```

Or install only some packages from the specified directories:

```sh
# mkbootstrap crux_gnulinux `mktemp -d`	\
    --ports-dir "./cruxmedia/crux/core"	\
    --ports-dir "./cruxmedia/crux/opt"	\
    "linux" "bash" "iputils"
```

Filenames are allowed:

```sh
# mkbootstrap crux_gnulinux `mktemp -d`	\
    "./linux#5x-1.pkg.tar.xz"			\
    "./cruxmedia/crux/core/bash#5.1-1.pkg.tar.xz"
```

If you choose another distro like debian_gnulinux, you must use "debootstrap"
options. mkbootstrap just switches to use the "debootstrap", nothing else.

### exportroot / importroot

For saving and loading features you can run "exportroot" and "importroot".

Well you have installed a "chroot" and you want to save the system state
for future use, so run:

```sh
# exportroot "chroot/" > "vanilla-system-state.rootfs"
```

And then, when you want to setup another system from this "chroot/", run:

```sh
# importroot "just-another-chroot/" < "vanilla-system-state.rootfs"
```

It's usable when you only have one system state and many configurations.

Go next.

### mkinitramfs

```sh
# mkinitramfs <directory> [options]
```

This command creates an initrd / initramfs image from the directory.
You can add overlays as well as directories or SquashFS images.

* `--output` "filename" -- filename to output the image. Can output to a STDOUT.
* `--standalone` -- create an initramfs image from the the directory "as is".
* `--overlay` "directory" -- add an overlay usting the selected directory.
can be used so many times as you want.
* `--as-directory` -- copy every overlay as directory.
* `--as-cpio` -- creates cpio-archive from every overlay.
* `--squashfs` -- creates SquashFS image for every overlay.
* `--squashfs-xz` -- creates SquashFS image with XZ-compression for every overlay.

Example:

We have installed a distro into "chroot/", let's make it bootable into a tmpfs.

```sh
# mkinitramfs $(mktemp -d) \
    --overlay "chroot/"	  \
    --output "initrd"
```

In this way the mkinitramfs compiles a "chroot/" directory into an "initrd" image "as is".

```sh
# mkinitramfs $(mktemp -d) \
    --overlay "chroot/"	   \
    --squashfs		   \
    --output "initrd"
```

In this way the mkinitramfs creates from "chroot/" directory the SquashFS-image.

You can also specify as many overlays as you want. For example, you can have an overlay
with the system, an overlay with the configuration, an overlay with your home-data, and so on.

```sh
# mkinitramfs $(mktemp -d) \
    --overlay "chroot/"    \
    --overlay "changes/"   \
    --overlay "/home"      \
    --squashfs-xz          \
    --output "initrd"
```

Every overlay will be compressed into a SquashFS image. Without --squash-xz it's
stored as directories, by default mkinitramfs runs the "cp -a" command.

As an output, you have "initrd" image now. At this moment you can boot it via PXE.
Boot your full system via PXE up and running in a tmpfs by one initrd-image!

Also you can create a bootable ISO image with included data.

### mkbootisofs

mkbootisofs just creating a BIOS / UEFI bootable ISO from the specified directory.

```sh
# mkbootisofs directory/ [options]
```

Available options:

* `--output` "filename" -- filename to output the image. Can output to a STDOUT.

Also you can add overlays using the same options as in mkinitramfs, i.e.:

* `--overlay` "directory" -- add an overlay usting the selected directory.
can be used so many times as you want.
* `--as-directory` -- copy every overlay as directory.
* `--as-cpio` -- creates cpio-archive from every overlay.
* `--squashfs` -- creates SquashFS image for every overlay.
* `--squashfs-xz` -- creates SquashFS image with XZ-compression for every overlay.

> !!! Note: Using the `--as-directory` for put it on ISO is not recommended.

Example:

For ISO making you must create the ISO/ directory manually.
Put a kernel and an initrd into it with your hands.

```sh
# mkdir ./ISO/
# mkdir ./ISO/boot
# cp /boot/vmlinuz ./ISO/boot/vmlinuz
# cp ./initrd ./ISO/boot/initrd
```

Now you can just do mkbootisofs for create bootable ISO.

```sh
# mkbootisofs ISO/ > bootable.iso
```

And then you can using "dd" to burn it on a USB-flash.

```sh
# dd if=./bootable.iso of=/dev/sdX status=progress
```

Also you can create ISO image with some directories as overlays.

```sh
# mkbootisofs ISO/ \
    --overlay "gnulinux-rootfs/"    \
    --overlay "rootfs-changes/"   \
    --squashfs-xz          \
    --output "boot.iso"
```

Simple.

### mkoverlayfs

```sh
# mkoverlayfs directory/ [options]
```

mkoverlayfs creates different archives from the selected directory.
Don't use the `--overlay` option, use only one directory at time.

* `--as-directory` -- Copy directory as directory. Nuff said.
* `--as-cpio` -- Creates cpio-archive from directory.
* `--squashfs` -- Creates SquashFS image from directory.
* `--squashfs-xz` -- Creates SquashFS image with XZ-compression from directory.

Example:

```sh
mkoverlayfs chroot/ \
    --squashfs-xz \
    --output chroot.squashfs \
```

Just creates SquashFS XZ-compressed image from the "chroot/" directory.

## Use cases

1. Create a configuration once. Save it as a script. Use forever.

   1. Living in tmpfs.
   2. Just reboot upon system breaks.

2. Update; just put a new vmlinuz and initrd to the production server and run:

   `# kexec -l /vmlinuz --initrd=/initrd && kexec -e`

   to reload new confgiuration "on-the-fly".

   1. Edit it locally.
   2. Reconfigure by one command or a script.
   3. Test on a local QEMU or Bare-Metal.
   4. Upload it to the remote server.
   5. Do a kexec.

3. Upgrade, from an existing GNU/Linux to the same but running in tmpfs.

   1. Create your configuration by one command or a script.
   2. Upload to the remote server (VDS or something).
   3. `# kexec -l /vmlinuz --initrd=/initrd`
   4. `# systemctl kexec` (a Debian-like way)
   5. Create your own bootable ISO, upload it via the hoster's control panel.
   6. Boot it every time from your own ISO with your configuration!
   7. Format any existing /dev/vda disks, they are no more needed!
   8. Use the full disk-space as encrypt-data storage, without any OS.

4. Create your own portable GNU/Linux distro! Nuff said.

## Examples

### initrd as standalone linux system

For really good initrd do this step-by-step:

* [ Download official CRUX GNU/Linux ISO ]
* [ Mount it to ./cruxmedia ]

Then run:

* `./booty/bootstrap-templates/crux_gnulinux-embedded/crux_gnulinux-embedded.bbuild`

And now you have "crux_gnulinux-embedded.rootfs" with ~160MB++ size.

* `./booty/bootstrap-templates/crux_gnulinux-initrd/crux_gnulinux-initrd.bbuild`

And now you have "crux_gnulinux-initrd.rootfs" with ~160MB++ size.
Its a ready to boot initrd image, but 160MB...

* `xz --check=crc32 --keep --threads=0 --best --verbose crux_gnulinux-initrd.rootfs`

And now you have "crux_gnulinux-initrd.rootfs.xz" with 32MB size!
CRUX GNU/Linux as initramfs with OpenSSH included!
Boot and run "ssh root@host-ip" to login into initramfs! Enjoy!

### boot to any linux from the storage device

You can boot to any Linux. For example I take the Gentoo GNU/Linux.
So got the Gentoo GNU/Linux, download stage3 first from the official web-site.
Do it with your hands.

```sh
# wget https://bouncer.gentoo.org/fetch/root/all/releases/amd64/autobuilds/[...]/stage3-amd64-[...].tar.xz
# mkdir gentoo/
# tar xf stage3-* -C gentoo/
```

Optional do with your hands any configuration with "chroot". Any.
Now create the SquashFS archive (overlay) with Gentoo's "chroot".
Put it in everywhere... to the root of your storage device.

```sh
# mkoverlayfs gentoo/ --squashfs-xz --output /gentoo.squashfs
```

Create a standlone initrd image.

```sh
# mkdir initramfs/
# mkinitramfs initramfs/ > /boot/initrd
```

And then setup your bootloader for booting by using this initrd with pass some
options to the kernel.

```sh
linux /boot/vmlinuz boobs.use-overlayfs boobs.search-rootfs=/gentoo.squashfs
initrd /boot/initrd
```

Optional add the `boobs.copy-to-ram` option for booting to RAM and take out your
storage device.

Thats it. It can be USB storage or something else, you can setup your configuration
on the local machine, upload it to your KVM (VDS, VPS and so on) and boot! Enjoy.

### MOAR

Just see bootstrap-templates/ and bootstrap-systems/ for more examples.

For more examples how I use this look at the directories:

* bootstrap-templates/
* bootstrap-systems/

Templates - scripts for chroots creation and saving, nothing else.

Systems -- scripts for production-ready images configuration and creation.

For example, run a template script:

```sh
# ./booty/bootstrap-templates/crux_gnulinux-embedded.bbuild
```

You will get a "crux_gnulinux-embedded.rootfs" as a lightweight system for embedded use.
Now you can use this template to configure all your embedded systems, adding
some packages, setting up config files, and so on.

So then, run a system script:

```sh
# ./booty/bootstrap-systems/crux_gnulinux-core/crux_gnulinux-core.bbuild
```

And now you will get a "production-ready" install.iso.

GG
