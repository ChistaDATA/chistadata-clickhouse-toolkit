-- ChistaDATA ClickHouse Toolkit | Module 04: Replication & Merges
-- License: GPL-3.0 | Copyright 2026 ChistaDATA, Inc.

-- 4.1 Replication Queue Backlog
SELECT
    database, table, count() AS queue_depth,
    sum(num_tries) AS total_retries,
    max(num_tries) AS max_retries,
    min(create_time) AS oldest_entry
FROM system.replication_queue
GROUP BY database, table
ORDER BY queue_depth DESC;

-- 4.2 Replica Health Overview
SELECT
    database, table, engine,
    is_leader, can_become_leader, is_readonly, is_session_expired,
    future_parts, parts_to_check,
    queue_size, inserts_in_queue, merges_in_queue,
    log_max_index - log_pointer AS replication_lag,
    total_replicas, active_replicas,
    last_queue_update, zookeeper_exception
FROM system.replicas
ORDER BY replication_lag DESC, queue_size DESC;

-- 4.3 Active Merges with Progress
SELECT
    database, table, num_parts, elapsed,
    round(progress * 100, 1) AS progress_pct,
    formatReadableSize(total_size_bytes_compressed) AS total_compressed,
    formatReadableSize(bytes_read_uncompressed) AS bytes_read,
    merge_type, merge_algorithm, result_part_name
FROM system.merges
ORDER BY elapsed DESC;

-- 4.4 Merge History (last 6 hours)
SELECT
    database, table,
    formatReadableSize(sum(size_in_bytes)) AS total_merged,
    count() AS merge_count,
    round(avg(duration_ms) / 1000.0, 2) AS avg_duration_sec,
    round(max(duration_ms) / 1000.0, 2) AS max_duration_sec
FROM system.part_log
WHERE event_type = 'MergeParts'
  AND event_time >= now() - INTERVAL 6 HOUR
GROUP BY database, table
ORDER BY total_merged DESC;

-- 4.5 In-Progress and Stuck Mutations
SELECT
    database, table, mutation_id, command, create_time,
    parts_to_do, is_done,
    latest_failed_part, latest_fail_time, latest_fail_reason
FROM system.mutations
WHERE is_done = 0
ORDER BY create_time ASC;

-- 4.6 Distributed DDL Queue
SELECT
    entry, host_name, host_address, port,
    status, exception_code, exception_text,
    query_finish_time, query_duration_ms
FROM system.distributed_ddl_queue
WHERE status != 'Finished'
ORDER BY entry DESC;
