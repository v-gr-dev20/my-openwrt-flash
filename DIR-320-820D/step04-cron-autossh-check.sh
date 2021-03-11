#!/bin/sh

# Добавление регулярной проверки доступности административного хоста
cat - << END > /etc/crontabs/root
# reset network if the connection to the administrative host is lost
5 * * * *	[ "\$( /usr/bin/ssh -fT -y -K 60 -i /etc/dropbear/dropbear_rsa_host_key admin@grigorovich-fam4.ddns.net ssh -T -y -K30 -i /etc/dropbear/dropbear_rsa_host_key -p8022 root@127.0.0.1 /usr/bin/dropbearkey -y -f /etc/dropbear/dropbear_rsa_host_key 2>/dev/null |/bin/grep '^ssh-rsa ' )" == "\$( /usr/bin/dropbearkey -y -f /etc/dropbear/dropbear_rsa_host_key 2>/dev/null |/bin/grep '^ssh-rsa ' )" ] || /etc/init.d/autossh restart
END

chmod 600 /etc/crontabs/root
/etc/init.d/cron restart

#Добавление ключей для обратного входа с административного хоста
newKey=/tmp/$$key.pub
allLocalKeys=/etc/dropbear/authorized_keys
ssh -T -y -i /etc/dropbear/dropbear_rsa_host_key admin@grigorovich-fam4.ddns.net \
	dropbearkey -y -f /etc/dropbear/dropbear_rsa_host_key 2>/dev/null |grep -E '^ssh-rsa ' > $newKey
allLocalKeysCount=$( cat $allLocalKeys |sort |uniq |wc -l )
withNewKeyCount=$( { cat $allLocalKeys; cat $newKey; } |sort |uniq |wc -l )
[[ $allLocalKeysCount -lt $withNewKeyCount ]] && {
	cat $newKey >> $allLocalKeys
	echo "New key added"
} || {
	echo "The key is already present"
}