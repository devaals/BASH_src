#!/bin/bash
#Автор: Верещага Артём (a.vereschaga@vniias.ru)
#Version 1.0
#Скрипт поиска шаблона в файле
#Запуск скрипта ./pattern.sh <ЧТО_ИЩЕМ> <В_ЧЁМ_ИЩЕМ>
#Например: ./script.sh root /etc/passwd
PATTERN=$1
FILE=$2
output_log="/tmp/out_grep.log"
if grep -q $PATTERN $FILE;
then
     echo "Строки влючающие в себя '$PATTERN':" > $output_log
     echo -e "$(grep -n $PATTERN $FILE)\n" >> $output_log
else
     echo "Ошибка: Шаблон '$PATTERN' не найден в '$FILE'"
     echo "Осуществляем выход..."
exit 0
fi
exit 0
