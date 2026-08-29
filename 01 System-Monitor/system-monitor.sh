#! /bin/bash
#====================================================
# System monitor dashboard
# CPU, System informations
#====================================================

# --- Settings and Variables ---

#====================================================
# Configuration
#====================================================

REPORT_DIR="reports" 
REPORT_FILE="$REPORT_DIR/system_report_$(date +%Y%m%d_%H%M).html"
LATEST_LINK="$REPORT_DIR/index.html"
LOG_DIR="logs"
LOG_FILE="$LOG_DIR/monitor.log"
HISTORY_FILE="$LOG_DIR/history.csv"
RETENTION_DAYS=30
INTERFACE=$(ip route | awk '/default/ {print $5; exit}')

mkdir -p "$REPORT_DIR" "$LOG_DIR"

log() {
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

#====================================================
# CPU
#====================================================

get_cpu_data() {
	CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
	CPU_USAGE=${CPU_USAGE:-0}

	CPU_CORES=$(nproc)

	LOAD_1=$(cut -d' ' -f1 /proc/loadavg)
	LOAD_5=$(cut -d' ' -f2 /proc/loadavg)
	LOAD_15=$(cut -d' ' -f3 /proc/loadavg)

	CPU_MODEL=$(grep "model name"  /proc/cpuinfo | head -1 | cut -d":" -f2 | sed 's/^ *//')

	#TOP_CPU=$(ps aux --sort=-%cpu | head -6 | awk 'NR>1 {printf "<tr><td>%s</td><td>%s</td><td>%.1f%%</td><td>%s</td></tr>", $1, $2, $3, $11}')
	TOP_CPU=$(ps aux --sort=-%cpu | head -6 | awk 'NR>1 {printf "%s \t%s \t%.1f%% \t%s\n", $1, $2, $3, $11}')
}
#====================================================
# System informations
#====================================================
get_system_info() {
	HOSTNAME=$(hostname)
	UPTIME=$(uptime -p)
	KERNEL=$(uname -r)
	OS=$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)
	TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
	USER=$(whoami)
}
#====================================================
# RAM
#====================================================
get_ram_data() {
	MEM_TOTAL=$(free -m | awk '/^Mem:/{print $2}')	
	MEM_USED=$(free -m | awk '/^Mem:/{print $3}')	
	MEM_FREE=$(free -m | awk '/^Mem:/{print $4}')	
 	MEM_AVAILABLE=$(free -m | awk '/^Mem:/{print $7}')
 	MEM_BUFFERS=$(free -m | awk '/^Mem:/{print $6}')	
 	MEM_PERCENT=$(awk "BEGIN {printf \"%.1f\", ($MEM_USED/$MEM_TOTAL)*100}")
 	#SWAP 
 	SWAP_TOTAL=$(free -m | awk '/^Swap:/{print $2}')	
 	SWAP_USED=$(free -m | awk '/^Swap:/{print $3}')	
 	SWAP_FREE=$(free -m | awk '/^Swap:/{print $4}')	
 	SWAP_PERCENT="0"
 	if [ "$SWAP_TOTAL" -gt 0 ]; then
 		SWAP_PERCENT=$(awk "BEGIN {printf \"%.1f\", ($SWAP_USED/$SWAP_TOTAL)*100}")
 	fi
	TOP_RAM=$(ps aux --sort=-%mem | head -6 | awk 'NR>1 {printf "%s\t%s\t%.1f%%\t%s MB\t%s\n", $1, $2, $4, int($6/1024), $11}')
}
#====================================================
# Network informations
#====================================================
get_network_data() {
    INTERFACE=${INTERFACE:-eth0}
    
    # Measuring 
    RX1=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes 2>/dev/null || echo 0)
    TX1=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes 2>/dev/null || echo 0)
    sleep 1
    RX2=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes 2>/dev/null || echo 0)
    TX2=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes 2>/dev/null || echo 0)
    
    
    RX_SPEED=$(awk "BEGIN {printf \"%.2f\", ($RX2-$RX1)/1024}")
    TX_SPEED=$(awk "BEGIN {printf \"%.2f\", ($TX2-$TX1)/1024}")
    
    # Total
    RX_TOTAL=$(awk "BEGIN {printf \"%.2f\", $RX2/1024/1024/1024}")   # GB
    TX_TOTAL=$(awk "BEGIN {printf \"%.2f\", $TX2/1024/1024/1024}")   # GB
    
    # Number of connections
    CONNECTIONS=$(ss -tuln | wc -l)
    
    # Open ports
    OPEN_PORTS=$(ss -tuln | awk 'NR>1 {printf "%s\t%s\t%s\n", $1, $5, $6}')
    
    # Network interfaces
    INTERFACES=$(ip -s link show | grep -E '^[0-9]+:' | awk '{print $2}' | sed 's/://')
    
}

