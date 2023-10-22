SELECT 
      a.trx_id, 
      a.trx_mysql_thread_id,
      a.trx_state, 
      a.trx_started, 
      TIMESTAMPDIFF(SECOND,a.trx_started, now()) as "Transaction Open(Sec)", 
	  a.trx_tables_in_use,
	  a.trx_tables_locked,
	  a.trx_query,
      a.trx_rows_modified, 
      b.USER, 
      b.host, 
      b.db, 
      b.command, 
      b.time
FROM  information_schema.innodb_trx a 
inner join information_schema.processlist b on a.trx_mysql_thread_id=b.id
WHERE TIMESTAMPDIFF(SECOND,a.trx_started, now()) > 10
ORDER BY trx_started limit 3\G
