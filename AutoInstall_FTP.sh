###############################################################################################################################
# ----------------------------------------------
# NAME:   Auto Install FTP Server Centos 7+
#
# AUTHOR : Volkov Alexey & Artem Vereschaga & Vladislav Patrushev
# VERSION: v.1.4
# DATE   : 27.11.2017
#
# ----------------------------------------------
###############################################################################################################################
#######Обявление переменных#######

# Переменная для проверки наименования ОС
export OS_name; OS_name=$(cat /etc/redhat-release | awk '{print $1}')
# Переменная для проверки версии ОС
export Version; Version=$(cat /etc/redhat-release | grep 'CentOS'|  awk '{print $4}')
# Переменная содержащая ip-адрес ftp
export ftpUrl; ftpUrl=10.160.20.13
# Переменная содержащая порт
export ftpport; ftpport=21
# Переменная содержащая логин
export ftpLogin; ftpLogin=Reader_S
# Переменная содержащая пароль
export ftpPass; ftpPass=7ujmMJU
# Переменная содержащая корневую директорию ftp
export ftp_dir; ftp_dir=/opt/ftp

###############################################################################################################################
#Проверка на какой версии ОС выполняется скрипт и из под какого пользователя он запущен

if [[ "$OS_name" == "CentOS" && "$Version" > '7' ]];
    then echo -e "Наименование ОС:\e[32m$OS_name\e[0m, версия ОС:\e[32m$Version\e[0m"
            elif [[ "$OS_name" != "CentOS" ]]; then echo "Скрипт запущен на:"
        echo -e "\e[31m$(cat /etc/redhat-release)\e[0m"
            echo -e "Скрипт предназначен для запуска на ОС \e[32mCentOS\e[0m версии \e[32m7\e[0m и выше!"
        echo -e "Осуществляем выход через 3 секунды!"
            sleep 3 && exit
        else echo -e "\e[31mНе смог определить ОС и версию ОС\e[0m."
        echo -e "Осуществляем выход через 3 секунды!"
        sleep 3
        exit
    fi
if [ $(whoami) != "root" ];
    then
        echo -e "\e[31mНеобходимо запустить обновление из-под\e[0m \e[32mroot\e[0m."
        echo -e "Осуществляем выход через 3 секунды!"
        sleep 3
    exit
fi

if [ "$(systemctl status firewalld | grep Active | awk {'print $2,$3'})" = 'active (running)' ]; then
        echo -e "\e[31mСтатус: Firewall Работает, выключите Firewall и запустите установку заново.\e[0m"
        echo -e "Осуществляем выход через 3 секунды!"
        sleep 3
        exit
    else
    echo -e "\e[32mСтатус: Firewall Выключен, продолжаем установку...\e[0m"
    fi

if [ "$(getenforce)" = 'Enforcing' ]; then 
        echo -e "\e[31mСтатус: Selinux Включен. Выключите Selinux и запустите установку заново.\e[0m"
        echo -e "Осуществляем выход через 3 секунды!"
        sleep 3
        exit
    elif
[ "$(getenforce)" = 'Permissive' ]; then 
        echo -e "\e[31mСтатус: Selinux Включен. Выключите Selinux и запустите установку заного.\e[0m"
        echo -e "Осуществляем выход через 3 секунды!"
        sleep 3
        exit
    elif
[ "$(getenforce)" = 'Disabled' ]; then 
        echo -e "\e[32mСтатус: Selinux Выключен, продолжаем установку...\e[0m"
else
        echo -e "\e[31mНе удалось определить состояние Selinux\e[0m"
        echo -e "Осуществляем выход через 3 секунды!"
        sleep 3
    exit
fi
###############################################################################################################################

timeout 1 bash -c "cat < /dev/null > /dev/tcp/${ftpUrl}/${ftpport}"
RESULT=$?
if [ "${RESULT}" -ne 0 ]; then
    echo -e "\e[31mFailed: Нет Доступа до FTP://$ftpUrl. Обратитесь к системному Администратору\e[0m"
else
echo -e "\e[32mConnected: Доступ к FTP есть, начинаю установку\e[0m"
wget -t 25 ftp://$ftpLogin:$ftpPass@$ftpUrl/Software/vsftpd-3.0.2-22.el7.x86_64.rpm -O /opt/vsftpd-3.0.2-22.el7.x86_64.rpm
cd /opt/ && yum -y localinstall /opt/vsftpd-3.0.2-22.el7.x86_64.rpm; sleep 0.1; rm -r vsftpd-3.0.2-22.el7.x86_64.rpm; mkdir -p ftp
chmod -R 755 $ftp_dir
useradd -g ftp -d $ftp_dir ftpuser -s /sbin/nologin
setfacl -R -m "u:ftpuser:rwx" $ftp_dir
sed -i "s/.*anonymous_enable=.*/anonymous_enable=NO/" /etc/vsftpd/vsftpd.conf
sed -i "s/.*local_enable=.*/local_enable=YES/" /etc/vsftpd/vsftpd.conf
sed -i "s/.*write_enable=.*/write_enable=YES/" /etc/vsftpd/vsftpd.conf
sed -i "s/.*dirmessage_enable=.*/dirmessage_enable=YES/" /etc/vsftpd/vsftpd.conf
sed -i "s/.*xferlog_enable=.*/xferlog_enable=YES/" /etc/vsftpd/vsftpd.conf
sed -i "s/.*chroot_local_user=.*/chroot_local_user=YES/" /etc/vsftpd/vsftpd.conf
sed -i "s/.*connect_from_port_20=.*/connect_from_port_20=YES/" /etc/vsftpd/vsftpd.conf
sed -i "s/.*xferlog_std_format=.*/xferlog_std_format=YES/" /etc/vsftpd/vsftpd.conf
echo -e "allow_writeable_chroot=YES\npasv_enable=YES" >> /etc/vsftpd/vsftpd.conf
cd /etc/vsftpd && echo rvec-adm >> user_list
systemctl start vsftpd
echo -e "P@ssw0rd\nP@ssw0rd\n" | passwd ftpuser > /dev/null 2>&1
echo -e "\e[32mУстановлен пароль для ftpuser. Пароль P@ssw0rd\e[0m"
fi
###############################################################################################################################
