#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Missing General Log. Usage: $0 <General Log File>" >&2
    exit 1
fi

awk '
BEGIN { query = ""; collecting = 0; }
/Query.*[Ss][Ee][Ll][Ee][Cc][Tt]/ {
    if (collecting == 1 && query != "") {
        printf "%s;\n", query
        query = ""
    }

    start = match($0, /[Ss][Ee][Ll][Ee][Cc][Tt]/)
    if (start) {
        remaining = substr($0, start)
        if (remaining ~ /.*;$/ || remaining ~ /^select.*limit[[:space:]]+[0-9]+$/ ||
            remaining ~ /^select[[:space:]]+@@/ || remaining ~ /^select[[:space:]]+USER\(\)/) {
            printf "%s;\n", remaining
        } else {
            query = remaining
            collecting = 1
        }
    }
    next
}
collecting == 1 {
    if ($0 ~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}T/) {
        if (query != "") {
            printf "%s;\n", query
            query = ""
            collecting = 0
        }
    } else if ($0 !~ /^Time/ && $0 !~ /^\/usr\/local/ && $0 !~ /^Tcp port/) {
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0)
        if ($0 != "") {
            if (length(query) > 0) {
                query = sprintf("%s\n%s", query, $0)
            } else {
                query = $0
            }
        }
    }
}
END {
    if (query != "") printf "%s;\n", query
}
' "$1" > select_queries.sql


GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}Please check the generated file : ${NC}select_queries.sql"
