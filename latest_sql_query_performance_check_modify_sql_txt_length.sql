SELECT 
`THREAD_ID`,`EVENT_ID`,
DATE_ADD(SYSDATE(), INTERVAL - ((select Variable_value from sys.metrics where Variable_name = 'uptime') - TIMER_START*POW(10,-12)) SECOND) 'start_time',
DATE_ADD(SYSDATE(), INTERVAL - ((select Variable_value from sys.metrics where Variable_name = 'uptime') - TIMER_END*POW(10,-12)) SECOND) 'end_time',
replace(replace(replace(left(SQL_TEXT,20),'\)r\n',''),'\r',''),'\n','') as sql_text,
(`TIMER_WAIT` / 1000000000.0) AS `t (ms)`,
`ROWS_EXAMINED` AS `ROWS_EXAMINED`,
`ROWS_AFFECTED` AS `ROWS_AFFECTED`,
`ROWS_SENT` AS `ROWS_SENT`,
`CREATED_TMP_TABLES` AS `CREATED_TMP_TABLES`,
`CREATED_TMP_DISK_TABLES` AS `CREATED_TMP_DISK_TABLES`,
`SORT_MERGE_PASSES` AS `SORT_MERGE_PASSES`,
`NO_INDEX_USED` AS `NO_INDEX_USED`,
`NO_GOOD_INDEX_USED` AS `NO_GOOD_INDEX_USED`
FROM `performance_schema`.`events_statements_history` ORDER BY `TIMER_START` DESC limit 10;