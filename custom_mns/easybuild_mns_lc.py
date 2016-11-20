##
# Copyright 2013-2016 Ghent University
#
# This file is part of EasyBuild,
# originally created by the HPC team of Ghent University (http://ugent.be/hpc/en),
# with support of Ghent University (http://ugent.be/hpc),
# the Flemish Supercomputer Centre (VSC) (https://www.vscentrum.be),
# Flemish Research Foundation (FWO) (http://www.fwo.be/en)
# and the Department of Economy, Science and Innovation (EWI) (http://www.ewi-vlaanderen.be/en).
#
# http://github.com/hpcugent/easybuild
#
# EasyBuild is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation v2.
#
# EasyBuild is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with EasyBuild.  If not, see <http://www.gnu.org/licenses/>.
##
"""
Implementation of (default) EasyBuild module naming scheme in lowercase.
Derived from the original easybuild_mns.py code by Kenneth Hoste (Ghent University)
available at:
    https://github.com/hpcugent/easybuild-framework/blob/master/easybuild/tools/module_naming_scheme/easybuild_mns.py
Using instructions from:
    https://github.com/hpcugent/easybuild/wiki/Using-a-custom-module-naming-scheme

:author: HPC @ QUT
"""

import os
from easybuild.tools.module_naming_scheme import ModuleNamingScheme
from easybuild.tools.module_naming_scheme.utilities import det_full_ec_version

class EasyBuildMNSlc(ModuleNamingScheme):
    """Class implementing lowercase version of the default EasyBuild module naming scheme."""

    REQUIRED_KEYS = ['name', 'version', 'versionsuffix', 'toolchain']

    def det_full_module_name(self, ec):
        """
        Determine full module name from given easyconfig, according to the EasyBuild module naming scheme.

        :param ec: dict-like object with easyconfig parameter values (e.g. 'name', 'version', etc.)
        :return: string with lowercase of full module name <name>/<installversion>, e.g.: 'gzip/1.5-goolf-1.4.10
        """

        # fetch required values
        name = ec['name']
        fversion = det_full_ec_version(ec)
        #version = ec['version']
        #tc_name = ec['toolchain']['name']
        #tc_version = ec['toolchain']['version']

        # compose module name by lowercasing and stitching parts together
        return os.path.join(name.lower(), fversion.lower())


# NOTE: by default det_short_module_name(self, ec) just calls
#       det_full_module_name(self, ec), so don't need to override it


    def is_short_modname_for(self, short_modname, name):
        """ 
        Determine whether the specified (short) module name is a module for software with the specified name.
        Default implementation checks via a strict regex pattern, and assumes short module names are of the form:
            <name>/<version>[-<toolchain>]
        We lowercase everything and then call the default implementation
        """
        return ModuleNamingScheme.is_short_modname_for(self, short_modname.lower(), name.lower())


