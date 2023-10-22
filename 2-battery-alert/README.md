### What is this?
A shell script that -
1. Sends a desktop notification when Laptop's battery level falls below (<=) a lower bound - so that user can plug-in the charger
2. Also, notifies when battery level crosses (>=) upper bound suggesting user to unplug charger.

### Implementation
1. A shell script fetches - 
    - Current battery percentage
    - Current battery status - charging/discharging
2. Based on the above information, it sends a desktop notification when one of the below conditions is met -
    - Battery percentage <= lower bound and battery status is discharging
    - Battery percentage >= upper bound and battery status is charging
3. This shell script is scheduled to run every 5m using cronjob - 
```
0/5 * * * * bash ~/work/shell-scripts/battery_alert.sh &> ~/work/shell-scripts/logs/battery_alert.log
```
4. Tested on `macOS Ventura 13.3` on ARM-based CPU (M1)