#====================================================
# GENERATE HTML report
#====================================================
cat > "$REPORT_FILE" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>System Monitor Report - HOSTNAME_PLACEHOLDER</title>
    </head>
    <body>
        <h1>System Monitor Report</h1>
        <h2>Hostname: HOSTNAME_PLACEHOLDER</h2>
		<h3>Report generated on: DATE_PLACEHOLDER</h3>
        <p>Uptime: UPTIME_PLACEHOLDER</p>
        <p>OS: OS_PLACEHOLDER</p>
        <p>Kernel: KERNEL_PLACEHOLDER</p>
        <p>User: USER_PLACEHOLDER</p>

        <h2>CPU Information</h2>
        <p>CPU name: CPU_NAME_PLACEHOLDER</p>
        <p>CPU Usage: CPU_USAGE_PLACEHOLDER%</p>
        <p>CPU Core: CPU_CORE_PLACEHOLDER</p>
        <p>Load average 1 min: LOAD_AVERAGE_1_MIN_PLACEHOLDER%</p>
        <p>Load average 5 min: LOAD_AVERAGE_5_MIN_PLACEHOLDER%</p>
        <p>Load average 15 min: LOAD_AVERAGE_15_MIN_PLACEHOLDER%</p>
        <p>TOP 5 processes: TOP_5_PROCESSES_PLACEHOLDER</p>

        <h2>Memory Information</h2>
        <p>Total Memory: TOTAL_MEMORY_PLACEHOLDER MB</p>
        <p>Used Memory: USED_MEMORY_PLACEHOLDER MB</p>
        <p>Free Memory: FREE_MEMORY_PLACEHOLDER MB</p>
        <p>Available Memory: AVAILABLE_MEMORY_PLACEHOLDER MB</p>
        <p>Buffered Memory: BUFFERED_MEMORY_PLACEHOLDER MB</p>
        <p>Used Memory (%): USED_MEMORY_PERCENTAGE_PLACEHOLDER%</p>
        <p>TOP 5 Memory Processes: TOP_5_MEMORY_PROCESSES_PLACEHOLDER</p>
        
        <h2>Swap Information</h2>
        <p>Total Swap: TOTAL_SWAP_PLACEHOLDER MB</p>
        <p>Used Swap: USED_SWAP_PLACEHOLDER MB</p>
        <p>Free Swap: FREE_SWAP_PLACEHOLDER MB</p>
        <p>Percentage Swap (%): PERCENTAGE_SWAP_PLACEHOLDER%</p>

        <h2>Disk Usage</h2>
        <p>Total Disk Space: TOTAL_DISK_PLACEHOLDER GB</p>
        <p>Used Disk Space: USED_DISK_PLACEHOLDER GB</p>
        <p>Free Disk Space: FREE_DISK_PLACEHOLDER GB</p>

        <h2>Network Information</h2>
        <p>Default interface: DEFAULT_INTERFACE_PLACEHOLDER</p>
        <p>RX Speed: RX_SPEED_PLACEHOLDER Mbps</p>
        <p>TX Speed: TX_SPEED_PLACEHOLDER Mbps</p>
        <p>RX Total: RX_TOTAL_PLACEHOLDER MB</p>
        <p>TX Total: TX_TOTAL_PLACEHOLDER MB</p>

        <p>Connections: CONNECTIONS_PLACEHOLDER</p>
        <p>Open ports: OPEN_PORTS_PLACEHOLDER</p>
        <p>Interfaces: INTERFACES_PLACEHOLDER</p>


        <footer>
            <br>
            <p>&copy; 2026 System Monitor - TokodiB</p>
        </footer>
	</body>
