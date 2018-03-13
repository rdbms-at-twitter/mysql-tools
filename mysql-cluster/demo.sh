#!/bin/sh

# Please Set NDB Connection to your Management Node IP in Cluster Environment
export NDB_CONNECTSTRING=192.168.56.114:1186

echo "======================================================================"
echo " NDB API経由でMySQL Clusterへ接続しデータ処理します。                 "
echo "======================================================================"

java -classpath //mysql-cluster/share/java/clusterj-7.4.6.jar:. -Djava.library.path=/mysql-cluster/lib Main

