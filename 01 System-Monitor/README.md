# 01 - System Monitor

A Bash-based Linux system monitoring tool that collects system information and generates HTML report.

The project is designed as a practical Bash scripting exercise. It starts with simple system information gathering and gradually develops into an automated monitoring solution with HTML reporting and scheduled execution.

## 🎯 Project Goal

The goal of this project is to create a Bash script that can monitor the basic health and resource usage of a Linux System.

The final version should be able to:
- [ ] Monitor CPU usage
- [ ] Monitor RAM usage
- [ ] Monitor disk usage
- [ ] Monitor network traffik
- [ ] Gathering basic information
- [ ] Generate an HTML reports
- [ ] Add timestamps to reports
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
- [ ] Display current user

** Commands to investigate **
- `hostname`
- `date`
- `uname`
- `uptime`
- `whoami`

### Phase 3 — CPU Monitoring

- [x] Detect number of CPU cores
- [ ] Read CPU information
- [x] Calculate CPU usage
- [ ] Read load average
- [ ] Display CPU information
- [ ] Create a CPU monitoring function

** Commands / files to investigate **
- `nproc`
- `lscpu`
- `top`
- `mpstat`
- `/proc/cpuinfo`
- `/proc/loadavg`