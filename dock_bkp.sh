#!/bin/env bash
# Наименование: dock_bkp.sh
#
# Автор: Верещага А.А.
#
# Версия: 1.1
#
# Описание:
# Скрипт коммитит слой записи контейнера в образ, а затем создаёт бекап из образа в /backups/docker/mediawiki.
# Также осуществляется копирование в архивную копию данных из VOLUMES(/opt/docker_data/mariadb-wiki)
#
#######Определение переменных######

#Получаем текущее максимальное значение для образов niias/mariadb и niias/mediawiki:
#Получить максимальный TAG для образа niias/mariadb:
previous_tag_mariadb=$(docker images |grep "niias/mariadb" | awk '{ print $2 }'| grep -Eo '[0-9]+' | sort -nk1 | tail -n 1)
#Получить максимальный TAG для образа niias/mediawiki:
previous_tag_mediawiki=$(docker images |grep "niias/mediawiki" | awk '{ print $2 }'| grep -Eo '[0-9]+' | sort -nk1 | tail -n 1)

#Получаем следующее значение для образов niias/mariadb и niias/mediawiki:
#Получить следующий TAG для образа niias/mariadb:
next_tag_mariadb=$(let "previous_tag_mariadb +=1";echo $previous_tag_mariadb)
#Получить следующий TAG для образа niias/mariadb:
next_tag_mediawiki=$(let "previous_tag_mediawiki +=1";echo $previous_tag_mediawiki)

#Получаем ID контейнеров, которые обеспечивают сервис MEDIAWIKI:
#Получить ID контейнера mediawiki:
cont_mediawiki=$(docker ps -a |grep "mediawiki"|awk '{ print $1 }')
#Получить ID контейнера mariadb-wiki:
cont_mariadb_wiki=$(docker ps -a |grep "mariadb-wiki"|awk '{ print $1 }')

xdate=$(date +%Y-%m-%d_%H-%M-%S)
bd="/backups/docker/mediawiki"
#######Определение переменных######

if [ $(whoami) != "root" ];
    then
        echo -e "$(date +%Y-%m-%d_%H-%M-%S)\tНеобходимо запустить обновление из-под root!"|tee -a $xdate-docker_bkp.log
	echo -e "$(date +%Y-%m-%d_%H-%M-%S)\tОсуществляем выход через 3 секунды!"|tee -a $xdate-docker_bkp.log
        sleep 3
        exit
    fi
if [ -d $bd ]; then echo -e "$(date +%Y-%m-%d_%H-%M-%S)\tДиректория для бекапов существует."|tee -a $xdate-docker_bkp.log
    else
        echo -e "$(date +%Y-%m-%d_%H-%M-%S)\tСоздаём директорию для бекапов."|tee -a $xdate-docker_bkp.log
    	mkdir -p $bd
fi

#Основное тело скрипта#
#Создаём новые образы — путём коммита контейнеров в новые образы, с TAG увеличеным на 1
echo -e "$(date +%Y-%m-%d_%H-%M-%S)\tНачинаем процесс создания резервной копии образа. Записываем последний слой контейнера в новый образ, помещаем его в локальный репозиторий docker."|tee -a $xdate-docker_bkp.log
docker commit -a 'AutoBackup' $cont_mariadb_wiki  niias/mariadb:tag$next_tag_mariadb >> /dev/null 2>&1; sleep 0.1
docker commit -a 'AutoBackup' $cont_mediawiki  niias/mediawiki:tag$next_tag_mediawiki >> /dev/null 2>&1; sleep 0.1
echo -e "$(date +%Y-%m-%d_%H-%M-%S)\tПроцесс создания резервной копии образа, перенос её в локальный репозиторий docker завершён."|tee -a $xdate-docker_bkp.log

#Сохраняем последнию версию образа из репозитория в архивный файл
echo -e "$(date +%Y-%m-%d_%H-%M-%S)\tСохраняем последний образ в архивную копию в $bd."|tee -a  $xdate-docker_bkp.log
docker save niias/mariadb:tag$next_tag_mariadb |bzip2 >/backups/docker/mediawiki/$(date +%Y-%m-%d_%H:%M:%S)_niias_mariadb_tag$next_tag_mariadb.bz2; sleep 0.1
docker save niias/mediawiki:tag$next_tag_mediawiki |bzip2 >/backups/docker/mediawiki/$(date +%Y-%m-%d_%H:%M:%S)_niias_mediawiki_tag$next_tag_mediawiki.bz2; sleep 0.1
echo -e "$(date +%Y-%m-%d_%H-%M-%S)\tСоздание архивных копий в $bd завершено."|tee -a $xdate-docker_bkp.log
sleep 0.1
echo -e "$(date +%Y-%m-%d_%H-%M-%S)\tСоздание архивной копии данных смонтированных томов контейнеров(VOLUMES)."|tee -a $xdate-docker_bkp.log
zip -9 $bd/$(date +%Y-%m-%d_%H:%M:%S)_mariadb-wiki_volume_tag$next_tag_mariadb.zip -r /opt/docker_data/mariadb-wiki/ >> /dev/null 2>&1 |tee -a $xdate-docker_bkp.log
sleep 0.1
exit
