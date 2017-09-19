#!/bin/bash
# for new versions of vmd extract the perl configure script,
# replace the default values of $install_bin_dir and $install_library_dir
# with references to environment variables. These are set in the easyconfig.
diff -Naur 1.9.3/configure.orig 1.9.3/configure > vmd-1.9.3-configure.patch
