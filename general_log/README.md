## Generate sql file for mysqlslap

- Generate a query file. (output: select_queries.sql )

```
$ sh general_log_filter.sh /usr/local/mysql/data/general.log
$ ls -l
total 8
-rw-rw-r-- 1 ec2-user ec2-user 419 Feb  4 09:11 general_log_filter.sh
-rw-r--r-- 1 ec2-user  ec2-user  570 Feb  4 09:12 select_queries.sql
$ cat select_queries.sql
select @@global.general_log;
select * from rental limit 10;
select customer_id,count(*) total from rental group by customer_id order by total desc limit 19;
select customer_id,count(*) total from rental group by customer_id order by total desc limit 10;
select * from staff limit 10;
select * from film limit 10;
select * from film limit 1;
select length,count(*) film_length from film group by length order by film_length desc limit 10;
select length film_length from film group by length order by length desc limit 10;
select @@version_comment limit 1;
select USER();
```




```
[root@ip-172-31-102-178 general_log]# /usr/local/mysql/bin/mysqlslap \
>   --concurrency=10 \
>   --iterations=1 \
>   --query=select_queries.sql \
>   --delimiter=";" \
>   --host=127.0.0.1 \
>   --user=admin \
>   --password=$pass \
>   --create-schema=sakila
mysqlslap: [Warning] Using a password on the command line interface can be insecure.
Benchmark
        Average number of seconds to run all queries: 0.174 seconds
        Minimum number of seconds to run all queries: 0.174 seconds
        Maximum number of seconds to run all queries: 0.174 seconds
        Number of clients running queries: 10
        Average number of queries per client: 11

[root@ip-172-31-102-178 general_log]#
```


## In case of using slow query log 


```
awk '/^select/,/;/ {if($0!~/^$/) printf "%s ", $0} /;/ {print ""}' slow_query.log | sed '/^$/d' | sed '/^select$/d' > select_queries.sql
```
