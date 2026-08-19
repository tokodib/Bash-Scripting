# 01 - System Monitor

A Bash-based Linux system monitoring tool that collects system information and generates HTML report.

The project is designed as a practical Bash scripting exercise. It starts with simple system information gathering and gradually develops into an automated monitoring solution with HTML reporting and scheduled execution.

## 🎯 Project Goal

The goal of this project is to create a Bash script that can monitor the basic health and resource usage of a Linux System.

The final version should be able to:
- [x] Monitor CPU usage
- [x] Monitor RAM usage
- [ ] Monitor disk usage
- [ ] Monitor network traffik
- [x] Gathering basic information
- [ ] Generate an HTML reports
- [x] Add timestamps to reports
- [ ] Store generated reports
- [ ] Run automatically using `cron`
- [ ] Delete old reports

## 🗺️ Development Roadmap

### Phase 1 — Project Setup

- [x] Create project directory
- [x] Create README.md
- [x] Create initial monitor.sh
- [x] Add Bash shebang
- [x] Make the script executable
- [x] Create initial Git commit

### Phase 2 — Basic System Information

- [x] Display hostname
- [x] Display current date and time
- [x] Display operating system
- [x] Display kernel version
- [x] Display system uptime
- [x] Display current user

** Commands to investigate **
- `hostname`
- `date`
- `uname`
- `uptime`
- `whoami`

### Phase 3 — CPU Monitoring

- [x] Detect number of CPU cores
- [x] Read CPU information
- [x] Calculate CPU usage
- [x] Read load average
- [x] Display CPU information
- [x] Create a CPU monitoring function

** Commands / files to investigate **
- `nproc`
- `lscpu`
- `top`
- `mpstat`
- `/proc/cpuinfo`
- `/proc/loadavg`

### Phase 4 — RAM Monitoring

- [x] Detect total RAM
- [x] Detect used RAM
- [x] Detect available RAM
- [x] Calculate RAM usage percentage
- [x] Create a memory monitoring function
- [x] Total Swap
- [x] Used Swap
- [x] Free Swap

** Commands / files to investigate **
- `free`
