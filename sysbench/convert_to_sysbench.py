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

                            exclude_starts = ('SET', 'SHOW', 'BEGIN', 'COMMIT',
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

    def generate_sysbench_script(self, output_file):
        print("Generating sysbench script...")

        # ヘッダー部分
        header = """#!/usr/bin/env sysbench
require("sysbench")

sysbench.cmdline.options = {
    {
        ["name"] = "db-driver",
        ["type"] = "string",
        ["default"] = "mysql"
    },
    {
        ["name"] = "mysql-host",
        ["type"] = "string",
        ["default"] = "localhost"
    },
    {
        ["name"] = "mysql-user",
        ["type"] = "string",
        ["default"] = "root"
    },
    {
        ["name"] = "mysql-password",
        ["type"] = "string",
        ["default"] = ""
    },
    {
        ["name"] = "mysql-db",
        ["type"] = "string",
        ["default"] = "test"
    }
}

function thread_init()
    drv = sysbench.sql.driver()
    con = drv:connect()
end

function event()
"""

        # フッター部分
        footer = """
end

function thread_done()
    con:disconnect()
end
"""

        # クエリブロックの生成
        query_blocks = []
        for query in self.queries:
            escaped_query = query.replace("'", "\\'").replace('"', '\\"')
            query_blocks.append("    con:query([[{}]])".format(escaped_query))

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

