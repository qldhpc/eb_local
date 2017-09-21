#!/bin/bash
sourcepath=`eb --show-config | grep "sourcepath" | awk '{print $4}'`
read -p "version (1.5.0):" input
version=${input:-"1.5.0"}
read -p "toolchain (foss-2017a):" input
toolchain=${input:-"foss-2017a"}
cp makefile-raw new/makefile
cat <<InstallTarget >> new/makefile
install:
        mkdir -p $sourcepath/tetgen/$version-$toolchain/bin
        mkdir -p $sourcepath/tetgen/$version-$toolchain/lib
        cp libtet.a $sourcepath/tetgen/$version-$toolchain/lib
        cp tetgen /pkg/suse12/software/tetgen/$version-$toolchain/bin
InstallTarget
diff -Naur old new > makefile.patch
