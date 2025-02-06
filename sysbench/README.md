## Generate Sysbench Script from MySQL General Log


- Usage :  python convert_to_sysbench.py <general log> <target lua>

```
python convert_to_sysbench.py /usr/local/mysql/data/ip-172-31-102-178.log workload.lua
```


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
        read:                            15450
        write:                           0
        other:                           0
        total:                           15450
    transactions:                        1030   (102.11 per sec.)
    queries:                             15450  (1531.65 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

Throughput:
    events/s (eps):                      102.1102
    time elapsed:                        10.0871s
    total number of events:              1030

Latency (ms):
         min:                                   91.81
         avg:                                  195.40
         max:                                  476.70
         95th percentile:                      292.60
         sum:                               201257.12

Threads fairness:
    events (avg/stddev):           51.5000/0.67
    execution time (avg/stddev):   10.0629/0.02
```
