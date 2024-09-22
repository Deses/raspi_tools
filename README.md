These are some scripts I made for personal use, but feel free to use them or suggest any changes. :)

## Motivation
I wanted to have all the usual maintenance tasks in one file to be easily run manually or invoked from cron.

There's also a backup script that uses `dd` and the excellent [PiShrink by Drewsif](https://github.com/Drewsif/PiShrink) to massively reduce the space required by backups.

## Installation
```
wget https://raw.githubusercontent.com/Deses/raspi_tools/refs/heads/main/maintenance.sh
chmod +x maintenance.sh
sudo mv maintenance.sh /usr/local/bin/maintenance

wget https://raw.githubusercontent.com/Deses/raspi_tools/refs/heads/main/pibackup.sh
chmod +x pibackup.sh
sudo mv pibackup.sh /usr/local/bin/pibackup
```

## Options for maintenance.sh
- `-t, --teleport`
Runs Pi-hole's teleporter.

- `-c, --cleanup`
Cleans up teleporter backups older than 1 year.

- `-u, --upgrade`
**Not recommended for automation!** Performs a full system update, including upgrading installed packages, removing obsolete packages, and cleaning up unnecessary files.

- `-p, --piupdate`
**Not recommended for automation!** Updates Pi-hole to the latest version.

- `-g, --gravity`
Updates Pi-hole's adlists.  

- `-r, --reboot`
Reboots the system.

## Options for pibackup.sh
No options. Edit the script to set the location of your backup folder and change the filename settings (if you want).

## Crontab example
```
# 4 am - Daily
0  4 * * *      maintenance -t -c

# 5 am - Saturday
0  5 * * 6      maintenance -u
5  5 * * 6      maintenance -p
10 5 * * 6      maintenance -g
15 5 * * 6      maintenance -r

# 5 am - Sunday
0  5 * * 0      pibackup
```
