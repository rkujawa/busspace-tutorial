#!/bin/sh
#
# This script starts the GXemul in cobalt mode.
#

. `dirname $0`/environment.conf

if [ "$1" == "-n" ] ; then
	$GXEMUL_BINARY -x -E cobalt $NETBSD_KERNEL 
else
	$GXEMUL_BINARY -x -E cobalt -d $NETBSD_FS_IMG $NETBSD_KERNEL 
fi

