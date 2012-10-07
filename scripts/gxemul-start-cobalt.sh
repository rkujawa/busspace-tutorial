#!/bin/sh
#
# This script starts the GXemul in cobalt mode.
#

. `dirname $0`/environment.conf

GXEMUL_FLAGS="-x -E cobalt"

if [ "$1" == "-n" ] ; then
	$GXEMUL_BINARY $GXEMUL_FLAGS $NETBSD_KERNEL 
else
	$GXEMUL_BINARY $GXEMUL_FLAGS -d $NETBSD_FS_IMG $NETBSD_KERNEL 
fi

