-- Check Thread Variables on the MySQL Instace.
-- select * from performance_schema.variables_by_thread where VARIABLE_NAME in ('interactive_timeout','wait_timeout') and THREAD_ID = (SELECT THREAD_ID FROM performance_schema.threads where PROCESSLIST_ID = connection_id());
select * from performance_schema.variables_by_thread where THREAD_ID = (SELECT THREAD_ID FROM performance_schema.threads where PROCESSLIST_ID = connection_id());