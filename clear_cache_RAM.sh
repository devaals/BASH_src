#!/bin/bash

#Автор: Ребровский Сергей (s.rebrovskiy@vniias.ru)
#Version 1.0

#Скрипт позволяет очистить закешированную ОП

##### До прогона скрипта ######
# cat /proc/meminfo
# MemTotal:     49432464 kB
# MemFree:      44957604 kB
# Buffers:          1756 kB
# Cached:        3679404 kB

##### После прогона скрипта ######
# cat /proc/meminfo
# MemTotal:     49432464 kB
# MemFree:        168604 kb
# Buffers:         85140 kB
# Cached:       47634592 kB


if [ $(whoami) != "root" ]; then
	echo -e "\e[31mНеобходимо запустить скрипт из-под\e[0m \e[32mroot\e[0m. Осуществляем выход!"
	sleep 3
	exit
fi

sync #сбросить на диск всё самое лишнее, позволяет освободить больше памяти.
echo 3 > /proc/sys/vm/drop_caches #сбросить страничный кэш, dentry и inodes: