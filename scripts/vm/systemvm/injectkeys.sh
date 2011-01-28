#!/bin/bash
# Copies keys that enable SSH communication with system vms
# $1 = new public key
# $2 = new private key

#set -x

TMP=${HOME}/tmp
SYSTEMVM_PATCH_DIR=../../../vms/
MOUNTPATH=/mnt/cloud/systemvm
TMPDIR=${TMP}/cloud/systemvm


inject_into_iso() {
  local isofile=${SYSTEMVM_PATCH_DIR}/$1
  local newpubkey=$2
  local backup=${isofile}.bak
  local tmpiso=${TMP}/$1
  [ ! -f $isofile ] && echo "$(basename $0): Could not find systemvm iso patch file $isofile" && return 1
  sudo mount -o loop $isofile $MOUNTPATH 
  [ $? -ne 0 ] && echo "$(basename $0): Failed to mount original iso $isofile" && return 1
  diff -q $MOUNTPATH/authorized_keys $newpubkey &> /dev/null && return 0
  sudo cp -b $isofile $backup
  [ $? -ne 0 ] && echo "$(basename $0): Failed to backup original iso $isofile" && return 1
  rm -rf $TMPDIR
  mkdir -p $TMPDIR
  [ ! -d $TMPDIR  ] && echo "$(basename $0): Could not find/create temporary dir $TMPDIR" && return 1
  sudo cp -fr $MOUNTPATH/* $TMPDIR/
  [ $? -ne 0 ] && echo "$(basename $0): Failed to copy from original iso $isofile" && return 1
  sudo cp $newpubkey $TMPDIR/authorized_keys
  [ $? -ne 0 ] && echo "$(basename $0): Failed to copy key $newpubkey from original iso to new iso " && return 1
  mkisofs -quiet -r -o $tmpiso $TMPDIR
  [ $? -ne 0 ] && echo "$(basename $0): Failed to create new iso $tmpiso from $TMPDIR" && return 1
  sudo umount $MOUNTPATH
  [ $? -ne 0 ] && echo "$(basename $0): Failed to unmount old iso from $MOUNTPATH" && return 1
  sudo cp -f $tmpiso $isofile
  [ $? -ne 0 ] && echo "$(basename $0): Failed to overwrite old iso $isofile with $tmpiso" && return 1
  rm -rf $TMPDIR
}

copy_priv_key() {
  local newprivkey=$1
  diff -q $newprivkey $(dirname $0)/id_rsa.cloud && return 0
  sudo cp -fb $newprivkey $(dirname $0)/id_rsa.cloud 
  return $?
}

mkdir -p $MOUNTPATH

[ $# -ne 2 ] && echo "Usage: $(basename $0)  <new public key file> <new private key file>" && exit 3
newpubkey=$1
newprivkey=$2
[ ! -f $newpubkey ] && echo "$(basename $0): Could not open $newpubkey" && exit 3
[ ! -f $newprivkey ] && echo "$(basename $0): Could not open $newprivkey" && exit 3

command -v mkisofs > /dev/null   || (echo "$(basename $0): mkisofs not found, please install or ensure PATH is accurate" ; exit 4)

inject_into_iso systemvm.iso $newpubkey
#inject_into_iso systemvm-premium.iso $newpubkey

[ $? -ne 0 ] && exit 5

copy_priv_key $newprivkey

exit $?
