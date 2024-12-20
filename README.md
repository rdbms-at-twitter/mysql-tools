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

### Errorの確認　(8.0.22 ~)

```sql
mysql> SELECT LOGGED,THREAD_ID,PRIO,ERROR_CODE,SUBSYSTEM,sys.format_statement(DATA) FROM performance_schema.error_log order by LOGGED desc limit 10;
+----------------------------+-----------+------+------------+-----------+-------------------------------------------------------------------+
| LOGGED                     | THREAD_ID | PRIO | ERROR_CODE | SUBSYSTEM | sys.format_statement(DATA)                                        |
+----------------------------+-----------+------+------------+-----------+-------------------------------------------------------------------+
| 2024-12-16 09:38:34.430343 |    206869 | Note | MY-010914  | Server    | Aborted connection 206869 to d ... eading communication packets). |
| 2024-12-16 09:38:34.429723 |    206866 | Note | MY-010914  | Server    | Aborted connection 206866 to d ... eading communication packets). |
| 2024-12-16 09:38:34.427429 |    206870 | Note | MY-010914  | Server    | Aborted connection 206870 to d ... eading communication packets). |
| 2024-12-16 09:38:34.385606 |    206865 | Note | MY-010914  | Server    | Aborted connection 206865 to d ... eading communication packets). |
| 2024-12-16 09:38:34.367643 |    206867 | Note | MY-010914  | Server    | Aborted connection 206867 to d ... eading communication packets). |
| 2024-12-16 09:38:34.284570 |    206868 | Note | MY-010914  | Server    | Aborted connection 206868 to d ... eading communication packets). |
| 2024-12-16 09:38:34.235154 |    206863 | Note | MY-010914  | Server    | Aborted connection 206863 to d ... eading communication packets). |
| 2024-12-16 09:38:34.096448 |    206862 | Note | MY-010914  | Server    | Aborted connection 206862 to d ... eading communication packets). |
| 2024-12-16 09:38:33.970807 |    206864 | Note | MY-010914  | Server    | Aborted connection 206864 to d ... eading communication packets). |
| 2024-12-16 09:38:33.913408 |    206861 | Note | MY-010914  | Server    | Aborted connection 206861 to d ... eading communication packets). |
+----------------------------+-----------+------+------------+-----------+-------------------------------------------------------------------+
10 rows in set (0.00 sec)
```

### CPU TIMEの確認　(8.0.28 ~)

```
mysql> SELECT sys.format_statement(DIGEST_TEXT) AS query,
    -> FORMAT_PICO_TIME(AVG_TIMER_WAIT) AS avg_cpu_time,
    -> FORMAT_PICO_TIME(MIN_TIMER_WAIT) AS min_cpu_time,
    -> FORMAT_PICO_TIME(MAX_TIMER_WAIT) AS max_cpu_time,
    -> COUNT_STAR AS query_count
    -> FROM performance_schema.events_statements_summary_by_digest
    -> WHERE DIGEST_TEXT IS NOT NULL
    -> AND SCHEMA_NAME NOT LIKE 'mysql.%'
    -> ORDER BY AVG_TIMER_WAIT DESC
    -> LIMIT 10;
+-------------------------------------------------------------------+--------------+--------------+--------------+-------------+
| query                                                             | avg_cpu_time | min_cpu_time | max_cpu_time | query_count |
+-------------------------------------------------------------------+--------------+--------------+--------------+-------------+
| OPTIMIZE TABLE `booking`                                          | 13.32 min    | 13.32 min    | 13.32 min    |           1 |
| CALL `InsertLargeData` (...)                                      | 11.92 min    | 1.75 ms      | 1.08 h       |          13 |
| CALL `UpdateLargeData` (?)                                        | 3.99 min     | 422.75 us    | 6.67 min     |          11 |
| SELECT `ewhl` . `THREAD_ID` ,  ... ql_text` ORDER BY `total` DESC | 1.36 min     | 35.72 ms     | 6.54 min     |          16 |
| SELECT `ewhl` . `EVENT_NAME` , ... ql_text` ORDER BY `total` DESC | 1.04 min     | 57.36 ms     | 3.11 min     |           3 |
| LOCK TABLES `T_Character` READ ... CAL , `t_histories` READ LOCAL | 57.50 s      | 57.50 s      | 57.50 s      |           1 |
| INSERT INTO `large_table` ( `column1` , `column2` ) VALUES (...)  | 50.01 s      | 50.00 s      | 50.01 s      |           2 |
| DELETE FROM `booking` WHERE `booking_id` BETWEEN ? AND ?          | 26.75 s      | 4.27 s       | 49.24 s      |           2 |
| SELECT COUNT ( * ) , `sleep` (?) FROM `booking`                   | 21.58 s      | 21.58 s      | 21.58 s      |           1 |
| SELECT COUNT ( * ) FROM `booking`                                 | 19.60 s      | 2.02 s       | 37.18 s      |           2 |
+-------------------------------------------------------------------+--------------+--------------+--------------+-------------+
10 rows in set (0.01 sec)

```

