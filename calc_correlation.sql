select (( SUM( column1 * column2 ) - SUM( column1 ) * SUM( column2 ) / COUNT( column1 ) ) / COUNT( column2 )) / (STDDEV_POP(column1) * STDDEV_POP(column2)) as corr from table_name;
