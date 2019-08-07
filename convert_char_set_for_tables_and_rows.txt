/*** Check tables which tables charactor set is not utf8mb4 ***/
SELECT T.TABLE_SCHEMA,T.TABLE_NAME,T.TABLE_COLLATION,C.character_set_name FROM information_schema.`TABLES` T,
information_schema.`COLLATION_CHARACTER_SET_APPLICABILITY` C WHERE C.collation_name = T.table_collation 
AND CHARACTER_SET_NAME <> 'utf8mb4' and TABLE_SCHEMA NOT IN('mysql','information_schema','performance_schema','sys');

/*** Alter table convert charactor set to utf8mb4 ***/
select distinct(concat('alter tale ' ,T.TABLE_SCHEMA,'.',T.TABLE_NAME, ' convert to character set utf8mb4;')) as convert_query
from information_schema.`TABLES` T,information_schema.`COLLATION_CHARACTER_SET_APPLICABILITY` C WHERE C.collation_name = T.table_collation 
AND CHARACTER_SET_NAME <> 'utf8mb4' and TABLE_SCHEMA NOT IN('mysql','information_schema','performance_schema','sys');

/*** Alter table  for converting charactor set of rows to utf8mb4 ***/
select distinct(concat('alter tale ' ,TABLE_SCHEMA,'.',TABLE_NAME, ' convert to character set utf8mb4;')) as convert_query 
from information_schema.COLUMNS where CHARACTER_SET_NAME <> 'utf8mb4' 
and TABLE_SCHEMA NOT IN('mysql','information_schema','performance_schema','sys');
