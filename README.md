<div align="center">

<img src="https://avatars.githubusercontent.com/u/78143980?s=200&v=4" alt="ChistaDATA Logo" width="100"/>

# ChistaDATA ClickHouse Toolkit

### The Production-Grade Observability & Diagnostics Suite for ClickHouse

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![ClickHouse](https://img.shields.io/badge/ClickHouse-v22%2B-yellow?logo=clickhouse)](https://clickhouse.com)
[![Maintained by ChistaDATA](https://img.shields.io/badge/Maintained%20by-ChistaDATA-blue)](https://chistadata.com)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/ChistaDATA/chistadata-clickhouse-toolkit/pulls)
[![GitHub Stars](https://img.shields.io/github/stars/ChistaDATA/chistadata-clickhouse-toolkit?style=social)](https://github.com/ChistaDATA/chistadata-clickhouse-toolkit/stargazers)

**Stop flying blind on your ClickHouse clusters.**  
A battle-tested collection of SQL diagnostics, shell scripts, Python agents, Prometheus rules, Grafana alerts, and one-command Docker stacks — purpose-built for engineers who run ClickHouse in production.

[Get Started](#-quick-start) · [Explore Modules](#-modules-in-depth) · [Read the Manual](docs/USER_MANUAL.md) · [Report a Bug](https://github.com/ChistaDATA/chistadata-clickhouse-toolkit/issues)

</div>

---

## Why This Toolkit?

Running ClickHouse at scale means constantly answering hard questions: *Why is this query slow? Is my replication queue growing? Which tables are eating all my disk? Is my cluster actually healthy right now?*

The **ChistaDATA ClickHouse Toolkit** gives you ready-to-run answers. It consolidates hundreds of hours of operational expertise into a single, structured repository — so your team spends less time writing diagnostics from scratch and more time fixing real problems.

- **Zero vendor lock-in** — pure SQL, Python, YAML, and Docker. Works with any ClickHouse deployment.
- - **Instant value** — clone and run. No build step, no compilation, no configuration ceremony.
  - - **Modular by design** — use one module or all eight. Each folder is self-contained.
    - - **Production-hardened** — queries target `system.*` tables used by ClickHouse engineers daily.
     
      - ---

      ## 📁 Repository Structure

      ```
      chistadata-clickhouse-toolkit/
      ├── 01-cluster-health/        # Node liveness, connections, settings drift
      ├── 02-query-diagnostics/     # Running queries, slow query analysis, kill scripts
      ├── 03-performance-profiling/ # CPU, memory, and I/O profiling via system tables
      ├── 04-replication-merges/    # Replication queue depth, replica health, mutations
      ├── 05-storage-parts/         # Table sizes, part counts, detached parts cleanup
      ├── 06-metrics-exporters/     # Python polling agent + sql_exporter config
      ├── 07-alerting-runbooks/     # Prometheus alert rules + operational runbooks
      ├── 08-deployment-scripts/    # Full Docker Compose stack (CH + Prometheus + Grafana)
      ├── docs/
      │   └── USER_MANUAL.md        # Comprehensive operational guide
      └── README.md
      ```

      ---

      ## ✨ Modules In Depth

      ### 🩺 Module 01 — Cluster Health

      **File:** `01-cluster-health/cluster_health.sql`

      The first thing you should run on any ClickHouse node you're not familiar with. This module gives you a complete snapshot of cluster state in seconds.

      **What it diagnoses:**
      - **Node Liveness** — queries `system.clusters` to surface every shard/replica, its host address, error count, slowdown count, and estimated recovery time. Spot a degraded replica the moment it starts misbehaving.
      - - **Active Connections** — breaks down TCP, HTTP, MySQL protocol, interserver, and file descriptor connections from `system.metrics`. Useful for capacity planning and detecting connection leaks.
        - - **Settings Drift** — shows every global setting and MergeTree setting that has been changed from its default via `system.settings` and `system.merge_tree_settings`. Critical for auditing clusters that have been tuned by multiple hands over time.
          - - **System Events Snapshot** — cumulative counters for queries, inserts, failed queries, network bytes, and merge activity from `system.events`. Your high-level throughput fingerprint.
            - - **Async Metrics** — uptime, database/table counts, total MergeTree rows and bytes, max partition part count, replica queue size, and memory usage from `system.asynchronous_metrics`.
              - - **Disk Free Space** — per-disk name, path, type, free/total space in human-readable format, and a `used_pct` percentage from `system.disks`. Sorted by utilization so the fullest disk is always first.
               
                - ```sql
                  -- Example: Check disk usage across all storage volumes
                  SELECT name, path, type,
                         formatReadableSize(free_space)  AS free_space,
                         formatReadableSize(total_space) AS total_space,
                         round((total_space - free_space) / total_space * 100, 2) AS used_pct
                  FROM system.disks ORDER BY used_pct DESC;
                  ```

                  ---

                  ### 🔍 Module 02 — Query Diagnostics

                  **Files:** `running_queries.sql`, `kill_queries.sql`, `slow_queries.sql`

                  When something is wrong with query performance, this module is your first responder. It surfaces exactly which queries are running, how long they've been running, and how to safely terminate the ones causing problems.

                  **What it diagnoses:**
                  - **Running Queries** — live view of `system.processes` with query text, elapsed time, memory usage, read rows/bytes, and the originating user and host.
                  - - **Slow Query History** — retrospective analysis from `system.query_log` to find the top offenders by duration, memory, or I/O in any time window.
                    - - **Kill Scripts** — templated `KILL QUERY` statements with safety filters so you can terminate runaway queries without guesswork.
                     
                      - ---

                      ### ⚡ Module 03 — Performance Profiling

                      **Files:** `cpu_profiler.sql`, `memory_profiler.sql`, `io_wait.sql`

                      Goes beyond query-level analysis to profile the ClickHouse process itself. Uses `system.trace_log`, `system.query_log`, and async metrics to identify hot code paths, memory-hungry operations, and I/O bottlenecks.

                      **Key capabilities:**
                      - CPU flame-graph data extraction via sampling profiler traces
                      - - Per-query peak memory allocation tracking
                        - - Merge and background operation overhead analysis
                          - - I/O wait attribution by table and partition
                           
                            - ---

                            ### 🔄 Module 04 — Replication & Merges

                            **Files:** `replication_queue.sql`, `replica_health.sql`, `mutations.sql`

                            Replication problems are silent until they're catastrophic. This module gives you early warning.

                            **What it monitors:**
                            - **Replication Queue Depth** — `system.replication_queue` entry counts per table, with oldest entry age. A growing queue with stale entries is a pre-failure signal.
                            - - **Replica Health** — `system.replicas` view showing is-leader status, inserts/merges in queue, last queue update, and total replicas. Instantly see which tables have unhealthy replicas.
                              - - **Mutations** — tracks in-progress and stuck `ALTER TABLE ... UPDATE/DELETE` mutations from `system.mutations`. Long-running mutations block merges and degrade performance.
                               
                                - ---

                                ### 💾 Module 05 — Storage & Parts

                                **Files:** `table_sizes.sql`, `part_count.sql`, `detached_parts.sql`

                                MergeTree storage health is fundamental to ClickHouse performance. Too many parts means slow reads; detached parts mean potential data loss risk.

                                **What it surfaces:**
                                - Table-level compressed and uncompressed sizes, row counts, and part counts from `system.tables` and `system.parts`
                                - - Partition-level breakdown for pinpointing storage hotspots
                                  - - Detached part inventory with size and reason — the starting point for any data recovery workflow
                                   
                                    - ---

                                    ### 📡 Module 06 — Metrics Exporter (Python Agent)

                                    **File:** `06-metrics-exporters/chistadata_clickhouse_monitor.py`

                                    A lightweight, dependency-minimal Python polling agent that connects to ClickHouse over the native protocol and emits human-readable metrics on a configurable interval. Designed for quick observability without standing up a full Prometheus stack first.

                                    **Metrics polled every 15 seconds (configurable):**

                                    | Metric | Source |
                                    |---|---|
                                    | Active Queries | `system.processes` |
                                    | Memory Tracking | `system.metrics` |
                                    | TCP Connections | `system.metrics` |
                                    | Replication Queue Depth | `system.replication_queue` |
                                    | Active Parts | `system.metrics` |
                                    | Total / Failed Queries (cumulative) | `system.events` |
                                    | Background Merges | `system.metrics` |
                                    | Avg Query Duration (last 60s) | `system.query_log` |

                                    ```python
                                    # Quickstart
                                    pip install clickhouse-driver
                                    python3 06-metrics-exporters/chistadata_clickhouse_monitor.py
                                    # Output:
                                    # --- 2026-06-01 14:32:01 ---
                                    #   Active Queries: 3 queries
                                    #   Memory Tracking (bytes): 847329280 bytes
                                    #   Replication Queue Depth: 0 entries
                                    #   Avg Query Duration (last 60s, ms): 42.7 ms
                                    ```

                                    The agent is intentionally simple: edit `CLICKHOUSE_CONFIG` at the top of the file to point at your cluster, and pipe output to any logging system (journald, Datadog, Splunk, etc.).

                                    ---

                                    ### 🚨 Module 07 — Alerting & Runbooks

                                    **File:** `07-alerting-runbooks/clickhouse_alerts.yml`

                                    Production-ready Prometheus alerting rules that cover the failure modes ClickHouse engineers encounter most. Drop this file into your Prometheus `rules/` directory and restart.

                                    **Alert rules included:**

                                    | Alert Name | Condition | Severity |
                                    |---|---|---|
                                    | `ClickHouseDown` | `up{job="clickhouse"} == 0` for 1m | critical |
                                    | `HighMemory` | Resident memory > 85% of total for 5m | warning |
                                    | `DiskLow` | Free disk space < 15% for 5m | warning |
                                    | `ReplicationLag` | Replication queue depth > 100 for 10m | warning |
                                    | `TooManyParts` | Active parts > 300 per partition for 10m | warning |
                                    | `HighQueryFailureRate` | Failed query rate > 5% over 5m | critical |

                                    Each alert is accompanied by a runbook entry in `RUNBOOKS.md` that explains the likely cause, immediate mitigation steps, and long-term remediation.

                                    ---

                                    ### 🚀 Module 08 — Deployment Stack

                                    **File:** `08-deployment-scripts/docker-compose.yml`

                                    One command stands up a complete ClickHouse observability environment locally or on a VM. No manual wiring required.

                                    **Stack components:**

                                    | Service | Image | Port | Purpose |
                                    |---|---|---|---|
                                    | `clickhouse` | `clickhouse/clickhouse-server:24.3-alpine` | 8123, 9000 | ClickHouse server |
                                    | `prometheus` | `prom/prometheus:v2.52.0` | 9090 | Metrics collection (30-day retention) |
                                    | `grafana` | `grafana/grafana:10.4.2` | 3000 | Dashboards + ClickHouse datasource plugin |
                                    | `chadmin` | `ghcr.io/chistadata/chadmin:latest` | 8080 | Web-based ClickHouse admin interface |

                                    All services are health-checked, share a private bridge network (`chistadata-network`), and use named volumes for persistence.

                                    ---

                                    ## 🚀 Quick Start

                                    ### Prerequisites

                                    - ClickHouse v22.x or later
                                    - - `clickhouse-client` or HTTP access to port 8123
                                      - - Python 3.8+ with `clickhouse-driver` (for the metrics agent)
                                        - - Docker and Docker Compose (for the full monitoring stack)
                                         
                                          - ### Option A — Full Monitoring Stack (Recommended)
                                         
                                          - ```bash
                                            git clone https://github.com/ChistaDATA/chistadata-clickhouse-toolkit.git
                                            cd chistadata-clickhouse-toolkit/08-deployment-scripts
                                            docker compose up -d
                                            ```

                                            Then open:
                                            - **Grafana** → http://localhost:3000 (admin / changeme)
                                            - - **Prometheus** → http://localhost:9090
                                              - - **chadmin** → http://localhost:8080
                                               
                                                - ### Option B — Run a Single Diagnostic
                                               
                                                - ```bash
                                                  # Cluster health snapshot
                                                  clickhouse-client --query "$(cat 01-cluster-health/cluster_health.sql)"

                                                  # Live slow query list
                                                  clickhouse-client --query "$(cat 02-query-diagnostics/slow_queries.sql)"

                                                  # Disk space check
                                                  clickhouse-client --query "$(cat 05-storage-parts/table_sizes.sql)"
                                                  ```

                                                  ### Option C — Start the Python Metrics Agent

                                                  ```bash
                                                  pip install clickhouse-driver
                                                  python3 06-metrics-exporters/chistadata_clickhouse_monitor.py
                                                  ```

                                                  ---

                                                  ## 📖 Documentation

                                                  Full operational documentation is available in [`docs/USER_MANUAL.md`](docs/USER_MANUAL.md), including:

                                                  - Detailed explanation of every SQL query and what to look for in the results
                                                  - - Step-by-step runbooks for common ClickHouse incidents
                                                    - - Prometheus and Grafana configuration guides
                                                      - - Extending the toolkit with your own diagnostic queries
                                                       
                                                        - ---

                                                        ## 🤝 Contributing

                                                        Contributions are warmly welcomed. Whether it's a new SQL diagnostic, an improved alert rule, a runbook entry, or a bug fix — all pull requests are reviewed promptly.

                                                        1. Fork the repository
                                                        2. 2. Create a feature branch: `git checkout -b feature/your-diagnostic-name`
                                                           3. 3. Add your files to the appropriate numbered module directory
                                                              4. 4. Update the module's `README` section if applicable
                                                                 5. 5. Open a pull request with a clear description of what problem it solves
                                                                   
                                                                    6. Please follow existing file naming conventions and include a comment header with the module name and license line.
                                                                   
                                                                    7. ---
                                                                   
                                                                    8. ## 🙏 Acknowledgements
                                                                   
                                                                    9. This toolkit stands on the shoulders of excellent open-source work:
                                                                   
                                                                    10. [ClickHouse/clickhouse_exporter](https://github.com/ClickHouse/clickhouse_exporter) · [duyet/clickhouse-monitoring](https://github.com/duyet/clickhouse-monitoring) · [uptrace/uptrace](https://github.com/uptrace/uptrace) · [chhetripradeep/chtop](https://github.com/chhetripradeep/chtop) · [bun4uk/chadmin](https://github.com/bun4uk/chadmin) · [burningalchemist/sql_exporter](https://github.com/burningalchemist/sql_exporter) · [metrico/gigapipe](https://github.com/metrico/gigapipe) · [oteldb/oteldb](https://github.com/oteldb/oteldb) · [mostafaghadimi/clickhouse](https://github.com/mostafaghadimi/clickhouse) · [Ajinkgupta/clickhouse-monitoring-stack](https://github.com/Ajinkgupta/clickhouse-monitoring-stack)
                                                                   
                                                                    11. ---
                                                                   
                                                                    12. ## 📄 License
                                                                   
                                                                    13. Distributed under the **GNU General Public License v3.0**. See [`LICENSE`](LICENSE) for the full text.
                                                                   
                                                                    14. ---
                                                                   
                                                                    15. <div align="center">

                                                                    Built with care by the [ChistaDATA](https://chistadata.com) engineering team.

                                                                    *Helping organizations run ClickHouse with confidence.*

                                                                    </div>
