INSTALL=/usr/bin/install	
CC=$(CROSS_COMPILE)-gcc
STRIP=$(CROSS_COMPILE)-strip
DEPENDS=$(shell pwd)/depends
PC=$(shell pwd)
LIBPNG=libpng-1.6.30
ply-image: libpng ply-image.c ply-frame-buffer.c checkmodifier.c Makefile
	$(CC) ply-image.c ply-frame-buffer.c -lm -L./depends/lib -I./depends/include -lz -lpng16 -o ply-image
	$(STRIP) ply-image
	$(CC) checkmodifier.c -o checkmodifier
	$(STRIP) checkmodifier

zlib:
	wget http://www.zlib.net/zlib-1.2.11.tar.gz
	tar -xvf zlib-1.2.11.tar.gz
	cd zlib-1.2.11;AS=$(CROSS_COMPILE)-as LD=$(CROSS_COMPILE)-ld CC=$(CROSS_COMPILE)-gcc ./configure --prefix=$(DEPENDS) && make && make install
	
libpng: zlib
	wget ftp://ftp-osl.osuosl.org/pub/libpng/src/libpng16/$(LIBPNG).tar.gz
	tar -xvf $(LIBPNG).tar.gz
	cd $(LIBPNG);LDFLAGS="-L$(DEPENDS)/lib" ./configure --prefix=$(DEPENDS) --host=$(CROSS_COMPILE) --enable-arm-neon=$(NEON) && make && make install

install:
	$(INSTALL) -d $(DESTDIR)/sbin
	$(INSTALL) -d $(DESTDIR)/usr/bin
	$(INSTALL) -m 755 -c ply-image $(DESTDIR)/usr/bin/ply-image
	$(INSTALL) -m 755 -c checkmodifier $(DESTDIR)/sbin/checkmodifier
	$(INSTALL) -m 755 -c splash_early $(DESTDIR)/sbin/splash_early
	$(INSTALL) -m 644 -c splash.png $(DESTDIR)/usr/splash.png
	$(INSTALL) -m 644 -c splash_sad.png $(DESTDIR)/usr/splash_sad.png
	
clean:
	rm -f -r zlib* libpng* depends
	rm -f ply-image
	rm -f checkmodifier
	rm -f zlib*

