#!/bin/sh
#
# This script starts the GXemul in cobalt mode.
#

. `dirname $0`/environment.conf

$GXEMUL_BINARY -x -E cobalt -d $NETBSD_FS_IMG $NETBSD_KERNEL 

#$GXEMUL_BINARY -x -E cobalt $NETBSD_KERNEL 

