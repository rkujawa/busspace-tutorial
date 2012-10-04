busspace-eurobsdcon2012
=======================

Materials for bus_space(9) tutorial for EuroBSDcon 2012.

Prerequisites for running the materials:
- gcc, g++ and usual build tools
- X11 client libraries (server not required but recommended)
- git
- wget (or other download tool)

Download and run the scripts/setup.sh script. It will automagically fetch the 
git repositories, build the GXemul, the NetBSD tools and kernel. This script 
was tested only on the NetBSD 6 and MacOS X 10.8.2, YMMV.


Known problems
==============

Some git installations are unable to verify github.com certificate. Add
-c http.sslVerify=false option GITHUB_OPTS variable at the beginning of
setup.sh script.

-- 
Radoslaw Kujawa

