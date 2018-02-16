#!/bin/bash
#
# Автор: Верещага А.А.
#
# Информация:
# Скрипт разработан для настройки прокси и репозиториев ОС, установленой в минимальной конфигурации(minimal)
#
# Версия: 2.0
#
# Изменения(от 26.10.2017): 
# - старые блоки проверок
# + условия выбора для внесения изменений в настройки
# + условия обработки создания бекапов конфиг-х файлов
# + условия проверки строк конфиг-х файлов, которые планируется изменить
# + вывод информационных сообщений в цвете
#
# Версия: 2.1
# Изменения(от 16.02.2018): 
# + добавлена установка пакетов bzip2, zip, unzip
# + запрос на установку шрифтов получает автоматический ответ("-y")
#
# Запуск скрипта:
# Запускать из-под root или sudo, желательно на только что развёрнутой системе

###Создание бэкапа файлов конфигурации###
bash_pro=~/.bash_profile
yum_conf=/etc/yum.conf
wget_rc=/etc/wgetrc
profile=/etc/profile
export xdate; xdate=$(date +%Y-%m-%d_%H:%M:%S)

echo -e "\e[32mСоздать резервные копии файлов\e[0m \"\e[31m$bash_pro\e[0m\" \"\e[31m$yum_conf\e[0m\" \"\e[31m$profile\e[0m\"\e[32m! (\e[32mY\e[0m)es/(\e[31mN\e[0m)o"
echo
read answer
echo
while true; do
    if [ "$answer" == "Y" -o "$answer" == "y" ]
	then
		if [ -f ~/.bash_profile.bkp ]; then echo -e '\e[32mРезервная копия для\e[0m \e[33m~/.bash_profile\e[0m \e[32mуже\e[0m \e[31mсуществует\e[0m!'
			echo -e "\e[32mСоздаю резервную копию в формате\e[0m \e[33m~/.bash_profile.bkp_\e[32m\e[31m<Год-месяц-день_Часы:минуты:секунды>\e[0m"
			cp $bash_pro ~/.bash_profile.bkp_$xdate
		else 
			cp $bash_pro ~/.bash_profile.bkp
		fi
		echo
		if [ -f /etc/yum.conf.bkp ]; then echo -e '\e[32mРезервная копия для\e[0m \e[33m/etc/yum.conf \e[0m \e[32mуже\e[0m \e[31mсуществует\e[0m!'
			echo -e "\e[32mСоздаю резервную копию в формате\e[0m \e[33m/etc/yum.conf.bkp_<Год-месяц-день_Часы:минуты:секунды>\e[0m"
			cp $yum_conf  /etc/yum.conf.bkp_$xdate
		else 
			cp $yum_conf  /etc/yum.conf.bkp
		fi
		echo
		if [ -f /etc/profile.bkp ]; then echo -e '\e[32mРезервная копия для\e[0m \e[33m/etc/profile\e[0m \e[32mуже\e[0m \e[31mсуществует\e[0m!'
			echo -e "\e[32mСоздаю резервную копию в формате\e[0m \e[33m/etc/profile.bkp_<Год-месяц-день_Часы:минуты:секунды>\e[0m"
			cp $profile  /etc/profile.bkp_$xdate
		else 
			cp $profile  /etc/yum.conf.bkp
		fi
		echo
		echo -e '\e[32mКопии созданы!\e[0m'
		break 1
	elif [ "$answer" == "N" -o "$answer" == "n" ]; then
		echo -e "\e[31mОтказались\e[0m \e[32mсоздавать резервные копии конфиг-х файлов! \e[0m"
		break 1
    else
	echo -e "\e[31mВвели не верно\e[0m. \e[32mПробуем ещё раз\e[0m. Хотите выполнить этот шаг — \e[32m(Y)es\e[0m/\e[31m(N)o\e[0m?"
        read answer
    fi
