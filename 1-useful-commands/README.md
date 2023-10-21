<details>

<summary>rsync -a -P --delete $src $dst</summary>

- This command syncs only the changes from source to desination.
- `--delete` option deletes data at destination if it is absent at source.
- `-a` option stands for archive; it preserves permissions, last-modified-time, symbolic links and other meta data at destination
- `rsync` reduces sync time & disk i/o when we perform multiple syncs b/w same 'source & destination'

</details>

<details>
<summary>rsync -P -a -e "ssh -i $path_to_privatekey_local" $src $username@$remote_host:$remote_path</summary>

- This command syncs changes from local - `$src` - to a remote machine: `$remote_host`
- As network I/O is more time consuming than Disk I/O, the time & cost savings with rsync are more significant here, by propagating only the changes over network, instead of whole `$src` copy every time.
</details>