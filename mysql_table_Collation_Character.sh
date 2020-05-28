ELECT T.TABLE_SCHEMA,T.TABLE_NAME,T.TABLE_COLLATION,C.character_set_name FROM information_schema.`TABLES` T,
information_schema.`COLLATION_CHARACTER_SET_APPLICABILITY` C WHERE C.collation_name = T.table_collation 
AND CHARACTER_SET_NAME <> 'utf8mb4' and TABLE_SCHEMA NOT IN('mysql','information_schema','performance_schema','sys');
