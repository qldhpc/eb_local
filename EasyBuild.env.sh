#!/bin/sh

# source this file to configure the EasyBuild environment
echo "Setting the EasyBuild environment..."
export EASYBUILD_PREFIX=/pkg/suse12
export EASYBUILD_CONFIGFILES=$EASYBUILD_PREFIX/eb_local/config.cfg
module use $EASYBUILD_PREFIX/modules/all
echo "done."
echo "Run 'module load EasyBuild' after this."

echo "NOTE: EasyBuild environment variables can be permanently set"
echo "      in the EasyBuild/<version> module file by appending the lines:"
echo "      setenv  EASYBUILD_PREFIX      $EASYBUILD_PREFIX"
echo "      setenv  EASYBUILD_CONFIGFILES $EASYBUILD_PREFIX/eb_local/config.cfg"
echo
echo "EasyBuild modules can be permanently added to the default module search path"
echo "by appending to /usr/share/modules/init/.modulespath the line:"
echo "    $EASYBUILD_PREFIX/modules/all"
echo

