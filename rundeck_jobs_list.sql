SELECT
id as 'ジョブID',
job_name as 'ジョブ名',
replace(replace(replace(description, '\r\n',''),'\r',''),'\n','') as 'ジョブ概要',
year as '年',day_of_month as '月次(日)',
month as '月',day_of_week as '日または曜日',
hour as '時',
minute as '分',
seconds as '秒',
next_execution as '次回実行時間',
case when execution_enabled=1 then '有効' else '無効' end as 'ジョブ有効・無効',
case when schedule_enabled=1  then '有効' else '無効' end as 'スケジュール有効・無効',
total_time '合計処理時間(ミリ秒)',round((total_time/1000)/60,2) '合計処理時間(分)'
FROM rundeck.scheduled_execution;