### 待機イベントの確認

```
mysql> select ewhl.THREAD_ID,ewhl.EVENT_NAME,ewhl.operation,
    -> ewhl.SOURCE,sys.format_statement(esc.DIGEST_TEXT) sql_text
    -> from performance_schema.events_waits_current ewhl
    -> LEFT JOIN performance_schema.events_statements_current esc
    -> ON ewhl.THREAD_ID = esc.THREAD_ID
    -> where ewhl.event_name like "wait/synch/sxlock/innodb%";
+-----------+------------------------------------------+----------------+-----------------+----------+
| THREAD_ID | EVENT_NAME                               | operation      | SOURCE          | sql_text |
+-----------+------------------------------------------+----------------+-----------------+----------+
|        27 | wait/synch/sxlock/innodb/trx_purge_latch | exclusive_lock | srv0srv.cc:3428 | NULL     |
+-----------+------------------------------------------+----------------+-----------------+----------+
1 row in set (0.01 sec)

mysql> select ewhl.THREAD_ID,ewhl.EVENT_NAME,ewhl.operation,
    -> ewhl.SOURCE,sys.format_statement(esc.DIGEST_TEXT) sql_text,count(*) total
    -> from performance_schema.events_waits_history ewhl
    -> LEFT JOIN performance_schema.events_statements_history esc
    -> ON ewhl.THREAD_ID = esc.THREAD_ID
    -> where ewhl.event_name like "wait/synch/sxlock/innodb%"
    -> group by ewhl.THREAD_ID,ewhl.EVENT_NAME,ewhl.operation,ewhl.SOURCE,sql_text
    -> order by total desc;
+-----------+-------------------------------------------+----------------+-----------------+----------+-------+
| THREAD_ID | EVENT_NAME                                | operation      | SOURCE          | sql_text | total |
+-----------+-------------------------------------------+----------------+-----------------+----------+-------+
|        17 | wait/synch/sxlock/innodb/btr_search_latch | shared_lock    | srv0srv.cc:1570 | NULL     |     8 |
|        10 | wait/synch/sxlock/innodb/hash_table_locks | exclusive_lock | buf0buf.cc:7172 | NULL     |     2 |
|        27 | wait/synch/sxlock/innodb/trx_purge_latch  | exclusive_lock | srv0srv.cc:3428 | NULL     |     2 |
|        27 | wait/synch/sxlock/innodb/hash_table_locks | shared_lock    | buf0buf.cc:5695 | NULL     |     2 |
|        26 | wait/synch/sxlock/innodb/hash_table_locks | shared_lock    | buf0buf.cc:5695 | NULL     |     1 |
|        26 | wait/synch/sxlock/innodb/hash_table_locks | shared_lock    | buf0buf.cc:4878 | NULL     |     1 |
|        27 | wait/synch/sxlock/innodb/trx_purge_latch  | exclusive_lock | srv0srv.cc:3465 | NULL     |     1 |
+-----------+-------------------------------------------+----------------+-----------------+----------+-------+
7 rows in set, 1 warning (0.02 sec)
```

### QPS Estimation

