#!/bin/bash
read -p "version:" version
diff -Naur Makefile.in.orig Makefile.in > Tk-${version}-Makefile.in.patch
#diff -Naur tkWindow.c.orig tkWindow.c > Tk-${version}-tkWindow.c.patch
sed -i Tk-${version}-Makefile.in.patch -f - << MAKE_SCRIPT
 s:--- Makefile.in.orig:--- tk8.6.6/unix/Makefile.in.orig:
 s:+++ Makefile.in:+++ tk8.6.6/unix/Makefile.in:
MAKE_SCRIPT
#sed -i Tk-${version}-tkWindow.c.patch -f - << WINDOW_SCRIPT
# s:--- tkWindow.c.orig:--- tk8.6.6/generic/tkWindow.c.orig:
# s:+++ tkWindow.c:+++ tk8.6.6/generic/tkWindow.c:
#WINDOW_SCRIPT
