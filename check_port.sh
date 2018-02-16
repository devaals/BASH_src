#!/bin/bash
#
# Наименование:
# check_port.sh
#
# Версия: 1.0
#
# Автор: Патрушев В.С.
#
# Email: v.patryshev@vniias.ru
#
# Описание:
# Скрипт проверки доступности порта без ипользования telnet
#
# Запуск скрипта:
# ./check_port.sh <ip_address> <port>

HOST=$1
PORT=$2
timeout 1 /bin/bash -c "cat < /dev/null > /dev/tcp/${HOST}/${PORT}"
RESULT=$?
if [ "${RESULT}" -ne 0 ]; then
    echo -e "\e[31mFailed\e[0m, port \e[31m$PORT\e[0m is closed on \e[32m$HOST\e[0m"
else
    echo -e "\e[32mSuccess\e[0m, port \e[31m$PORT\e[0m is opened on \e[32m$HOST\e[0m"
fi