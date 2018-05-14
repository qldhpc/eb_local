include ../../../mk/pitchfork.mk

# Local variables
_VERSION = 1.0.6
_NAME    = libbzip2-$(_VERSION)
_URL     = http://www.bzip.org/$(_VERSION)
_WRKSRC  = $(WORKDIR)/bzip2-$(_VERSION)
_FILE    = bzip2-$(_VERSION).tar.gz

# Local works
ifeq ($(origin HAVE_LIBBZIP2),undefined)
do-extract: $(_WRKSRC)
$(_WRKSRC): | do-fetch
	tar zxf $(_FILE) -C $(WORKDIR)
do-fetch: $(_FILE)
$(_FILE):
	$(PFHOME)/bin/pitchfork fetch --url $(_URL)/$@
do-build: $(_WRKSRC)/libbz2.$(DYLIB).$(_VERSION)
$(_WRKSRC)/libbz2.$(DYLIB).$(_VERSION): | do-extract
	$(MAKE) -C $(_WRKSRC) -f Makefile-libbz2_so >& build.log || $(PFHOME)/bin/diewith build.log
do-install: $(PREFIX)/var/pkg/$(_NAME)
$(PREFIX)/var/pkg/$(_NAME): | do-build
	rm -rf $(STAGING)/$(_NAME)
	mkdir -p $(STAGING)/$(_NAME)/lib/pkgconfig $(STAGING)/$(_NAME)/include $(STAGING)/$(_NAME)/bin
	cp -aL $(_WRKSRC)/bzip2-shared $(STAGING)/$(_NAME)/bin/bzip2
	cp -aL $(_WRKSRC)/bzlib.h $(STAGING)/$(_NAME)/include
	cp -aL $(_WRKSRC)/libbz2.* $(STAGING)/$(_NAME)/lib
	ln -sfn libbz2.$(DYLIB).1.0 $(STAGING)/$(_NAME)/lib/libbz2.$(DYLIB).1
	ln -sfn libbz2.$(DYLIB).1   $(STAGING)/$(_NAME)/lib/libbz2.$(DYLIB)
	$(SED) -e "s@^prefix=.*@prefix=$(PREFIX)@" bzip2.pc > $(STAGING)/$(_NAME)/lib/pkgconfig/bzip2.pc
	cd $(STAGING)/$(_NAME) && tar cf - * | tar xf - -C $(PREFIX)
	find $(STAGING)/$(_NAME) ! -type d|awk -F '$(STAGING)/$(_NAME)/' '{print $$2}' > $@
else
do-install:
	rm -rf $(STAGING)/$(_NAME)
	mkdir -p $(STAGING)/$(_NAME)/lib/pkgconfig $(STAGING)/$(_NAME)/include $(STAGING)/$(_NAME)/bin
	cp -aL $(HAVE_LIBBZIP2)/bin/bzip2 $(STAGING)/$(_NAME)/bin/
	cp -aL $(HAVE_LIBBZIP2)/include/bzlib.h $(STAGING)/$(_NAME)/include
	cp -aL $(HAVE_LIBBZIP2)/lib/libbz2.* $(STAGING)/$(_NAME)/lib
	ln -sfn libbz2.$(DYLIB).1.0 $(STAGING)/$(_NAME)/lib/libbz2.$(DYLIB).1
	ln -sfn libbz2.$(DYLIB).1   $(STAGING)/$(_NAME)/lib/libbz2.$(DYLIB)
	$(SED) -e "s@^prefix=.*@prefix=$(PREFIX)@" bzip2.pc > $(STAGING)/$(_NAME)/lib/pkgconfig/bzip2.pc
	cd $(STAGING)/$(_NAME) && tar cf - * | tar xf - -C $(PREFIX)
	find $(STAGING)/$(_NAME) ! -type d|awk -F '$(STAGING)/$(_NAME)/' '{print $$2}' > $(PREFIX)/var/pkg/$(_NAME)
endif
do-clean:
	$(MAKE) -C $(_WRKSRC) clean
	rm -f build.log install.log
	rm -rf $(STAGING)/$(_NAME)
do-distclean:
	$(MAKE) -C $(_WRKSRC) distclean
	rm -f $(_WRKSRC)/configure.log config.log
do-flush:
	rm -rf $(_WRKSRC) || true
