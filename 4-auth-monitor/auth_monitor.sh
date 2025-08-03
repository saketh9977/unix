#!/bin/bash

set -e
echo "auth_monitor: starting..."
date

echo $USER

# "log show" may miss some logs -  best-effort, non-fail-stop system; so, "log stream" is chosen.

# grep doesn't flush output (i) either until its buffer is full or (ii) until it sees EOF
# neither EOF is emitted nor a buffer gets filled with 1-2 lines of 'log stream output', which makes grep to output nothing
# stdbuf -oL forces grep to flush buffer on seeing '\n'

# tested on macOS 15.5 with M1 chip.

log stream --info --debug \
  --predicate '(
  (process == "authd" AND (
    composedMessage CONTAINS[c] "evaluates 1 rights" OR
    composedMessage CONTAINS[c] "Succeeded authorizing right" OR
    composedMessage CONTAINS[c] "Failed to authorize right"
  )) OR
  (process == "homed" AND (
    composedMessage CONTAINS[c] "Device lock state (locked): 2"
  ))
)' \
| stdbuf -oL grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{6}\+[0-9]{4}' \
| awk '
  /evaluates 1 rights/ {
    print $1, substr($2, 1, 8), substr($2, index($2, "+")), "login-attempt"
  }
  /Succeeded authorizing right/ {
    print $1, substr($2, 1, 8), substr($2, index($2, "+")), "login-succeeded"
  }
  /Failed to authorize right/ {
    print $1, substr($2, 1, 8), substr($2, index($2, "+")), "login-failed"
  }
  /Device lock state \(locked\): 2/ {
    print $1, substr($2, 1, 8), substr($2, index($2, "+")), "locked"
  }
'

date
echo "auth_monitor: ending..."

