CREATE TABLE `customer_test` (
  `customer_id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_group_id` int(11) NOT NULL,
  `customer_code` varchar(16) DEFAULT NULL,
  `last_name` varchar(20) NOT NULL,
  `first_name` varchar(20) NOT NULL,
  `last_name_kana` varchar(40) NOT NULL,
  `first_name_kana` varchar(40) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(128) NOT NULL,
  `birth_date` datetime DEFAULT NULL,
  `sex` tinyint(4) DEFAULT NULL COMMENT '0:不明, 1:男性, 2:女性',
  `case_sensitve` varchar(256)  COLLATE  utf8mb4_bin GENERATED ALWAYS AS (concat(last_name,first_name)) VIRTUAL,
  PRIMARY KEY (`customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;




insert into customer_test(customer_id,customer_group_id,customer_code,last_name,first_name,last_name_kana,first_name_kana,email,password,birth_date,sex) 
select customer_id,customer_group_id,customer_code,last_name,first_name,last_name_kana,first_name_kana,email,password,birth_date,sex from customer;


localhost [test]> insert into customer_test(customer_group_id,customer_code,last_name,first_name,last_name_kana,first_name_kana,email,password,birth_date,sex) 
    -> values(1,'00000001ABC','ABCDEF','GHIJK','カタカナ','ｶﾀｶﾅ','test@locondo.jp','password','1979-07-16 00:00:00',2);
Query OK, 1 row affected (0.00 sec)


localhost [test]> select * from customer_test where case_sensitve like 'ABCD%';
+-------------+-------------------+---------------+-----------+------------+----------------+-----------------+-----------------+----------+---------------------+------+---------------+
| customer_id | customer_group_id | customer_code | last_name | first_name | last_name_kana | first_name_kana | email           | password | birth_date          | sex  | case_sensitve |
+-------------+-------------------+---------------+-----------+------------+----------------+-----------------+-----------------+----------+---------------------+------+---------------+
|        3118 |                 1 | 00000001ABC   | ABCDEF    | GHIJK      | カタカナ       | ｶﾀｶﾅ            | test@locondo.jp | password | 1979-07-16 00:00:00 |    2 | ABCDEFGHIJK   |
+-------------+-------------------+---------------+-----------+------------+----------------+-----------------+-----------------+----------+---------------------+------+---------------+
1 row in set (0.01 sec)

localhost [test]> select * from customer_test where case_sensitve like 'abcd%';
Empty set (0.00 sec)
