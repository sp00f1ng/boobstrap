DESTDIR =
BINDIR = /usr/bin

VERSION = 2.0
NAME = booty

all: booty

booty: booty.in

.PHONY:	install clean

install: all
	install -D -m 0755 booty.in $(DESTDIR)$(BINDIR)/booty

clean:
	rm booty
