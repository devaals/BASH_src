#!/bin/bash

#Автор: Ребровский Сергей (s.rebrovskiy@vniias.ru)
#Version 1.0

#Скрипт выгружает дамп потоков и пишет его в файл.
#Можно привезать его к cron.

xdate=`date +%Y-%m-%d_%H:%M`

#Jstack лежит в папке java/bin/ 
#Для поиска месторасположения можно воспользоваться командой locate jstack
jstack=/opt/ruby_projects/jdk1.7.0_79/bin/jstack

#Получаем pid java-процесса.
#Первый вариант подозреваю, что может не сработать в случае работы нескольких экземпляров Вектора на одном сервере.
#p=$(top -n1 | grep -m1 jsvc-64.bin | perl -pe 's/\e\[?.*?[\@-~] ?//g' | cut -f1 -d' ')
#Второй вариант более надежный, здесь нужно указать явное месторасположения файла с pid процесса.
p=$(cat /opt/ruby_projects/arm/rvec/daemon/DEV_NN.pid)


$jstack -l $p > /tmp/$xdate.tdump
