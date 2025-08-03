### What is this?
A shell script that monitors -
1. login attempts
2. successful logins
3. failed logins
4. logouts/locks

Timestamps with event name are logged to `STDOUT` for each of the above events.

### Check it out
1. Run it using `bash auth_monitor.sh`
2. Deploying it as a daemon using `launchctl` fails, because `log stream` lacks Terminal-associated context - TCC/SIP limit even your own user from seeing certain logs — unless your app or script is run within an interactive Terminal session (like when you manually run the script)
3. Tested it on macOS 15.5 with M1 chip.