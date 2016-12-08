
import os
import os.path
import shutil

from easybuild.framework.easyblock import EasyBlock
from easybuild.easyblocks.generic.configuremake import ConfigureMake
from easybuild.framework.easyconfig import CUSTOM
from easybuild.tools.build_log import EasyBuildError
from easybuild.tools.run import run_cmd


class EB_LAMMPS(EasyBlock):
    """
    Support for building LAMMPS 
    - modify Makefiles for libs 
    - build with Make.py and install
    """
    def __init__(self, *args, **kwargs):
        """Initialisation of custom class variables for LAMMPS."""
        super(EB_LAMMPS, self).__init__(*args, **kwargs)
        self.pkgs = []
        self.lib_opts = []
	self.opts = []
        self.lib_custom_links = {}
	self.actions = []
	self.rename = 'auto'
	self.flags = []
	self.makelammps = None

    @staticmethod
    def extra_options():
        extra_vars = {
            'pkgs': [' ', "List of packages to add or remove from LAMMPS", CUSTOM],
            'lib_opts': [' ', "Arguments to be used with library switches in Make.py",CUSTOM],
            'opts': [' ', "Other option switches to be used with Make.py ", CUSTOM],
            'lib_custom_links': [{ } , "Custom linking options for USER Libs", CUSTOM],
            'actions': [ ' ', "Arguments to be used with the action switch of Make.py", CUSTOM],
            'rename': [ 'auto', "Renames the LAMMPS binary to lmp_<rename>", CUSTOM],
            'flags': [ ' ' , "Arguments to be used with the flag switch for Make.py", CUSTOM],
        }
        return ConfigureMake.extra_options(extra_vars)

    def configure_step(self):
        """
        Create Make.Lammps file for packages to build from
        """
        self.pkgs = self.cfg['pkgs']
        self.lib_opts = self.cfg['lib_opts']
        self.opts =self.cfg['opts'] 
        self.lib_custom_links = self.cfg['lib_custom_links']
        self.actions = self.cfg['actions']
        self.rename = self.cfg['rename']
        self.flags = self.cfg['flags']
     
        for lib in self.lib_custom_links:
            try:
                self.makelammps = os.path.join(self.builddir,self.name + "-" + self.version,"lib",lib,"Makefile.lammps.eb")
                txt = '\n'.join([
  	        "# Settings that the LAMMPS build will import when this package library is used",
                " ",
                "user-%s_SYSINC = %s" % (lib, self.lib_custom_links[lib]['SYSINC']),
                "user-%s_SYSLIB = %s" % (lib, self.lib_custom_links[lib]['SYSLIB']),
                "user-%s_SYSPATH = %s "% (lib, self.lib_custom_links[lib]['SYSPATH']),
                ])
	        f=file(self.makelammps,"w")
	        f.write(txt)
	        f.close
            except OSError, err:
                raise EasyBuildError("Failed to create Makefile.lammps.eb for user-lib-%(lib)s: %s", err)
	    try:
                if os.path.exists(os.path.join(self.builddir,self.name+"-"+self.version,"lib",lib,"Makefile.lammps")):
		    os.remove(os.path.join(self.builddir,self.name+"-"+self.version,"lib",lib,"Makefile.lammps"))
		shutil.copy2(os.path.join(self.builddir,self.name+"-"+self.version,"lib",lib,"Makefile.lammps.eb"),os.path.join(self.builddir,self.name+"-"+self.version,"lib",lib,"Makefile.lammps"))
	    except OSError, err:
                raise EasyBuildError("Failed to copy Makefile.lammps.eb to Makefile.lammps: %s", err)

    def build_step(self):
        """
        Build with Make.py script and specified options
        """

	try:
	    os.chdir(self.builddir+"/"+self.name+"-"+self.version+"/src/")
	except OSError, err:
                raise EasyBuildError("Failed to change the path to the build dir: %s", err)

	"""
	Clean build area
	"""
        cmd = "make clean-all"
        run_cmd(cmd, log_all=True, simple=True, log_output=True)
	
        cmd ="./Make.py -j 16"

	#Add options 
	for opt in self.opts:
	    cmd += " "+opt
	#Add flags
	for flag in self.flags:
            cmd += " "+flag
	#Add library options
	for libopts in self.lib_opts:
            cmd += " "+libopts
        #Add/Remove Packages
	cmd += " -p"
	for pkg in self.pkgs:
	    cmd += " "+pkg
	#Rename binary
	cmd += " -o "+self.rename
	#Add actions 
        cmd += " -a"
        for action in self.actions:
            cmd +=" "+action
	#Build with Makefile.auto
	cmd += " file exe"

        run_cmd(cmd, log_all=True, simple=True, log_output=True)

	

    def install_step(self):
        """
        Install by copying files to install dir
        """
        srcdir = os.path.join(self.builddir,self.name+"-"+self.version,"src")
        destdir = self.installdir
        srcfile = os.path.join(srcdir, "lmp_"+self.rename)
        try:
            if os.path.exists(destdir):
                shutil.copy(srcfile, destdir)
	    else:
                os.makedirs(destdir)
                shutil.copy(srcfile, destdir)
        except OSError, err:
            raise EasyBuildError("Copying %s to installation dir %s failed: %s", srcfile, destdir, err)

    def sanity_check_step(self):
        """
        Custom sanity check for LAMMPS
        """
        custom_paths = {
                        'files': ["lmp_"+self.rename],
                        'dirs': []
                       }
        super(EB_LAMMPS, self).sanity_check_step(custom_paths)

    def make_module_req_guess(self):
        """Custom extra module file entries for LAMMPS ."""
        guesses = super(EB_LAMMPS, self).make_module_req_guess()
        guesses.update({"PATH":'/ '})
        return guesses 
