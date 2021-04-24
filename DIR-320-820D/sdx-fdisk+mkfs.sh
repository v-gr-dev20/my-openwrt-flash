#!/bin/sh
# Скрипт форматирует /dev/sd* (все данные будут стерты!):
# Для реального запуска форматирования необходимо удалить/закомментировать следующую строку
#echo 'Remove/comment the protective line' && exit 1

# проверяем, что находимся на целевом хосте
[ "DIR320-820D" == "$( cat /proc/sys/kernel/hostname )" ] || exit 1

# создаем разделы
targetDev=/dev/sda
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF \
| fdisk ${targetDev}
	g		# создать новую таблицу разделов GPT
	n		# создать запись нового раздела
			# default - следующий номер раздела 1
			# default - начать со следующего свободного сектора
			# default - разметить раздел на все свободное пространство
	y		# ответ на возможный запрос очистки сигнатуры прежнего раздела
	t		# задать тип нового раздела
			# default - текущий номер раздела 1
	20		# тип раздела 20 Linux filesystem
	p		# print the in-memory partition table
	w		# write the partition table
	q		# and we're done
EOF

# форматируем разделы
mkfs.ext4 -L mobile1 "${targetDev}1"

block info

