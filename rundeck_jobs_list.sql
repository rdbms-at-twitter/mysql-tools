SELECT
id as '�W���uID',
job_name as '�W���u��',
replace(replace(replace(description, '\r\n',''),'\r',''),'\n','') as '�W���u�T�v',
year as '�N',day_of_month as '����(��)',
month as '��',day_of_week as '���܂��͗j��',
hour as '��',
minute as '��',
seconds as '�b',
next_execution as '������s����',
case when execution_enabled=1 then '�L��' else '����' end as '�W���u�L���E����',
case when schedule_enabled=1  then '�L��' else '����' end as '�X�P�W���[���L���E����',
total_time '���v��������(�~���b)',round((total_time/1000)/60,2) '���v��������(��)'
FROM rundeck.scheduled_execution;