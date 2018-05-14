import os
import os.path
import shutil
from subprocess import call
from easybuild.framework.easyblock import EasyBlock
from easybuild.easyblocks.generic.configuremake import ConfigureMake
from easybuild.framework.easyconfig import CUSTOM
from easybuild.tools.build_log import EasyBuildError
from easybuild.tools.run import run_cmd

class EB_LAMMPS_SIMPLE(EasyBlock):
    """
    Build new lammps without Make.py
    """
    def configure_step(self):
        pass

    def build_step(self):
        blddir = os.path.join(self.builddir,"lammps-"+self.version,"src")
        os.chdir(blddir)
        opts = []
        opts.append("make")
        opts.append("mpi")
        call(opts)

    def install_step(self):
        srcdir = os.path.join(self.builddir,"lammps-"+self.version,"src")
        destdir = self.installdir+"/bin"
        srcfile = os.path.join(srcdir, "lmp_mpi")
        try:
            if os.path.exists(destdir):
                shutil.copy(srcfile, destdir)
            else:
                os.makedirs(destdir)
                shutil.copy(srcfile, destdir)
        except OSError, err:
            raise EasyBuildError("Copying %s to installation dir %s failed: %s", srcfile, destdir, err)
        
