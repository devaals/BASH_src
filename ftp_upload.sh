#!/bin/sh
#Экспорт переменных
=======
#Переменные 
export SERVER=10.160.20.13
export USER=NIIAS_7
export PWD=E68vTf
export SOURCE_DIRS="/opt/"
export BACKUP_DIR="Software/MKMZD"

#Работа с ftp
#Автоматический логин на удалённый ресурс
#Удаление всех файлов, удовлетворяющих маске  *.tar.gz из директории $BACKUP_DIR
#Копирование на ftp содержимого $SOURCE_DIRS, с одновременным архивированием содержимого
=======
#Логин на удалённый ресурс
#Удаление всех файлов, удовлетворяющих маске  *.tar.gz
#Копирование на ftp содержимого SOURCE_DIRS, с одновременным архивированием содержимого
#Выход с ftp
ftp -n $SERVER << EOS
quote USER $USER
quote PASS $PWD
cd $BACKUP_DIR
mdelete *.tar.gz
verbose
binary
put "| tar cvzf - $SOURCE_DIRS" `date +%Y-%m-%d_%H-%M-%S`.tar.gz
quit
EOS
#Переход в $SOURCE_DIRS и удаление его содержимого
=======
#Переход в SOURCE_DIRS и удаление его содержимого
cd $SOURCE_DIRS
rm -rf $(pwd)/*
