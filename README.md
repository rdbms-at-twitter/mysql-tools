# mysql-tools
MySQL Tools and scripts
This Repository Contain MySQL Management Scripts and Tools

Example
<BR>

```sh

root@localhost [sys]> select now(),sleep(10);
+---------------------+-----------+
| now()               | sleep(10) |
+---------------------+-----------+
| 2019-07-20 00:50:38 |         0 |
+---------------------+-----------+
1 row in set (10.00 sec)

root@localhost [sys]> SELECT
    -> `THREAD_ID`,
    -> `TIMER_START`,
    -> `TIMER_END`,
    ->  DATE_ADD(SYSDATE(), INTERVAL - ((select Variable_value from sys.metrics where Variable_name = 'uptime') - TIMER_START*POW(10,-12)) SECOND) 'Start_Time',
    ->  DATE_ADD(SYSDATE(), INTERVAL - ((select Variable_value from sys.metrics where Variable_name = 'uptime') - TIMER_END*POW(10,-12)) SECOND) 'End_Time',
    -> `SQL_TEXT` AS `SQL_TEXT`,
    -> (`TIMER_WAIT` / 1000000000.0) AS `TIMER_WAIT (ms)`,
    -> `ROWS_EXAMINED` AS `ROWS_EXAMINED`,
    -> `ROWS_AFFECTED` AS `ROWS_AFFECTED`,
    -> `ROWS_SENT` AS `ROWS_SENT`,
    -> `CREATED_TMP_TABLES` AS `CREATED_TMP_TABLES`,
    -> `CREATED_TMP_DISK_TABLES` AS `CREATED_TMP_DISK_TABLES`,
    -> `SORT_MERGE_PASSES` AS `SORT_MERGE_PASSES`,
    -> `NO_INDEX_USED` AS `NO_INDEX_USED`,
    -> `NO_GOOD_INDEX_USED` AS `NO_GOOD_INDEX_USED`
    -> FROM
    -> `performance_schema`.`events_statements_history`
    -> ORDER BY `TIMER_START` DESC LIMIT 1\G
*************************** 1. row ***************************
              THREAD_ID: 1626
            TIMER_START: 2422470300968059000
              TIMER_END: 2422480301316512000
           Start_Time: 2019-07-20 00:50:38.300969
           End_Time: 2019-07-20 00:50:48.301317
               SQL_TEXT: select now(),sleep(10)
        TIMER_WAIT (ms): 10000.3485
          ROWS_EXAMINED: 0
          ROWS_AFFECTED: 0
              ROWS_SENT: 1
     CREATED_TMP_TABLES: 0
CREATED_TMP_DISK_TABLES: 0
      SORT_MERGE_PASSES: 0
          NO_INDEX_USED: 0
     NO_GOOD_INDEX_USED: 0
1 row in set (0.02 sec)
<BR>

```


### NOTE (MySQL接続に関して)

```sql

SHOW GLOBAL STATUS LIKE 'Aborted%';

【Aborted Clients】
接続中のクライアントがいきなり切断した
ネットワークの問題
mysql_close()の呼び忘れ
ソケットのR/Wに対するタイムアウトなど

【Aborted_Connects】
クライアントが接続しようと試みたが失敗した
パスワードが間違ってる
データベースへアクセスする権限がない
不正アクセスかも？

connect_timeout
セッションを確立するまでのタイムアウト
デフォルトは10秒

wait_timeout/interactive_timeout
セッションが新しいリクエストを発行するまでのタイムアウト
長時間アイドル状態のセッションを切る為のもの
デフォルトは8時間

net_read_timeout/net_write_timeout
ソケットに対するR/Wのタイムアウト
デフォルト値はそれぞれ30秒、60秒
```
