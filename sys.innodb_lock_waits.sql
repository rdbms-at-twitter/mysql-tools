CREATE 
    ALGORITHM = TEMPTABLE 
    DEFINER = `mysql.sys`@`localhost` 
    SQL SECURITY INVOKER
VIEW `innodb_lock_waits` AS
    SELECT 
        `r`.`trx_wait_started` AS `wait_started`,
        TIMEDIFF(NOW(), `r`.`trx_wait_started`) AS `wait_age`,
        TIMESTAMPDIFF(SECOND,
            `r`.`trx_wait_started`,
            NOW()) AS `wait_age_secs`,
        `rl`.`lock_table` AS `locked_table`,
        `rl`.`lock_index` AS `locked_index`,
        `rl`.`lock_type` AS `locked_type`,
        `r`.`trx_id` AS `waiting_trx_id`,
        `r`.`trx_started` AS `waiting_trx_started`,
        TIMEDIFF(NOW(), `r`.`trx_started`) AS `waiting_trx_age`,
        `r`.`trx_rows_locked` AS `waiting_trx_rows_locked`,
        `r`.`trx_rows_modified` AS `waiting_trx_rows_modified`,
        `r`.`trx_mysql_thread_id` AS `waiting_pid`,
        `sys`.`format_statement`(`r`.`trx_query`) AS `waiting_query`,
        `rl`.`lock_id` AS `waiting_lock_id`,
        `rl`.`lock_mode` AS `waiting_lock_mode`,
        `b`.`trx_id` AS `blocking_trx_id`,
        `b`.`trx_mysql_thread_id` AS `blocking_pid`,
        IF((`b`.`trx_mysql_thread_id` = CONNECTION_ID()),
            'Your connection is blocking',
            `sys`.`format_statement`(`b`.`trx_query`)) AS `blocking_query`,
        `bl`.`lock_id` AS `blocking_lock_id`,
        `bl`.`lock_mode` AS `blocking_lock_mode`,
        `b`.`trx_started` AS `blocking_trx_started`,
        TIMEDIFF(NOW(), `b`.`trx_started`) AS `blocking_trx_age`,
        `b`.`trx_rows_locked` AS `blocking_trx_rows_locked`,
        `b`.`trx_rows_modified` AS `blocking_trx_rows_modified`,
        CONCAT('KILL QUERY ', `b`.`trx_mysql_thread_id`) AS `sql_kill_blocking_query`,
        CONCAT('KILL ', `b`.`trx_mysql_thread_id`) AS `sql_kill_blocking_connection`
    FROM
        ((((`information_schema`.`innodb_lock_waits` `w`
        JOIN `information_schema`.`innodb_trx` `b` ON ((`b`.`trx_id` = `w`.`blocking_trx_id`)))
        JOIN `information_schema`.`innodb_trx` `r` ON ((`r`.`trx_id` = `w`.`requesting_trx_id`)))
        JOIN `information_schema`.`innodb_locks` `bl` ON ((`bl`.`lock_id` = `w`.`blocking_lock_id`)))
        JOIN `information_schema`.`innodb_locks` `rl` ON ((`rl`.`lock_id` = `w`.`requested_lock_id`)))
    ORDER BY `r`.`trx_wait_started`