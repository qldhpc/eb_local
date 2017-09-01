#!/bin/bash
diff -Naur Makefile.in.top.orig Makefile.in.top > BLAST+-2.6.0_make.patch
diff -Naur teamcity_boost.cpp.orig teamcity_boost.cpp > BLAST+-2.6.0_teamcity.patch
diff -Naur test_boost.cpp.orig test_boost.cpp > BLAST+-2.6.0_test.patch
sed -i BLAST+-2.6.0_make.patch -f - << MAKE_SCRIPT
 s:--- Makefile.in.top.orig:--- ncbi-blast-2.6.0+-src/c++/src/build-system/Makefile.in.top.orig:
 s:+++ Makefile.in.top:+++ ncbi-blast-2.6.0+-src/c++/src/build-system/Makefile.in.top:
MAKE_SCRIPT
sed -i BLAST+-2.6.0_test.patch -f - << TEST_SCRIPT
 s:--- test_boost.cpp.orig:--- ncbi-blast-2.6.0+-src/c++/src/corelib/test_boost.cpp.orig:
 s:+++ test_boost.cpp:+++ ncbi-blast-2.6.0+-src/c++/src/corelib/test_boost.cpp:
TEST_SCRIPT
sed -i BLAST+-2.6.0_teamcity.patch -f - << TESTCITY_SCRIPT
 s:--- teamcity_boost.cpp.orig:--- ncbi-blast-2.6.0+-src/c++/src/corelib/teamcity_boost.cpp.orig:
 s:+++ teamcity_boost.cpp:+++ ncbi-blast-2.6.0+-src/c++/src/corelib/teamcity_boost.cpp:
TESTCITY_SCRIPT