</html>
HTMLEOF


#====================================================
# Print System informations
#====================================================

echo "Report properities:"
echo "REPORT_DIR : $REPORT_DIR" 
echo "REPORT_FILE : $REPORT_FILE" 
echo "LATEST_LINK : $LATEST_LINK" 
echo "LOG_DIR : $LOG_DIR" 
echo "LOG_FILE : $LOG_FILE"
echo "HISTORY_FILE : $HISTORY_FILE" 
echo "RETENTION_DAYS : $RETENTION_DAYS"
echo "DEFAULT INTERFACE: $INTERFACE" 

get_cpu_data
echo -e "\nCPU Info:"
echo "CPU name: $CPU_MODEL"
echo "CPU usage : $CPU_USAGE %"
echo "CPU cores : $CPU_CORES"
echo "Load average 1min : $LOAD_1"
echo "Load average 5min : $LOAD_5"
echo "Load average 15min : $LOAD_15"

echo -e "\nTOP 5 CPU load:"
echo "USER 	PID 	USE 	APP"
echo "$TOP_CPU"

get_ram_data
echo -e "\nMemory info:"
echo "Total memory : $MEM_TOTAL Mbyte"
echo "Used memory : $MEM_USED Mbyte"
echo "Memory Free : $MEM_FREE Mbyte"
echo "Memory Available : $MEM_AVAILABLE Mbyte"
echo "Memory Buffer : $MEM_BUFFERS Mbyte"
echo "Memory used (%) : $MEM_PERCENT %"

echo -e "\nSwap info:" 
echo "Total Swap : $SWAP_TOTAL Mbyte"
echo "Used Swap : $SWAP_USED Mbyte"
echo "Free Swap : $SWAP_FREE Mbyte"
echo "Percent Swap : $SWAP_PERCENT %"

echo -e "\nTOP 5 RAM load:"
echo "USER 	PID 	MEM% 	USE 	APP"
echo "$TOP_RAM"

get_network_data
echo -e "\nNetwork informations:"
echo "RX Speed: $RX_SPEED"
echo "TX Speed: $TX_SPEED"
echo "RX Total: $RX_TOTAL"
echo "TX Total: $TX_TOTAL"
echo -e "\nConnections : \n$CONNECTIONS"
echo -e "\nOpen Ports : \n$OPEN_PORTS"
echo -e "\nInterfaces : \n$INTERFACES"


get_system_info

echo -e "\nSystem info:"
echo "Hostname: $HOSTNAME"
echo "Uptime: $UPTIME"
echo "OS: $OS"
echo "Kernel: $KERNEL"
echo "User: $USER"
echo "Generated: $TIMESTAMP"

