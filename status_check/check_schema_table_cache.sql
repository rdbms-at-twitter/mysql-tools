WITH cache_stats AS (
    SELECT
        ROUND((hits.VARIABLE_VALUE / (hits.VARIABLE_VALUE + misses.VARIABLE_VALUE)) * 100, 2) AS hit_ratio,
        gs1.VARIABLE_VALUE AS open_tables,
        gs2.VARIABLE_VALUE AS open_table_definitions,
        gs3.VARIABLE_VALUE AS opened_table_definitions,
        gs4.VARIABLE_VALUE AS cache_overflows,
        COUNT(DISTINCT th.OBJECT_SCHEMA) as active_schemas,
        (SELECT COUNT(*) FROM information_schema.SCHEMATA) as total_schemas,
        (SELECT COUNT(*) FROM information_schema.TABLES) as total_tables,
        COUNT(DISTINCT CONCAT(th.OBJECT_SCHEMA, '/', th.OBJECT_NAME)) as active_tablespaces,
        @@max_connections as max_connections,
        @@table_open_cache as table_open_cache,
        @@table_definition_cache as table_definition_cache,
        @@tablespace_definition_cache as tablespace_definition_cache,
        @@schema_definition_cache as schema_definition_cache
    FROM
        (SELECT VARIABLE_VALUE FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Table_open_cache_hits') hits,
        (SELECT VARIABLE_VALUE FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Table_open_cache_misses') misses,
        performance_schema.global_status gs1,
        performance_schema.global_status gs2,
        performance_schema.global_status gs3,
        performance_schema.global_status gs4,
        performance_schema.table_handles th
        JOIN information_schema.TABLES t ON th.OBJECT_SCHEMA = t.TABLE_SCHEMA AND th.OBJECT_NAME = t.TABLE_NAME
    WHERE
        gs1.VARIABLE_NAME = 'Open_tables'
        AND gs2.VARIABLE_NAME = 'Open_table_definitions'
        AND gs3.VARIABLE_NAME = 'Opened_table_definitions'
        AND gs4.VARIABLE_NAME = 'Table_open_cache_overflows'
        AND t.ENGINE = 'InnoDB'
)
SELECT
    parameter,
    current_value,
    actual_count,
    CASE
        WHEN parameter = 'table_open_cache' AND hit_ratio < 95
        THEN CONCAT('推奨: ', max_connections * 6)
        WHEN parameter = 'table_definition_cache' AND open_table_definitions >= table_definition_cache * 0.8
        THEN CONCAT('推奨: ', open_table_definitions * 2)
        WHEN parameter = 'tablespace_definition_cache' AND active_tablespaces >= tablespace_definition_cache * 0.8
        THEN CONCAT('推奨: ', GREATEST(256, active_tablespaces * 2))
        WHEN parameter = 'schema_definition_cache' AND active_schemas >= schema_definition_cache * 0.8
        THEN CONCAT('推奨: ', GREATEST(256, active_schemas * 2))
        ELSE '現状維持'
    END as recommendation,
    CASE
        WHEN parameter = 'table_open_cache'
        THEN CONCAT('ヒット率: ', hit_ratio, '%, オーバーフロー: ', cache_overflows)
        WHEN parameter = 'table_definition_cache'
        THEN CONCAT('使用率: ', ROUND((open_table_definitions/table_definition_cache)*100, 1), '%')
        WHEN parameter = 'tablespace_definition_cache'
        THEN CONCAT('使用率: ', ROUND((active_tablespaces/tablespace_definition_cache)*100, 1), '%')
        WHEN parameter = 'schema_definition_cache'
        THEN CONCAT('使用率: ', ROUND((active_schemas/schema_definition_cache)*100, 1), '%')
    END as status
FROM (
    SELECT 'table_open_cache' as parameter, table_open_cache as current_value, open_tables as actual_count, hit_ratio, cache_overflows, max_connections, table_definition_cache, open_table_definitions, tablespace_definition_cache, active_tablespaces, schema_definition_cache, active_schemas FROM cache_stats
    UNION ALL
    SELECT 'table_definition_cache', table_definition_cache, open_table_definitions, hit_ratio, cache_overflows, max_connections, table_definition_cache, open_table_definitions, tablespace_definition_cache, active_tablespaces, schema_definition_cache, active_schemas FROM cache_stats
    UNION ALL
    SELECT 'tablespace_definition_cache', tablespace_definition_cache, active_tablespaces, hit_ratio, cache_overflows, max_connections, table_definition_cache, open_table_definitions, tablespace_definition_cache, active_tablespaces, schema_definition_cache, active_schemas FROM cache_stats
    UNION ALL
    SELECT 'schema_definition_cache', schema_definition_cache, active_schemas, hit_ratio, cache_overflows, max_connections, table_definition_cache, open_table_definitions, tablespace_definition_cache, active_tablespaces, schema_definition_cache, active_schemas FROM cache_stats
) metrics;
