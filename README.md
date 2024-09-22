These are some script I made for personal use to have all the usual maintenance tasks all in one file to be later invoked from cron or manually.
Feel free to use them or suggest any changes. :)

## Installation
```
wget https://raw.githubusercontent.com/Deses/raspi_tools/refs/heads/main/maintenance.sh
chmod +x maintenance.sh
sudo mv maintenance.sh /usr/local/bin/maintenance

wget https://raw.githubusercontent.com/Deses/raspi_tools/refs/heads/main/pibackup.sh
chmod +x pibackup.sh
sudo mv pibackup.sh /usr/local/bin/pibackup
```

## Crontab settings
```
# 5 AM Daily
0  5 * * *      maintenance -t
1  5 * * *      maintenance -c
# 5 AM on saturdays
5  5 * * 6      maintenance -u
10 5 * * 6      maintenance -p
15 5 * * 6      maintenance -g
20 5 * * 6      maintenance -r
```
