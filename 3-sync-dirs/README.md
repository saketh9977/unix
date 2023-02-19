See the below Bash Script -
```
src="<source dir>"
dst="<destination dir>"

rsync -a -r -v -P --delete $src $dst
```
- `--delete` option deletes data at destination if it is absent at source.
- `-a` option stands for archive; it preserves permissions, last-modified-time, symbolic links and other meta data at destination

## Usecase 1 - local backup:
Imagine you want to store your data at 2 places: main copy on local disk and backup copy on an external disk. You frequently make changes to your main copy and you want to propagate these changes to backup copy every week. We have multiple options -
1. Every week, delete backup copy and copy whole data from main copy to backup copy on external disk. This writes the whole data at destination everytime & may incur more P/E cycles (more than the below option) of your external disk over a long period, which may decrease the life expectancy of your external disk.

2. We can use the above `rsync` command to propagate only **the changes** from main copy to back copy every week - less data is transferred from source to destination - reducing time and cost - this accounts for fewer no. of P/E cycles of your external disk.

## Usecase 2 - remote backup:
This is similar to the usecase-1, except that the destination is a remote location i.e. main copy is on local disk and backup copy is on a remote machine.

As network I/O is more time consuming than Disk I/O, the time & cost savings with rsync are more significant here, by propagating only the changes over network, instead of whole main copy.

You may use `aws s3 sync <src> <dst>` to sync two s3 locations