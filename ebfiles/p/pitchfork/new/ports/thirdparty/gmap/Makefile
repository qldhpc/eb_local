include ../../../mk/pitchfork.mk

# Local variables
_NAME   = gmap-2016-11-07
_URL    = http://research-pub.gene.com/gmap/src
_FILE   = gmap-gsnap-2016-11-07.tar.gz
_WRKSRC = $(WORKDIR)/$(_NAME)
ifneq ($(OPSYS),Darwin)
LDFLAGS += -Wl,-rpath,'$$\$$\$$$$ORIGIN/../lib'
export LDFLAGS
endif

# Local works
ifeq ($(origin HAVE_GMAP),undefined)
do-fetch: $(_FILE)
$(_FILE):
	$(PFHOME)/bin/pitchfork fetch --url $(_URL)/$@
do-extract: $(_WRKSRC)
$(_WRKSRC): | do-fetch
	tar zxf $(_FILE) -C $(WORKDIR)
do-config: $(_WRKSRC)/config.log
$(_WRKSRC)/config.log: | do-extract
	(cd $(_WRKSRC) && \
        ./configure --prefix=$(STAGING)/$(_NAME)) >& config.log || $(PFHOME)/bin/diewith config.log
do-build: $(_WRKSRC)/src/gmap
$(_WRKSRC)/src/gmap: | do-config
	$(MAKE) -C $(_WRKSRC) >& build.log || $(PFHOME)/bin/diewith build.log
do-install: $(PREFIX)/var/pkg/$(_NAME)
$(PREFIX)/var/pkg/$(_NAME): | do-build
	rm -rf $(STAGING)/$(_NAME)
	$(MAKE) -C $(_WRKSRC) install >& install.log || $(PFHOME)/bin/diewith install.log
	cd $(STAGING)/$(_NAME) && tar cf - * | tar xf - -C $(PREFIX)
	find $(STAGING)/$(_NAME)|awk -F '$(STAGING)/$(_NAME)/' '{print $$2}'|sort -r > $@
else
do-install: | $(PREFIX)/var/pkg/$(_NAME)
$(PREFIX)/var/pkg/$(_NAME):
	rm -rf $(STAGING)/$(_NAME)
	mkdir -p $(STAGING)/$(_NAME)/bin
	rsync -aKx \
            $(HAVE_GMAP)/bin/gmap* \
            $(HAVE_GMAP)/bin/*_coords \
            $(STAGING)/$(_NAME)/bin/
	cd $(STAGING)/$(_NAME) && tar cf - * | tar xf - -C $(PREFIX)
	find $(STAGING)/$(_NAME)|awk -F '$(STAGING)/$(_NAME)/' '{print $$2}'|sort -r > $@
endif
do-clean:
	$(MAKE) -C $(_WRKSRC) clean
	rm -f build.log install.log
	rm -rf $(STAGING)/$(_NAME)
do-distclean:
	$(MAKE) -C $(_WRKSRC) distclean
	rm -f $(_WRKSRC)/config.log config.log
do-flush:
	rm -rf $(_WRKSRC) || true
