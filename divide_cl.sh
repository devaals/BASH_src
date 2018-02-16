#!/bin/bash
# Тренажёрный комплекс №2
export psql101; psql101="krw-izt-psq-301"
export psql102; psql102="krw-izt-psq-302"
export main101; main101="krw-izt-app-301"
export main102; main102="krw-izt-app-302"
export drv101; drv101="krw-izt-drv-301"
export drv102; drv102="krw-izt-drv-302"
export line101; line101="krw-izt-line-301"
export line102; line102="krw-izt-line-302"
export web101; web101="krw-izt-web-301"
export web102; web102="krw-izt-web-302"

export WORK_DIR; WORK_DIR="/opt/ruby_projects"

logger -t "$0" pid $$ $(whoami) выбирает, что делать с кластером.
echo -e "\e[32mВыберите, что\e[0m \e[31mсделать\e[0m \e[32mс кластером:\e[0m"
echo -e  "\e[33m1)\e[0m \e[32mОбъеденить под версией\e[0m \e[31m 1.0\e[0m"
echo -e "\e[33m2)\e[0m \e[31mРазъеденить\e[0m \e[32mпод версиями\e[0m \e[31m1.0\e[0m \e[32mи\e[0m \e[31m2.0\e[0m"

read item
case "$item" in
	1) logger -t "$0" pid $$ $(whoami) объединяет кластер
	ip_1=$main101 ip_2=$main102 ip_3=$drv101 ip_4=$drv102 ip_5=$line101 ip_6=$line102 ip_7=$web101 ip_8=$web102
	echo -e "Введите \e[31mпароль\e[0m для \e[32mrvec-adm\e[0m:"
	pssh -A -H "$ip_1 $ip_2" -l rvec-adm -t 1500 "sed -i -e \"/recovery_policy/,/]/ s|^|#|\" $WORK_DIR/conf/config_main*; sed -i -e \"/recovery_policy/,/]/ s|^|#|\" $WORK_DIR/rvec/conf/config_main*; sed -i -e \"/standalone/ s|^|#|\" $WORK_DIR/rvec/conf/config_main*"
	logger -t "start.sh" результат: $?
	echo -e "Введите \e[31mпароль\e[0m для \e[32mrvec-adm\e[0m:"
	pssh -A -H "$ip_4 $ip_6 $ip_8 $ip_2" -l rvec-adm -t 1500 "sed -i -e \"/version/ s|2.0|1.0|\" $WORK_DIR/conf/config*; sed -i -e \"/version/ s|2.0|1.0|\" $WORK_DIR/rvec/conf/config*; /etc/init.d/rvec-daemon.sh restart"
	logger -t "start.sh" результат: $?
	echo -e "Введите \e[31mпароль\e[0m для \e[32mrvec-adm\e[0m:"
	pssh -A -H "$ip_1" -l rvec-adm -t 1500 "/etc/init.d/rvec-daemon.sh restart"
	logger -t "start.sh" результат: $?			
	;;
	2) logger -t "$0" pid $$ $(whoami) разъединяет кластер
	ip_1=$main101 ip_2=$main102 ip_3="" ip_4=$drv102 ip_5="" ip_6=$line102 ip_7="" ip_8=$web102
	echo -e "Введите \e[31mпароль\e[0m для \e[32mrvec-adm\e[0m:"
	pssh -A -H "$ip_1 $ip_2" -l rvec-adm -t 1500 "sed -i -e \"/recovery_policy/,/]/ s|^#||\" $WORK_DIR/conf/config_main*; sed -i -e \"/recovery_policy/,/]/ s|^#||\" $WORK_DIR/rvec/conf/config_main*; sed -i -e \"/standalone/ s|^#||\" $WORK_DIR/rvec/conf/config_main*"
	logger -t "start.sh" результат: $?
	echo -e "Введите \e[31mпароль\e[0m для \e[32mrvec-adm\e[0m:"
	pssh -A -H "$ip_2 $ip_4 $ip_6 $ip_8" -l rvec-adm -t 1500 "sed -i -e \"/version/ s|1.0|2.0|\" $WORK_DIR/conf/config*; sed -i -e \"/version/ s|1.0|2.0|\" $WORK_DIR/rvec/conf/config*"
	logger -t "start.sh" результат: $?
	echo -e "Введите \e[31mпароль\e[0m для \e[32mrvec-adm\e[0m:"
	pssh -A -H "$ip_1 $ip_2 $ip_4 $ip_6 $ip_8" -l rvec-adm -t 1500 "/etc/init.d/rvec-daemon.sh restart"
	logger -t "start.sh" результат: $?
	;;	
	*)
	echo -e '\e[31mНичего не ввели!\e[0m'
	sleep 2
	;;
esac
echo -e "Нажмите клавишу \e[32mEnter\e[0m \e[31mдля завершения\e[0m"
read qa

exit 0