```
mysql> SELECT
    -> SUM(exec_count) AS rollback_count,
    -> MIN(first_seen) AS first_execution,
    -> MAX(last_seen) AS last_execution,
    -> TIMESTAMPDIFF(SECOND, MIN(first_seen), MAX(last_seen)) AS duration_seconds,
    -> CASE
    ->  WHEN TIMESTAMPDIFF(SECOND, MIN(first_seen), MAX(last_seen)) > 0
    ->  THEN SUM(exec_count) / TIMESTAMPDIFF(SECOND, MIN(first_seen), MAX(last_seen))
    ->  ELSE NULL
    ->  END AS QPS,
    ->  current_timestamp AS check_time
    -> FROM
    -> sys.statement_analysis
    -> WHERE
    -> query LIKE 'rollback%'
    -> AND last_seen IS NOT NULL;
+----------------+----------------------------+----------------------------+------------------+--------+---------------------+
| rollback_count | first_execution            | last_execution             | duration_seconds | QPS    | check_time          |
+----------------+----------------------------+----------------------------+------------------+--------+---------------------+
|              6 | 2024-12-13 07:19:34.819200 | 2024-12-16 09:19:17.828338 |           266383 | 0.0000 | 2024-12-19 00:18:47 |
+----------------+----------------------------+----------------------------+------------------+--------+---------------------+
1 row in set (0.03 sec)
```

### Row Operation

```
mysql> select table_schema,table_name,total_latency,rows_fetched,rows_inserted,rows_updated,rows_deleted
    -> from sys.schema_table_statistics where table_schema = 'airportdb' limit 5;
+--------------+-------------+---------------+--------------+---------------+--------------+--------------+
| table_schema | table_name  | total_latency | rows_fetched | rows_inserted | rows_updated | rows_deleted |
+--------------+-------------+---------------+--------------+---------------+--------------+--------------+
| airportdb    | booking     | 5.87 h        |    462435671 |             0 |            0 |        40214 |
| airportdb    | test        | 1.59 h        |    152880971 |     100000001 |     72880930 |            0 |
| airportdb    | large_table | 1.68 min      |        10001 |         10002 |        10000 |            0 |
| airportdb    | passenger   | 52.08 s       |       175000 |             0 |            0 |            0 |
| airportdb    | confirm     |   0 ps        |            0 |             0 |            0 |            0 |
+--------------+-------------+---------------+--------------+---------------+--------------+--------------+
5 rows in set (0.02 sec)

mysql> select * from booking where booking_id = 1;
+------------+-----------+------+--------------+--------+
| booking_id | flight_id | seat | passenger_id | price  |
+------------+-----------+------+--------------+--------+
|          1 |      3863 | NULL |         2947 | 109.88 |
+------------+-----------+------+--------------+--------+
1 row in set (0.00 sec)

mysql> select table_schema,table_name,total_latency,rows_fetched,rows_inserted,rows_updated,rows_deleted
    -> from sys.schema_table_statistics where table_schema = 'airportdb' limit 5;
+--------------+-------------+---------------+--------------+---------------+--------------+--------------+
| table_schema | table_name  | total_latency | rows_fetched | rows_inserted | rows_updated | rows_deleted |
+--------------+-------------+---------------+--------------+---------------+--------------+--------------+
| airportdb    | booking     | 5.87 h        |    462435672 |             0 |            0 |        40214 |
| airportdb    | test        | 1.59 h        |    152880971 |     100000001 |     72880930 |            0 |
| airportdb    | large_table | 1.68 min      |        10001 |         10002 |        10000 |            0 |
| airportdb    | passenger   | 52.08 s       |       175000 |             0 |            0 |            0 |
| airportdb    | confirm     |   0 ps        |            0 |             0 |            0 |            0 |
+--------------+-------------+---------------+--------------+---------------+--------------+--------------+
5 rows in set (0.01 sec)
```
- 上記内容は以下でも確認可能 : 

```
select 
OBJECT_SCHEMA,OBJECT_NAME,COUNT_READ,COUNT_WRITE,COUNT_FETCH,
COUNT_INSERT,COUNT_UPDATE,COUNT_DELETE,
FORMAT_PICO_TIME(AVG_TIMER_READ) avg_read,FORMAT_PICO_TIME(AVG_TIMER_WRITE) avg_write,
FORMAT_PICO_TIME(AVG_TIMER_FETCH) avg_fetch,FORMAT_PICO_TIME(AVG_TIMER_INSERT) avg_insert,
FORMAT_PICO_TIME(AVG_TIMER_UPDATE) avg_update,FORMAT_PICO_TIME(AVG_TIMER_DELETE) avg_delete
from performance_schema.table_io_waits_summary_by_table
where OBJECT_SCHEMA = 'airportdb' limit 10;
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
