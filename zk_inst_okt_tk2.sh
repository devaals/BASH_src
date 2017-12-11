#!/bin/bash
#Скрипт развёртывания ZooKeeper 3.4.6 на серверах ТК2 Октябрьской ЖД
#Автор: Артём Верещага a.vereschaga@vniias.ru
#Версия: 1.2
#Запуск скрипта производить с узла 10.35.33.11 с правами root
#Перед использованием скрипта настроить авторизацию ssh по ключам между 10.35.33.11 и серверами:
#10.35.33.11
#10.35.33.21
#10.35.33.12
#10.35.33.13
#10.35.33.22
#10.35.33.23
#Иначе придётся часто вводить пароль рута
if [ "$(whoami)" != "root" ]; then
	echo -e "\e[31mНеобходимо запустить обновление из-под\e[0m \e[32mroot\e[0m. Осуществляем выход!"	
	sleep 5
	exit
fi

#Переменные
export ftp_srv; ftp_srv="10.160.20.13"
export ftp_soft; ftp_soft="Software"
export ftp_zoo; ftp_zoo="zookeeper-3.4.6.tar.gz"
export ftp_user; ftp_user="Reader_S"
export ftp_pass; ftp_pass="7ujmMJU"
export zoo_346; zoo_346="zookeeper-3.4.6"
export zoo; zoo="zookeeper"
#Получаем ip-адрес
export server; server=$(/sbin/ip a | grep "inet" | grep 10 | awk '{print $2}'|cut -f 1 -d / -s)

#Переходим в директорию /opt
cd /opt

#Скачиваем ПО Zookeeper версии 3.4.6
wget -t 3 ftp://$ftp_user:$ftp_pass@$ftp_srv/$ftp_soft/$ftp_zoo

if [[ "$server" == "10.35.33.11" ]]
then 
	echo -e '\e[32mЗапуск скрипта осуществлён с сервера \e[0m \e[31m10.35.33.11!\e[0m'
	if [[ -f $ftp_zoo ]]; then echo -e "\e[32mФайл \e[31m$ftp_zoo\e[0m успешно закачан в директорию /opt\e[0m"
		echo 
		echo -e '\e[32mПродолжаем установку ПО zookeeper в /opt\e[0m'
		#Распаковываем 
		tar xzvf $ftp_zoo
		#Переименовываем
		mv $zoo_346 $zoo
		#Создаём директории data и log в zookeeper
		mkdir -p $zoo/{data,log}
		#Добавляем в файл zkEnv.sh строку ". ~/.bash_profile" сразу после строки "#!/usr/bin/env bash" (для упрощения приводится команда sed)
		sed -i "s|#!/usr/bin/env bash|#!/usr/bin/env bash \n . ~/.bash_profile|" /opt/$zoo/bin/zkEnv.sh
		#Изменяем параметр ZOO_LOG_DIR в файле zkEnv.sh(для упрощения приводится команда sed)
		sed -i "s|ZOO_LOG_DIR=\x22\x2E\x22|ZOO_LOG_DIR=\x22/opt/zookeeper/log\x22|" /opt/$zoo/bin/zkEnv.sh
		#Изменяем параметр ZOO_LOG4J_PROP в файле zkEnv.sh(для упрощения приводится команда sed)
		sed -i "s|ZOO_LOG4J_PROP=\x22INFO,CONSOLE\x22|ZOO_LOG4J_PROP=\x22INFO,ROLLINGFILE\x22|" /opt/$zoo/bin/zkEnv.sh
		#Создаём актуальный zoo.cfg
		touch $zoo/conf/zoo.cfg
		cat >>$zoo/conf/zoo.cfg<<EOF
# Конфигурационный файл ZooKeeper
# Порт для подключения клиентов
clientPort=3000
# Путь к директории с данными ZooKeeper
dataDir=/opt/zookeeper/data
# Длина такта (в миллисекундах)
tickTime=2000
# Количество тактов для подключения к лидеру и синхронизации с ним
initLimit=10
# Количество тактов для синхронизации с лидером
syncLimit=5
# Периодичность удаления старых данных ZooKeeper (в часах). 0 - не удалять.
autopurge.purgeInterval=1
# Количество файлов, оставляемое при удалении старых данных
autopurge.snapRetainCount=3
# Адреса всех серверов кластера ZooKeeper
# Формат: server.number=host:leader_port:election_port[:observer]
server.1=10.35.33.11:3001:3002
server.2=10.35.33.21:3001:3002
server.3=10.35.33.12:3001:3002
server.4=10.35.33.13:3001:3002
server.5=10.35.33.22:3001:3002
server.6=10.35.33.23:3001:3002
EOF
		echo '1' > $zoo/data/myid && chmod +x $zoo/check_zoo.sh; sleep 0.2; echo '*/1 * * * * /opt/zookeeper/check_zoo.sh' >> /var/spool/cron/root
		chown rvec-adm:rvec-adm -R $zoo 
		scp -Cqr $zoo root@10.35.33.21:/opt/ &&  ssh root@10.35.33.21 "echo '*/1 * * * * /opt/zookeeper/check_zoo.sh' >> /var/spool/cron/root; echo '2' > /opt/zookeeper/data/myid"
		scp -Cqr $zoo root@10.35.33.12:/opt/ &&  ssh root@10.35.33.12 "echo '*/1 * * * * /opt/zookeeper/check_zoo.sh' >> /var/spool/cron/root; echo '3' > /opt/zookeeper/data/myid"
		scp -Cqr $zoo root@10.35.33.13:/opt/ &&  ssh root@10.35.33.13 "echo '*/1 * * * * /opt/zookeeper/check_zoo.sh' >> /var/spool/cron/root; echo '4' > /opt/zookeeper/data/myid"
		scp -Cqr $zoo root@10.35.33.22:/opt/ &&  ssh root@10.35.33.22 "echo '*/1 * * * * /opt/zookeeper/check_zoo.sh' >> /var/spool/cron/root; echo '5' > /opt/zookeeper/data/myid"
		scp -Cqr $zoo root@10.35.33.23:/opt/ &&  ssh root@10.35.33.23 "echo '*/1 * * * * /opt/zookeeper/check_zoo.sh' >> /var/spool/cron/root; echo '6' > /opt/zookeeper/data/myid"
	else
                echo -e "\e[32mФайл\e[0m \e[31m$ftp_zoo\e[0m \e[32mотсутствует в директории /opt\e[0\e[32\!\e[0m"
		echo -e '\e[32mПроверьте наличие\e[0m \e[31mфайла на ftp и права на директории(ACL)!\e[0m'
                echo -e '\e[31mПрекращаем работу и осуществляем выход из скрипта через 3 секунды!\e[0m'
                sleep 3.0
                exit 0
	fi

else 
	echo -e '\e[32mЗапуск скрипта осуществлён не с сервера \e[0m \e[31m10.35.33.11!\e[0m'
	echo -e '\e[31mПрекращаем работу скрипта и осуществляем выход через 3 секунды!\e[0m'
	sleep 3 && exit 0
	sleep 3.0
	exit 0
fi

exit 0
