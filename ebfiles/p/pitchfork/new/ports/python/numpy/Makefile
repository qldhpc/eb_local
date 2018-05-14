include ../../../mk/pitchfork.mk

# FC check
include ../../../mk/chkfc.mk

# Local variables
_NAME   = numpy-1.10.2
_URL    = https://pypi.python.org/packages/source/n/numpy
_FILE   = $(_NAME).tar.gz
_WRKSRC = $(WORKDIR)/$(_NAME)
LDFLAGS = -L$(PREFIX)/lib
export LDFLAGS

# Local works
do-extract: | $(_WRKSRC)
$(_WRKSRC): | do-fetch
	tar zxf $(_FILE) -C $(WORKDIR)
do-fetch: | $(_FILE)
$(_FILE):
	$(PFHOME)/bin/pitchfork fetch --url $(_URL)/$@
ifneq ($(OPSYS),Darwin)
do-config: | $(_WRKSRC)/site.cfg
$(_WRKSRC)/site.cfg: | do-extract
	$(SED) -e 's@_PREFIX_@$(PREFIX)@g' site.cfg.template > $(_WRKSRC)/site.cfg
else
do-config: | do-extract
endif
do-install: | $(PREFIX)/var/pkg/$(_NAME)
$(PREFIX)/var/pkg/$(_NAME): | do-config
	rm -rf $(STAGING)/$(_NAME)
	mkdir -p $(STAGING)/$(_NAME)
	$(PIP) install --root $(STAGING)/$(_NAME) --no-deps $(_WRKSRC)/
	rsync -aKx $(STAGING)/$(_NAME)/$(PREFIX)/ $(PREFIX)/
	cd $(STAGING)/$(_NAME)$(PREFIX) && find * ! -type d|grep -v '^$$'|sort -r > $@
do-clean:
	rm -rf $(STAGING)/$(_NAME)
do-distclean:
	rm -f $(_WRKSRC)/site.cfg
do-flush:
	rm -rf $(_WRKSRC)
