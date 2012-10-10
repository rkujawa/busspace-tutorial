#!/bin/sh
# This script was tested only on the NetBSD/amd64 6.0 and MacOS X 10.8.2.

DOWNLOAD_TOOL=wget	# wget, curl, etc.
DOWNLOAD_TOOL_FLAGS="--no-check-certificate" # my wget doesn't like github cert
GIT_OPTS=""
#GIT_OPTS="-c http.sslVerify=false"

LOG_GXEMUL=/tmp/setup-gxemul.log
LOG_GIT_CLONE=/tmp/setup-git-clone.log
LOG_NETBSD_IMG=/tmp/setup-netbsd-cobalt-image.log
LOG_NETBSD_SRC=/tmp/setup-netbsd-src.log

GITHUB_URL=https://github.com
GITHUB_ACCOUNT=rkujawa
REPO_BUSSPACE_NAME=busspace-eurobsdcon2012
REPO_GXEMUL_NAME=gxemul-eurobsdcon2012
NETBSD_SRC_FILE=netbsd-20121002.tar.bz2
NETBSD_SRC_DIR=src-clean
NETBSD_COBALT_IMG_FILE=netbsd-cobalt.img.bz2

WORK_DIR=$1
ENVTMPFILE=`mktemp -t environment.conf.XXXXXX`
ENVSAVETO=$WORK_DIR/$REPO_BUSSPACE_NAME/scripts/environment.conf

prerequisites () {

which git > /dev/null 2>&1

echo "== Checking prerequisites"

if [ "$?" != 0 ] ; then
	echo "-- Please install git first!"
	exit 1
fi

which $DOWNLOAD_TOOL > /dev/null 2>&1

if [ "$?" != 0 ] ; then
	echo "-- Install wget or change DOWNLOAD_TOOL and DOWNLOAD_TOOL_FLAGS variables in this script!" 
	exit 1
fi

which gcc > /dev/null 2>&1

if [ "$?" != 0 ] ; then
	echo "-- Please install development environment, gcc was not found!"
	exit 1
fi

}

fetch_netbsdsrc() {

NETBSD_SRC_URL=$GITHUB_URL/downloads/$GITHUB_ACCOUNT/$REPO_BUSSPACE_NAME/$NETBSD_SRC_FILE

echo "== Fetching the NetBSD source, logging to $LOG_NETBSD_SRC"
cd $WORK_DIR

$DOWNLOAD_TOOL $DOWNLOAD_TOOL_FLAGS $NETBSD_SRC_URL > $LOG_NETBSD_SRC 2>&1

if [ -f "$NETBSD_SRC_FILE" ] ; then
	echo "-- Successfuly downloaded the archive, extracting..."
else
	echo "-- Couldn't download $NETBSD_SRC_URL"
	exit 1
fi

tar -jxf $NETBSD_SRC_FILE >> $LOG_NETBSD_SRC 2>&1

if [ -d "$NETBSD_SRC_DIR" ] ; then
	echo "-- Source extracted successfully"
else
	echo "-- Problem extracting the NetBSD source"
	exit 1
fi

mv $NETBSD_SRC_DIR src

rm $NETBSD_SRC_FILE

echo "NETBSD_SRC_DIR=$WORK_DIR/src" >> $ENVTMPFILE
echo 'NETBSD_KERNEL=$NETBSD_SRC_DIR/sys/arch/cobalt/compile/obj/GENERIC/netbsd' >> $ENVTMPFILE

}

