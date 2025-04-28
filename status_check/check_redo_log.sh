#!/bin/bash

MYSQL_USER="your_user"
MYSQL_PASS="your_password"
MySQL_HOST="Instance"

# First LSN
FIRST_LSN=$(mysql -h $MySQL_HOST -u $MYSQL_USER -p$MYSQL_PASS -e "pager grep sequence; show engine innodb status\G" | grep "Log sequence number" | awk '{print $NF}')

# Wait 60 seconds
sleep 60

# Second LSN
SECOND_LSN=$(mysql -h $MySQL_HOST -u $MYSQL_USER -p$MYSQL_PASS -e "pager grep sequence; show engine innodb status\G" | grep "Log sequence number" | awk '{print $NF}')

# Calculate difference
DIFF=$((SECOND_LSN - FIRST_LSN))

# Format the difference using FORMAT_BYTES
mysql -h $MySQL_HOST -u $MYSQL_USER -p$MYSQL_PASS -e "
WITH diff_calc AS (SELECT $DIFF AS bytes_diff)
SELECT CONCAT(FORMAT_BYTES(bytes_diff), ' (', bytes_diff, ' bytes)') AS redo_growth
FROM diff_calc;select page_type,count(*) from information_schema.innodb_buffer_page group by page_type;"
