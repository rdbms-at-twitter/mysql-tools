#!/bin/bash

# Provide General Log File
if [ "$#" -ne 1 ]; then
    echo "Missing General Log. Usage: $0 general_log.log" >&2
    exit 1
fi

# Extract all queries and handle multi-line queries
awk '
    /Query.*SELECT|Query.*INSERT|Query.*UPDATE|Query.*DELETE/ {
        # Start collecting query
        in_query = 1
        match($0, /Query\s+(.*)/, arr)
        query = arr[1]
        next
    }
    in_query && /^[[:space:]]/ {
        # Continuation of query
        query = query " " $0
        next
    }
    in_query {
        # End of query reached
        print query
        in_query = 0
        query = ""
    }
' "$1" | \
    # Clean up formatting
    sed 's/[[:space:]]\+/ /g' | \
    # Put semi-colon if not
    sed 's/[;]*$/;/' > all_queries.sql

# Clean up the file
sed -i -e '/^$/d' -e 's/"//g' all_queries.sql
