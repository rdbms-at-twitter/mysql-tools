#! /bin/bash


echo "SQLSLAPデータベースを作成して、ベンチマークを実行します"

/usr/local/mysql/bin/mysqlslap --no-defaults --create-schema=SQLSLAP --auto-generate-sql --auto-generate-sql-add-autoincrement --engine=InnoDB --number-int-cols=3 --number-char-cols=5 --concurrency=30 --auto-generate-sql-write-number=1000 --auto-generate-sql-execute-number=1000 --auto-generate-sql-load-type=mixed -u root -p
