#!/bin/env bash
# Автор: Верещага А.А.
#
# mail: a.vereschaga@vniias.ru
#
# Информация:
# Скрипт позволяет определить существование директории на удалённых серверах.
#
# Версия: 1.2
#
# Описание: 
# Скрипт проверяет существует ли директория на удалённом сервере/серверах.
# Необходимо настроить авторизацию по ключам(на сервере, где планируется запуск скрипта) к серверам
# на которых планируется проверять наличие директории, иначе потребуется вводить пароль root.
# 
# Запуск скрипта:
# ./verify.sh <"DIR"> <"net_ip"> <"ip">
# Где <"DIR"> - директория, наличие которой проверяем
# <"net_ip"> - общая часть IP-адреса(первые три октета адреса)
# <"ip"> - последний октет IP-адреса
# 
# Примеры запуска:
# ./verify.sh /opt/ruby_projects/ "10.246.116" "11 21 20 31 41" 
# Проверит существование директории /opt/ruby_projects/ на серверах 10.246.116.11, 10.246.116.21, 10.246.116.20, 10.246.116.31, 10.246.116.41
# 
# Вывод скрипта:
# Directory rvec on 10.246.116.11 exists
# Directory rvec on 10.246.116.21 exists
# Directory rvec on 10.246.116.20 not found
# Directory rvec on 10.246.116.31 exists
# Directory rvec on 10.246.116.41 exists
# 
# ./verify.sh "/opt/ruby_projects/rvec2" "10.35.33" "11 12 13 14 21 22 23 24"
# Directory rvec on 10.35.33.11 not found
# Directory rvec on 10.35.33.12 exists
# Directory rvec on 10.35.33.13 exists
# Directory rvec on 10.35.33.14 not found
# Directory rvec on 10.35.33.21 not found
# Directory rvec on 10.35.33.22 exists
# Directory rvec on 10.35.33.23 exists
# Directory rvec on 10.35.33.24 not found
#
# Вывод раскрашивается в цвета: "exists" - зелёный, "not found" - красный

export rem_verify="if [ -d $1 ]; then echo OK; else echo NOT_OK; fi"
export rem_srv=$2
export rem_host=$3

# Удаление временных файлов после завершения работы скрипта
trap "rm -f /tmp/echo_*" 0 1 2 5 9 15

#Функция вывода справки
PrintHelp() {
echo -ne "
    Скрипт \e[31m$(basename $0)\e[0m проверяет существует ли директория на удалённом сервере/серверах.
    \e[31mНеобходимо настроить\e[0m \e[32mавторизацию по ключам\e[0m(на сервере, где планируется запуск скрипта) к серверам
    на которых планируется проверять наличие директории, иначе потребуется вводить пароль \e[31mroot\e[0m.

    \e[32mИспользование скрипта\e[0m:
    ./$(basename $0) /opt/ruby_projects/ \"10.246.116\" \"11 21 20 31 41\"
    ./$(basename $0) \"/opt/ruby_projects/\" \"10.246.116\" \"11 21 20 31 41\"
"
}

#Если кол-во аргументов, передаваемых скрипту неравно трём будет выводиться справка
if [[ $# -eq 0 || $# -gt 3 ]]; then
    PrintHelp
elif [[ $# -eq 1 ]]; then
    PrintHelp
elif [[ $# -eq 2 ]]; then
    PrintHelp
else
#В цикле обрабатывается отправление команды $rem_verify на выбранные сервера и занесение ответа в файл echo_<ip-сервера>
for i in $rem_host
    do ssh root@$rem_srv.$i "$rem_verify" > /tmp/echo_$i
# Условие проверяет наличие в файлах строки с "OK", в случае отсутствия данной строки выведется сообщение, что на данном сервере искомая директория не найдена
    if [ $(cat /tmp/echo_$i) == 'OK' ]
    then echo -e "Directory rvec on $rem_srv.$i \e[32mexists\e[0m"
    else echo -e "Directory rvec on $rem_srv.$i \e[31mnot found\e[0m"
    fi
done
fi
