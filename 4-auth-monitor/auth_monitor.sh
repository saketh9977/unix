#!/bin/bash

set -e
echo "auth_monitor: starting..."
date

echo $USER

# "log show" may miss some logs -  best-effort, non-fail-stop system; so, "log stream" is chosen.

# grep doesn't flush output (i) either until its buffer is full or (ii) until it sees EOF
# neither EOF is emitted nor a buffer gets filled with 1-2 lines of 'log stream output', which makes grep to output nothing
# stdbuf -oL forces grep to flush buffer on seeing '\n'

# process == "authd" captures noise (background-daemon-login attempts are also tracked, we just need foreground-manual-login attempts)
# Looks like process == "loginwindow" & process == "homed" are more reliable

# tested on macOS 15.5 with M1 chip.


log stream --info --debug \
  --predicate '(
    (
      process == "loginwindow" AND (
        composedMessage CONTAINS[c] "loginPressed," OR
        composedMessage CONTAINS[c] "Attempt #" OR
        composedMessage CONTAINS[c] "Auth began" OR
        composedMessage CONTAINS[c] "auth started with lock UI showing" OR
        composedMessage CONTAINS[c] "to prevent further interaction" OR
        composedMessage CONTAINS[c] "Screensaver authorization succeeded" OR
        composedMessage CONTAINS[c] "Screensaver authorization failed" OR
        composedMessage CONTAINS[c] "INCORRECT password" OR
        composedMessage CONTAINS[c] "lock UI is showing" OR
        composedMessage CONTAINS[c] "focused user name: saketh"
      )
    ) OR 
    (
      process == "homed" AND (
        composedMessage CONTAINS[c] "Device lock state (locked): "
      )
    )  
  )' \
  | stdbuf -oL grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{6}\+[0-9]{4}' \
  | awk '
    /loginPressed,/ {
      print $1, substr($2, 1, 8), substr($2, index($2, "+")), "login button clicked"
    }
    /Attempt #/ {
      print $1, substr($2, 1, 8), substr($2, index($2, "+")), "Attempt", $NF
    }
    /Auth began/ {
      print $1, substr($2, 1, 8), substr($2, index($2, "+")), "validating..."
    }
    /auth started with lock UI showing/ {
      print $1, substr($2, 1, 8), substr($2, index($2, "+")), "validating (lock ui showing)..."
    }
    /to prevent further interaction/ {
      print $1, substr($2, 1, 8), substr($2, index($2, "+")), "disable user input"
    }
    /Screensaver authorization succeeded/ {
      print $1, substr($2, 1, 8), substr($2, index($2, "+")), "login succeeded"
    }
    /Screensaver authorization failed/ {
      print $1, substr($2, 1, 8), substr($2, index($2, "+")), "login failed"
    }
    /INCORRECT password/ {
      print $1, substr($2, 1, 8), substr($2, index($2, "+")), "incorrect password"
    }
    /lock UI is showing/ {
      print $1, substr($2, 1, 8), substr($2, index($2, "+")), "lock ui showing"
    }
    /Device lock state \(locked\): 2/ {
      print $1, substr($2, 1, 8), substr($2, index($2, "+")), "locked (homed)"
    }
    /Device lock state \(locked\): 0/ {
      print $1, substr($2, 1, 8), substr($2, index($2, "+")), "unlocked (homed)"
    }
'

date
echo "auth_monitor: ending..."

