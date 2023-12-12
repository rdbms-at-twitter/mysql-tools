#!/bin/bash

    ################################################################################
    # Please run this script 60 second during following period.
    #  (1) typical workload (2) During Peak workload 
    # Use this data for checking the instance status. 
    # convert epoch time ex: 
    # SQL: select from_unixtime(1701933453);  Shell date --date "@1701933453"
    ################################################################################
     
    # DATE=`date +"%s"`                                # Sets the EPOCH time
    FILE_DATE=`date +"%Y-%m-%d_%H-%M-%S"`              # Set File Nmae
    INSTANCE_ENDPOINT="<192.168.1.1>"                  # Specifys the instance ip or name
    USER="<user name>"                                 # username
    PWD="<password>"                                   # password 
    LOG_PATH=/tmp/database_check/$INSTANCE_ENDPOINT    # Create Log Directory (Please Modify Dir if required)
    FILE_EXTENTION1=".1st.log"
    FILE_EXTENTION2=".2nd.log"

    if [ ! -d $LOG_PATH ]; then
            mkdir -p $LOG_PATH/{globalvariables,globalstatus,enginestatus,processlist,innodbtrx,datalock} 
            echo "Finished to create log destination folders."

        # Get Instance variables
        mysql -h $INSTANCE_ENDPOINT -u $USER -p$PWD -Be "SHOW GLOBAL VARIABLES;" >> $LOG_PATH/globalvariables/$FILE_DATE


        # Start to obtain Instance Status
        mysql -h $INSTANCE_ENDPOINT -u $USER -p$PWD -Be "SHOW GLOBAL STATUS;" >> $LOG_PATH/globalstatus/$FILE_DATE$FILE_EXTENTION1
        mysql -h $INSTANCE_ENDPOINT -u $USER -p$PWD -e "SHOW ENGINE INNODB STATUS\G" >> $LOG_PATH/enginestatus/$FILE_DATE$FILE_EXTENTION1
        mysql -h $INSTANCE_ENDPOINT -u $USER -p$PWD -Be "select *,PS_THREAD_ID(ID) from performance_schema.processlist;" >> $LOG_PATH/processlist/$FILE_DATE$FILE_EXTENTION1
        mysql -h $INSTANCE_ENDPOINT -u $USER -p$PWD -Be "select * from information_schema.innodb_trx;" >> $LOG_PATH/innodbtrx/$FILE_DATE$FILE_EXTENTION1
        mysql -h $INSTANCE_ENDPOINT -u $USER -p$PWD -Be "select * from performance_schema.data_locks;" >> $LOG_PATH/datalock/$FILE_DATE$FILE_EXTENTION1

        echo 'First Loop is finised. Please wait 60 more seconds for next loop.'

        for I in {1..60}; do
           sleep 1
           BAR="$(yes . | head -n ${I} | tr -d '\n')"
           printf "\r[%3d/60] %s" $((I * 1)) ${BAR}
        done
        printf "\n"

        mysql -h $INSTANCE_ENDPOINT -u $USER -p$PWD -Be "SHOW GLOBAL STATUS;" >> $LOG_PATH/globalstatus/$FILE_DATE$FILE_EXTENTION2
        mysql -h $INSTANCE_ENDPOINT -u $USER -p$PWD -e "SHOW ENGINE INNODB STATUS\G" >> $LOG_PATH/enginestatus/$FILE_DATE$FILE_EXTENTION2
        mysql -h $INSTANCE_ENDPOINT -u $USER -p$PWD -Be "select *,PS_THREAD_ID(ID) from performance_schema.processlist;" >> $LOG_PATH/processlist/$FILE_DATE$FILE_EXTENTION2
        mysql -h $INSTANCE_ENDPOINT -u $USER -p$PWD -Be "select * from information_schema.innodb_trx;" >> $LOG_PATH/innodbtrx/$FILE_DATE$FILE_EXTENTION2
        mysql -h $INSTANCE_ENDPOINT -u $USER -p$PWD -Be "select * from performance_schema.data_locks;" >> $LOG_PATH/datalock/$FILE_DATE$FILE_EXTENTION2

        echo 'Finished to check the instance status. Thanks'

    else 
        echo "Folder is already exist. Please check it."
    fi