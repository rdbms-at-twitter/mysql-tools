#!/bin/bash

# Provide General Log File
if [ "$#" -ne 1 ]; then
    echo "Missing General Log. Usage: $0 general_log.log" >&2
    exit 1
fi

# Extract all queries and handle multi-line queries
awk '
    /Query/ {
        # Start collecting query
        if (in_query) {
            # If we were already collecting a query, print it
            print query ";"
        }
        in_query = 1
        match($0, /Query\s+(.*)/, arr)
        query = arr[1]
        next
    }
    in_query && /^[[:space:]]/ {
        # Continuation of query - remove leading whitespace
        sub(/^[[:space:]]+/, "")
        query = query " " $0
        next
    }
    in_query {
        # End of query reached
        print query ";"
        in_query = 0
        query = ""
    }
    END {
        # Print any remaining query
        if (in_query) {
            print query ";"
        }
    }
' "$1" | \
    # Clean up formatting
    sed 's/[[:space:]]\+/ /g' | \
    # Remove double semicolons
    sed 's/;;*/;/' > all_queries.sql

# Clean up the file
sed -i -e '/^$/d' -e 's/"//g' all_queries.sql

# Print the counts
echo "SELECT query counts:"
grep -i '^SELECT' all_queries.sql | sort -nr | wc -l
echo "INSERT query counts:"
grep -i '^INSERT' all_queries.sql | sort -nr | wc -l
echo "UPDATE query counts:"
grep -i '^UPDATE' all_queries.sql | sort -nr | wc -l
echo "DELETE query counts:"
grep -i '^DELETE' all_queries.sql | sort -nr | wc -l
