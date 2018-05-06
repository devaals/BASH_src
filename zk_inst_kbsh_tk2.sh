#!/bin/bash
#Скрипт развёртывания ZooKeeper 3.4.6 на ТК2 Куйбышевской ЖД
#Автор: Артём Верещага a.vereschaga@vniias.ru

if [ "$(whoami)" != "root" ]; then
	echo -e "\e[31mНеобходимо запустить обновление из-под\e[0m \e[32mroot\e[0m. Осуществляем выход!"
	sleep 3
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

#Скачиваем ПО zookeeper версии 3.4.6
wget -t 3 ftp://$ftp_user:$ftp_pass@$ftp_srv/$ftp_soft/$ftp_zoo

#Проверяем скачался ли файл в /opt, если да продолжаем установку, иначе выводим предупреждение и выходим
if [ -f $ftp_zoo ]; then echo -e "\e[32mФайл \e[31m$ftp_zoo\e[0m успешно закачан в директорию /opt\e[0m"
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
server.1=10.64.6.20:3001:3002
server.2=10.64.6.21:3001:3002
server.3=10.64.6.26:3001:3002
server.4=10.64.6.27:3001:3002
server.5=10.64.6.32:3001:3002
server.6=10.64.6.33:3001:3002
EOF
	if [ "$server" == "10.64.6.20" ]; then echo '1' > $zoo/data/myid
		elif [ "$server" == "10.64.6.21" ]; then echo '2' > $zoo/data/myid
		elif [ "$server" == "10.64.6.26" ]; then echo '3' > $zoo/data/myid
		elif [ "$server" == "10.64.6.27" ]; then echo '4' > $zoo/data/myid
		elif [ "$server" == "10.64.6.32" ]; then echo '5' > $zoo/data/myid
		elif [ "$server" == "10.64.6.33" ]; then echo '6' > $zoo/data/myid
	else echo 'Сервер не определён. Осуществляем выход через 3 секунды!' && sleep 3.0 && exit 0; fi
	#Создаём сервис systemd
	touch /etc/systemd/system/zoo.service
	cat >> /etc/systemd/system/zoo.service <<EOF
[Unit]
Description=Apache Zookeeper server.
Documentation=http://zookeeper.apache.org
Requires=network.target remote-fs.target.
After=network.target remote-fs.target


[Service]
Type=forking
User=root
Group=root
ExecStart=/opt/zookeeper/bin/zkServer.sh start
ExecStop=/opt/zookeeper/bin/zkServer.sh stop
ExecReload=/opt/zookeeper/bin/zkServer.sh restart
Restart=always

		
[Install]
WantedBy=multi-user.target
EOF
	#Назначаем владельцем директорий /opt/zookeeper
	chown root. -R /opt/$zoo
	
	#Добавляем сервис zoo.service в автозагрузку
	systemctl enable zoo.service
	#Запускаем сервис zoo.service
	systemctl daemon-reload && systemctl start zoo.service
	
	else echo -e "\e[32mФайл \e[31m$ftp_zoo\e[0m отсутствует в директории /opt\e[0m."
		echo -e '\e[32mПроверьте наличие файла на ftp и права на директории(ACL)\e[0m.'
		echo -e 'Прекращаем работу и осуществляем выход из скрипта через 3 секунды!'
		sleep 3.0
		exit 0
fi
exit 0