#!/bin/env bash
#
# Наименование: docker_repo.sh
#
# Автор: Верещага А.А. 
#
# email: a.vereschaga@vniias.ru berserk@inbox.ru vaal@alex-master.com
#
# Версия: 1.0
#
# Описание:
# Скрипт автоматизированной установки/настройки Docker
#
# Запуск осуществлять из-под root

source /etc/rc.d/init.d/functions

if [ $(whoami) != "root" ]; then
    echo -e "\e[31mНеобходимо запустить обновление из-под\e[0m \e[32mroot\e[0m."
    sleep 3
    exit
fi

export OUTFILE="/tmp/docker-ce.repo"

trap "rm -rf $OUTFILE" 0 1 2 8 9 15

(
cat <<"EOF"
[docker-ce-stable]
name=Docker CE Stable - $basearch
baseurl=https://download.docker.com/linux/centos/7/$basearch/stable
enabled=0
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg

[docker-ce-stable-debuginfo]
name=Docker CE Stable - Debuginfo $basearch
baseurl=https://download.docker.com/linux/centos/7/debug-$basearch/stable
enabled=0
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg

[docker-ce-stable-source]
name=Docker CE Stable - Sources
baseurl=https://download.docker.com/linux/centos/7/source/stable
enabled=0
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg

[docker-ce-edge]
name=Docker CE Edge - $basearch
baseurl=https://download.docker.com/linux/centos/7/$basearch/edge
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg

[docker-ce-edge-debuginfo]
name=Docker CE Edge - Debuginfo $basearch
baseurl=https://download.docker.com/linux/centos/7/debug-$basearch/edge
enabled=0
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg

[docker-ce-edge-source]
name=Docker CE Edge - Sources
baseurl=https://download.docker.com/linux/centos/7/source/edge
enabled=0
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg

[docker-ce-test]
name=Docker CE Test - $basearch
baseurl=https://download.docker.com/linux/centos/7/$basearch/test
enabled=0
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg

[docker-ce-test-debuginfo]
name=Docker CE Test - Debuginfo $basearch
baseurl=https://download.docker.com/linux/centos/7/debug-$basearch/test
enabled=0
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg

[docker-ce-test-source]
name=Docker CE Test - Sources
baseurl=https://download.docker.com/linux/centos/7/source/test
enabled=0
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg
EOF
) > $OUTFILE


#Обновление системы, установка программных пакетов, установка реозитория epel
echo -e "\e[32mОсуществить обновление системы и установку пакетов\e[0m\e[31m?\e[0m (\e[32mY\e[0m)es/(\e[31mN\e[0m)o"
echo
read answer
echo
while true; do
if [ "$answer" == "Y" -o "$answer" == "y" ]
then
    yum update -y > /dev/null 2>&1; sleep 0.1; yum install -y epel-release deltarpm lynx net-tools \
    kernel-devel perl gcc make wget nano docker mc atop iftop htop binutils hexedit dos2unix pigz > /dev/null 2>&1
    if [ $? == '0' ]; then
        echo -n "Обновление и установка пакетов заврешена: "
        echo_success
    else
	echo -n "Обновление и установка пакетов прошли с ошибкой: "
	echo_failure
        echo
        sleep 5
        break 1
    fi
break 1
elif [ "$answer" == "N" -o "$answer" == "n" ]; then
    echo -e '\e[31mОтказались\e[0m \e[32mобновлять систему\e[0m\e[31m!\e[0m'
    break 1
else
    echo -e "\e[31mВвели не верно\e[0m. \e[32mПробуем ещё раз\e[0m. Хотите выполнить этот шаг — \e[32m(Y)es\e[0m/\e[31m(N)o\e[0m?"
read answer
fi
done

echo

#Установка группы пакетов шрифтов
echo -e "\e[32mОсуществить установку шрифтов\e[0m\e[31m?\e[0m (\e[32mY\e[0m)es/(\e[31mN\e[0m)o"
echo
read answer
echo
while true; do
if [ "$answer" == "Y" -o "$answer" == "y" ]
then
    yum groupinstall -y 'Шрифты' > /dev/null 2>&1
    if [ $? == '0' ]; then 
	echo -n "Установка шрифтов заврешена: "
	echo_success
    else 
	echo "Установка шрифтов прошла с ошибкой: " 
	echo_failure
	echo 
	sleep 5
	break 1
    fi
break 1
elif [ "$answer" == "N" -o "$answer" == "n" ]; then
    echo -e '\e[31mОтказались\e[0m \e[32mустанавливать шрифты\e[0m\e[31m!\e[0m'
    break 1
else
    echo -e "\e[31mВвели не верно\e[0m. \e[32mПробуем ещё раз\e[0m. Хотите выполнить этот шаг — \e[32m(Y)es\e[0m/\e[31m(N)o\e[0m?"
    read answer
