#!/bin/bash

[ "$UID" = "0" ] || exec sudo "$0" "$@"

set -e

DEV_LUKS_BOOT=/dev/mapper/luks_boot
echo DEV_LUKS_BOOT=$DEV_LUKS_BOOT
[ -e "$DEV_LUKS_BOOT" ] || cryptsetup luksOpen /dev/nvme0n1p2 luks_boot
[ -e /dev/mapper/luks_lvm ] || cryptsetup luksOpen /dev/nvme0n1p4 luks_lvm

while ! [ -e /dev/vgkubuntu/root ]
do
  echo waiting for /dev/vgkubuntu/root...
  sleep 1
done

cd /mnt/nvme0lvm

may_mount () {
  local TARGET=$(cd "$2"; pwd)
  mount | grep "$TARGET" || mount "$@"
}

may_mount /dev/vgkubuntu/root .
may_mount /dev/vgkubuntu/var var
may_mount /dev/vgkubuntu/home home
may_mount "$DEV_LUKS_BOOT" boot
may_mount /dev/nvme0n1p1 boot/efi
mount --rbind /sys sys
mount --rbind /dev dev
mount -t proc /proc proc
