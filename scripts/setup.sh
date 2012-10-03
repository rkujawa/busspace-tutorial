#!/bin/sh
# This script was tested only on the NetBSD/amd64 6.0 and MacOS X 10.8.2.

DOWNLOAD_TOOL=wget	# wget, curl, etc.
DOWNLOAD_TOOL_FLAGS="--no-check-certificate" # doh

LOG_GXEMUL=/tmp/build-gxemul.log
LOG_GIT_CLONE=/tmp/build-git-clone.log
LOG_NETBSD_IMG=/tmp/fetch-netbsd-cobalt-image.log

GITHUB_URL=https://github.com
GITHUB_ACCOUNT=rkujawa
REPO_BUSSPACE_NAME=busspace-eurobsdcon2012
REPO_GXEMUL_NAME=gxemul-eurobsdcon2012
NETBSD_SRC_FILE=netbsd-20121002.tar.bz2
NETBSD_SRC_DIR=src-clean
NETBSD_COBALT_IMG_FILE=netbsd-cobalt.img.bz2

fetch_netbsdsrc() {

NETBSD_SRC_URL=$GITHUB_URL/downloads/$GITHUB_ACCOUNT/$REPO_BUSSPACE_NAME/$NETBSD_SRC_FILE

echo "== Fetching the NetBSD source"
cd $WORK_DIR

$DOWNLOAD_TOOL $DOWNLOAD_TOOL_FLAGS $NETBSD_SRC_URL 

if [ -f "$NETBSD_SRC_FILE" ] ; then
	echo "-- Successfuly downloaded the archive, extracting..."
else
	echo "-- Couldn't download $NETBSD_SRC_URL"
	exit 1
fi

tar -jxf $NETBSD_SRC_FILE

if [ -d "NETBSD_SRC_DIR" ] ; then
	echo "-- Source extracted successfully"
else
	echo "-- Problem extracting the NetBSD source"
	exit 1
fi

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

bzip2 -d $NETBSD_COBALT_IMG_FILE

if [ -f "`echo $NETBSD_COBALT_IMG_FILE | sed s/\.bz2//`" ] ; then
	echo "-- Image uncompressed successfully"
else
	echo "-- Problem uncompressing the image"
	exit 1
fi
}

create_workdir() {

echo "== Creating work directory $WORK_DIR"

mkdir -p $WORK_DIR
cd $WORK_DIR

if [ "$?" == 0 ] ; then
	echo "-- Work directory ready"
else
	echo "-- Can't cd into $WORK_DIR - please investigate the problem."
	exit 1
fi

}

clone_repos() {

	echo "== Cloning git repositories, logging to $LOG_GIT_CLONE"

git clone $GITHUB_ACCOUNT_URL/$REPO_BUSSPACE_NAME.git > $LOG_GIT_CLONE 2>&1
git clone $GITHUB_ACCOUNT_URL/$REPO_GXEMUL_NAME.git >> $LOG_GIT_CLONE 2>&1

if [ "$?" == 0 ] ; then
	echo "-- Repositories cloned successfuly"
else
	echo "-- Can't clone the git repository - see $LOG_GIT_CLONE"
	exit 1
fi 

}

build_gxemul() {

echo "== Building GXemul, logging to $LOG_GXEMUL"

# Work around build problem on MacOS X 
if [ `uname` == "Darwin" ] ; then
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

}


if [ -z "$1" ] ; then
	echo "This script attempts to setup a sane environment for running materials"
	echo "from EuroBSDcon 2012 bus_space(9) tutorial. Please specify the path to"
	echo "work directory (it will be created if it does not exist). To start again" 
	echo "just delete the directory."
	echo ""
	echo "usage:\t$0 path"
	exit 1
fi 

WORK_DIR=$1

git > /dev/null 2>&1

if [ "$?" == 127 ] ; then
	echo "-- Please install git first!"
	exit 1
fi

create_workdir

#clone_repos
#fetch_netbsdimg
#fetch_netbsdsrc
#build_gxemul

exit 0

