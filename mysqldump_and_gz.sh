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

############ DBバックアップ完了 #############

/usr/local/mysql/bin/mysqldump --user=ユーザ --password=パスワード --all-databases --flush-logs --single-transaction --master-data=2  | gzip > /home/admin/backup/ALLDB_${TODAY}.sql.gz

############ 1 Week前のバックアップファイル削除 #############

# rm /home/admin/backup/ALLDB_${DFILES}.sql.gz

