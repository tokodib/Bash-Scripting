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

}

get_cpu_data
echo "CPU usage : $CPU_USAGE %"
echo "CPU cores : $CPU_CORES"

get_system_info
echo -e "\nSystem info:"
echo "Hostname: $HOSTNAME"
echo "Uptime: $UPTIME"
echo "OS: $OS"
echo "Kernel: $KERNEL"
echo "Generated: $TIMESTAMP"

#echo -e "Echo test: \nHostname: $HOSTNAME \nUptime: $UPTIME \nOS: $OS \nKernel: $KERNEL \nGenerated: $TIMESTAMP"