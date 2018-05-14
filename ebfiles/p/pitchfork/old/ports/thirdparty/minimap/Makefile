include ../../../mk/pitchfork.mk

# Local variables 
_NAME             = minimap
_URL              = https://github.com/lh3/minimap/archive
$(_NAME)_VERSION ?= 1cd6ae3bc7c7a6f9e7c03c0b7a93a12647bba244
_VERSION          = 0.2-r124-dirty
_WRKSRC           = $(WORKDIR)/$(_NAME)
_FILE             = $($(_NAME)_VERSION).tar.gz

# Local works
do-extract: $(_WRKSRC)
$(_WRKSRC): | do-fetch
	tar zxf $(_FILE) -C $(WORKDIR)
	mv $(WORKDIR)/$(_NAME)-$($(_NAME)_VERSION) $(_WRKSRC)
do-fetch: $(_FILE)
$(_FILE):
	$(PFHOME)/bin/pitchfork fetch --url $(_URL)/$@
do-build: $(_WRKSRC)/minimap
$(_WRKSRC)/minimap: | do-extract
	$(MAKE) -C $(_WRKSRC) \
		CFLAGS="-g -Wall -O2 -Wc++-compat -Wno-unused-function -I$(PREFIX)/include" \
		LIBS="-L$(PREFIX)/lib -lm -lz -lpthread" \
		>& build.log
do-install: $(PREFIX)/var/pkg/$(_NAME)
$(PREFIX)/var/pkg/$(_NAME): | do-build
	rsync -avx $(_WRKSRC)/minimap $(PREFIX)/bin/ >& install.log
	echo $(PREFIX)/bin/minimap > $(PREFIX)/var/pkg/$(_NAME)
	echo "# $(_VERSION)" >> $(PREFIX)/var/pkg/$(_NAME)
do-clean:
	$(MAKE) -C $(_WRKSRC) clean
	rm -f build.log install.log
	rm -rf $(STAGING)/$(_NAME)
do-distclean: | do-clean
do-flush:
	rm -rf $(_WRKSRC) || true
