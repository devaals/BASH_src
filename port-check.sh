#!/bin/bash

# PortCheck - скрипт для проверки доступности порта(ов) на хосте(ах).
# 
# Лицензия:	GNU GPLv2
# Автор:	Roman (Angel 2S2) Shagrov
# 
# Обо всех ошибках, замечаниях и преложениях пишите на saimon.ghost@gmail.com 
# или оставляйте комментарии в моем блоге - http://angel2s2.blogspot.com/
# 
#
# История изменений ( - - удалено; + - добавлено; = - изменено):
# 
# Версия 1.0:
# Первая публичная версия.
#
# Ресурс:
# http://blog.angel2s2.ru/2009/02/port-check.html


# Проверяем зависимости
_prnt() { echo "$1 не найден!!!" ; exit 254 ; }
if [[ ! $(which ping) ]] ; then _prnt 'ping' ; fi
if [[ ! $(which basename) ]] ; then _prnt 'basename' ; fi
if [[ ! $(which printf) ]] ; then _prnt 'printf' ; fi
if [[ ! $(which bc) ]] ; then _prnt 'bc' ; fi
if [[ ! $(which nc) ]] ; then 
  if [[ ! $(which netcat) ]] ; then
    _prnt 'netcat'
  else
    NC='netcat'
  fi
else
  NC='nc'
fi


EXIT=0				# По умолчанию выход "хороший"
ISQUIET='no'				# Ничего не выводить
ISVERBOSE='no'				# Если указан -v|--verbose, будет 'yes', иначе 'no' 
PORTS=''				# Массив портов
HOSTS=''				# Массив хостов

VERSION=1.0
AUTHOR='Roman (Angel 2S2) Shagrov'

Version() {
	echo -ne "
Script Name:	port-check $VERSION
Author:		$AUTHOR
License:	GNU GPLv2
Copyright:	(c) $AUTHOR, 2009
Date:		18.02.2009
Dependences:	netcat, ping, basename, printf, bc

"
}

PrintHelp() {
	echo -ne "
Скрипт $(basename $0) проверяет на доступность указанные порты на указанных хостах.
Возвращает количество закрытых портов.

Использование:
 $(basename $0) [-q|-v] host port
 $(basename $0) [-q|-v] host \"port1 .. portN\"
 $(basename $0) [-q|-v] \"host1 .. hostN\" port
 $(basename $0) [-q|-v] \"host1 .. hostN\" \"port1 .. portN\"



 -q, --quiet
	Ничего не выводить

 -v, --verbose
	Выводить т.ж. открытые порты, иначе только закрытые и не доступные хосты

 -V, --version 
	Показать версию

 -h, --help
	Показать эту справку

"
}

# Если никаких ключей не указано, показать справку
if [[ $# -eq 0 ]] ; then PrintHelp ; exit 255 ; fi

# Разбор ключей
while [ $# -gt 0 ]; do
    case "$1" in
	  -q|--quiet)     if [[ "$ISVERBOSE" = "yes" ]] ; then echo 'Ошибка: Ключи -v, --verbose и -q, --quiet одновременно использовать нельзя!' ; echo '' ; PrintHelp ; exit 1 ; else ISQUIET='yes' ; fi ;;
	  -v|--verbose)   if [[ "$ISQUIET" = "yes" ]] ; then echo 'Ошибка: Ключи -v, --verbose и -q, --quiet одновременно использовать нельзя!' ; echo '' ; PrintHelp ; exit 1; else ISVERBOSE='yes' ; fi ;;
	  -V|--version)   Version; exit 1 ;;
      -h|--help)      PrintHelp ; exit 1 ;;
	  *)			  break ;;
    esac
    shift
done

COUNTER() { EXIT=$(echo $EXIT+1 | bc) ; }								  # Счётчик закрытых портов

# Главная функция скрипта, именно она проверяет порты ($1 = host, $2 = port)
portcheck() {
  if [[ -z "$HOSTSTATUS" ]] ; then					# Проверяем флаг состояния хоста, если он не определён, значит мы ещё не проверяли этот хост,
    if ( ping -c 2 $1 > /dev/null 2> /dev/null ) ; then					# проверяем текущий хост на доступность,
      HOSTSTATUS='up'					# если доступен, поднимаем флаг состояния хоста,
    else
		HOSTSTATUS='down'												  # иначе опускаем.
    fi
  fi
  if [[ "$ISQUIET" = "yes" ]] ; then						           # Если активирован "тихий" режим, то ничего не выводим.
    if [[ "$HOSTSTATUS" = "up" ]] ; then						           # Если хост доступен,
      if ( ! $NC -w3 -z $1 $2 ) ; then					               # проверяем текущий порт и если он закрыт,
        COUNTER						           # увеличиваем счетчик закрытых портов на 1.
      fi
    else														   # Если хост не доступен,
        COUNTER												    		   # увеличиваем счетчик закрытых портов на 1.
    fi
  else				   # Если "тихий" режим не активирован,
    if [[ "$HOSTSTATUS" = "up" ]] ; then				   # если хост доступен,
      if ( $NC -w3 -z $1 $2 ) ; then			     	   # проверяем указанный порт и если он открыт,
        if [[ "$ISVERBOSE" = "yes" ]] ; then			     	   # проверяем режим вывода, если включен подробный вывод,
          printf  "$1:$2	"%-8s"open\n"			   # сообщаем, что текущий порт открыт, иначе ничего не сообщаем.
        fi
        else		  		                   # Если текущий порт закрыт,
            printf  "$1:$2	"%-8s"CLOSE!!!\n"			                   # сообщаем об этом
            COUNTER					               # и увеличиваем счетчик закрытых портов на 1.
        fi
    else						         # Если текущий хост не доступен,
        printf  "Host $1 unreachable!!!\n"						         # сообщаем об этом
        COUNTER						         # и увеличиваем счетчик закрытых портов на 1.
    fi
  fi
}

HOSTSTATUS=''			# "Инициализируем" флаг состояния хоста.
HOSTS=("$1")			# Создаём массив хостов для проверки.
PORTS=("$2")			# Создаём массив портов для проверки.
for H in ${HOSTS[@]} ; do			# В цикле перебираем все хосты,
  for P in ${PORTS[@]} ; do			# в подцикле перебираем все порты,
    if [[ ("$HOSTSTATUS" = "up") || (-z "$HOSTSTATUS") ]] ; then	        # если хост доступен или состояние хоста не известно,
        portcheck $H $P	        # проверяем текущий порт,
    else	        # иначе
        COUNTER			# просто увеличиваем счетчик закрытых портов.
    fi
  done
  HOSTSTATUS=''															 # Сбрасывает флаг состояния хоста.
done

exit $EXIT													              # Выходим и возвращаем количество закрытых портов