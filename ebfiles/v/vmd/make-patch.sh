#!/bin/bash
# for new versions of vmd extract the perl configure script,
# replace the default values of $install_bin_dir and $install_library_dir
# with references to environment variables. These are set in the easyconfig.
diff -Naur configure.orig configure > vmd-configure.patch
