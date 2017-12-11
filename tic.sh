#!/bin/bash
# Скрипт проверки доступности порта без ипользования telnet
# Взято с https://olegon.ru/showthread.php?t=9821
#
# Запуск скрипта:
# ./tic.sh <ip-address> <port>
#
# Пример запуска:
# ./tic.sh 10.246.116.50 5432


( exec 3</dev/tcp/$1/$2 ) >/dev/null 2>&1
if (( $?==0 )) ; then
echo "yes";
else
echo "no";
fi;
exec 3<&-