DESTDIR =
BINDIR = /usr/bin
SHAREDIR = /usr/share

VERSION = 2.0
NAME = booty

all: booty

booty: booty.in

.PHONY:	install clean

install: all
	install -D -m 0755 booty.in $(DESTDIR)$(BINDIR)/booty
	install -D -m 0644 booty-init.in $(DESTDIR)$(SHAREDIR)/booty/init.rc

clean:
	rm booty
