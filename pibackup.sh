#!/bin/bash

BACKUP_DIR="/set/your/backup/path"
LOG_FILE="/set/your/log/path/cron.log"
DATE=$(date '+%Y-%m-%d_%H-%M-%S')
HOSTNAME=$(hostname)
BACKUP_IMAGE="$BACKUP_DIR/${HOSTNAME}_backup_$DATE.img"

if [ ! -d "$BACKUP_DIR" ]; then
    echo "Output folder $BACKUP_DIR does not exist."
    exit 1
fi

if [ ! -f "/usr/local/bin/pishrink" ]; then
    echo "PiShrink not found at /usr/local/bin/pishrink."
    echo "Please install PiShrink by following the instructions at: https://github.com/Drewsif/PiShrink"
    exit 1
else
    if ! command -v pigz &> /dev/null; then
        echo "pigz not found. Install pigz by running: apt install pigz"
        exit 1
    fi
fi

log() {
    echo "---$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE" 2>&1
}

log  "---Creating backup of SD card to $BACKUP_IMAGE..."
sudo dd if=/dev/mmcblk0 of="$BACKUP_IMAGE" bs=1M status=progress >> "$LOG_FILE" 2>&1

log  "---Shrinking the image with PiShrink..."
sudo /usr/local/bin/pishrink -v -z -a "$BACKUP_IMAGE" >> "$LOG_FILE" 2>&1

log  "---Backup complete! Image stored at $BACKUP_IMAGE"
