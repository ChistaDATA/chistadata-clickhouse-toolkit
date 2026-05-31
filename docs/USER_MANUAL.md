# ChistaDATA ClickHouse Toolkit — User Manual

**Version:** 1.0.0 | **License:** GPL-3.0 | **Copyright:** 2026 ChistaDATA, Inc.

---

## Table of Contents

1. Introduction
2. 2. Prerequisites
   3. 3. Installation
      4. 4. Module Reference
         5. 5. Troubleshooting Workflow
            6. 6. Contributing
               7. 7. License
                 
                  8. ---
                 
                  9. ## 1. Introduction
                 
                  10. The ChistaDATA ClickHouse Toolkit is a production-grade, open-source collection of diagnostic SQL scripts, monitoring configurations, Python agents, Prometheus alerting rules, and operational runbooks for ClickHouse deployments. It is designed for database administrators, site reliability engineers, and developers who operate ClickHouse in production environments.
                 
                  11. The toolkit is organized into eight modules, each targeting a specific operational domain. Modules 01 through 05 contain diagnostic SQL scripts that query ClickHouse system tables. Module 06 provides metrics collection tooling. Module 07 contains Prometheus alerting rules and operational runbooks. Module 08 provides deployment automation via Docker Compose.
                 
                  12. ---
                 
                  13. ## 2. Prerequisites
                 
                  14. Before using this toolkit, ensure the following are present in your environment:
                 
                  15. - ClickHouse server version 22.x or later
                      - - Access to clickhouse-client CLI or the HTTP interface on port 8123
                        - - Python 3.8 or later with pip (for the metrics polling agent in Module 06)
                          - - Docker and Docker Compose v2 (for the deployment stack in Module 08)
                            - - A ClickHouse user with SELECT permissions on system tables
                             
                              - ### Minimum Required ClickHouse Permissions
                             
                              - ```sql
                                GRANT SELECT ON system.* TO diagnostic_user;
                                GRANT KILL QUERY ON *.* TO diagnostic_user;
                                ```

                                ---

                                ## 3. Installation

                                ### Clone the Repository

                                ```bash
                                git clone https://github.com/ChistaDATA/chistadata-clickhouse-toolkit.git
                                cd chistadata-clickhouse-toolkit
                                ```

                                ### Install Python Agent Dependencies

                                ```bash
                                pip install clickhouse-driver
                                ```

                                ### Deploy the Full Monitoring Stack

                                ```bash
                                cd 08-deployment-scripts
                                docker compose up -d
                                ```

                                After deployment, the following services are accessible:

                                - ClickHouse HTTP API: http://localhost:8123
                                - - Prometheus: http://localhost:9090
                                  - - Grafana: http://localhost:3000 (default password: chistadata)
                                    - - Chadmin Admin Panel: http://localhost:8080
                                     
                                      - ---

                                      ## 4. Module Reference

                                      ### Module 01: Cluster Health

                                      File: 01-cluster-health/cluster_health.sql

                                      Run this module first in any troubleshooting session. It queries system.clusters for node liveness, system.metrics for active connection counts, system.settings and system.merge_tree_settings for configuration changes, system.events for cumulative event counters, system.asynchronous_metrics for CPU and memory metrics, and system.disks for disk free space.

                                      Usage: clickhouse-client --queries-file 01-cluster-health/cluster_health.sql

                                      ### Module 02: Query Diagnostics

                                      File: 02-query-diagnostics/query_diagnostics.sql

                                      Use this module when slow or failed queries are reported. It provides live query inspection via system.processes, historical slow query analysis from system.query_log, failed query investigation, memory consumption ranking, and per-minute throughput analysis.

                                      ### Module 03: Performance Profiling

                                      File: 03-performance-profiling/performance_profiling.sql

                                      This module uses ProfileEvents data from system.query_log to provide per-query CPU, I/O, and memory breakdowns. It also monitors background thread pool utilization and OS-level I/O wait metrics.

                                      Note: For stack-level CPU profiling, ensure query_profiler_real_time_period_ns is configured in ClickHouse settings.

                                      ### Module 04: Replication and Merges

                                      File: 04-replication-merges/replication_merges.sql

                                      Essential for diagnosing distributed ClickHouse deployments. Covers replication queue depth, replica health via system.replicas, active merge progress, merge history analysis, stuck mutations via system.mutations, and distributed DDL queue status.

                                      First steps when replication is suspected: check system.replicas for zookeeper_exception values, then check system.replication_queue for entries with high num_tries.

                                      ### Module 05: Storage and Parts

                                      File: 05-storage-parts/storage_parts.sql

                                      Provides visibility into ClickHouse storage. Key thresholds to monitor: more than 300 active parts per partition degrades performance; more than 1000 parts will throttle inserts; disk usage above 85% risks insert failures.

                                      ### Module 06: Metrics and Exporters

                                      Files: 06-metrics-exporters/chistadata_clickhouse_monitor.py, sql_exporter_config.yml

                                      The Python agent polls 9 key metrics every 15 seconds and prints them to stdout. Configure the CLICKHOUSE_CONFIG dictionary with your connection details. The SQL exporter YAML provides a ready-to-use configuration for burningalchemist/sql_exporter or justwatchcom/sql_exporter.

                                      ### Module 07: Alerting and Runbooks

                                      Files: 07-alerting-runbooks/clickhouse_alerts.yml, RUNBOOKS.md

                                      Contains 7 Prometheus alerting rules covering: instance down, high memory, low disk space, high part count, replication lag, elevated query failure rate, and stuck mutations. Runbooks cover 5 common failure scenarios with diagnosis queries and resolution steps.

                                      ### Module 08: Deployment Scripts

                                      File: 08-deployment-scripts/docker-compose.yml

                                      A complete Docker Compose stack with ClickHouse, Prometheus, Grafana (with ClickHouse plugin), and Chadmin. Start with: docker compose up -d

                                      ---

                                      ## 5. Recommended Troubleshooting Sequence

                                      When a ClickHouse incident is reported, follow this sequence:

                                      1. Cluster health first (Module 01): Confirm the node is reachable, check disk space and memory.
                                      2. 2. Running queries (Module 02): Look for runaway queries consuming memory or blocking resources.
                                         3. 3. Storage check (Module 05): Verify part counts and disk usage for affected tables.
                                            4. 4. Replication status (Module 04): For distributed clusters, check lag and merge queue.
                                               5. 5. Performance profile (Module 03): If the system is slow without obvious cause, profile query resource usage.
                                                  6. 6. Consult runbooks (Module 07): Match the symptom pattern to a runbook for a structured resolution.
                                                    
                                                     7. ---
                                                    
                                                     8. ## 6. Contributing
                                                    
                                                     9. Contributions are welcome. To contribute:
                                                    
                                                     10. 1. Fork the repository at https://github.com/ChistaDATA/chistadata-clickhouse-toolkit
                                                         2. 2. Create a feature branch
                                                            3. 3. Add SQL scripts, Python code, or documentation with the standard license header
                                                               4. 4. Test all SQL queries against ClickHouse 22.x or later
                                                                  5. 5. Open a pull request with a clear description
                                                                    
                                                                     6. Report issues at: https://github.com/ChistaDATA/chistadata-clickhouse-toolkit/issues
                                                                    
                                                                     7. ---
                                                                    
                                                                     8. ## 7. License
                                                                    
                                                                     9. This toolkit is distributed under the GNU General Public License v3.0 (GPL-3.0).
                                                                    
                                                                     10. This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or at your option any later version.
                                                                    
                                                                     11. See the LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for the full text.
                                                                    
                                                                     12. Copyright 2026 ChistaDATA, Inc. All rights reserved.
                                                                    
                                                                     13. ---
                                                                    
                                                                     14. For enterprise support and managed ClickHouse services, visit https://chistadata.com
