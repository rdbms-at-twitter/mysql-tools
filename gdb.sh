#!/bin/bash


# 注意：このコマンド実行中は他のプロセスがアクセス出来なくなります。
gdb -ex "set pagination 0" -ex "thread apply all bt" --batch -p $(pidof mysqld) 

