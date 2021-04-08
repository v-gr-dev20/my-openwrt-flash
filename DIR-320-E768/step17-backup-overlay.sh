#!/bin/sh

cd /overlay || exit 1
tar -czf - . |ssh -y -i /etc/dropbear/dropbear_rsa_host_key admin@192.168.2.1 "cat - > /tmp/mnt/data/backup/$( date '+%Y-%m-%d-%H%M%S' )-$( cat /proc/sys/kernel/hostname )-overlay.tgz"
