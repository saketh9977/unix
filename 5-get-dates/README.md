## Usecase
Imagine a Python script that consumes YYYY MM DD as input arguments -
```
python etl.py 2023 10 18
```
To invoke etl.py for whole month, you can use a shell script like this one

## Input
change start & end dates as per your requirements inside `get_dates.sh` -
```
get_dates__ "2023-10-18" "2023-10-21"
```

## Output
You can access each date's YYYY MM DD inside for loop at `line 41` -
```
echo "$year$month$day"
```

### Note:
- Why not just use a simple python wrapper function that implements a similar logic? 
- Imagine a usecase where you want to spawn multiple processes in parallel & want to capture output of each process in a separate log file immediately while the script is running -
```
python -u etl.py 2023 10 18 &> ./logs/2023-10-18.log &
```
using above command inside for loop at `get_dates.sh -> line 41` is easier than Python.
- Python for this usecase may need more effort for using multiprocessing package, managing log files, flushing STDOUT buffer etc. frequently.
