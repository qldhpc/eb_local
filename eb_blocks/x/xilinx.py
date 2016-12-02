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
EasyBuild support for XILINX, implemented as an easyblock

@author: Hamish Macintosh (Queensland University of Technology)
"""
import os

from easybuild.easyblocks.generic.binary import Binary
from easybuild.framework.easyblock import EasyBlock
from easybuild.tools.build_log import EasyBuildError
from easybuild.tools.run import run_cmd
from distutils.version import LooseVersion


class EB_XILINX(Binary):
    """Support for installing XILINX."""

    def __init__(self, *args, **kwargs):
        """Initialisation of custom class variables for XILINX."""
        super(EB_XILINX, self).__init__(*args, **kwargs)
        self.setupconfig= None
	

    def extract_step(self):
       """Use default extraction procedure instead of the one for the Binary easyblock."""
       EasyBlock.extract_step(self)

    def configure_step(self):
        """Configure XILINX installation."""
	try:
		self.setupconfigfile = os.path.join(self.builddir, "install_config.txt")
		txt = '\n'.join([
		"Edition=Vivado HL Design Edition",
		"Destination=%s" % self.installdir,
		"Modules=Zynq UltraScale+ MPSoC:1,Software Development Kit (SDK):0,DocNav:1,Spartan-7:0,Virtex-7:1,Kintex UltraScale:1,Kintex-7:1,Virtex UltraScale:1,Virtex UltraScale+:1,Zynq-7000:1,Kintex UltraScale+:1,Artix-7:1",
		"InstallOptions=Acquire or Manage a License Key:0,Enable WebTalk for SDK to send usage statistics to Xilinx:0,Enable WebTalk for Vivado to send usage statistics to Xilinx (Always enabled for WebPACK license):0",
		"CreateProgramGroupShortcuts=0",
		"ProgramGroupFolder=Xilinx Design Tools",
		"CreateShortcutsForAllUsers=0",
		"CreateDesktopShortcuts=0",
		"CreateFileAssociation=0",
                ])
		f = file(self.setupconfigfile, "w")
		f.write(txt)
		f.close()
        except IOError, err:
            raise EasyBuildError("Failed to create setup config file used for replaying installation: %s", err)

    def install_step(self):
        """Install XILINX using 'setup'."""
        os.chdir(self.builddir)
        if self.cfg['install_cmd'] is None:
            self.cfg['install_cmd'] = "%s/%s/xsetup " % (self.builddir,self.version)
            self.cfg['install_cmd'] += "--agree XilinxEULA,3rdPartyEULA,WebTalkTerms --batch Install --config %s" % (self.setupconfigfile)
        super(EB_XILINX, self).install_step()

    def sanity_check_step(self):
        """Custom sanity check for XILINX."""
        custom_paths = {
           'files': [ "Vivado/%(self.version)s/bin/vivado", "Vivado_HLS/%(self.version)s/bin/vivado_hls"],
           'dirs': ["Vivado/%(self.version)s/bin", "Vivado_HLS/%(self.version)s/bin/"],
        }
        super(EB_XILINX, self).sanity_check_step(custom_paths=custom_paths)   
      
 
    def make_module_req_guess(self):
        """Custom extra module file entries for XILINX"""
        guesses = super(EB_XILINX, self).make_module_req_guess()
        dirs = [
            "Vivado/%s/bin" % (self.version),
            "Vivado_HLS/%s/bin" % (self.version),
        ]
        guesses.update({"PATH": [dir for dir in dirs]})
        return guesses
