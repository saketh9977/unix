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

# loginwindow: (loginsupport)
# loginwindow: [com.apple.loginwindow.logging:Standard]
# loginwindow: [com.apple.loginwindow.logging:KeyMilestone]


log stream --info --debug \
  --predicate '(
    (
      process == "loginwindow" AND (
        composedMessage CONTAINS[c] "loginPressed," OR
        composedMessage CONTAINS[c] "Auth began" OR
        composedMessage CONTAINS[c] "auth started with lock UI showing" OR
        composedMessage CONTAINS[c] "to prevent further interaction" OR
        composedMessage CONTAINS[c] "Screensaver authorization succeeded" OR
        composedMessage CONTAINS[c] "Screensaver authorization failed" OR
        composedMessage CONTAINS[c] "INCORRECT password" OR
        composedMessage CONTAINS[c] "lock UI is showing" OR
        composedMessage CONTAINS[c] "focused user name:" OR
        composedMessage CONTAINS[c] "attempting login for user:" OR
        composedMessage CONTAINS[c] "is logged in" OR
        composedMessage CONTAINS[c] "Showing the user avatar for" OR
        composedMessage CONTAINS[c] "switching to user" OR
        composedMessage CONTAINS[c] "newUserOnConsole" OR
        composedMessage CONTAINS[c] "processing lock screen request" OR
        composedMessage CONTAINS[c] "immediate lock" OR
        composedMessage CONTAINS[c] "loginwindow sending screen is locked notification" OR
        composedMessage CONTAINS[c] "sessionUnlocked : 0" OR
        composedMessage CONTAINS[c] "ess_notify_lw_session_lock" OR
        composedMessage CONTAINS[c] "processing unlock screen request" OR
        composedMessage CONTAINS[c] "new state: Desktop showing" OR
        composedMessage CONTAINS[c] "sendNotificationOf kScreenIsUnlocked" OR
        composedMessage CONTAINS[c] "sending screen is locked notification" OR
        composedMessage CONTAINS[c] "new state: Shield window showing" OR
        composedMessage CONTAINS[c] "login state: LoginwindowUIShown" OR
        composedMessage CONTAINS[c] "tearing down screen lock space" OR
        composedMessage CONTAINS[c] "ess_notify_lw_session_unlock" OR
        composedMessage CONTAINS[c] "enter.  userName:" OR
        composedMessage CONTAINS[c] "Enter. Prefs: "
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
    /focused user name: .*/ {
      print $1, substr($2, 1, 8), substr($2, index($2, "+")), "focused user name:", $NF
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
    /attempting login for user: .*/ {
      print $1, substr($2, 1, 8), substr($2, index($2, "+")), "attempting login for user:", $NF
    }
    /User .* is logged in/ {
      print $1, substr($2, 1, 8), substr($2, index($2, "+")), "User", $(NF-3), "is logged in"
    }
    /Showing the user avatar for .*/ {
      print $1, substr($2, 1, 8), substr($2, index($2, "+")), "Showing the user avatar for", $NF
    }
    /switching to user/ {
      print $1, substr($2, 1, 8), substr($2, index($2, "+")), "switching to user:", $(NF-1)
    }
    /newUserOnConsole: .*/ {
      print $1, substr($2, 1, 8), substr($2, index($2, "+")), "newUserOnConsole:", $NF
    }
    /processing lock screen request/ {
      print $1, substr($2, 1, 8), substr($2, index($2, "+")), "processing lock screen request"
    }
    /immediate lock/ {
      print $1, substr($2, 1, 8), substr($2, index($2, "+")), "lock immediately"
    }
    /loginwindow sending screen is locked notification|sending screen is locked notification/ {
      print $1, substr($2, 1, 8), substr($2, index($2, "+")), "screen is locked notification"
    }
    /sessionUnlocked : 0/ {
      print $1, substr($2, 1, 8), substr($2, index($2, "+")), "session locked"
    }
    /ess_notify_lw_session_lock/ {
      print $1, substr($2, 1, 8), substr($2, index($2, "+")), "session locked notification"
    }
    /processing unlock screen request/ {
      print $1, substr($2, 1, 8), substr($2, index($2, "+")), "processing unlock screen request"
    }
    /new state: Desktop showing/ {
      print $1, substr($2, 1, 8), substr($2, index($2, "+")), "showing desktop"
    }
    /sendNotificationOf kScreenIsUnlocked/ {
      print $1, substr($2, 1, 8), substr($2, index($2, "+")), "screen is unlocked notification"
    }
    /new state: Shield window showing/ {
      print $1, substr($2, 1, 8), substr($2, index($2, "+")), "showing shield window"
    }
    /login state: LoginwindowUIShown/ {
      print $1, substr($2, 1, 8), substr($2, index($2, "+")), "showing login window"
    }
    /tearing down screen lock space/ {
      print $1, substr($2, 1, 8), substr($2, index($2, "+")), "removing screen lock"
    }
    /ess_notify_lw_session_unlock/ {
      print $1, substr($2, 1, 8), substr($2, index($2, "+")), "session unlock notification"
    }
    /enter\.  userName:/ {
      print $1, substr($2, 1, 8), substr($2, index($2, "+")), "settingup", $(NF-3)
    }
    /Enter\. Prefs: / {
      print $1, substr($2, 1, 8), substr($2, index($2, "+")), "settingup prefs for", $(NF-1)
    }
'

date
echo "auth_monitor: ending..."

