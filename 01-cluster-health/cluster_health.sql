-- ChistaDATA ClickHouse Toolkit | Module 01: Cluster Health
-- License: GPL-3.0 | Copyright 2026 ChistaDATA, Inc.

-- Node Liveness
SELECT cluster, shard_num, replica_num, host_name,
       host_address, port, is_local, errors_count,
              slowdowns_count, estimated_recovery_time
              FROM system.clusters ORDER BY cluster, shard_num, replica_num;

              -- Active Connections
              SELECT metric, value FROM system.metrics
              WHERE metric IN ('TCPConnection','HTTPConnection','MySQLConnection',
                  'InterserverConnection','OpenFileForRead','OpenFileForWrite')
                  ORDER BY metric;

                  -- Changed Global Settings
                  SELECT name, value, changed, description, type
                  FROM system.settings WHERE changed = 1 ORDER BY name;

                  -- Changed MergeTree Settings
                  SELECT name, value, changed, description
                  FROM system.merge_tree_settings WHERE changed = 1 ORDER BY name;

                  -- System Events Snapshot
                  SELECT event, value, description FROM system.events
                  WHERE event IN ('Query','SelectQuery','InsertQuery','FailedQuery',
                      'FailedSelectQuery','FailedInsertQuery','NetworkReceiveBytes',
                          'NetworkSendBytes','MergedRows','MergedUncompressedBytes')
                          ORDER BY event;

                          -- Async Metrics (CPU, Memory, Uptime)
                          SELECT metric, value FROM system.asynchronous_metrics
                          WHERE metric IN ('Uptime','NumberOfDatabases','NumberOfTables',
                              'TotalRowsOfMergeTreeTables','TotalBytesOfMergeTreeTables',
                                  'MaxPartCountForPartition','ReplicasMaxQueueSize',
                                      'MemoryResident','MemoryVirtual')
                                      ORDER BY metric;

                                      -- Disk Free Space
                                      SELECT name, path, type,
                                          formatReadableSize(free_space) AS free_space,
                                              formatReadableSize(total_space) AS total_space,
                                                  round((total_space - free_space) / total_space * 100, 2) AS used_pct
                                                  FROM system.disks ORDER BY used_pct DESC;
