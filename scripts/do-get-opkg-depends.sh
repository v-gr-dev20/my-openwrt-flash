#!/bin/sh
# Проверяет зависимость $1 - списка пакетов opkg от $2 - другого списка пакетов

sourcesList="$1"
dependsList="$2"
IFS=' 	
'
for si in $sourcesList ;do
	for di in $dependsList ;do
		{ opkg status "$si" |grep -E "^Depends:" |sed 's/^Depends://' |grep -Ew "$di" > /dev/null 2>&1
		} && {
			echo "$si"
			break
		}
	done
done |sort |uniq