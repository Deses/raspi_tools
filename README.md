This is my little script to have all the usual maintenance tasks all in one file to be later used in several cron jobs.

I put the scrip into `/usr/local/bin/` and gave it execution perms: `chmod +x maintenance`.

Then, in crontab I set it like this to run some tasks daily and some on saturday.

```
0  5 * * *      maintenance -t
1  5 * * *      maintenance -c
5  5 * * 6      maintenance -u
10 5 * * 6      maintenance -p
15 5 * * 6      maintenance -g
20 5 * * 6      maintenance -r
```
