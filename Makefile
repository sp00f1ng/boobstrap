DESTDIR =
BINDIR = /usr/bin
ETCDIR = /etc
SHAREDIR = /usr/share
USRDIR = /usr

VERSION = 1.4
NAME = booty

# Packages directory
DISTRO_PACKAGES_DIR = ./packages

# Distro specific directories
ARCH_DIR = ArchLinux


all: booty

booty: booty.in

.PHONY:	install clean arch-pkg

install: all
	install -D -m 0755 booty.in $(DESTDIR)$(BINDIR)/booty
	install -D -m 0644 booty.conf $(DESTDIR)$(ETCDIR)/booty/booty.conf
	install -D -m 0644 booty-init.in $(DESTDIR)$(SHAREDIR)/booty/init
	install -D -m 0644 loader-grub.conf $(DESTDIR)$(SHAREDIR)/booty/grub/grub.cfg
	install -D -m 0644 loader-syslinux.conf $(DESTDIR)$(SHAREDIR)/booty/syslinux/syslinux.cfg
	for sys in systems/*/*/*; \
		do install -D -m 0644 $$sys $(DESTDIR)$(USRDIR)/$$sys; \
	done
	ln -sf booty $(DESTDIR)$(BINDIR)/mkbootstrap
	ln -sf booty $(DESTDIR)$(BINDIR)/mkinitramfs
	ln -sf booty $(DESTDIR)$(BINDIR)/mkbootisofs
	ln -sf booty $(DESTDIR)$(BINDIR)/exportroot
	ln -sf booty $(DESTDIR)$(BINDIR)/importroot
	install -D -m 0755 distmk.in $(DESTDIR)$(BINDIR)/distmk

clean:
	rm -f booty

arch-pkg:
	cd $(DISTRO_PACKAGES_DIR)/$(ARCH_DIR) && makepkg -s
