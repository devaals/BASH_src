#!/bin/bash
#Перед выполнением скрипта надо проверить доступность репозиториев
. /etc/init.d/functions
if [ $(whoami) != "root" ]; then
	echo -e '\e[32mВыполенение скрипта осуществляется из-под\e[0m \e[31mroot\e[0m !'
	echo "Выходим через 3 секунды!"
	sleep 3
	exit
fi
#Переменные
OU="oracle"; export OU
OG="oinstal"; export OG
ORCL_SID="isuzht"; export ORCL_SID
OUSER=$(cat /etc/passwd |grep 'oracle' | awk -F ":" '{ print $1 }')

####Основной скрипт####
#Установка дополнительных системных пакетов\

yum install -y --nogpg binutils.x86_64 compat-db.x86_64 compat-libstdc++* elfutils-libelf* gcc-c++.x86_64 gcc.x86_64 gdbm.x86_64 \
glibc-devel* glibc-headers.x86_64 glibc* ksh.x86_64 libaio-devel* libaio* libstdc++* make.x86_64 sysstat.x86_64 unixODBC* \
xorg-x11-utils* elfutils-libelf-devel compat-libcap1.x86_64 mc nano gcc make openssh-clients wget xinetd vsftpd gamin unzip ntp \
net-snmp ntsysv libXext.x86_64 compat-libstdc++ readline-devel.x86_64 telnet
sleep 0.2
#Установка пакета rlwrap
cd /tmp
wget -t 25 ftp://Reader_S:7ujmMJU@10.160.20.13/Software/rlwrap-0.42.tar.gz -O /tmp/rlwrap-0.42.tar.gz
tar -zxvf  rlwrap-0.42.tar.gz
cd rlwrap-0.42
./configure
make 
make check
make install
cd ~
rm -rf /tmp/rlwrap-0.42
echo -ne "\t\t\tУстановка пакета rlwrap завершена"; echo_sucсess
#Создание пользователя oracle и, требуемых для установки СУБД, групп  
echo "Установлены необходимые системные пакеты";
if [[ $OU == $OUSER ]]; then echo "Пользователь oracle существует в системе.";
else 
	echo "Создаём необходимые группы:"
	groupadd oinstall; echo -n "Создана группа oinstall";
	sleep 0.2
	groupadd dba; echo -n "Создана группа dba"; 
	sleep 0.2
	groupadd oper; echo -n "Создана группа oper"; 
	sleep 0.2
	groupadd asmadmin; echo -n "Создана группа asmadmin"; 
	sleep 0.2
	echo "Пользователь oracle отсутствует в системе. Создаём пользователя:"
	useradd -g oinstall -G dba,oper,asmadmin oracle; 
	echo "Устанавливаем пароль для пользователя oracle:"
	passwd oracle
	echo -ne "\t\t       Группы и пользователь oracle созданы"; echo_success
fi
#Настройка параметров ядра ОС
echo "Настраиваем параметры ядра ОС:"
	cp /etc/bashrc /etc/bashrc.bkp
	cp /etc/sysctl.conf /etc/sysctl.conf.bkp
	cp /etc/security/limits.conf /etc/security/limits.conf.bkp
	cp /etc/pam.d/login /etc/pam.d/login.bkp
	cp /etc/profile /etc/profile.bkp
	sleep 0.2