done
echo
###Добавление параметров proxy###
echo -e "\e[32mПровести настройку прокси пользователя?\e[0m (\e[32mY\e[0m)es/(\e[31mN\e[0m)o"
echo
read answer
echo
while true; do
    if [ "$answer" == "Y" -o "$answer" == "y" ]
    then
	a=`cat $bash_pro|grep -c 'MY_PROXY_URL='`
	if [ $a -eq 0 ]; then echo 'MY_PROXY_URL="http://a.vereschaga:1234rewQ@proxy.ctt.com.mps:8080"' >> $bash_pro 
	    echo 'export MY_PROXY_URL' >> $bash_pro
	else
	    echo -e "\e[32mНастройка прокси была произведена\e[0m \e[31mранее! \e[0m"
	fi
	break 1
    elif [ "$answer" == "N" -o "$answer" == "n" ]; then
	echo -e "\e[31mОтказались\e[0m \e[32mот настройки прокси! \e[0m"
	break 1
    else
	echo -e "\e[31mВвели не верно\e[0m. \e[32mПробуем ещё раз\e[0m. Хотите выполнить этот шаг — \e[32m(Y)es\e[0m/\e[31m(N)o\e[0m?"
        read answer
    fi
done
echo

###Настройка параметров proxy для yum###
echo -e "\e[32mПровести настройку прокси для YUM?\e[0m (\e[32mY\e[0m)es/(\e[31mN\e[0m)o"
echo
read answer
echo
while true; do
    if [ "$answer" == "Y" -o "$answer" == "y" ]
    then
	b1=`cat $yum_conf|grep -c 'proxy='`
	b2=`cat $yum_conf|grep -c 'proxy_username='`
	b3=`cat $yum_conf|grep -c 'proxy_password='`

	if [ $b1 -eq 0 ]; then echo 'proxy=http://proxy.ctt.com.mps:8080' >> $yum_conf
	else 
    	    echo -e "\e[32mВ\e[0m \e[31m$yum_conf\e[0m \e[31mприсутствует\e[0m \e[32mстрока с настройкой\e[0m \"\e[31mproxy=http://proxy.ctt.com.mps:8080\e[0m\". \e[32mПроверьте файл\e[0m \e[31m$yum_conf\e[0m"
	fi	
	
	if [ $b2 -eq 0 ]; then echo 'proxy_username=vniias.ru\a.vereschaga' >> $yum_conf
	else
	    echo -e "\e[32mВ\e[0m \e[31m$yum_conf\e[0m \e[31mприсутствует\e[0m \e[32mстрока с настройкой\e[0m \"\e[31mproxy_username=vniias.ru\a.vereschaga\e[0m\". \e[32mПроверьте файл\e[0m \e[31m$yum_conf\e[0m"
	fi
	
	if [ $b3 -eq 0 ]; then echo 'proxy_password=1234rewQ' >> $yum_conf
	    echo "export http_proxy='http://a.vereschaga:1234rewQ@proxy.ctt.com.mps:8080'" >> $profile
	    echo "export https_proxy='http://a.vereschaga:1234rewQ@proxy.ctt.com.mps:8080'" >> $profile
	    echo 'Defaults    env_keep += "http_proxy"'>> /etc/sudoers
	else 
	    echo -e "\e[32mВ\e[0m \e[31m$yum_conf\e[0m \e[31mприсутствует\e[0m \e[32mстроки с настройкой\e[0m. \e[32mПроверьте файл\e[0m \e[31m$yum_conf\e[0m"
	fi
	break 1
    elif [ "$answer" == "N" -o "$answer" == "n" ]
    then
	echo -e "\e[31mОтказались\e[0m \e[32mпроизводить настройку прокси\e[0m"
        break 1
    else
        echo -e "\e[31mВвели не верно\e[0m. \e[32mПробуем ещё раз\e[0m. Хотите выполнить этот шаг — \e[32m(Y)es\e[0m/\e[31m(N)o\e[0m?"
	read answer
    fi
done
echo

#обновляем систему, устанавливаем репозиторий epel, ставим дополнения и утилиты
echo -e "\e[32mПровести настройку репозиториев и обновление системы? \e[0m(\e[32mY\e[0m)es/(\e[31mN\e[0m)o"
echo
read answer
echo
while true; do
    if [ "$answer" == "Y" -o "$answer" == "y" ]
    then
	yum update -y
	yum install -y "epel-release" "deltarpm" "lynx" "net-tools" "kernel-devel*" "kernel-header*" "perl" "gcc" "make" "wget" "nano" "mc" "atop" "iftop" "htop" "binutils" "hexedit" "dos2unix" "pigz" "bzip2" "zip" "unzip" "bind-utils"
	yum groupinstall -y "Шрифты"
	break 1
    elif [ "$answer" == "N" -o "$answer" == "n" ]
    then 
	echo -e "\e[31mОтказались\e[0m \e[32mпроизводить настройку репозиториев и обновление системы! \e[0m"
	break 1
    else
	echo -e "\e[31mВвели не верно\e[0m. \e[32mПробуем ещё раз\e[0m. Хотите выполнить этот шаг — \e[32m(Y)es\e[0m/\e[31m(N)o\e[0m?"
	read answer
    fi
