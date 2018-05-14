include ../../../mk/pitchfork.mk

# CXX check
include ../../../mk/chkcxx.mk

# Local variables
_NAME             = blasr_libcpp
$(_NAME)_REPO    ?= git://github.com/PacificBiosciences/$(_NAME)
_WRKSRC           = $(WORKDIR)/$(_NAME)
$(_NAME)_VERSION ?= HEAD
_REVISION         = $(shell cd $(_WRKSRC) && $(GIT) rev-parse --short $($(_NAME)_VERSION) || true)

# Local works
ifeq ($(origin HAVE_BLASR_LIBCPP),undefined)
do-fetch: $(_WRKSRC)
$(_WRKSRC):
ifeq ($(wildcard $($(_NAME)_REPO)),)
	$(GIT) clone $($(_NAME)_REPO) $@
	cd $(_WRKSRC) && $(GIT) checkout $($(_NAME)_VERSION)
else
	ln -sfn $($(_NAME)_REPO) $(_WRKSRC)
endif
do-config: $(_WRKSRC)/defines.mk
$(_WRKSRC)/defines.mk: | do-fetch
	cd $(_WRKSRC) && \
        $(SYSPYTHON) configure.py \
            PREFIX=$(PREFIX) \
          HDF5_INC=$(HDF5_ROOT)/include \
          HDF5_LIB=$(HDF5_ROOT)/lib \
          ZLIB_LIB=$(ZLIB_ROOT) \
         PBBAM_INC=$(PREFIX)/include PBBAM_LIB=$(PREFIX)/lib \
         BOOST_INC=$(BOOST_ROOT)/include \
        HTSLIB_INC=$(PREFIX)/src/htslib/include \
        HTSLIB_LIB=$(PREFIX)/src/htslib/lib
do-build: $(_WRKSRC)/alignment/libblasr.$(DYLIB)
$(_WRKSRC)/alignment/libblasr.$(DYLIB): | do-config
	$(MAKE) -C $(_WRKSRC) libpbdata LDLIBS=-lpbbam
	$(MAKE) -C $(_WRKSRC) libpbihdf
	$(MAKE) -C $(_WRKSRC) libblasr
do-install: $(PREFIX)/var/pkg/$(_NAME)
$(PREFIX)/var/pkg/$(_NAME): | do-build
	cp -aL $(_WRKSRC)/alignment/libblasr.$(DYLIB) $(PREFIX)/lib/
	cp -aL $(_WRKSRC)/hdf/libpbihdf.$(DYLIB) $(PREFIX)/lib/
	cp -aL $(_WRKSRC)/pbdata/libpbdata.$(DYLIB) $(PREFIX)/lib/
	cd $(_WRKSRC) && tar cf - `find alignment hdf pbdata \( -name '*.hpp' -or -name '*.h' \)` | tar xf - -C $(PREFIX)/include
	echo lib/libblasr.$(DYLIB) > $@
	echo lib/libpbihdf.$(DYLIB) >> $@
	echo lib/libpbdata.$(DYLIB) >> $@
	cd $(_WRKSRC) && find alignment hdf pbdata \( -name '*.hpp' -or -name '*.h' \) | awk '{print "include/"$$1}' >> $@
	@echo "# $(_REVISION)" >> $@
else
ifeq ($(wildcard $(HAVE_BLASR_LIBCPP)/lib/libblasr.$(DYLIB)),)
    $(error $(HAVE_BLASR_LIBCPP)/lib/libblasr.$(DYLIB) not found)
endif
do-install: $(PREFIX)/var/pkg/$(_NAME)
$(PREFIX)/var/pkg/$(_NAME):
	cp -aL $(HAVE_BLASR_LIBCPP)/lib/libblasr.$(DYLIB) $(PREFIX)/lib/
	cp -aL $(HAVE_BLASR_LIBCPP)/lib/libpbihdf.$(DYLIB) $(PREFIX)/lib/
	cp -aL $(HAVE_BLASR_LIBCPP)/lib/libpbdata.$(DYLIB) $(PREFIX)/lib/
	cd $(HAVE_BLASR_LIBCPP)/include && tar cf - `find alignment hdf pbdata \( -name '*.hpp' -or -name '*.h' \)` | tar xf - -C $(PREFIX)/include
	echo lib/libblasr.$(DYLIB) > $@
	echo lib/libpbihdf.$(DYLIB) >> $@
	echo lib/libpbdata.$(DYLIB) >> $@
	cd $(HAVE_BLASR_LIBCPP)/include && find alignment hdf pbdata \( -name '*.hpp' -or -name '*.h' \) | awk '{print "include/"$$1}' >> $@
	@echo "# $(shell basename $(HAVE_BLASR_LIBCPP)|awk -F - '{print $$NF}')" >> $@
endif
do-clean:
	$(MAKE) -C $(_WRKSRC) clean
do-distclean:
	test -d $(_WRKSRC) && cd $(_WRKSRC) && $(GIT) clean -xdf || true
do-flush:
	rm -rf $(_WRKSRC)
