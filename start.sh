#!/bin/sh

# kill ports if have
kill-port 9099 8080

# start emulators
echo "Starting emulators..."
firebase emulators:start --import=.//emulator_data --export-on-exit

echo "Stopping ..."
