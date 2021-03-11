#!/bin/sh

# Патч для возможности старта сервиса во время boot
# https://openwrt.org/docs/guide-user/services/ssh/autossh#run_as_service

findBeforeInsert="\\[ \"\$enabled\" = 1 \\] || exit 0" 
toInsert="\\texport HOME=\/root"
[ 1 -le $( sed '/'"${toInsert}"'/!d' /etc/init.d/autossh |wc -l ) ] || {
	sed '/'"${findBeforeInsert}"'/a '\\"${toInsert}" -i /etc/init.d/autossh
}
# Необходимо заранее добавить локальный публичный ключ в ~/.ssh/authorized_keys на удаленном хосте
# Публичный ключ можно получить так:
#> dropbearkey -y -f /etc/dropbear/dropbear_rsa_host_key |grep '^ssh-rsa '

uci -q batch << EOF

set autossh.@autossh[0]=autossh
set autossh.@autossh[0].ssh='-TN -y -K 60 -i /etc/dropbear/dropbear_rsa_host_key -o ExitOnForwardFailure=yes -R 8022:localhost:22 admin@grigorovich-fam4.ddns.net'
set autossh.@autossh[0].gatetime='0'
set autossh.@autossh[0].monitorport='8023'
set autossh.@autossh[0].poll='600'
set autossh.@autossh[0].enabled='1'

EOF

uci commit autossh || exit 1
/etc/init.d/autossh restart
