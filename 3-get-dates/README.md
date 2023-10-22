## Usecase
Imagine a Python script that consumes YYYY MM DD as input arguments -
```
python etl.py 2023 10 18
```
To invoke `etl.py` for whole month, you can use a shell script like this one which can trigger Python script in a loop for each day in a month

## Input
Pass start & end dates as arguments to shell script -
```
bash get_dates.sh 2023-09-23 2023-10-22
```

## Output
You can access each date's YYYY MM DD inside `for` loop at `line 48` -
```
echo "$year$month$day"
```
This can be replaced with any valid bash command like below -
```
python etl.py $year $month $day
```


### Note:
- Why not just use a simple python wrapper function that implements a similar logic? 
- Imagine a usecase where you want to spawn multiple processes in parallel & want to capture output of each process in a separate log file immediately while the script is running -
```
python -u etl.py $year $month $day &> ./logs/$year-$month-$day.log &
```
using above command inside for loop at `get_dates.sh -> line 48` is easier than Python.
- Python for this usecase may need more effort for using multiprocessing package, managing log files, flushing STDOUT buffer frequently etc.
