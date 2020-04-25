SELECT OBJECT_TYPE, OBJECT_SCHEMA, OBJECT_NAME, LOCK_TYPE, LOCK_STATUS,
THREAD_ID, PROCESSLIST_ID, PROCESSLIST_INFO
FROM performance_schema.metadata_locks
INNER JOIN performance_schema.threads ON THREAD_ID = OWNER_THREAD_ID
WHERE PROCESSLIST_ID <> CONNECTION_ID();