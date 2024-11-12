#!/usr/bin/env bash

VALVE_INPUT_VENDOR_ID="28de"

while : ; do 
    echo "Starting waydroid watch"

    # Keep waiting for waydroid to start
    while : ; do
        if [[ "$(waydroid status | grep Session: | awk '{print $2}')" == "RUNNING" ]]; then 
            WATCH_PID=$(ps aux |grep waydroid | grep show-full-ui | head -1 | awk '{print $2}')
            echo "Found PID: ${WATCH_PID}"
            break
        fi 
        sleep 5
    done

    # We only want to add the controller if it's a steam input
    for d in /sys/devices/virtual/input/input*; do
        if [[ $(cat "$d"/id/vendor) == "$VALVE_INPUT_VENDOR_ID" ]]
            then for e in $d/event*; do
                echo "Trying to enable controller ${e}/uevent"
                echo add | sudo /run/current-system/sw/bin/tee -a $e/uevent
            done
        fi
    done

    echo "Now waiting for process to exit"

    # After the controller is added, we wait the process to finish
    tail --pid=$WATCH_PID -f /dev/null

    echo "Waydroid exited, releasing loop..."
done
