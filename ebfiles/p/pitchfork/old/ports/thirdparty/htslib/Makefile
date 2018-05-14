include ../../../mk/pitchfork.mk

# Local variables
_NAME    = htslib
_VERSION = 1.3.2
_FILE    = $(_NAME)-$(_VERSION).tar.bz2
_URL     = https://github.com/samtools/htslib/releases/download/$(_VERSION)
_WRKSRC  = $(WORKDIR)/$(_NAME)-$(_VERSION)
ifneq ($(OPSYS),Darwin)
LDFLAGS += -Wl,-rpath,'\$$\$$ORIGIN/../lib'
export LDFLAGS
endif

# Local works
ifeq ($(origin HAVE_HTSLIB),undefined)
do-extract: $(_WRKSRC)
$(_WRKSRC): | do-fetch
	tar jxf $(_FILE) -C $(WORKDIR)
do-fetch: $(_FILE)
$(_FILE):
	$(PFHOME)/bin/pitchfork fetch --url $(_URL)/$@
do-config: $(_WRKSRC)/config.mk
$(_WRKSRC)/config.mk: | do-extract
	cd $(_WRKSRC) && \
           CFLAGS="$(CFLAGS) -Wall -O2 -Wno-unused-function" \
          LDFLAGS="$(LDFLAGS)" \
               CC="$(CC)" \
        ZLIB_ROOT="$(ZLIB_ROOT)" \
        ./configure --prefix=$(PREFIX) \
                    --disable-gcs --disable-s3 --disable-libcurl --disable-bz2 --disable-lzma \
        >& config.log || $(PFHOME)/bin/diewith config.log
do-build: $(_WRKSRC)/libhts.$(DYLIB)
$(_WRKSRC)/libhts.$(DYLIB): | do-config
	$(MAKE) -C $(_WRKSRC) >& build.log || $(PFHOME)/bin/diewith build.log
do-install: $(PREFIX)/var/pkg/$(_NAME)
$(PREFIX)/var/pkg/$(_NAME): | do-build
	mkdir -p $(PREFIX)/src/htslib/lib
	mkdir -p $(PREFIX)/src/htslib/include
	cd $(_WRKSRC) && tar cf - */*.h | tar xf - -C $(PREFIX)/src/htslib/include/
	cd $(_WRKSRC) && tar cf - *.a   | tar xf - -C $(PREFIX)/src/htslib/lib/
	cd $(PREFIX)  && find src/htslib ! -type d > $@
	@echo "# $(_REVISION)" >> $@ 
#this thing cannot be installed to prefix/lib or it will kill pysam/samtools
else
do-install: $(PREFIX)/var/pkg/$(_NAME)
$(PREFIX)/var/pkg/$(_NAME):
	rm -rf $(STAGING)/$(_NAME)
	mkdir -p $(STAGING)/$(_NAME)/src/htslib
	cd $(HAVE_HTSLIB) && tar cf - lib/libhts.* include/htslib include/cram | tar xf - -C $(STAGING)/$(_NAME)/src/htslib
	cd $(STAGING)/$(_NAME) && tar cf - src/htslib | tar xf - -C $(PREFIX)
	cd $(STAGING)/$(_NAME) && find src/htslib ! -type d > $@
	@echo "# $(HAVE_HTSLIB)" >> $@
endif
do-clean:
	$(MAKE) -C $(_WRKSRC) clean
do-distclean:
	cd $(_WRKSRC) && $(GIT) clean -xdf
do-flash:
	rm -rf $(_WRKSRC)
