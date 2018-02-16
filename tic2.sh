#!/bin/bash
# Наименование: tic2.sh
#
# Автор: Верещага А.А.
#
# Версия: 1.0
#
# Описание:
# Скрипт проверки доступности порта удалённой системы
#
# Запуск скрипта:
# ./tic2.sh <ip_address> <port>
#

a=$(nmap -v $1 -Pn -p $2 | grep open | wc -l)
if [ $a -gt 1 ];
then
#put here your restart script
echo "Порт $2 открыт, заходи, гостем будешь!"
else
echo "Порт закрыт!"
fi
