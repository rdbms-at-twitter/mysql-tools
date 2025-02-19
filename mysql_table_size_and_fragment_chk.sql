-- ～　MySQL5.7

SELECT 
    table_schema as `Database`, 
    table_name AS `Table`, 
    ROUND((data_length + index_length) / 1024 / 1024, 2) as 'Total_Size_MB',
    ROUND(data_length / 1024 / 1024, 2) as 'Data_Size_MB',
    ROUND(index_length / 1024 / 1024, 2) as 'Index_Size_MB',
    ROUND(DATA_FREE / 1024 / 1024, 2) as 'FreeSpace_MB',
    ROUND((DATA_FREE / (data_length + index_length)) * 100, 2) as 'Fragment_Pct'
FROM information_schema.TABLES 
WHERE table_schema = '<Schema Name>' 
ORDER BY (data_length + index_length) DESC 
LIMIT 10;

-- MySQL 8.0 ～

SELECT 
table_schema as `Database`, 
table_name AS `Table`, 
FORMAT_BYTES(data_length + index_length) 'Total_Size',
FORMAT_BYTES(data_length) 'Data_Size',
FORMAT_BYTES(index_length) 'Index_Size',
FORMAT_BYTES(DATA_FREE) 'FreeSpace',
ROUND((DATA_FREE / (data_length + index_length)) * 100, 2) as 'Fragment_Pct'
FROM information_schema.TABLES 
where table_schema = '<Schema Name>' 
ORDER BY (data_length + index_length) desc 
limit 10;
