#!/bin/bash

# Provide General Log File
# Ex : sh general_log_filter.sh /usr/local/mysql/data/general.log

if [ "$#" -ne 1 ]; then echo "Missing General Log. Usage: $0 <General Log File>" >&2 && exit 1; fi

# Filter Select Query from General Log

grep -i "select" $1 | sed -n 's/.*Query\s\+\(SELECT.*\)/\1/ip' > select_queries.sql
sed -i -e '/^$/d' -e 's/"//g' select_queries.sql

## If semi-colon is not required, please comment out the following line.
sed -i 's/$/;/' select_queries.sql

echo "Please check the generated file : select_queries.sql"
