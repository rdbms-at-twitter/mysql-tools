#!/usr/bin/env python
# -*- coding: utf-8 -*-

import re
from datetime import datetime
import argparse

class GeneralLogParser:
    def __init__(self, log_file):
        self.log_file = log_file
        self.queries = []
        self.query_stats = {}

    def parse_log(self):
        print("Parsing MySQL general log...")
        with open(self.log_file, 'r') as f:
            for line in f:
                try:
                    if 'Query' in line:
                        query_match = re.search(r'Query\s+(.*?)$', line)

                        if query_match:
                            query = query_match.group(1).strip()

                            exclude_starts = ('SET', 'BEGIN', 'COMMIT',
                                           'ROLLBACK', 'USE', 'START TRANSACTION')

                            if not query.startswith(exclude_starts):
                                self.queries.append(query)

                                if query in self.query_stats:
                                    self.query_stats[query] += 1
                                else:
                                    self.query_stats[query] = 1

                except Exception as e:
                    print("Error processing line: {}".format(e))
                    continue

    def preprocess_query(self, query):
        # LIKEクエリの特別処理は行わない
        return query

    def is_valid_query(self, query):
        """クエリの妥当性をチェックする補助メソッド"""
        # 空のクエリをチェック
        if not query.strip():
            return False

        # 基本的なSQLキーワードで始まるかチェック
        valid_starts = ('SELECT', 'INSERT', 'UPDATE', 'DELETE', 'SHOW', 'DESCRIBE', 'EXPLAIN')
        if not any(query.upper().startswith(keyword) for keyword in valid_starts):
            return False

        # 最小長をチェック
        if len(query.strip()) < 7:  # "SELECT" + 空白 + 何か
            return False

        return True

    def generate_sysbench_script(self, output_file):
        print("Generating sysbench script...")

        # ヘッダー部分
        header = """#!/usr/bin/env sysbench

require("oltp_common")

function prepare_statements()
   -- Prepare statements if needed
end

function thread_init()
    drv = sysbench.sql.driver()
    con = drv:connect()
end

function event()"""

        # フッター部分
        footer = """
end

function thread_done()
    con:disconnect()
end"""

        # クエリブロックの生成
        query_blocks = []
        for query in self.queries:
            # 空のクエリや不完全なクエリをスキップ
            if not query.strip() or query.strip().lower() == 'select':
                continue

            # クエリのバリデーション
            if self.is_valid_query(query):
                # クエリをそのままダブルブラケットで囲む
                query_blocks.append("    con:query([[{}]])".format(query))

        # 最終的なスクリプトの組み立て
        final_script = header + "\n" + "\n".join(query_blocks) + footer

        # ファイルへの書き込み
        with open(output_file, 'w') as f:
            f.write(final_script)

        print("Generated sysbench script: {}".format(output_file))
        print("Total unique queries: {}".format(len(self.query_stats)))
        print("Total query executions: {}".format(sum(self.query_stats.values())))

def main():
    parser = argparse.ArgumentParser(description='Convert MySQL general log to sysbench script')
    parser.add_argument('log_file', help='Path to MySQL general log file')
    parser.add_argument('output_file', help='Output sysbench script file')
    args = parser.parse_args()

    parser = GeneralLogParser(args.log_file)
    parser.parse_log()
    parser.generate_sysbench_script(args.output_file)

if __name__ == "__main__":
    main()
