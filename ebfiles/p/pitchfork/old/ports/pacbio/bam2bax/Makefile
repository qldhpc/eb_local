include ../../../mk/pitchfork.mk

# CXX check
include ../../../mk/chkcxx.mk

# Local variables
_NAME             = bam2bax
_WRKSRC           = $(WORKDIR)/$(_NAME)
$(_NAME)_VERSION ?= HEAD
_REVISION         = $(shell cd $(_WRKSRC) && $(GIT) rev-parse --short $($(_NAME)_VERSION) || true)
ifeq ($(origin $(_NAME)_REPO),undefined)
    $(error "You need to set $(_NAME)_REPO")
endif
ifeq ($(OPSYS),FreeBSD)
MAKE            := $(MAKE) DL_LIBFLAGS=''
endif
ifneq ($(wildcard $(PREFIX)/lib/libsz.so),)
CMAKE_LDFLAGS = -lsz
else
CMAKE_LDFLAGS =
endif
ifneq ($(wildcard $(PREFIX)/lib/libpbbam.$(DYLIB)),)
PacBioBAM_LIBRARIES = $(PREFIX)/lib/libpbbam.$(DYLIB)
else
PacBioBAM_LIBRARIES = $(PREFIX)/lib/libpbbam.a
endif
ifeq ($(OPSYS),Darwin)
else ifeq (,$(findstring /usr/lib/gcc,$(shell $(CC) -print-libgcc-file-name)))
CMAKE_LDFLAGS += -lpthread
endif

# Local works
do-fetch: $(_WRKSRC)
$(_WRKSRC):
ifeq ($(wildcard $($(_NAME)_REPO)),)
	$(GIT) clone $($(_NAME)_REPO) $@
	cd $(_WRKSRC) && $(GIT) checkout $($(_NAME)_VERSION)
else
	ln -sfn $($(_NAME)_REPO) $(_WRKSRC)
endif
do-config: $(_WRKSRC)/build/Makefile
$(_WRKSRC)/build/Makefile: | do-fetch
	mkdir -p $(_WRKSRC)/build
	cd $(_WRKSRC)/build && \
        $(CMAKE) \
              -DBoost_INCLUDE_DIRS=$(BOOST_ROOT)/include \
              -DHDF5_RootDir=$(HDF5_ROOT) \
              -DPacBioBAM_INCLUDE_DIRS=$(PREFIX)/include \
              -DPacBioBAM_LIBRARIES=$(PacBioBAM_LIBRARIES) \
              -DHTSLIB_INCLUDE_DIRS=$(PREFIX)/src/htslib/include \
              -DHTSLIB_LIBRARIES=$(PREFIX)/src/htslib/lib/libhts.a \
              -DGTEST_SRC_DIR=$(PREFIX)/src/gtest \
              -DZLIB_LIBRARIES=$(ZLIB_ROOT)/lib/libz.$(DYLIB) \
              -DZLIB_INCLUDE_DIRS=$(ZLIB_ROOT)/include \
              -DBam2Bax_EXE_LINKER_FLAGS="$(CMAKE_LDFLAGS)" \
              -DBLASR_INCLUDE_DIRS=$(PREFIX)/include/alignment \
              -DPBIHDF_INCLUDE_DIRS=$(PREFIX)/include/hdf \
              -DPBDATA_INCLUDE_DIRS=$(PREFIX)/include/pbdata \
              -DBLASR_LIBRARIES=$(PREFIX)/lib/libblasr.$(DYLIB) \
              -DPBIHDF_LIBRARIES=$(PREFIX)/lib/libpbihdf.$(DYLIB) \
              -DPBDATA_LIBRARIES=$(PREFIX)/lib/libpbdata.$(DYLIB) \
        ..
do-build: | do-config
	$(MAKE) -C $(_WRKSRC)/build
do-test-bam2bax:
	$(MAKE) -C $(_WRKSRC)/build test
do-install: $(PREFIX)/var/pkg/$(_NAME)
$(PREFIX)/var/pkg/$(_NAME): | do-build
	cd $(_WRKSRC) && tar cf - bin | tar xf - -C $(PREFIX)/
	cd $(PREFIX) && \
        find bin/bam2bax \
             bin/bam2plx \
        > $@
	@echo "# $(_REVISION)" >> $@
do-clean:
	@rm -rf ${_WRKSRC}/bin/
	@rm -rf ${_WRKSRC}/build
do-distclean:
	test -d $(_WRKSRC) && cd $(_WRKSRC) && $(GIT) clean -xdf || true
do-flush:
	rm -rf $(_WRKSRC)