fetch_netbsdimg() {

NETBSD_IMG_URL=$GITHUB_URL/downloads/$GITHUB_ACCOUNT/$REPO_BUSSPACE_NAME/$NETBSD_COBALT_IMG_FILE

echo "== Fetching the NetBSD/cobalt filesystem image, logging to $LOG_NETBSD_IMG"
cd $WORK_DIR

$DOWNLOAD_TOOL $DOWNLOAD_TOOL_FLAGS $NETBSD_IMG_URL > $LOG_NETBSD_IMG 2>&1 

if [ -f "$NETBSD_COBALT_IMG_FILE" ] ; then
	echo "-- Successfuly downloaded the image, uncompressing..."
else
	echo "-- Couldn't download $NETBSD_IMG_URL"
	exit 1
fi

bzip2 -d $NETBSD_COBALT_IMG_FILE >> $LOG_NETBSD_SRC 2>&1

NETBSD_COBALT_UNCOMPRESSED_IMG_FILE=`echo $NETBSD_COBALT_IMG_FILE | sed s/\.bz2//`

if [ -f "$NETBSD_COBALT_UNCOMPRESSED_IMG_FILE" ] ; then
	echo "-- Image uncompressed successfully"
else
	echo "-- Problem uncompressing the image"
	exit 1
fi

echo "NETBSD_FS_IMG=$WORK_DIR/$NETBSD_COBALT_UNCOMPRESSED_IMG_FILE" >> $ENVTMPFILE

}

create_workdir() {

echo "== Creating work directory $WORK_DIR"

mkdir -p $WORK_DIR
cd $WORK_DIR

if [ $? -eq 0 ] ; then
	echo "-- Work directory ready"
else
	echo "-- Can't cd into $WORK_DIR - please investigate the problem."
	exit 1
fi

}

clone_repos() {

	echo "== Cloning git repositories, logging to $LOG_GIT_CLONE"

git $GIT_OPTS clone $GITHUB_URL/$GITHUB_ACCOUNT/$REPO_BUSSPACE_NAME.git > $LOG_GIT_CLONE 2>&1
git $GIT_OPTS clone $GITHUB_URL/$GITHUB_ACCOUNT/$REPO_GXEMUL_NAME.git >> $LOG_GIT_CLONE 2>&1

if [ $? -eq 0 ] ; then
	echo "-- Repositories cloned successfuly"
else
	echo "-- Can't clone the git repository - see $LOG_GIT_CLONE"
	exit 1
fi 

echo "BST_REPO=$WORK_DIR/$REPO_BUSSPACE_NAME" >> $ENVTMPFILE

}

build_gxemul() {

echo "== Building GXemul, logging to $LOG_GXEMUL"

# Work around build problem on MacOS X 
if [ ! -z "`uname | grep Darwin`" ] ; then
	export CXX=g++
fi

cd $WORK_DIR/$REPO_GXEMUL_NAME/gxemul-current

./configure > $LOG_GXEMUL 2>&1
make >> $LOG_GXEMUL 2>&1

if [ -x "$WORK_DIR/$REPO_GXEMUL_NAME/gxemul-current/gxemul" ] ; then
	echo "-- GXemul was build successfully"
else 
	echo "-- Couldn't build GXemul, see $LOG_GXEMUL"
	exit 1
fi

echo "GXEMUL_BINARY=$WORK_DIR/$REPO_GXEMUL_NAME/gxemul-current/gxemul" >> $ENVTMPFILE

}

usage() {
	echo "This script attempts to setup a sane environment for running materials"
	echo "from EuroBSDcon 2012 bus_space(9) tutorial. Please specify the path to"
	echo "work directory (it will be created if it does not exist). To start again" 
	echo "just delete the directory."
	echo ""
	echo "usage: $0 path"
}

lolitsdone() {
	echo "Your development environment is ready in $WORK_DIR !"
	echo ""
	echo "Now you can try running:"
	echo "scripts/integrate-driver.sh - to integrate the example driver source"
	echo "	code into the NetBSD source"
	echo "scripts/netbsd-kernel-rebuild.sh - to rebuld the kernel"
	echo "scripts/gxemul-start-cobalt.sh - to start the NetBSD/cobalt with newly"
	echo "	rebuilt kernel"
	echo ""
	echo "Have fun!"
}

if [ -z "$1" ] ; then
	usage
	exit 1
fi 

echo "# work dir $1" >> $ENVTMPFILE

prerequisites
create_workdir
clone_repos
fetch_netbsdimg
fetch_netbsdsrc
build_gxemul

cp $ENVTMPFILE $ENVSAVETO
if [ $? -eq 0 ] ; then
	echo "-- Environment settings saved to $ENVSAVETO"
else
	echo "-- Problem saving environment settings to $ENVSAVETO"
fi

rm $ENVTMPFILE

lolitsdone

exit 0

