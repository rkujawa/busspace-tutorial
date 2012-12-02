busspace-eurobsdcon2012
=======================

Materials for the EuroBSDcon 2012 bus_space(9) tutorial.

Prerequisites for running the materials:
- UNIX-like operating system, preferably NetBSD
- gcc, g++ and usual build tools
- X11 client libraries (server not required but recommended)
- git
- wget (or other download tool)

Download and run the scripts/setup.sh script. It will automagically fetch the git repositories, GXemul, the NetBSD tools and kernel. Follow instructions. This script was tested only on the NetBSD 6 and MacOS X 10.8.2, YMMV.  

Known problems
==============

Some git installations are unable to verify github.com certificate. Add -c http.sslVerify=false option GIT_OPTS variable at the beginning of setup.sh script. Keep in mind that this potentially exposes you to a man-in-the-middle attack.

Manual installation
===================

If you don't want to use the scripts, or the scripts do not work for you,
materials can be installed manually:

- Clone the bus_space tutorial repository: https://github.com/rkujawa/busspace-tutorial
- Clone the modified GXemul repository: https://github.com/rkujawa/gxemul-busspace-tutorial
- Build the GXemul (configure, make...)
- Download and uncompress the NetBSD/cobalt filesystem image: https://github.com/downloads/rkujawa/busspace-tutorial/netbsd-cobalt.img.bz2
- Download and extract the NetBSD source: https://github.com/downloads/rkujawa/busspace-tutorial/netbsd-20121002.tar.bz2
- Change directory to the NetBSD source directory and build the NetBSD/cobalt tools and kernel: ./build.sh -m cobalt -U tools && ./build.sh -m cobalt -U kernel=GENERIC
- Run the GXemul Cobalt emulation with the newly built kernel

If you decide to use scripts after manual installation you need to fill in variables in scripts/environment.conf file.

-- 
Radoslaw Kujawa

rkujawa at NetBSD dot org

