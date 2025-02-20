#!/bin/bash

# Provide General Log File
if [ "$#" -ne 1 ]; then
    echo "Missing General Log. Usage: $0 general_log.log" >&2
    exit 1
fi

# Extract all queries in order and clean up formatting
grep -i "Query\s\+" $1 | \
sed -n 's/.*Query\s\+\(SELECT\|INSERT\|UPDATE\|DELETE\).*$/\0/ip' | \
# In case of select Query Only for multi-threads testing.
# sed -n 's/.*Query\s\+\(SELECT\).*$/\0/ip' | \
sed -n 's/.*Query\s\+\(.*\)/\1/p' | \
sed 's/[[:space:]]\+/ /g' | \
# Put semi-colon if not.
sed 's/$/;/' > all_queries.sql

# Clean up the file
sed -i -e '/^$/d' -e 's/"//g' all_queries.sql
