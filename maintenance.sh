#!/bin/bash

BACKUP_DIR="/mnt/unraid/Backups"
LOG_FILE="/mnt/unraid/Backups/cron.log"

# Function for logging with date in standard format
log() {
    if [ -f "$LOG_FILE" ]; then
        # Loop through the log file in reverse to find the last valid log entry with a date
        while read -r line; do
            # Check if the line starts with a valid date (YYYY-MM-DD HH:MM:SS)
            if [[ "$line" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}" "[0-9]{2}:[0-9]{2}:[0-9]{2} ]]; then
                last_log_date=$(echo "$line" | awk '{print $1 " " $2}')

                # Convert the last log date to seconds since epoch
                last_log_timestamp=$(date -d "$last_log_date" +%s)

                # Get the current date in seconds since epoch
                current_timestamp=$(date +%s)

                # Calculate the difference in days (86400 seconds = 1 day)
                diff_days=$(( (current_timestamp - last_log_timestamp) / 86400 ))

                # Clear the log if the last entry is older than 5 days
                if [ "$diff_days" -gt 5 ]; then
                    > "$LOG_FILE"
                fi
                break
            fi
        done < <(tac "$LOG_FILE")  # Read log file in reverse
    fi

    # Append the new log message
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE" 2>&1
}

help() {
    echo "Usage: $0 [OPTION]"
    echo "Options:"
    echo "  -t, --teleport       Run Pi-hole teleport backup"
    echo "  -c, --cleanup        Run backup cleanup"
    echo "  -u, --update         Run system update and upgrade"
    echo "  -p, --piupdate       Run Pi-hole update"
    echo "  -r, --reboot         Log reboot and reboot the system"
    echo "  -h, --help           Show this help message"
    exit 0
}

teleport() {
    log "Creating Pi-hole teleport..."
    cd  "$BACKUP_DIR" && /usr/local/bin/pihole -a -t >> "$LOG_FILE" 2>&1
}

cleanup() {
    log "Searching for Pi-hole backups older than 1 year..."
    find "$BACKUP_DIR" -type f -name "pi-hole-pihole-teleporter_*.tar.gz" -mtime +365 | while read -r file; do
        log "Deleting Pi-hole backup: $file"
        rm "$file"
    done
}

update() {
    log "Updating system..."
    sudo apt-get update >> "$LOG_FILE" 2>&1
    sudo apt-get upgrade -y >> "$LOG_FILE" 2>&1
    sudo apt-get autoremove >> "$LOG_FILE" 2>&1
    sudo apt-get autoclean >> "$LOG_FILE" 2>&1
}

piholeUp() {
    log "Updating Pi-hole..."
    /usr/local/bin/pihole -up >> "$LOG_FILE" 2>&1
}

piholeGravity() {
    log "Updating Gravity..."
    /usr/local/bin/pihole -g >> "$LOG_FILE" 2>&1
}

sysReboot() {
    log "Rebooting system..."
    sudo /sbin/reboot
}

# Parse command-line options
if [[ "$1" == "" ]]; then
    echo "Error: No option provided."
    help
fi

while [[ "$1" != "" ]]; do
    case $1 in
        -t | --teleport ) teleport
                          ;;
        -c | --cleanup )  cleanup
                          ;;
        -u | --update )   update
                          ;;
        -p | --piupdate ) piholeUp
                          ;;
        -g | --gravity ) piholeGravity
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
