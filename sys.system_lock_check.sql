CREATE 
    ALGORITHM = TEMPTABLE 
    DEFINER = `mysql.sys`@`localhost` 
    SQL SECURITY INVOKER
VIEW `system_lock_check` AS
    SELECT 
        `PT`.`PROCESSLIST_STATE` AS `PROCESSLIST_STATE`,
        `PE`.`THREAD_ID` AS `THREAD_ID`,
        `PE`.`SOURCE` AS `SOURCE`,
        `PE`.`EVENT_NAME` AS `EVENT_NAME`,
        `PE`.`TIMER_WAIT` AS `TIMER_WAIT`,
        `PE`.`LOCK_TIME` AS `LOCK_TIME`,
        `PE`.`CURRENT_SCHEMA` AS `CURRENT_SCHEMA`,
        `PE`.`SQL_TEXT` AS `SQL_TEXT`,
        (`PE`.`TIMER_WAIT` / 1000000000.0) AS `t (ms)`,
        `PE`.`ROWS_EXAMINED` AS `ROWS_EXAMINED`
    FROM
        (`performance_schema`.`events_statements_history` `PE`
        JOIN `performance_schema`.`threads` `PT`)
    WHERE
        ((`PE`.`THREAD_ID` = `PT`.`THREAD_ID`)
            AND (`PT`.`PROCESSLIST_STATE` = 'System lock'))
    ORDER BY `PE`.`TIMER_START` DESC