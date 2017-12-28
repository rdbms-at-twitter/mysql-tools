/**** You can check your DDL statement progress status with MySQL ***/

/*** This value is disabled by default, please change configuration before executing an alter statement. ***/
UPDATE performance_schema.setup_instruments SET ENABLED = 'YES', TIMED = 'YES' WHERE NAME = 'stage/sql/altering table';
UPDATE performance_schema.setup_consumers SET ENABLED = 'YES' WHERE NAME LIKE '%stages%';
UPDATE performance_schema.setup_timers SET TIMER_NAME = 'MICROSECOND' WHERE NAME = 'stage';

/*** Execute Alter Statement Here ***/

/*** Monitor Status of the DDL ***/
SELECT EVENT_NAME, WORK_COMPLETED, WORK_ESTIMATED,(WORK_COMPLETED/WORK_ESTIMATED) * 100 as 'Complate %' FROM performance_schema.events_stages_history;
SELECT EVENT_NAME, WORK_COMPLETED, WORK_ESTIMATED,(WORK_COMPLETED/WORK_ESTIMATED) * 100 as 'Complate %' FROM performance_schema.events_stages_current;