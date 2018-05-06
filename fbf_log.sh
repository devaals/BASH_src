#!/bin/bash
#Скрипт поиска больших файлов в определённых директориях
#Автор: Артём Верещага a.vereschaga@vniias.ru
#Version: 1.0
export xdate=`date +%Y-%m-%d_%H-%M`
export fbf_log='/tmp/fbf.log'
#Функция поиска 10 самых больших файлов в директории /opt

if [ ! -f $fbf_log ]; then
		touch $fbf_log && echo $xdate >>$fbf_log
	elif [ -f $fbf_log ]; then
			echo "Выводим результат выполнения скрипта в $fbf_log"
			else
			logger -t "$0" pid $$ $(whoami) нет прав на содание $fbf_log;
			fi

			#Функция поиска 10 самых больших файлов в директории /home
			fbf_home() {
				echo 'Самые большие файлы дирекории /home:' >>$fbf_log
				echo `date +%Y-%m-%d_%H-%M` >> $fbf_log	
				find /home -mount -type f -ls 2> /dev/null | sort -rnk7 | head -10 | awk '{printf "%10d MB\t%s\n",($7/1024)/1024,$NF}'|cat >> $fbf_log
				echo
				sleep 1
			}
			fbf_opt() {
				echo `date +%Y-%m-%d_%H-%M` >> $fbf_log
				echo 'Самые большие файлы дирекории /opt:' >>$fbf_log
				find /opt -mount -type f -ls 2> /dev/null | sort -rnk7 | head -10 | awk '{printf "%10d MB\t%s\n",($7/1024)/1024,$NF}' | cat >> $fbf_log
				echo
				sleep 1
			}

			#Функция поиска 10 самых больших файлов в директории /var
			fbf_var() {
				echo `date +%Y-%m-%d_%H-%M` >> $fbf_log
				echo 'Самые большие файлы дирекории /var:' >>$fbf_log
				find /var -mount -type f -ls 2> /dev/null | sort -rnk7 | head -10 | awk '{printf "%10d MB\t%s\n",($7/1024)/1024,$NF}' | cat >> $fbf_log
				echo
				sleep 1
			}

			#Функция поиска 10 самых больших файлов в директориях /u01 и /u02
			fbf_u01_u02() {
				if [[ -d /u01 ]]; then
					`date +%Y-%m-%d_%H-%M` >> $fbf_log
					echo 'Самые большие файлы дирекории /u01:' >> $fbf_log
					find /u01 -mount -type f -ls 2> /dev/null | sort -rnk7 | head -10 | awk '{printf "%10d MB\t%s\n",($7/1024)/1024,$NF}'|cat >> $fbf_log
				else echo "`date +%Y-%m-%d_%H-%M` Директории /u01 не существует!" >> $fbf_log;
				fi
				if [[  -d /u02 ]]; then
					`date +%Y-%m-%d_%H-%M` >> $fbf_log
					echo 'Самые большие файлы дирекории /u02:' >> $fbf_log
					find /u02 -mount -type f -ls 2> /dev/null | sort -rnk7 | head -10 | awk '{printf "%10d MB\t%s\n",($7/1024)/1024,$NF}'|cat >> $fbf_log
				else echo "`date +%Y-%m-%d_%H-%M` Директории /u02 не существует!" >> $fbf_log;
				fi
				sleep 1
			}

			fbf_opt
			sleep 5
			fbf_home
			sleep 5
			fbf_var
			sleep 5
			fbf_u01_u02
			sleep 5
	echo -e "\e[32m Осуществляем выход из скрипта\e[0m. \e[32mРезультат работы сохранён в файле\e[0m \e[31m$fbf_log\e[0m"
	sleep 5
exit 0