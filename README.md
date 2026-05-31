# ChistaDATA ClickHouse Toolkit

> A production-grade, open-source toolkit for troubleshooting, diagnosing, and monitoring ClickHouse deployments.
>
> [![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
> [![Maintained by ChistaDATA](https://img.shields.io/badge/Maintained%20by-ChistaDATA-blue)](https://chistadata.com)
>
> ---
>
> ## Overview
>
> The **ChistaDATA ClickHouse Toolkit** is a comprehensive, community-driven collection of SQL diagnostic queries, shell scripts, Python agents, Prometheus exporter configurations, Grafana alerting rules, and Docker Compose deployment stacks, all purpose-built for ClickHouse observability and troubleshooting.
>
> This toolkit is built upon and inspired by leading open-source repositories including `ClickHouse/clickhouse_exporter`, `duyet/clickhouse-monitoring`, `uptrace/uptrace`, `chhetripradeep/chtop`, `burningalchemist/sql_exporter`, `bun4uk/chadmin`, `oteldb/oteldb`, `metrico/gigapipe`, and others.
>
> ---
>
> ## Repository Structure
>
> ```
> chistadata-clickhouse-toolkit/
> ├── 01-cluster-health/
> ├── 02-query-diagnostics/
> ├── 03-performance-profiling/
> ├── 04-replication-merges/
> ├── 05-storage-parts/
> ├── 06-metrics-exporters/
> ├── 07-alerting-runbooks/
> ├── 08-deployment-scripts/
> ├── docs/
> │   └── USER_MANUAL.md
> └── README.md
> ```
>
> ---
>
> ## Quick Start
>
> ### Prerequisites
>
> - ClickHouse v22.x or later
> - - `clickhouse-client` or HTTP access to port 8123
>   - - Python 3.8+ with `clickhouse-driver`
>     - - Docker and Docker Compose
>      
>       - ### One-Command Monitoring Stack
>      
>       - ```bash
>         git clone https://github.com/ChistaDATA/chistadata-clickhouse-toolkit.git
>         cd chistadata-clickhouse-toolkit/08-deployment-scripts
>         docker compose up -d
>         ```
>
> ### Run a Health Check
>
> ```bash
> clickhouse-client --query "$(cat 01-cluster-health/cluster_health.sql)"
> ```
>
> ### Start the Python Metrics Agent
>
> ```bash
> pip install clickhouse-driver
> python3 06-metrics-exporters/chistadata_clickhouse_monitor.py
> ```
>
> ---
>
> ## Modules at a Glance
>
> | Module | Focus Area | Key Files |
> |--------|-----------|----------|
> | 01 | Cluster Health | cluster_health.sql, disk_space.sql, async_metrics.sql |
> | 02 | Query Diagnostics | running_queries.sql, kill_queries.sql, slow_queries.sql |
> | 03 | Performance Profiling | cpu_profiler.sql, memory_profiler.sql, io_wait.sql |
> | 04 | Replication & Merges | replication_queue.sql, replica_health.sql, mutations.sql |
> | 05 | Storage & Parts | table_sizes.sql, part_count.sql, detached_parts.sql |
> | 06 | Metrics & Exporters | chistadata_clickhouse_monitor.py, sql_exporter_config.yml |
> | 07 | Alerting & Runbooks | clickhouse_alerts.yml, RUNBOOKS.md |
> | 08 | Deployment Scripts | docker-compose.yml, setup.sh |
>
> ---
>
> ## Acknowledgements
>
> This toolkit acknowledges the following open-source projects:
>
> - [ClickHouse/clickhouse_exporter](https://github.com/ClickHouse/clickhouse_exporter)
> - - [duyet/clickhouse-monitoring](https://github.com/duyet/clickhouse-monitoring)
>   - - [uptrace/uptrace](https://github.com/uptrace/uptrace)
>     - - [chhetripradeep/chtop](https://github.com/chhetripradeep/chtop)
>       - - [bun4uk/chadmin](https://github.com/bun4uk/chadmin)
>         - - [burningalchemist/sql_exporter](https://github.com/burningalchemist/sql_exporter)
>           - - [metrico/gigapipe](https://github.com/metrico/gigapipe)
>             - - [oteldb/oteldb](https://github.com/oteldb/oteldb)
>               - - [mostafaghadimi/clickhouse](https://github.com/mostafaghadimi/clickhouse)
>                 - - [Ajinkgupta/clickhouse-monitoring-stack](https://github.com/Ajinkgupta/clickhouse-monitoring-stack)
>                  
>                   - ---
>
> ## License
>
> Distributed under the **GNU General Public License v3.0 (GPL-3.0)**.
> See the [LICENSE](./LICENSE) file for the full license text.
>
> Copyright 2026 ChistaDATA, Inc. All rights reserved.
>
> ---
>
> *Built with care by the ChistaDATA engineering team.*
