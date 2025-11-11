#!/bin/bash

# MySQL TempStorageEngine 監視・アドバイススクリプト
# 使用方法: ./mysql_temp_storage_advisor.sh [mysql_options]

MYSQL_CMD="mysql $@"

echo "=== MySQL TempStorageEngine 利用状況分析 ==="
echo "実行時刻: $(date)"
echo

# 現在の設定値を取得
echo "--- 現在の設定 ---"
$MYSQL_CMD -e "
SELECT
    @@temptable_max_ram/1024/1024/1024 AS 'temptable_max_ram_GB',
    @@temptable_max_mmap/1024/1024/1024 AS 'temptable_max_mmap_GB',
    @@internal_tmp_mem_storage_engine AS 'tmp_storage_engine'
" 2>/dev/null

if [ $? -ne 0 ]; then
    echo "エラー: MySQLに接続できません"
    exit 1
fi

echo
echo "--- TempTable メモリ使用状況 ---"

# メモリ使用状況を取得してアドバイス
$MYSQL_CMD -e "
SELECT
    EVENT_NAME,
    COUNT_ALLOC,
    COUNT_FREE,
    format_bytes(SUM_NUMBER_OF_BYTES_ALLOC) AS SUM_ALLOC,
    format_bytes(SUM_NUMBER_OF_BYTES_FREE) AS SUM_FREE,
    CURRENT_COUNT_USED,
    format_bytes(CURRENT_NUMBER_OF_BYTES_USED) AS CURRENT_USED,
    HIGH_COUNT_USED,
    format_bytes(HIGH_NUMBER_OF_BYTES_USED) AS HIGH_USED
FROM performance_schema.memory_summary_global_by_event_name
WHERE EVENT_NAME LIKE 'memory/temptable%'
ORDER BY EVENT_NAME;
" 2>/dev/null

echo
echo "--- 分析とアドバイス ---"

# 設定値とメトリクスを取得してアドバイス生成
$MYSQL_CMD -N -e "
SELECT
    CONCAT('RAM上限: ', FORMAT(@@temptable_max_ram/1024/1024/1024, 2), ' GB') AS config_info
UNION ALL
SELECT
    CONCAT('MMAP上限: ', FORMAT(@@temptable_max_mmap/1024/1024/1024, 2), ' GB')
UNION ALL
SELECT
    CONCAT('ストレージエンジン: ', @@internal_tmp_mem_storage_engine)
UNION ALL
SELECT '---'
UNION ALL
SELECT
    CASE
        WHEN ram.HIGH_NUMBER_OF_BYTES_USED > @@temptable_max_ram * 0.8 THEN
            CONCAT('⚠️  RAM使用率が高い (', FORMAT(ram.HIGH_NUMBER_OF_BYTES_USED/@@temptable_max_ram*100, 1), '%) - temptable_max_ramの増加を検討')
        WHEN ram.HIGH_NUMBER_OF_BYTES_USED > @@temptable_max_ram * 0.6 THEN
            CONCAT('📊 RAM使用率: ', FORMAT(ram.HIGH_NUMBER_OF_BYTES_USED/@@temptable_max_ram*100, 1), '% - 監視継続')
        ELSE
            CONCAT('✅ RAM使用率: ', FORMAT(ram.HIGH_NUMBER_OF_BYTES_USED/@@temptable_max_ram*100, 1), '% - 正常範囲')
    END
FROM performance_schema.memory_summary_global_by_event_name ram
WHERE ram.EVENT_NAME = 'memory/temptable/physical_ram'
UNION ALL
SELECT
    CASE
        WHEN disk.HIGH_NUMBER_OF_BYTES_USED > 0 THEN
            CONCAT('🔴 ディスク使用検出 (最大: ', format_bytes(disk.HIGH_NUMBER_OF_BYTES_USED), ') - クエリ最適化またはRAM増加が必要')
        ELSE
            '✅ ディスク使用なし - 良好'
    END
FROM performance_schema.memory_summary_global_by_event_name disk
WHERE disk.EVENT_NAME = 'memory/temptable/physical_disk'
UNION ALL
SELECT '---'
UNION ALL
SELECT
    CASE
        WHEN @@internal_tmp_mem_storage_engine = 'MEMORY' THEN
            '💡 推奨: internal_tmp_mem_storage_engine=TempTable でパフォーマンス向上'
        ELSE
            '✅ TempTableエンジン使用中'
    END;
" 2>/dev/null

echo
echo "--- 推奨アクション ---"
echo "• 高RAM使用率の場合: SET GLOBAL temptable_max_ram = <新しい値>;"
echo "• ディスク使用の場合: クエリのJOIN/GROUP BY/ORDER BYを最適化"
echo "• 継続監視: このスクリプトを定期実行してトレンドを把握"
