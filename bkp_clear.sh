#!/bin/bash
# Количество дней
export day; day=10
# Путь до папки с файлами
export where_find; where_find="/backups"

#Поиск файлов старше 10 дней и их удаление 
find $where_find -name "*.tar.gz" -type f -mtime +$day -delete
#Для сохранения лога файлов
#find $where_find -name "*.tar.gz" -type f -mtime +$day -delete > $where_find/bkp_clear.log
#cat  $where_find/bkp_clear.log

#Поиск пустых файлов
#find $where_find -type f -empty
#Найти пустые папки и удалить
find $where_find -type d -empty -exec rmdir -pv '{}' \; 2>/dev/null