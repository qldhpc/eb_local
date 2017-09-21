#!/bin/bash
prefix=`eb --show-config | grep "prefix" | awk '{print $4}'`
read -p "version (1.5.0):" input
version=${input:-"1.5.0"}
read -p "toolchain (foss-2017a):" input
toolchain=${input:-"foss-2017a"}
fullpath=$prefix/software/tetgen/$version-$toolchain
cp makefile-raw new/makefile
cat <<InstallTarget >> new/makefile

.PHONY: install
install: 
	mkdir -p $fullpath/bin 
	mkdir -p $fullpath/lib 
	install -m 557 tetgen $fullpath/bin/ 
	install -m 557 libtet.a $fullpath/lib/ 

InstallTarget
diff -Naur old new > makefile.patch
