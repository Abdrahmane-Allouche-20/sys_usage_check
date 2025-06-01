#!/bin/sh

CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=80

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_alert() {
    # Print in red and beep
    echo -e "\033[31m$(date '+%Y-%m-%d %H:%M:%S') - $1\033[0m\a"
}

check_cpu_usage() {
    log "Checking CPU usage ..."
    if command -v top >/dev/null 2>&1; then
        CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | cut -d. -f1)
        CPU_USAGE=$((100 - CPU_IDLE))
        if [ "$CPU_USAGE" -gt "$CPU_THRESHOLD" ]; then
            log_alert "CPU usage is high: $CPU_USAGE%"
        else
            log "CPU usage is normal: $CPU_USAGE%"
        fi
    else
        log "top command not found."
    fi
}

check_memory_usage() {
    log "Checking memory usage ..."
    if command -v free >/dev/null 2>&1; then
        MEMORY_USAGE=$(free | awk '/Mem:/ {printf("%.0f", $3/$2 * 100)}')
        if [ "$MEMORY_USAGE" -gt "$MEMORY_THRESHOLD" ]; then
            log_alert "Memory usage is high: $MEMORY_USAGE%"
        else
            log "Memory usage is normal: $MEMORY_USAGE%"
        fi
    else
        log "free command not found."
    fi
}

check_disk_usage() {
    log "Checking disk usage..."
    if command -v df >/dev/null 2>&1; then
        DISK_USAGE=$(df -P / | awk 'END{print $5}' | tr -d '%')
        if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
            log_alert "Disk usage is high: $DISK_USAGE%"
        else
            log "Disk usage is normal: $DISK_USAGE%"
        fi
    else
        log "df command not found."
    fi
}

check_cpu_usage
check_memory_usage
check_disk_usage