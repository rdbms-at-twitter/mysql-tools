create temporary table t1(c1 int primary key) engine=InnoDB;
select * from information_schema.innodb_temp_table_info;
show status like 'Created_tmp_disk_tables';
drop table t1;
select * from information_schema.innodb_temp_table_info;
