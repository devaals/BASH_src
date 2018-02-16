#!/bin/bash

# Автор: Верещага А.А.
#
# Информация:
# Скрипт разработан для настройки SELinux и службы firewalld
#
# Версия: 1.0
#
# Запуск скрипта: Запускать из-под root

if [ $(whoami) = "root" ]; then
       	echo -e "\e[32mСкрипт запущен из-под root. Продолжаем.\e[0m."

elif [ $(whoami) != "root" ]; then
	echo -e "\e[32mСкрипт запущен не из-под\e[0m \e[31mroot\e[0m! Выходим из скрипта через 3 секунды\e[0m."
	for i in {1..3}; do  echo -n $i && sleep 1;done
	echo
	exit
else echo -e "\e[31mНе удалось определить состояние\e[0m!"
fi

if [[ "$OS_name" == "CentOS" && "$Version" > '7' ]]; then
		echo -e "Наименование ОС:\e[32m$OS_name\e[0m, версия ОС:\e[32m$Version\e[0m"
elif [[ "$OS_name" != "CentOS" ]]; then echo "Скрипт запущен на:"
        echo -e "\e[31m$(cat /etc/redhat-release)\e[0m"
        echo -e "Скрипт предназначен для запуска на ОС \e[32mCentOS\e[0m версии \e[32m7\e[0m и выше!"
        echo -e "\e[32mВыходим из скрипта через 3 секунды\e[0m."
	for i in {1..3}; do  echo -n $i && sleep 1;done
	echo
	exit
else echo -e "\e[31mНе удалось определить OC\e[0m!"
fi

if [ "$(systemctl status firewalld | grep Active | awk {'print $2,$3'})" = 'active (running)' ]; then
       	echo -e "\e[31mСтатус: Firewall работает. Отключить Firewall?\e[0m (\e[32mY\e[0m)es/(\e[31mN\e[0m)o\e[0m"
    	read answer
	while true; do
		if [ "$answer" == "Y" -o "$answer" == "y" ]; then
			systemctl stop firewalld; sleep 0.1; systemctl disable firewalld
			echo -e "\e[31mСтатус: Firewall отключен."
		elif [ "$answer" == "N" -o "$answer" == "n" ]; then
			echo -e '\e[31mОтказались отключать Firewall. Отключение является обязательным! \e[0m'
			echo -e "\e[31mВыходим\e[0m."
			break 1
		else 
			echo -e "\e[31mВвели не верно\e[0m. \e[32mПробуем ещё раз\e[0m. Хотите выполнить этот шаг — \e[32m(Y)es\e[0m/\e[31m(N)o\e[0m?"
		read answer
		fi
	done
elif [ "$(systemctl status firewalld | grep Active | awk {'print $2,$3'})" != 'active (running)' ]; then
	echo -e "\e[31mСтатус: Firewall Отключен, продолжаем.\e[0m"
else echo -e "\e[31mНе удалось определить состояни firewalld\e[0m!"
fi

if [ "$(getenforce)" = 'Enforcing' || "$(getenforce)" = 'Permissive']; then 
   echo -e "\e[31mСтатус: Selinux Включен. Отключить Selinux?\e[0m(\e[32mY\e[0m)es/(\e[31mN\e[0m)o\e[0m"
   read answer
   while true; do
		if [ "$answer" == "Y" -o "$answer" == "y" ]; then
			setenforce 0 > /dev/null 2>&1
			######SED редактирующий /etc/selinux/config######
			echo -e "\e[31mСтатус: Selinux отключен."
		elif [ "$answer" == "N" -o "$answer" == "n" ]; then
			echo -e '\e[31mОтказались отключать Selinux. Отключение является обязательным! \e[0m'
			echo -e "\e[31mВыходим\e[0m."
			break 1
		else 
			echo -e "\e[31mВвели не верно\e[0m. \e[32mПробуем ещё раз\e[0m. Хотите выполнить этот шаг — \e[32m(Y)es\e[0m/\e[31m(N)o\e[0m?"
			read answer
		fi
   done
elif [ "$(getenforce)" = 'Disabled' ]; then 
        	echo -e "\e[31mСтатус: Firewall Отключен, продолжаем.\e[0m"
else
    echo -e "\e[31mНе удалось определить состояние SELinux\e[0m"
    for i in {1..5}; do  echo -n $i && sleep 1;done
    echo
fi