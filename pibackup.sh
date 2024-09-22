#!/bin/bash

OUTPUT_FOLDER="/set/your/backup/path"
DATE=$(date '+%Y-%m-%d_%H-%M-%S')
HOSTNAME=$(hostname)
BACKUP_IMAGE="$OUTPUT_FOLDER/${HOSTNAME}_backup_$DATE.img"

if [ ! -d "$OUTPUT_FOLDER" ]; then
    echo "Output folder $OUTPUT_FOLDER does not exist."
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

echo "Creating backup of SD card to $BACKUP_IMAGE..."
sudo dd if=/dev/mmcblk0 of="$BACKUP_IMAGE" bs=1M status=progress

echo "Shrinking the image with PiShrink..."
sudo /usr/local/bin/pishrink -v -z -a "$BACKUP_IMAGE"

echo "Backup complete! Image stored at $BACKUP_IMAGE"
