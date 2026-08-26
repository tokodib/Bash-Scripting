#! /bin/bash
#====================================================
# System monitor dashboard
# CPU, System informations
#====================================================

# --- Settings and Variables ---

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
# Print System informations
#====================================================
get_cpu_data
echo "CPU Info:"
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

#echo -e "Echo test: \nHostname: $HOSTNAME \nUptime: $UPTIME \nOS: $OS \nKernel: $KERNEL \nGenerated: $TIMESTAMP"