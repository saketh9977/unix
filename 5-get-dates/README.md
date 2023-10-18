## Usecase
Imagine a Python script that consumes YYYY MM DD as input arguments -
```
python etl.py 2023 10 18
```
To invoke etl.py for whole month, you can use a shell script like this one

## Input
change start & end dates as per your requirements inside `get_dates.txt` -
```
get_dates__ "2023-10-18" "2023-10-21"
```

## Output
You can access each date's YYYY MM DD inside for loop at `line 41` -
```
echo "$year$month$day"
```
