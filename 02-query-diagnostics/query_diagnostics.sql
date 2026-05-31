-- ChistaDATA ClickHouse Toolkit | Module 02: Query Diagnostics
-- License: GPL-3.0 | Copyright 2026 ChistaDATA, Inc.

-- 2.1 Currently Running Queries
SELECT
    query_id, user, client_hostname, elapsed,
    formatReadableSize(memory_usage) AS memory,
    read_rows, formatReadableSize(read_bytes) AS read_bytes,
    written_rows, query
FROM system.processes ORDER BY elapsed DESC;

-- 2.2 Kill a Runaway Query (replace query_id)
-- KILL QUERY WHERE query_id = '<query_id>' ASYNC;
-- KILL QUERY WHERE user = '<username>' ASYNC;
-- KILL QUERY WHERE elapsed > 300 ASYNC;

-- 2.3 Slow Queries - Last 24 Hours (Top 20)
SELECT
    query_id, user, query_start_time,
    round(query_duration_ms / 1000.0, 2) AS duration_sec,
    formatReadableSize(memory_usage) AS peak_memory,
    read_rows, formatReadableSize(read_bytes) AS read_bytes,
    exception_code, LEFT(query, 200) AS query_snippet
FROM system.query_log
WHERE type = 'QueryFinish'
  AND query_start_time >= now() - INTERVAL 24 HOUR
ORDER BY duration_sec DESC LIMIT 20;

-- 2.4 Failed Queries - Last 1 Hour
SELECT
    query_start_time, user, exception_code, exception,
    LEFT(query, 300) AS query_snippet, query_id
FROM system.query_log
WHERE type IN ('ExceptionBeforeStart','ExceptionWhileProcessing')
  AND query_start_time >= now() - INTERVAL 1 HOUR
ORDER BY query_start_time DESC LIMIT 50;

-- 2.5 Most Memory-Hungry Queries - Last 6 Hours
SELECT
    query_id, user, round(query_duration_ms/1000.0, 2) AS duration_sec,
    formatReadableSize(memory_usage) AS peak_memory,
    read_rows, LEFT(query, 200) AS query_snippet
FROM system.query_log
WHERE type = 'QueryFinish'
  AND query_start_time >= now() - INTERVAL 6 HOUR
ORDER BY memory_usage DESC LIMIT 20;

-- 2.6 Query Throughput Over Time (per minute)
SELECT
    toStartOfMinute(query_start_time) AS minute,
    countIf(type = 'QueryFinish') AS successful,
    countIf(type IN ('ExceptionBeforeStart','ExceptionWhileProcessing')) AS failed,
    round(avg(query_duration_ms), 1) AS avg_ms
FROM system.query_log
WHERE query_start_time >= now() - INTERVAL 1 HOUR
GROUP BY minute ORDER BY minute ASC;

-- 2.7 EXPLAIN Query Plan (replace with your query)
-- EXPLAIN PLAN SELECT 1;
-- EXPLAIN PIPELINE SELECT 1;
