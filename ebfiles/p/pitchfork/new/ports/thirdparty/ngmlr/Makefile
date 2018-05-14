include ../../../mk/pitchfork.mk

# Local variables
_NAME    = ngmlr
_VERSION = 0.2.4
_URL     = https://github.com/philres/ngmlr/releases/download/v$(_VERSION)/
_FILE    = ngmlr-$(_VERSION)-beta-linux-x86_64.tar.gz
_WRKSRC  = $(WORKDIR)/$(_NAME)

# Local works
do-extract: $(_WRKSRC)
$(_WRKSRC): | do-fetch
do-fetch: $(_FILE)
$(_FILE):
	$(PFHOME)/bin/pitchfork fetch --url $(_URL)/$@
do-install: $(PREFIX)/var/pkg/$(_NAME)
$(PREFIX)/var/pkg/$(_NAME): | do-extract
	rm -rf $(STAGING)/$(_NAME) && mkdir -p $(STAGING)/$(_NAME)/bin
	tar zxf $(_FILE) --strip 1 -C $(STAGING)/$(_NAME)/bin/
	cd $(STAGING)/$(_NAME) && tar cf - * | tar xf - -C $(PREFIX)
	find $(STAGING)/$(_NAME) ! -type d|awk -F '$(STAGING)/$(_NAME)/' '{print $$2}' > $@
do-clean:
	rm -f build.log install.log
	rm -rf $(STAGING)/$(_NAME)
do-distclean:
	rm -f $(_WRKSRC)/config.log config.log
do-flush:
	rm -rf $(_WRKSRC) || true
