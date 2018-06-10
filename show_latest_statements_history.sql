CREATE 
    ALGORITHM = TEMPTABLE 
    DEFINER = `mysql.sys`@`localhost` 
    SQL SECURITY INVOKER
VIEW `sys`.`show_latest_statements_history` AS
    SELECT 
        `performance_schema`.`events_statements_history`.`SQL_TEXT` AS `SQL_TEXT`,
        (`performance_schema`.`events_statements_history`.`TIMER_WAIT` / 1000000000.0) AS `t (ms)`,
        `performance_schema`.`events_statements_history`.`ROWS_EXAMINED` AS `ROWS_EXAMINED`,
        `performance_schema`.`events_statements_history`.`ROWS_AFFECTED` AS `ROWS_AFFECTED`,
        `performance_schema`.`events_statements_history`.`ROWS_SENT` AS `ROWS_SENT`,
        `performance_schema`.`events_statements_history`.`CREATED_TMP_TABLES` AS `CREATED_TMP_TABLES`,
        `performance_schema`.`events_statements_history`.`CREATED_TMP_DISK_TABLES` AS `CREATED_TMP_DISK_TABLES`,
        `performance_schema`.`events_statements_history`.`SORT_MERGE_PASSES` AS `SORT_MERGE_PASSES`,
        `performance_schema`.`events_statements_history`.`NO_INDEX_USED` AS `NO_INDEX_USED`,
        `performance_schema`.`events_statements_history`.`NO_GOOD_INDEX_USED` AS `NO_GOOD_INDEX_USED`
    FROM
        `performance_schema`.`events_statements_history`
    ORDER BY `performance_schema`.`events_statements_history`.`TIMER_START` DESC
    LIMIT 10