fi
done
echo
#Настройка репозиториев Docker
echo -e "\e[32mОсуществить настройку репозиториев Docker\e[0m\e[31m?\e[0m (\e[32mY\e[0m)es/(\e[31mN\e[0m)o"
echo
read answer
echo
while true; do
if [ "$answer" == "Y" -o "$answer" == "y" ]
then
    if [[ -f /etc/yum.repos.d/docker-ce.repo ]] && [[ $(ls -la /etc/yum.repos.d/docker-ce.repo| awk '{print $5}') -gt 1801 ]]; then
        echo -e '\e[31mНастройка репозиториев Docker проводилась ранее!\e[0m'
        echo;echo -e '\e[33mСодержимое файла docker-ce.repo: \e[0m'
        echo -e "\e[34m$(cat /etc/yum.repos.d/docker-ce.repo)\e[0m"
        break 1
    elif [[ -f /etc/yum.repos.d/docker-ce.repo ]] && [[ $(ls -la /etc/yum.repos.d/docker-ce.repo| awk '{print $5}') -eq 0 ]]; then
        cat $OUTFILE >/etc/yum.repos.d/docker-ce.repo
    break 1
else
    cat $OUTFILE >/etc/yum.repos.d/docker-ce.repo
break 1
fi
    echo -n "Настройка репозиториев docker завершена: "
    echo_success
elif [ "$answer" == "N" -o "$answer" == "n" ]; then
    echo -e '\e[31mОтказались\e[0m \e[32mнастраивать репозитории Docker\e[0m\e[31m!\e[0m'
    break 1
else
    echo -e "\e[31mВвели не верно\e[0m. \e[32mПробуем ещё раз\e[0m. Хотите выполнить этот шаг — \e[32m(Y)es\e[0m/\e[31m(N)o\e[0m?"
    read answer
fi
done
echo
#Установка Docker
echo -e "\e[32mОсуществить установку docker-ce\e[0m\e[31m?\e[0m (\e[32mY\e[0m)es/(\e[31mN\e[0m)o"
echo
read answer
echo
while true; do
if [ "$answer" == "Y" -o "$answer" == "y" ];then
    if [ $(rpm -qa |grep docker |awk -F"-" '{print $1}') == "docker" ]; then 
	echo -e '\e[32mПропускаем этап установки!\e[0m'
	echo -e '\e[32mВ системe\e[0m \e[31mуже установлено\e[0m \e[32mПО docker\e[0m\e[31m!\e[0m'
	break
    else
    yum install -y docker-ce > /dev/null  2>&1
    systemctl enable docker  > /dev/null  2>&1
    systemctl start docker > /dev/null  2>&1
    echo -n "Инсталляции docker завершена: "
    echo_success
    fi
    break 1
elif [ "$answer" == "N" -o "$answer" == "n" ]
then 
    echo -e '\e[31mОтказались\e[0m \e[32mустанавливать docker-ce\e[0m\e[31m!\e[0m'
    break 1
else
    echo -e "\e[31mВвели не верно\e[0m. \e[32mПробуем ещё раз\e[0m. Хотите выполнить этот шаг — \e[32m(Y)es\e[0m/\e[31m(N)o\e[0m?"
    read answer
fi
done
echo
echo -e "\e[32mОсуществить настройку docker-ce на использование системного прокси?\e[0m\e[31m?\e[0m (\e[32mY\e[0m)es/(\e[31mN\e[0m)o"
echo
read answer
echo
while true; do
if [ "$answer" == "Y" -o "$answer" == "y" ]
then
    if [[ -f /etc/systemd/system/docker.service.d/http-proxy.conf ]]; then
		echo -e '\e[31mНастройка docker на работу через прокси проводилась ранее!\e[0m'
		echo;echo -e '\e[33mСодержимое файла конфигурации http-proxy.conf: \e[0m'
		echo -e "\e[34m$(cat /etc/systemd/system/docker.service.d/http-proxy.conf)\e[0m"
		break 1
    elif [[ -d /etc/systemd/system/docker.service.d && ! -f /etc/systemd/system/docker.service.d/http-proxy.conf ]]; then
        echo '[Service]' > /etc/systemd/system/docker.service.d/http-proxy.conf
        echo 'Environment="HTTP_PROXY=http://a.vereschaga:1234rewQ@proxy.ctt.com.mps:8080"' >> /etc/systemd/system/docker.service.d/http-proxy.conf
        echo 'Environment="NO_PROXY=localhost,127.0.0.0/8"' >> /etc/systemd/system/docker.service.d/http-proxy.conf
        systemctl daemon-reload
        echo -n "Настройка функционирования docker через прокси завершена: "
        echo_success
        break 1
    else
		mkdir -p /etc/systemd/system/docker.service.d
        echo '[Service]' > /etc/systemd/system/docker.service.d/http-proxy.conf
		echo 'Environment="HTTP_PROXY=http://a.vereschaga:1234rewQ@proxy.ctt.com.mps:8080"' >> /etc/systemd/system/docker.service.d/http-proxy.conf
		echo 'Environment="NO_PROXY=localhost,127.0.0.0/8"' >> /etc/systemd/system/docker.service.d/http-proxy.conf
		systemctl daemon-reload
		echo -n "Настройка функционирования docker через прокси завершена: "
		echo_success
	break 1
    fi
elif [ "$answer" == "N" -o "$answer" == "n" ]
then
    echo -e '\e[31mОтказались\e[0m \e[32mнастраивать docker-ce на работу с системным прокси\e[0m\e[31m!\e[0m'
    break 1
else
    echo -e "\e[31mВвели не верно\e[0m. \e[32mПробуем ещё раз\e[0m. Хотите выполнить этот шаг — \e[32m(Y)es\e[0m/\e[31m(N)o\e[0m?"
    read answer
fi
done
sleep 3
echo 
exit 0
