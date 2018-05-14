##
# Copyright 2017 Queensland University of Technology
#
# torch.py is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with EasyBuild.  If not, see <http://www.gnu.org/licenses/>.
##
"""
EasyBuild support for installing Torch7

@author: Desmond Schmidt (Queensland University of Technology)
"""
import os
import shutil
import subprocess

from easybuild.easyblocks.generic.tarball import Tarball
from easybuild.tools.build_log import EasyBuildError


class Torch(Tarball):
    """
    Support for installing Torch7
    """

    def install_step(self):
        """Install by copying unzipped files to the installation dir, and running install.sh with the installdir as a prefix."""

        try:
            for item in os.listdir(self.cfg['start_dir']):
                if os.path.isdir(item):
                    shutil.copytree(os.path.join(self.cfg['start_dir'], item), os.path.join(self.installdir,item))
                    self.log.debug("Copied %s to %s" % (item, self.installdir))
                else:
                    shutil.copy2(os.path.join(self.cfg['start_dir'], item),self.installdir)
            self.log.info("installation path="+self.installdir)
            subprocess.call("export PREFIX="+self.installdir+";cd "+self.installdir+";./install.sh", shell=True)
        except OSError, err:
            raise EasyBuildError("Error: %s: copying from %s to %s failed" % (str(err),os.path.join(self.cfg['start_dir'],item),self.installdir))
