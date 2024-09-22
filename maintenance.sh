#!/bin/bash

BACKUP_DIR="/set/your/backup/path"
LOG_FILE="/set/your/log/path/cron.log"

log() {
    if [ -f "$LOG_FILE" ]; then
        while read -r line; do
            if [[ "$line" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}" "[0-9]{2}:[0-9]{2}:[0-9]{2} ]]; then
                last_log_date=$(echo "$line" | awk '{print $1 " " $2}')
                last_log_timestamp=$(date -d "$last_log_date" +%s)
                current_timestamp=$(date +%s)
                diff_days=$(( (current_timestamp - last_log_timestamp) / 86400 ))

                if [ "$diff_days" -gt 5 ]; then
                    > "$LOG_FILE"
                fi
                break
            fi
        done < <(tac "$LOG_FILE")
    fi
    echo "---$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE" 2>&1
}

help() {
    echo "Usage: $0 [OPTION]"
    echo "Options:"
    echo "  -t, --teleport       Create a Pi-hole teleport backup"
    echo "  -c, --cleanup        Cleanup old backups"
    echo "  -u, --upgrade        Update and upgrade the sytem"
    echo "  -p, --piupdate       Update Pi-hole"
    echo "  -g, --gravity        Update Pi-hole adlists"
    echo "  -r, --reboot         Reboot the system"
    echo "  -h, --help           Show this help message"
    exit 0
}

piholeTeleport() {
    if ! command -v pihole &> /dev/null; then
        log "Pi-hole is not installed. Please install Pi-hole before running this option."
        exit 1
    else
        log "Creating Pi-hole teleport..."
        cd  "$BACKUP_DIR" && /usr/local/bin/pihole -a -t >> "$LOG_FILE" 2>&1
    fi
}

cleanup() {
    log "Searching for Pi-hole backups older than 1 year..."
    find "$BACKUP_DIR" -type f -name "pi-hole-pihole-teleporter_*.tar.gz" -mtime +365 | while read -r file; do
        log "Deleting Pi-hole backup: $file"
        rm "$file"
    done
}

sysUpgrade() {
    log "Updating system..."
    sudo apt-get update >> "$LOG_FILE" 2>&1
    sudo apt-get upgrade -y >> "$LOG_FILE" 2>&1
    sudo apt-get autoremove >> "$LOG_FILE" 2>&1
    sudo apt-get autoclean >> "$LOG_FILE" 2>&1
}

piholeUpdate() {
    if ! command -v pihole &> /dev/null; then
        log "Pi-hole is not installed. Please install Pi-hole before running this option."
        exit 1
    else
        log "Updating Pi-hole..."
        /usr/local/bin/pihole -up >> "$LOG_FILE" 2>&1
    fi
}

piholeGravity() {
    if ! command -v pihole &> /dev/null; then
        log "Pi-hole is not installed. Please install Pi-hole before running this option."
        exit 1
    else
        log "Updating Gravity..."
        /usr/local/bin/pihole -g >> "$LOG_FILE" 2>&1
    fi
}

sysReboot() {
    log "Rebooting system..."
    sudo /sbin/reboot
}

if [[ "$1" == "" ]]; then
    echo "Error: No option provided."
    help
fi

while [[ "$1" != "" ]]; do
    case $1 in
        -t | --teleport ) piholeTeleport
                          ;;
        -c | --cleanup )  cleanup
                          ;;
        -p | --piupdate ) piholeUpdate
                          ;;
        -g | --gravity )  piholeGravity
                          ;;
        -u | --upgrade )  sysUpgrade
                          ;;
        -r | --reboot )   sysReboot
                          ;;
        -h | --help )     help
                          ;;
        * )               echo "Error: Invalid option '$1'."
                          help
    esac
    shift
done
