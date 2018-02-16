#!/bin/bash

# Объединённый скрипт timer.sh + fbf_log.sh
# Авторы: Ребровский Сергей <s.rebrovskiy@vniias.ru>, Артём Верещага <A.Vereschaga@vniias.ru>
# version 2.0

export fbf_log='/tmp/fbf.log'

fbf_home() {
	echo 'Самые большие файлы дирекории /home:' |tee -a $fbf_log
	echo `date +%Y-%m-%d_%H-%M` |tee -a  $fbf_log	
	find /home -mount -type f -ls 2> /dev/null | sort -rnk7 | head -10 | awk '{printf "%10d MB\t%s\n",($7/1024)/1024,$NF}'|tee -a $fbf_log
	echo
	sleep 1
}
export -f fbf_home

function timer(){
start=$(date +%s)
#Здесь размещаем скрипт, который хотим зафиксироваь по времени
#В строке ниже функции timer() передаются, в качестве аргумента, все параметры
"$*"
end=$(date +%s)

delta_sec=$(expr $end - $start)
if (( "$delta_sec" < 60 )); then
		echo "Время затраченное на выполнение - $delta_sec sec" | tee -a $fbf_log
	elif (( "$delta_sec" <3600 )); then
		total_min=$(expr $delta_sec / 60)
	# total_sec=$(expr $delta_sec % 60) - деление по модулю
	# Пример: если delta_sec=179, то total_sec будет равен 59
		total_sec=$(expr $delta_sec % 60)
		echo "Время затраченное на выполнение - $total_min min $total_sec sec" | tee -a $fbf_log
	else
		total_hour=$(expr $delta_sec / 3600)
		remainder_sec=$(expr $delta_sec % 3600)
		total_min=$(expr $remainder_sec / 60)
		total_sec=$(expr $remainder_sec % 60)
		echo "Время затраченное на выполнение - $total_hour hour $total_min min $total_sec sec" | tee -a $fbf_log
fi
}
#Функции timer() принимает в качестве аргумента имя функции fbf_home
timer fbf_home