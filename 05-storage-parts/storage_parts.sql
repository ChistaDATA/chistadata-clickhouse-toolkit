-- ChistaDATA ClickHouse Toolkit | Module 05: Storage & Parts
-- License: GPL-3.0 | Copyright 2026 ChistaDATA, Inc.

-- 5.1 Table Size Overview
SELECT
    database, table,
        sum(active) AS active_parts,
            sum(rows) AS total_rows,
                formatReadableSize(sum(bytes_on_disk)) AS on_disk,
                    formatReadableSize(sum(data_compressed_bytes)) AS compressed,
                        formatReadableSize(sum(data_uncompressed_bytes)) AS uncompressed,
                            round(sum(data_uncompressed_bytes) / sum(data_compressed_bytes), 2) AS compression_ratio
                            FROM system.parts
                            WHERE active = 1
                            GROUP BY database, table
                            ORDER BY sum(bytes_on_disk) DESC LIMIT 30;

                            -- 5.2 Parts Count Per Partition (Over-Partitioning Check)
                            SELECT
                                database, table, partition,
                                    count() AS part_count,
                                        sum(rows) AS total_rows,
                                            formatReadableSize(sum(bytes_on_disk)) AS partition_size
                                            FROM system.parts
                                            WHERE active = 1
                                            GROUP BY database, table, partition
                                            HAVING part_count > 100
                                            ORDER BY part_count DESC LIMIT 50;

                                            -- 5.3 Detached Parts
                                            SELECT
                                                database, table, name, disk, reason,
                                                    formatReadableSize(bytes_on_disk) AS size,
                                                        min_date, max_date
                                                        FROM system.detached_parts
                                                        ORDER BY bytes_on_disk DESC;

                                                        -- 5.4 Column-Level Compression Statistics
                                                        SELECT
                                                            database, table, column,
                                                                count() AS part_count,
                                                                    formatReadableSize(sum(column_data_compressed_bytes)) AS compressed,
                                                                        formatReadableSize(sum(column_data_uncompressed_bytes)) AS uncompressed,
                                                                            round(sum(column_data_uncompressed_bytes) / sum(column_data_compressed_bytes), 2) AS ratio
                                                                            FROM system.parts_columns
                                                                            WHERE active = 1
                                                                            GROUP BY database, table, column
                                                                            ORDER BY sum(column_data_compressed_bytes) DESC LIMIT 50;

                                                                            -- 5.5 Disk Usage Per Database
                                                                            SELECT
                                                                                database,
                                                                                    formatReadableSize(sum(bytes_on_disk)) AS total_on_disk,
                                                                                        formatReadableSize(sum(data_compressed_bytes)) AS total_compressed,
                                                                                            sum(rows) AS total_rows,
                                                                                                count() AS total_parts,
                                                                                                    count(DISTINCT table) AS total_tables
                                                                                                    FROM system.parts
                                                                                                    WHERE active = 1
                                                                                                    GROUP BY database
                                                                                                    ORDER BY sum(bytes_on_disk) DESC;
                                                                                                    
                                                                                                    -- 5.6 Part Log (last 1 hour)
                                                                                                    SELECT
                                                                                                        event_type, event_time, database, table, part_name,
                                                                                                            formatReadableSize(size_in_bytes) AS size,
                                                                                                                duration_ms, error, exception
                                                                                                                FROM system.part_log
                                                                                                                WHERE event_time >= now() - INTERVAL 1 HOUR
                                                                                                                ORDER BY event_time DESC LIMIT 100;
