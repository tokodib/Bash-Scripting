#! /bin/bash
#====================================================
# System monitor dashboard
# CPU
#====================================================

# --- Settings and Variables ---

get_cpu_data() {
	CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
	CPU_USAGE=${CPU_USAGE:-0}

	CPU_CORES=$(nproc)

echo "CPU usage : $CPU_USAGE"
echo "CPU cores : $CPU_CORES"
}

get_cpu_data
