CREATE 
    ALGORITHM = TEMPTABLE 
    DEFINER = `mysql.sys`@`localhost` 
    SQL SECURITY INVOKER
VIEW `check_current_query_performance` AS
    SELECT 
        `PE`.`THREAD_ID` AS `THREAD_ID`,
        `PE`.`SOURCE` AS `SOURCE`,
        `PE`.`EVENT_NAME` AS `EVENT_NAME`,
        `PE`.`TIMER_WAIT` AS `TIMER_WAIT`,
        `PE`.`LOCK_TIME` AS `LOCK_TIME`,
        `PE`.`CURRENT_SCHEMA` AS `CURRENT_SCHEMA`,
        `PE`.`SQL_TEXT` AS `SQL_TEXT`,
        (`PE`.`TIMER_WAIT` / 1000000000.0) AS `t (ms)`,
        `PE`.`ROWS_EXAMINED` AS `ROWS_EXAMINED`,
        `PT`.`PROCESSLIST_STATE` AS `PROCESSLIST_STATE`
    FROM
        (`performance_schema`.`events_statements_history` `PE`
        JOIN `performance_schema`.`threads` `PT`)
    WHERE
        (`PE`.`THREAD_ID` = `PT`.`THREAD_ID`)
    ORDER BY `PE`.`TIMER_START` DESC
    LIMIT 100