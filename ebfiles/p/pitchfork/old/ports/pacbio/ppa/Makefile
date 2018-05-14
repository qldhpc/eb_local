include ../../../mk/pitchfork.mk

# CXX check
include ../../../mk/chkcxx.mk

# Local variables
_NAME            = ppa
_WRKSRC          = $(WORKDIR)/$(_NAME)
_WRKSRCP4        = $(shell hostname -s)
_P4CLIENTNAME    = ${USER}-pitchfork-$(_WRKSRCP4)
_P4CLIENT        = P4CLIENT=$(_P4CLIENTNAME)
_BUILD           = $(_WRKSRC)/Sequel/ppa/build

# Local works
do-fetch: $(_WRKSRC) 
	cd $(_WRKSRC) && p4 -c $(_P4CLIENTNAME) sync
$(_WRKSRC):
ifeq ($(wildcard $($(_NAME)_REPO)),)
	mkdir -p $(_WRKSRC)
	if [[ `p4 clients | grep $(_P4CLIENTNAME)` ]]; then p4 client -d $(_P4CLIENTNAME); fi
	cd $(_WRKSRC) && \
        P4EDITOR=cat p4 -c $(_P4CLIENTNAME) client -S //PrimaryAnalysis/main_ppa
else
	ln -sfn $($(_NAME)_REPO) $(_WRKSRC)
endif
do-config: $(_BUILD)/Makefile
$(_BUILD)/Makefile: | do-fetch
	mkdir -p $(_BUILD)
	cd $(_BUILD) && \
    $(CMAKE) \
        -DSECONDARY_BUILD=T \
        -DPPA_build_tests=OFF \
        -DBoost_INCLUDE_DIRS=$(BOOST_ROOT)/include \
        -DPacBioBAM_INCLUDE_DIRS=$(PREFIX)/include \
        -DPacBioBAM_LIBRARIES=$(PREFIX)/lib/libpbbam.$(DYLIB) \
        -DHtslib_INCLUDE_DIRS=$(PREFIX)/src/htslib/include \
        -DHTSLIB_LIBRARIES=$(PREFIX)/src/htslib/lib/libhts.a \
        -DZLIB_LIBRARIES=$(ZLIB_ROOT)/lib/libz.$(DYLIB) \
        ..
do-build:
	$(MAKE) -j -C $(_BUILD) VERBOSE=1
do-install: $(PREFIX)/var/pkg/$(_NAME)
$(PREFIX)/var/pkg/$(_NAME): | do-build
	rsync -ax $(_BUILD)/ba* $(PREFIX)/bin/
	cd $(_BUILD) && find ba*  ! -type d|awk '{print "bin/"$$1}' > $@
do-clean:
	-$(MAKE) -C $(_BUILD) clean
do-distclean:
	rm -rf $(_BUILD)
do-flush:
