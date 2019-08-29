SELECT 
        left(SQL_TEXT,70) as 'Java Version', count(*)
FROM    performance_schema.events_statements_history where SQL_TEXT like '%java%'
GROUP BY left(SQL_TEXT,70) order by count(*) desc;

