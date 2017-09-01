#
# Makefile for Augustus
#
include common.mk

all:
	mkdir -p bin
	cd src && ${MAKE}
	cd auxprogs && ${MAKE}

clean:
	cd src && ${MAKE} clean
	cd auxprogs && ${MAKE} clean
INSTALLDIR = $(PREFIX)

install:
	install -d $(INSTALLDIR)
	cp -a config bin scripts $(INSTALLDIR)

# for internal purposes:
release:
	find . -name .svn | xargs rm -rf
	find . -name "*~" | xargs rm -f
	rm -f src/makedepend.pl
	rm -r augustus-training
	cd docs/tutorial2015/results; ls | grep -v do.sh | grep -v README | xargs rm; cd -
	make clean all
	make clean
	cd config/species; rm -rf tobacco xeno1 bombus_terrestris{1,3} symsag xenoturbella meara pavar newest elegans maker2_*
	rm generic/*.pbl
	cd src/parser; rm Makefile; cd -
	tar -czf ../augustus-$(AUGVERSION).tar.gz .

# remove -static from src/Makefile for MAC users
# remove -g -gdb from CXXFLAGS
# make COMPGENEPRED = true and SQLITE = true and MYSQL = true a comment
