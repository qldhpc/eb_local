#!/bin/bash
module load easybuild
rm -f /pkg/suse12/modules/lib/libreadline/7.0-foss-2017a
rm -rf /pkg/suse12/software/libreadline/7.0-foss-2017a
eb libreadline-7.0-foss-2017a.eb -dr --rebuild
rm -f /pkg/suse12/modules/devel/ncurses/6.0-foss-2017a
rm -rf /pkg/suse12/software/ncurses/6.0-foss-2017a
eb ncurses-6.0-foss-2017a.eb -dr --rebuild
rm -f /pkg/suse12/modules/tools/bzip2/1.0.6-foss-2017a
rm -rf /pkg/suse12/software/bzip2/1.0.6-foss-2017a
eb bzip2-1.0.6-foss-2017a.eb -dr --rebuild
rm -f /pkg/suse12/modules/tools/xz/5.2.3-foss-2017a
rm -rf /pkg/suse12/software/xz/5.2.3-foss-2017a
eb XZ-5.2.3-foss-2017a.eb -dr --rebuild
rm -f /pkg/suse12/modules/lib/zlib/1.2.11-foss-2017a
rm -rf /pkg/suse12/software/zlib/1.2.11-foss-2017a
eb zlib-1.2.11-foss-2017a.eb -dr --rebuild
rm -f /pkg/suse12/modules/devel/sqlite/3.19.3-foss-2017a
rm -rf /pkg/suse12/software/sqlite/3.19.3-foss-2017a
eb SQLite-3.19.3-foss-2017a.eb -dr --rebuild
rm -f /pkg/suse12/modules/devel/pcre/8.41-foss-2017a
rm -rf /pkg/suse12/software/pcre/8.41-foss-2017a
eb PCRE-8.41-foss-2017a.eb -dr --rebuild
rm -f /pkg/suse12/modules/lib/libpng/1.6.29-foss-2017a
rm -rf /pkg/suse12/software/libpng/1.6.29-foss-2017a
eb libpng-1.6.29-foss-2017a.eb -dr --rebuild
rm -f /pkg/suse12/modules/lib/libjpeg-turbo/1.5.1-foss-2017
rm -rf /pkg/suse12/software/libjpeg-turbo/1.5.1-foss-2017
eb libjpeg-turbo-1.5.1-foss-2017a.eb -dr --rebuild
rm -f /pkg/suse12/modules/lib/libtiff/4.0.8-foss-2017a
rm -rf /pkg/suse12/software/libtiff/4.0.8-foss-2017a
eb libTIFF-4.0.8-foss-2017a.eb -dr --rebuild
rm -f /pkg/suse12/modules/lang/tcl/8.6.6-foss-2017a
rm -rf /pkg/suse12/software/tcl/8.6.6-foss-2017a
eb Tcl-8.6.6-foss-2017a.eb -dr --rebuild
rm -f /pkg/suse12/modules/vis/tk/8.6.6-foss-2017a-no-x11
rm -rf /pkg/suse12/software/tk/8.6.6-foss-2017a-no-x11
eb Tk-8.6.6-foss-2017a-no-X11.eb -dr --rebuild
rm -f /pkg/suse12/modules/tools/curl/7.54.0-foss-2017a
rm -rf /pkg/suse12/software/curl/7.54.0-foss-2017a
eb cURL-7.54.0-foss-2017a.eb -dr --rebuild
rm -f /pkg/suse12/modules/lib/libxml2/2.9.4-foss-2017a
rm -rf /pkg/suse12/software/libxml2/2.9.4-foss-2017a
eb libxml2-2.9.4-foss-2017a.eb -dr --rebuild
rm -f /pkg/suse12/modules/data/gdal/2.2.1-foss-2017a
rm -rf /pkg/suse12/software/gdal/2.2.1-foss-2017a
eb GDAL-2.2.1-foss-2017a.eb -dr --rebuild
rm -f /pkg/suse12/modules/lib/proj/4.9.3-foss-2017a
rm -rf /pkg/suse12/software/proj/4.9.3-foss-2017a
eb PROJ-4.9.3-foss-2017a.eb -dr --rebuild
rm -f /pkg/suse12/modules/math/gmp/6.1.2-foss-2017a
rm -rf /pkg/suse12/software/gmp/6.1.2-foss-2017a
eb GMP-6.1.2-foss-2017a.eb -dr --rebuild
# now install R itself. First wipe out the destination
rm -rf /pkg/suse12/software/r/3.4.1-foss-2017a/
eb R-3.4.1-foss-2017a.eb -dr --rebuild
