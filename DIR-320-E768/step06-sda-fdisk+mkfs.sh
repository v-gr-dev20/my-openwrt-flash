#!/bin/sh
# Скрипт форматирует /dev/sda (все данные будут стерты!):
# /dev/sda1  32M Linux swap
# /dev/sda2  32M Linux swap
# /dev/sda3   2G Linux filesystem
# /dev/sda4 X.XG Linux filesystem
# Для реального запуска форматирования необходимо удалить/закомментировать следующую строку
echo 'Remove/comment the protective line' && exit 1

# устанавливаем временно в ram утилиты для форматирования диска
opkg update || exit 1
opkg --dest ram install fdisk

# проверяем, что находимся на целевом хосте
[ "DIR320-E768" == "$( cat /proc/sys/kernel/hostname )" ] || exit 1

# создаем разделы
targetDev=/dev/sda
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF \
| PATH=${PATH:+$PATH:}/tmp/usr/bin LD_LIBRARY_PATH=/lib:/usr/lib:/tmp/lib:/tmp/usr/lib /tmp/usr/sbin/fdisk ${targetDev}
	g		# создать новую таблицу разделов GPT
	n		# создать запись нового раздела
			# default - следующий номер раздела 1
			# default - начать со следующего свободного сектора
	+32M	# 32 MB - размер раздела
	y		# ответ на возможный запрос очистки сигнатуры прежнего раздела
	t		# задать тип нового раздела
			# default - текущий номер раздела 1
	19		# тип раздела 19 Linux swap
	n		# создать запись нового раздела
			# default - следующий номер раздела 2
			# default - начать со следующего свободного сектора
	+32M	# 32 MB - размер раздела
	y		# ответ на возможный запрос очистки сигнатуры прежнего раздела
	t		# задать тип нового раздела
			# default - текущий номер раздела 2
	19		# тип раздела 19 Linux swap
	n		# создать запись нового раздела
			# default - следующий номер раздела 3
			# default - начать со следующего свободного сектора
	+2G		# 2 GB - размер раздела
	y		# ответ на возможный запрос очистки сигнатуры прежнего раздела
	t		# задать тип нового раздела
			# default - текущий номер раздела 3
	20		# тип раздела 20 Linux filesystem
	n		# создать запись нового раздела
			# default - следующий номер раздела 4
			# default - начать со следующего свободного сектора
			# default - разметить раздел на все свободное пространство
	y		# ответ на возможный запрос очистки сигнатуры прежнего раздела
	t		# задать тип нового раздела
			# default - текущий номер раздела 4
	20		# тип раздела 20 Linux filesystem
	p		# print the in-memory partition table
	w		# write the partition table
	q		# and we're done
EOF

# форматируем разделы
mkswap -L swap01 /dev/sda1
mkswap -L swap02 /dev/sda2
mkfs.ext4 -L openwrt /dev/sda3
mkfs.ext4 -L home /dev/sda4

block info
block detect > /etc/config/fstab

