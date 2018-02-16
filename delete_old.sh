#!/bin/bash
#Удаление файлов старше 5 дней
#1 */1 * * 1-7 /u02/scripts_imp_exp/datapump/impdp_expdp/delete_old.sh - добавить строку в crontab
find /var/lib/pgsql/9.4/pgImpExp-rvec_krw/dump/export -type f -mtime +5 -exec rm -rf {} \;