echo -ne "\t\t\tБекапы конф. файлов созданы"; echo_success
	
	echo '#### New Oracle Kernel Parameters ####' >> /etc/sysctl.conf
	echo ' ####These parameters a recommended to control the rate at which virtual memory is reclaimed ####' >> /etc/sysctl.conf
	echo vm.swappiness=0 >> /etc/sysctl.conf
	echo vm.dirty_background_ratio=3 >> /etc/sysctl.conf
	echo vm.dirty_ratio=15 >> /etc/sysctl.conf
	echo vm.dirty_expire_centisecs=500 >> /etc/sysctl.conf
	echo vm.dirty_writeback_centisecs=100 >> /etc/sysctl.conf
	echo >> /etc/sysctl.conf
	echo '#### The following values are for 16 GB of RAM ####' >> /etc/sysctl.conf
	echo kernel.shmmax = 8589934592 >> /etc/sysctl.conf
	echo kernel.shmall = 4194304 >> /etc/sysctl.conf
	echo '####Do not scale this parameter with RAM ####' >> /etc/sysctl.conf
	echo kernel.shmmni = 4096 >> /etc/sysctl.conf
	echo >> /etc/sysctl.conf
	echo kernel.sem = 250 32000 100 128 >> /etc/sysctl.conf
	echo net.ipv4.ip_local_port_range = 9000 65500 >> /etc/sysctl.conf
	echo net.core.rmem_default = 262144 >> /etc/sysctl.conf
	echo net.core.rmem_max = 4194304 >> /etc/sysctl.conf
	echo net.core.wmem_default = 262144 >> /etc/sysctl.conf
	echo net.core.wmem_max = 1048586 >> /etc/sysctl.conf
	echo fs.file-max = 6815744 >> /etc/sysctl.conf
	echo fs.aio-max-nr = 1048576 >> /etc/sysctl.conf
	sysctl -p
	sleep 0.2
echo -ne "\t\t       Изменения в конфигурацию произведены"; echo_success
	
	echo "oracle		soft	nproc 		2047" >> /etc/security/limits.conf
	echo "oracle		hard	nproc		16384" >> /etc/security/limits.conf
	echo "oracle		soft	nofile		1024" >> /etc/security/limits.conf
	echo "oracle		hard	nofile		65536" >> /etc/security/limits.conf
	echo "oracle		soft	stack		10240" >> /etc/security/limits.conf
	echo "oracle		hard	stack		32768" >> /etc/security/limits.conf
	echo "session required pam_limits.so" >> /etc/pam.d/login
sed -i 's/done/done\n\tif [[ $USER == "oracle" ]]; then\n\t\tulimit -u 16384 -n 65536\n\tfi/' /etc/bashrc
	sleep 0.2	
echo -en "\t\t       Оболочка oracle настроена"; echo_success

	mkdir -p /u01/app/oracle/product/11.2.0/dbhome_1
	chown -R oracle:oinstall /u01
	chmod -R 775 /u01
	mkdir -p /u02/oradata
	chown -R oracle:oinstall /u02
	chmod -R 775 /u02/oradata
	sleep 0.2
echo -ne "\t\t\tКаталоги для установки СУБД созданы"; echo_success
#Внесение изменений в .bash_profile пользователя oracle	
	echo   >> /home/oracle/.bash_profile
	echo  'umask 022' >> /home/oracle/.bash_profile
	echo  'TMP=/tmp; export TMP' >> /home/oracle/.bash_profile
	echo  'TMPDIR=$TMP; export TMPDIR' >> /home/oracle/.bash_profile
	echo  "ORACLE_HOSTNAME=$(hostname); export ORACLE_HOSTNAME" >> /home/oracle/.bash_profile
	echo  'ORACLE_UNQNAME=isuzht; export ORACLE_UNQNAME' >> /home/oracle/.bash_profile
	echo  'ORACLE_BASE=/u01/app/oracle; export ORACLE_BASE' >> /home/oracle/.bash_profile
	echo  'export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/dbhome_1' >> /home/oracle/.bash_profile
	echo  'export ORACLE_SID=isuzht' >> /home/oracle/.bash_profile
	echo  'export NLS_LANG=AMERICAN_AMERICA.CL8MSWIN1251' >> /home/oracle/.bash_profile
	echo  'export ORACLE_HOME_LISTNER=$ORACLE_HOME' >> /home/oracle/.bash_profile
	echo  'PATH=$ORACLE_HOME/bin:$PATH' >> /home/oracle/.bash_profile
	echo  'export PATH' >> /home/oracle/.bash_profile
	echo  "alias sqlplus='rlwrap sqlplus' " >> /home/oracle/.bash_profile
	echo  "alias rman='rlwrap rman' " >> /home/oracle/.bash_profile
	sleep 0.2
echo -ne "\t\t       Профиль пользователя oracle настроен"; echo_success