#====================================================
# Change placeholders in the HTML report
#====================================================
sed -i "s/HOSTNAME_PLACEHOLDER/$HOSTNAME/g" "$REPORT_FILE"
sed -i "s/DATE_PLACEHOLDER/$TIMESTAMP/g" "$REPORT_FILE"
sed -i "s/UPTIME_PLACEHOLDER/$UPTIME/g" "$REPORT_FILE"
sed -i "s/OS_PLACEHOLDER/$OS/g" "$REPORT_FILE"
sed -i "s/KERNEL_PLACEHOLDER/$KERNEL/g" "$REPORT_FILE"
sed -i "s/USER_PLACEHOLDER/$USER/g" "$REPORT_FILE"
sed -i "s/CPU_NAME_PLACEHOLDER/$CPU_MODEL/g" "$REPORT_FILE"
sed -i "s/CPU_USAGE_PLACEHOLDER/$CPU_USAGE/g" "$REPORT_FILE"
sed -i "s/CPU_CORE_PLACEHOLDER/$CPU_CORES/g" "$REPORT_FILE"
sed -i "s/LOAD_AVERAGE_1_MIN_PLACEHOLDER/$LOAD_1/g" "$REPORT_FILE"
sed -i "s/LOAD_AVERAGE_5_MIN_PLACEHOLDER/$LOAD_5/g" "$REPORT_FILE"
sed -i "s/LOAD_AVERAGE_15_MIN_PLACEHOLDER/$LOAD_15/g" "$REPORT_FILE"

sed -i "s/TOTAL_MEMORY_PLACEHOLDER/$MEM_TOTAL/g" "$REPORT_FILE"
sed -i "s/USED_MEMORY_PLACEHOLDER/$MEM_USED/g" "$REPORT_FILE"
sed -i "s/FREE_MEMORY_PLACEHOLDER/$MEM_FREE/g" "$REPORT_FILE"
sed -i "s/AVAILABLE_MEMORY_PLACEHOLDER/$MEM_AVAILABLE/g" "$REPORT_FILE"
sed -i "s/BUFFERED_MEMORY_PLACEHOLDER/$MEM_BUFFERS/g" "$REPORT_FILE"
sed -i "s/USED_MEMORY_PERCENTAGE_PLACEHOLDER/$MEM_PERCENT/g" "$REPORT_FILE"
sed -i "s/TOTAL_SWAP_PLACEHOLDER/$SWAP_TOTAL/g" "$REPORT_FILE"
sed -i "s/USED_SWAP_PLACEHOLDER/$SWAP_USED/g" "$REPORT_FILE"
sed -i "s/FREE_SWAP_PLACEHOLDER/$SWAP_FREE/g" "$REPORT_FILE"
sed -i "s/PERCENTAGE_SWAP_PLACEHOLDER/$SWAP_PERCENT/g" "$REPORT_FILE"
sed -i "s/RX_SPEED_PLACEHOLDER/$RX_SPEED/g" "$REPORT_FILE"
sed -i "s/TX_SPEED_PLACEHOLDER/$TX_SPEED/g" "$REPORT_FILE"
sed -i "s/RX_TOTAL_PLACEHOLDER/$RX_TOTAL/g" "$REPORT_FILE"
sed -i "s/TX_TOTAL_PLACEHOLDER/$TX_TOTAL/g" "$REPORT_FILE"
sed -i "s/CONNECTIONS_PLACEHOLDER/$CONNECTIONS/g" "$REPORT_FILE"
sed -i "s/DEFAULT_INTERFACE_PLACEHOLDER/$INTERFACE/g" "$REPORT_FILE"
sed -i "s/TOTAL_DISK_PLACEHOLDER/$TOTAL_DISK/g" "$REPORT_FILE"
sed -i "s/USED_DISK_PLACEHOLDER/$USED_DISK/g" "$REPORT_FILE"
sed -i "s/FREE_DISK_PLACEHOLDER/$FREE_DISK/g" "$REPORT_FILE"

#sed -i "s/INTERFACES_PLACEHOLDER/$INTERFACES/g" "$REPORT_FILE"
#sed -i "s/TOP_5_PROCESSES_PLACEHOLDER/$TOP_CPU/g" "$REPORT_FILE"
#sed -i "s/TOP_5_MEMORY_PROCESSES_PLACEHOLDER/$TOP_RAM/g" "$REPORT_FILE"
#sed -i "s/OPEN_PORTS_PLACEHOLDER/$OPEN_PORTS/g" "$REPORT_FILE"

# --- Create index.html for actual report ---
cp "$REPORT_FILE" "$LATEST_LINK"

