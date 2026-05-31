-- ChistaDATA ClickHouse Toolkit | Module 03: Performance Profiling
-- License: GPL-3.0 | Copyright 2026 ChistaDATA, Inc.

-- 3.1 Per-Query Resource Breakdown (last hour)
SELECT
    query_id, user, LEFT(query, 100) AS query_snippet,
    query_duration_ms,
    ProfileEvents['UserTimeMicroseconds'] / 1e6 AS user_cpu_sec,
    ProfileEvents['SystemTimeMicroseconds'] / 1e6 AS sys_cpu_sec,
    ProfileEvents['DiskReadElapsedMicroseconds'] / 1e6 AS disk_read_sec,
    ProfileEvents['DiskWriteElapsedMicroseconds'] / 1e6 AS disk_write_sec,
    ProfileEvents['NetworkReceiveBytes'] AS net_recv_bytes,
    formatReadableSize(memory_usage) AS peak_memory
FROM system.query_log
WHERE type = 'QueryFinish'
  AND query_start_time >= now() - INTERVAL 1 HOUR
ORDER BY query_duration_ms DESC LIMIT 20;

-- 3.2 Background Thread Pool Utilization
SELECT metric, value, description
FROM system.metrics
WHERE metric ILIKE '%Thread%'
   OR metric ILIKE '%Pool%'
   OR metric ILIKE '%Background%'
ORDER BY metric;

-- 3.3 OS-Level I/O Wait
SELECT metric, value
FROM system.asynchronous_metrics
WHERE metric ILIKE '%IO%'
   OR metric ILIKE '%Disk%'
   OR metric ILIKE '%Read%'
   OR metric ILIKE '%Write%'
ORDER BY metric;

-- 3.4 Memory Allocation Analysis (last 30 min)
SELECT
    query_id, user,
    formatReadableSize(memory_usage) AS peak_memory,
    formatReadableSize(ProfileEvents['MemoryAllocatorPurge']) AS purged,
    LEFT(query, 150) AS query_snippet
FROM system.query_log
WHERE type = 'QueryFinish'
  AND query_start_time >= now() - INTERVAL 30 MINUTE
ORDER BY memory_usage DESC LIMIT 15;
