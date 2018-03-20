#! /bin/bash

######################################################
##   localhostデータベースバックアップ
##   From: localhost
##   Created Date: 2015年07月09日
##   Changed On  : 2015年07月09日
##   Created by:
##   Job Time: 3:00am         Tape Backup:  9:00am
######################################################

############### 日付設定 ################

set echo
TODAY=`date -d 'today' +%Y%m%d`
DFILES=`date -d '7 days ago' +%Y%m%d`

############ DBバックアップ #############

/usr/local/mysql/bin/mysqldump --user=username --password=password --all-databases --default-character-set=utf8mb4 --flush-logs --single-transaction --hex-blob --triggers --routines --events --master-data=2 | gzip > /home/admin/backup/ALLDB_${TODAY}.sql.gz

############ バックアップ完了＆1 Week前のバックアップファイル削除 #############

if [ -e /home/admin/backup/ALLDB_${DFILES}.sql.gz ]; then
    rm /home/admin/backup/ALLDB_${DFILES}.sql.gz
else
    echo "File is not found"
fi