#!/bin/bash

# Таймер выполнения скриптов
# Автор: Ребровский Сергей
# version 1.0

start=$(date +%s)

#Сюда помещаем скрипт, который хотим зафиксироваь по времени

end=$(date +%s)
delta_sec=$(expr $end - $start)
if (( "$delta_sec" < 60 )); then
	echo "$delta_sec sec"
elif (( "$delta_sec" <3600 )); then
	total_min=$(expr $delta_sec / 60)
	# total_sec=$(expr $delta_sec % 60) - деление по модулю
	# Пример: если delta_sec=179, то total_sec будет равен 59
	total_sec=$(expr $delta_sec % 60)
	echo "$total_min min $total_sec sec"
else
	total_hour=$(expr $delta_sec / 3600)
	remainder_sec=$(expr $delta_sec % 3600)
	total_min=$(expr $remainder_sec / 60)
	total_sec=$(expr $remainder_sec % 60)
	echo "$total_hour hour $total_min min $total_sec sec"
fi
		