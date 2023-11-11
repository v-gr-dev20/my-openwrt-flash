# !PowerShell

docker network inspect mynetwork |Out-Null
if( ! $? ) {
	docker network create --subnet 192.168.1.0/24 --gateway 192.168.1.254 mynetwork
}

docker run --rm --detach --name openwrt `
	--privileged `
	--cap-add=NET_ADMIN `
	--network="bridge" `
	-it openwrt sh -c "sleep 10; ifconfig veth1 up"

