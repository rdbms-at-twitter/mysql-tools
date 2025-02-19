-- ～　MySQL5.7
SELECT 
table_schema as `Database`, 
table_name AS `Table`, 
round(((data_length + index_length) / 1024 / 1024), 2) `Size_in_MB`,
round((DATA_FREE/1024/1024),2) 'Free_in_MB',
(round((DATA_FREE/1024/1024),2)/round(((data_length + index_length) / 1024 / 1024), 2)) * 100 as 'Fragment(%)'
FROM information_schema.TABLES where table_schema = 'test' ORDER BY (data_length + index_length) desc limit 10;

-- MySQL 8.0 ～

SELECT 
table_schema as `Database`, 
table_name AS `Table`, 
FORMAT_BYTES(data_length)  `Size_in_MB`,
FORMAT_BYTES(index_length) 'Secondary_Index_in_MB',
FORMAT_BYTES(DATA_FREE)/FORMAT_BYTES(data_length + index_length) * 100 as 'Fragment(%)'
FROM information_schema.TABLES where table_schema = 'test' ORDER BY (data_length + index_length) desc limit 10;
