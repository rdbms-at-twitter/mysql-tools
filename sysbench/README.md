## Generate Sysbench Script from MySQL General Log


- Usage :  python convert_to_sysbench.py <general log> <target lua>

```
python convert_to_sysbench.py /usr/local/mysql/data/ip-172-31-102-178.log workload.lua
```

- Example

```
# python convert_to_sysbench.py /usr/local/mysql/data/ip-172-31-102-178.log workload.lua
Parsing MySQL general log...
Generating sysbench script...
Generated sysbench script: workload.lua
Total unique queries: 14
Total query executions: 19
```

- Output (workload.lua)

```
#!/usr/bin/env sysbench

require("oltp_common")

function prepare_statements()
   -- Prepare statements if needed
end

function thread_init()
    drv = sysbench.sql.driver()
    con = drv:connect()
end

function event()
    con:query([[select @@global.general_log]])
    con:query([[select * from rental limit 10]])
    con:query([[select customer_id,count(*) total from rental group by customer_id order by total desc limit 19]])
    con:query([[select customer_id,count(*) total from rental group by customer_id order by total desc limit 10]])
    con:query([[show tables]])
    con:query([[select * from staff limit 10]])
    con:query([[show tables]])
    con:query([[select * from film limit 10]])
    con:query([[select * from film limit 1]])
    con:query([[select length,count(*) film_length from film group by length order by film_length desc limit 10]])
    con:query([[select length film_length from film group by length order by length desc limit 10]])
    con:query([[select @@version_comment limit 1]])
    con:query([[select USER()]])
    con:query([[show global variables like '%general%']])
    con:query([[show global variables like '%general%']])
end

function thread_done()
    con:disconnect()
end

```


## Run Sysbench

- Option (if LUA path is not configured)

```
export LUA_PATH="/home/user/workfolder/sysbench/src/lua/internal/?.lua;;"
```

- Run sysbench
  
```
$ /usr/local/bin/sysbench workload.lua \
> --db-driver=mysql \
> --mysql-host=<hostname> \
> --mysql-port=3306 \
--mysql-db=sakila \
> --mysql-user=admin \
> --mysql-password=$pass \
> --mysql-ssl=REQUIRED \
> --mysql-db=sakila \
> --threads=20 \
> run
sysbench 1.1.0-4228c85 (using bundled LuaJIT 2.1.0-beta3)

Running the test with following options:
Number of threads: 20
Initializing random number generator from current time


Initializing worker threads...

Threads started!

SQL statistics:
    queries performed:
        read:                            16275
        write:                           0
        other:                           0
        total:                           16275
    transactions:                        1085   (107.63 per sec.)
    queries:                             16275  (1614.52 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

Throughput:
    events/s (eps):                      107.6347
    time elapsed:                        10.0804s
    total number of events:              1085

Latency (ms):
         min:                                  108.56
         avg:                                  185.33
         max:                                  277.61
         95th percentile:                      215.44
         sum:                               201084.76

Threads fairness:
    events (avg/stddev):           54.2500/0.43
    execution time (avg/stddev):   10.0542/0.02

```
