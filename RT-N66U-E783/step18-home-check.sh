#!/bin/sh

echo
echo There must be the '/home'
block info |grep 'MOUNT="/home"'
echo
echo There must be the '/home'
uci show fstab.$( uci show fstab |sed "/^fstab\..\+\.target='\/home'/!d;s/^fstab\.\(.\+\)\.target=.\+$/\1/" )
echo
echo There must be the '/home'
mount |grep '/home'
