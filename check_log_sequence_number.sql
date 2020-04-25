mysql -u root -p -e "show engine innodb status\G" | grep -A3 "Log sequence number"
