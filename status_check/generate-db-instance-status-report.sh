#!/bin/bash

########################################################################################
# Please run this script after execute check-db-instance-status.sh.
# After execute this script, please download instance_status_final_report_w_diff.log.
# You will see status difference between 60 seconds.
########################################################################################

INSTANCE_ENDPOINT="<192.168.1.1>"                                         # Specifys the instance ip or name
LOG_PATH=/tmp/database_check/$INSTANCE_ENDPOINT                           # Create Log Directory (Please Modify Dir if required)
INSTANCE_STATUS_REPORT=instance_status_final_report.log                   # Final Report
INSTANCE_STATUS_REPORT_WITH_DIFF=instance_status_final_report_w_diff.log  # Check Diff between 2nd and 1st.

  folder_list=(globalstatus)
   i=0
    for generate_report in ${folder_list[@]}
    do

      echo "Start to generate report for ${generate_report}"
      diff $LOG_PATH/$generate_report/*.1st.log $LOG_PATH/$generate_report/*.2nd.log | grep '> ' | sed 's/> //' | awk {'print $1,"\t", $2'} > $LOG_PATH/$generate_report/2nd_status.log
      diff $LOG_PATH/$generate_report/*.2nd.log $LOG_PATH/$generate_report/*.1st.log | grep '> ' | sed 's/> //' | awk {'print $1,"\t", $2'} > $LOG_PATH/$generate_report/1st_status.log

      paste $LOG_PATH/$generate_report/1st_status.log $LOG_PATH/$generate_report/2nd_status.log > $LOG_PATH/$generate_report/$INSTANCE_STATUS_REPORT
      cat $LOG_PATH/$generate_report/$INSTANCE_STATUS_REPORT | awk '{print $1,"\t",$2,"\t",$4,"\t",($4 -$2)}' > $LOG_PATH/$generate_report/$INSTANCE_STATUS_REPORT_WITH_DIFF

      i=`expr $i+1`
    done

echo "Finish generating report. Thank you!!"