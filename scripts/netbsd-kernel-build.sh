#!/bin/sh
#
# This script rebuilds the NetBSD/cobalt kernel (and tools if necessary).
#

. `dirname $0`/environment.conf

if [ ! -d "$NETBSD_SRC_DIR" ] ; then
	echo Cannot find the NetBSD source directory
fi

cd $NETBSD_SRC_DIR

TOOLDIR_NAME="obj/tooldir.`uname -s`-`uname -r`-`uname -m`"

if [ ! -d "$TOOLDIR_NAME" ] ; then
	echo Tools directory not found, attempting to rebuild tools
	./build.sh -U -m cobalt tools
fi 

./build.sh -U -u -m cobalt kernel=GENERIC

