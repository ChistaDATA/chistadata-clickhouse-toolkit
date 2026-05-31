#!/usr/bin/env python3
# ChistaDATA ClickHouse Toolkit | Module 06: Metrics Polling Agent
# License: GPL-3.0 | Copyright 2026 ChistaDATA, Inc.
# Inspired by: cansayin/Monitoring-ClickHouse-Metrics

import time
import sys
import clickhouse_driver

CLICKHOUSE_CONFIG = {
      'host': 'localhost',
      'port': 9000,
      'user': 'default',
      'password': '',
      'database': 'default',
      'connect_timeout': 10,
}

METRICS_QUERIES = [
      {'name': 'Active Queries',
            'query': 'SELECT count() FROM system.processes',
            'unit': 'queries'},
      {'name': 'Memory Tracking (bytes)',
            'query': "SELECT value FROM system.metrics WHERE metric = 'MemoryTracking'",
            'unit': 'bytes'},
      {'name': 'TCP Connections',
            'query': "SELECT value FROM system.metrics WHERE metric = 'TCPConnection'",
            'unit': 'connections'},
      {'name': 'Replication Queue Depth',
            'query': 'SELECT count() FROM system.replication_queue',
            'unit': 'entries'},
      {'name': 'Active Parts',
            'query': "SELECT value FROM system.metrics WHERE metric = 'PartsActive'",
            'unit': 'parts'},
      {'name': 'Total Queries (cumulative)',
            'query': "SELECT value FROM system.events WHERE event = 'Query'",
            'unit': 'queries'},
      {'name': 'Failed Queries (cumulative)',
            'query': "SELECT value FROM system.events WHERE event = 'FailedQuery'",
            'unit': 'queries'},
      {'name': 'Background Merges',
            'query': "SELECT value FROM system.metrics WHERE metric = 'BackgroundMergesAndMutationsPoolTask'",
            'unit': 'tasks'},
      {'name': 'Avg Query Duration (last 60s, ms)',
            'query': "SELECT round(avg(query_duration_ms), 2) FROM system.query_log WHERE type = 'QueryFinish' AND query_start_time >= now() - INTERVAL 60 SECOND",
            'unit': 'ms'},
]


def collect_metrics(conn):
      results = {}
      cursor = conn.cursor()
      for m in METRICS_QUERIES:
                try:
                              cursor.execute(m['query'])
                              row = cursor.fetchone()
                              value = row[0] if row and row[0] is not None else 0
                              results[m['name']] = (value, m['unit'])
except Exception as e:
            results[m['name']] = (f'ERROR: {e}', m['unit'])
    return results


def main(interval_seconds=15):
      print(f"[ChistaDATA] Connecting to {CLICKHOUSE_CONFIG['host']}:{CLICKHOUSE_CONFIG['port']}")
      try:
                conn = clickhouse_driver.connect(**CLICKHOUSE_CONFIG)
except Exception as e:
        print(f"[FATAL] Cannot connect: {e}")
        sys.exit(1)

    print(f"[ChistaDATA] Polling every {interval_seconds}s. Ctrl+C to stop.")
    while True:
              print(f"\n--- {time.strftime('%Y-%m-%d %H:%M:%S')} ---")
              for name, (value, unit) in collect_metrics(conn).items():
                            print(f"  {name}: {value} {unit}")
                        time.sleep(interval_seconds)


if __name__ == '__main__':
      main()
