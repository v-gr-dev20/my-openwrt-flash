#!/bin/sh

tarName="$( date '+%Y-%m-%d-%H%M%S' )-$( cat /proc/sys/kernel/hostname )-overlay.tgz"
mkdir -p /home/backup &> /dev/null || exit 1
( cd /overlay ) || exit 1
( cd /rwm ) || exit 1
tar -czf "/home/backup/${tarName}" /overlay /rwm
cat "/home/backup/${tarName}" |ssh -y -i /etc/dropbear/dropbear_rsa_host_key admin@grigorovich-fam4.ddns.net "( mkdir -p /tmp/mnt/data/backup ;cat - > ""/tmp/mnt/data/backup/${tarName}"" )"