done
echo

#Настройка wget для работы через прокси
c1=`cat $wget_rc|grep -c '#https_proxy = http://proxy.yoyodyne.com:18023/'`
c2=`cat $wget_rc|grep -c '#http_proxy = http://proxy.yoyodyne.com:18023/'`
c3=`cat $wget_rc|grep -c '#ftp_proxy = http://proxy.yoyodyne.com:18023/'`
c4=`cat $wget_rc|grep -c '#use_proxy = on'`
echo -e "\e[32mПровести настройку\e[0m \e[31mwget\e[0m \e[32mдля работы через прокси? \e[0m(\e[32mY\e[0m)es/(\e[31mN\e[0m)o"
echo
read answer
echo
while true; do
    if [ "$answer" == "Y" -o "$answer" == "y" ]
    then
	#cp $wget_rc /etc/wgetrc.bkp
	if [ $c1 -eq 1 ]; then 	
	    sed -i "s%#https_proxy = http://proxy.yoyodyne.com:18023/%https_proxy = http://a.vereschaga:1234rewQ@proxy.ctt.com.mps:8080/%" $wget_rc
	else
	    echo -e "\e[32mПрисутствует\e[0m \e[32mстрока с\e[0m \"\e[31mhttps_proxy = http://a.vereschaga:1234rewQ@proxy.ctt.com.mps:8080/\e[0m\"."
	    echo -e "\e[32mВероятно настройки были выполнены ранее! \e[0m"
	    echo -e "\e[32mПроверьте файл\e[0m \e[31m$wget_rc\e[0m"
	fi

	if [ $c2 -eq 1 ]; then
	    sed -i "s%#http_proxy = http://proxy.yoyodyne.com:18023/%http_proxy = http://a.vereschaga:1234rewQ@proxy.ctt.com.mps:8080/%" $wget_rc
	else
	    echo -e "\e[32mПрисутствует\e[0m \e[32mстрока с\e[0m \"\e[31mhttp_proxy = http://a.vereschaga:1234rewQ@proxy.ctt.com.mps:8080/\e[0m\"."
	    echo -e "\e[32mВероятно настройки были выполнены ранее! \e[0m"
	    echo -e "\e[32mПроверьте файл\e[0m \e[31m$wget_rc\e[0m"
	fi

	if [ $c3 -eq 1 ]; then 
	    sed -i "s%#ftp_proxy = http://proxy.yoyodyne.com:18023/%ftp_proxy = http://a.vereschaga:1234rewQ@proxy.ctt.com.mps:8080/%" $wget_rc
	else
	    echo -e "\e[32mПрисутствует\e[0m \e[32mстрока с\e[0m \"\e[31mftp_proxy = http://a.vereschaga:1234rewQ@proxy.ctt.com.mps:8080/\e[0m\"."
	    echo -e "\e[32mВероятно настройки были выполнены ранее! \e[0m"
	    echo -e "\e[32mПроверьте файл\e[0m \e[31m$wget_rc\e[0m"
	fi

	if [ $c4 -eq 1 ]; then
	    sed -i "s%#use_proxy = on%use_proxy = on%" $wget_rc
	else
	    echo -e "\e[32mПрисутствует\e[0m \e[32mстрока с\e[0m \"\e[31muse_proxy = on\e[0m\"."
	    echo -e "\e[32mВероятно настройки были выполнены ранее! \e[0m"
	    echo -e "\e[32mПроверьте файл\e[0m \e[31m$wget_rc\e[0m"
	fi
	break 1
    elif [ "$answer" == "N" -o "$answer" == "n" ]
    then
	echo -e "\e[31mОтказались\e[0m \e[32mпроизводить настройку\e[0m \e[31mwget! \e[0m"
	break 1
    else
        echo -e "\e[31mВвели не верно\e[0m. \e[32mПробуем ещё раз\e[0m. Хотите выполнить этот шаг — \e[32m(Y)es\e[0m/\e[31m(N)o\e[0m?"
	read answer
    fi
done
echo
echo -e "\e[32mСкрипт\e[0m \e[31mзавершит\e[0m \e[32mсвою работу через\e[0m \e[31m3 секунды\e[0m !"
sleep 3
exit 0