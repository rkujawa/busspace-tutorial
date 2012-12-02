#!/bin/sh
#

. `dirname $0`/environment.conf

# XXX
# BST_REPO=~/repos/busspace-eurobsdcon2012

DRIVER_DIR=$BST_REPO/driver-faa/src

if [ -z "$NETBSD_SRC_DIR" ] ; then
	echo NETBSD_SRC_DIR not set.
	exit 1
fi

echo $NETBSD_SRC_DIR

cd $DRIVER_DIR
for file in `find . -type f | cut -c3-`
do
	if [ ! -z "`echo $file | grep \.diff$`" ] ; then
		FILE_NODIFF=`echo $file | sed s/.diff//`
		patch $NETBSD_SRC_DIR/$FILE_NODIFF $DRIVER_DIR/$file
	else
		cp -v $DRIVER_DIR/$file $NETBSD_SRC_DIR/$file	
	fi
done

cd $NETBSD_SRC_DIR/sys/dev/pci/
awk -f devlist2h.awk pcidevs

