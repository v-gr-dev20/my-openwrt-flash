#!/bin/bash
# https://openwrt.org/ru/docs/guide-user/additional-software/extroot_configuration

# Проверка
# Через командную строку

# Раздел на внешнем USB устройстве должен быть подмонтирован как overlay
grep -e /overlay /etc/mtab

# Свободное пространство в корневом разделе / должно быть равно пространству на /overlay.
df /overlay /
