# !PowerShell

docker network inspect mynetwork |Out-Null
if( ! $? ) {
	docker network create mynetwork
}

#docker run --rm --detach --name openwrt `
#	--privileged `
#	--device /dev/net/tun `
#	--cap-add=NET_ADMIN `
#	-p 8022:22 -p 8080:80 `
#	--network="mynetwork" `
#	-it openwrt


docker run --rm --detach --name openwrt `
	--privileged `
	--device /dev/net/tun `
	--cap-add=NET_ADMIN `
	-p 8022:22 -p 8080:80 `
	--network="mynetwork" `
	-it openwrt
