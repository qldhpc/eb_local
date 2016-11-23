##
# Copyright 2009-2016 Ghent University
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
EasyBuild support for COMSOL, implemented as an easyblock

@author: Hamish Macintosh (Queensland University of Technology)
"""
import os

from easybuild.easyblocks.generic.binary import Binary
from easybuild.framework.easyblock import EasyBlock
from easybuild.tools.build_log import EasyBuildError
from easybuild.tools.run import run_cmd
from distutils.version import LooseVersion


class EB_COMSOL(Binary):
    """Support for installing COMSOL."""

    def __init__(self, *args, **kwargs):
        """Initialisation of custom class variables for COMSOL."""
        super(EB_COMSOL, self).__init__(*args, **kwargs)
        self.setupconfig= None
	

    def extract_step(self):
       """Use default extraction procedure instead of the one for the Binary easyblock."""
       EasyBlock.extract_step(self)

    def configure_step(self):
        """Configure COMSOL installation."""
	try:
		self.setupconfigfile = os.path.join(self.builddir, "setupconfig.ini")
		txt = '\n'.join([
		#the options below are COMSOL defaults where not assigned by variable
		"installdir = %s" % self.installdir,
		"uninstall = 0",
		"showgui = 0",
		"autofinish = 1",
		"quiet = 0",
		"language = en_US",
		"agree = 1",
		"license = %s@%s" % (self.cfg['license_server_port'],self.cfg['license_server']),
		"name =",
		"company =",
		"lictype =",
		"licno =",
		"matlabdir =",
		"proedir =",
		"creopdir =",
		"llexcelallusers = 0",
		"doc = selected",
		"applications = selected",
		"cad = 1",
		"licmanager = 1",
		"startmenushortcuts = 0",
		"desktopshortcuts = 0",
		"linuxlauncher = 0",
		"symlinks = 0",
		"fileassoc = 0",
		"checkupdate = 0",
		"firewall = 0",
		"setsecuritypolicy = 0",
		"security.comsol.allowbatch = 1",
		"security.comsol.allowexternalprocess = 0",
		"security.comsol.allowmethods = 1",
		"security.comsol.allowapplications = 1",
		"security.external.enable = 1",
		"security.external.propertypermission = 0",
		"security.external.runtimepermission = 0",
		"security.external.filepermission = limited",
		"security.external.socketpermission = 0",
		"security.external.netpermission = 0",
		"security.external.reflectpermission = 0",
		"security.external.securitypermission = 0",
		"server.port = 2036",
		"server.service = 1",
		"server.service.account = default",
		"server.service.password =",
		"server.service.start = auto",
		"server.createadmin = 0",
		"server.admin = localadmin",
		"server.admin.password = changeit",
		"server.multiple = 0",
		"server.primary = 1",
		"server.multiple.prefsdir =",
		"server.multiple.primaryhost = auto",
		"server.multiple.primaryport = auto",
		"server.multiple.primaryuser = auto",
		"server.windowsauthentication = 0",
		"server.windowsauthentication.adminrole = BUILTIN\Administrators",
		"server.windowsauthentication.poweruserrole = BUILTIN\Power Users",
		"server.windowsauthentication.userrole = BUILTIN\Users",
		"server.windowsauthentication.guestrole = BUILTIN\Guests",
                ])
		f = file(self.setupconfigfile, "w")
		f.write(txt)
		f.close()
        except IOError, err:
            raise EasyBuildError("Failed to create setup config file used for replaying installation: %s", err)

    def install_step(self):
        """Install COMSOL using 'setup'."""
        os.chdir(self.builddir)
        if self.cfg['install_cmd'] is None:
            self.cfg['install_cmd'] = "%s/%s/setup" % (self.builddir,self.version)
            self.cfg['install_cmd'] += " -s %s" % (self.setupconfigfile)
        super(EB_COMSOL, self).install_step()

    def sanity_check_step(self):
        """Custom sanity check for COMSOL."""
        custom_paths = {
           'files': [ "bin/comsol" ],
           'dirs': ["bin"],
        }
        super(EB_COMSOL, self).sanity_check_step(custom_paths=custom_paths)   
       
    def make_module_req_guess(self):
        """Update PATH guesses for COMSOL."""
        guesses = super(EB_COMSOL, self).make_module_req_guess()
	guesses.update({
            'PATH': ["bin"],
        })
        return guesses
