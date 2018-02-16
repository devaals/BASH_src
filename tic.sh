#!/bin/bash
# Скрипт проверки доступности порта без ипользования telnet
# Взято с https://olegon.ru/showthread.php?t=9821
#
# Запуск скрипта:
# ./tic.sh <ip-address> <port>
#
# Пример запуска:
# ./tic.sh 10.246.116.50 5432
#
# Расширенное применение:
# Можно использовать на хостах с ОС Windows, единственным условием является наличие
# в системе эмулятора Linux, например: Cygwin или MINGW64 и т.д.
#
# Для проверки доступности порта в диапозоне ip-адресов можно использовать следующую конструкцию:
# for i in {1..10}; do
#	./tic.sh 10.35.33.$i 22 
# done
#
# Проверка с помощью вложенных циклов for:
# for i in {1..10}; do
#	for j in {21,22,1521,3389};do
#		./tic.sh 10.35.33.$i $j
#	done 
# done
#
# Цвета консоли:
# export BOLD='\033[1m'
# export red='\033[0;31m'
# export RED='\033[1;31m'
# export GREEN='\033[0;32m'
# export green='\033[1;32m'
# export YELLOW='\033[0;33m'
# export yellow='\033[1;33m'
# export blue='\033[0;34m'
# export BLUE='\033[1;34m'
# export MAGENTA='\033[0;35m'
# export magenta='\033[1;35m'
# export cyan='\033[0;36m'
# export CYAN='\033[1;36m'
# export NC='\033[0m' # No Color



( exec 3</dev/tcp/$1/$2 ) >/dev/null 2>&1
if (( $?==0 )) ; then
echo -e "\e[32myes\e[0m, on \e[34m$1\e[0m \e[32mopen\e[0m \e[32m$2\e[0m" && echo "yes, on $1 open $2">>$(basename $0).log;
else
echo -e "\e[31mno\e[0m, on \e[34m$1\e[0m \e[31mclose\e[0m \e[32m$2\e[0m" && echo "no, on $1 close $2">>$(basename $0).log;
fi;
exec 3<&-