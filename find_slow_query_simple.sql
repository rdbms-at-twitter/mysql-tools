SELECT trx.trx_id, trx.trx_started,trx.trx_mysql_thread_id,trx.trx_tables_in_use FROM INFORMATION_SCHEMA.INNODB_TRX trx WHERE trx.trx_started < CURRENT_TIMESTAMP - INTERVAL 60 SECOND;
