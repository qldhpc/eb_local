include ../../../mk/pitchfork.mk

# CXX check
include ../../../mk/chkcxx.mk

# Local variables
_NAME             = blasr
$(_NAME)_REPO    ?= git://github.com/PacificBiosciences/$(_NAME)
_WRKSRC           = $(WORKDIR)/$(_NAME)
$(_NAME)_VERSION ?= HEAD
_REVISION         = $(shell cd $(_WRKSRC) && $(GIT) rev-parse --short $($(_NAME)_VERSION) || true)
ifeq ($(OPSYS),FreeBSD)
MAKE            := $(MAKE) DL_LIBFLAGS=''
endif
ifneq ($(wildcard $(PREFIX)/lib/libsz.so),)
HDF5_LIBFLAGS = -lhdf5_cpp -lhdf5 -lsz
else
HDF5_LIBFLAGS = -lhdf5_cpp -lhdf5
endif
ifneq ($(wildcard $(PREFIX)/lib/libpbbam.$(DYLIB)),)
PacBioBAM_LIBRARIES = $(PREFIX)/lib/libpbbam.$(DYLIB)
else
PacBioBAM_LIBRARIES = $(PREFIX)/lib/libpbbam.a
endif

# Local works
ifeq ($(origin HAVE_BLASR),undefined)
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
        $(SYSPYTHON) configure.py --shared \
               PREFIX=$(PREFIX) \
             HDF5_INC=$(HDF5_ROOT)/include \
             HDF5_LIB=$(HDF5_ROOT)/lib \
             ZLIB_LIB=$(ZLIB_ROOT) \
            BOOST_INC=$(BOOST_ROOT)/include \
        LIBPBDATA_INC=$(PREFIX)/include/pbdata \
        LIBPBIHDF_INC=$(PREFIX)/include/hdf \
         LIBBLASR_INC=$(PREFIX)/include/alignment \
        LIBPBDATA_LIB=$(PREFIX)/lib \
        LIBPBIHDF_LIB=$(PREFIX)/lib \
         LIBBLASR_LIB=$(PREFIX)/lib \
            PBBAM_INC=$(PREFIX)/include \
            PBBAM_LIB=$(PREFIX)/lib \
           HTSLIB_INC=$(PREFIX)/src/htslib/include \
           HTSLIB_LIB=$(PREFIX)/src/htslib/lib
do-build: $(_WRKSRC)/blasr
$(_WRKSRC)/blasr: | do-config
ifneq ($(wildcard $(PREFIX)/lib/libsz.so),)
	$(MAKE) -C $(_WRKSRC) blasr HDF5_LIBFLAGS="$(HDF5_LIBFLAGS)"
	$(MAKE) -C $(_WRKSRC)/utils HDF5_LIBFLAGS="$(HDF5_LIBFLAGS)"
else
	$(MAKE) -C $(_WRKSRC) blasr
	$(MAKE) -C $(_WRKSRC)/utils
endif
do-install: $(PREFIX)/var/pkg/$(_NAME)
$(PREFIX)/var/pkg/$(_NAME): | do-build
	cd $(_WRKSRC) && tar cf - blasr | tar xf - -C $(PREFIX)/bin/
	cd $(_WRKSRC)/utils && tar cf - loadPulses pls2fasta sawriter | tar xf - -C $(PREFIX)/bin/
	cd $(_WRKSRC)/utils && tar cf - samFilter samtoh5 samtom4 sdpMatcher toAfg | tar xf - -C $(PREFIX)/bin/
	cd $(PREFIX) && \
        find bin/blasr      \
             bin/loadPulses \
             bin/pls2fasta  \
             bin/sawriter   \
             bin/samFilter  \
             bin/samtoh5    \
             bin/samtom4    \
             bin/sdpMatcher \
             bin/toAfg      \
        > $@
	@echo "# $(_REVISION)" >> $@
else
ifeq ($(wildcard $(HAVE_BLASR)/bin/blasr),)
    $(error $(HAVE_BLASR)/bin/blasr not find)
endif
do-install: $(PREFIX)/var/pkg/$(_NAME)
$(PREFIX)/var/pkg/$(_NAME):
	cd $(HAVE_BLASR)/bin && \
        tar cf - blasr      \
                 loadPulses \
                 pls2fasta  \
                 sawriter   \
                 samFilter  \
                 samtoh5    \
                 samtom4    \
                 sdpMatcher \
                 toAfg      \
        | tar xf - -C $(PREFIX)/bin/
	cd $(PREFIX) && \
        find bin/blasr      \
             bin/loadPulses \
             bin/pls2fasta  \
             bin/sawriter   \
             bin/samFilter  \
             bin/samtoh5    \
             bin/samtom4    \
             bin/sdpMatcher \
             bin/toAfg      \
        > $@
endif
do-clean:
	$(MAKE) -C $(_WRKSRC) clean
do-distclean:
	test -d $(_WRKSRC) && cd $(_WRKSRC) && $(GIT) clean -xdf || true
do-flush:
	rm -rf $(_WRKSRC)
