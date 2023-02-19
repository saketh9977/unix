
1. Run `netstat -p`. Note down the port number of the process that you want to monitor nework traffic for.
2. Run `sudo iftop -i wlp5s0`. Press `p` to enable ports.
    - Notice the entry corresponding to the port number of your interest
    - The last 3 columns seem to represent -

    ```
    Specifically, these three columns in iftop are the average traffic during the last 2, 10 and 40 seconds
    ```
    - Each process seems to have 2 rows: upload and download bandwidth respectively
 