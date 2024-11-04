#!/usr/bin/env bash

VALVE_INPUT_VENDOR_ID="28de"

# Open a thread to fix the controller after the session starts
{
    while : ; do
        if [[ "$(waydroid status | grep Session: | awk '{print $2}')" == "RUNNING" ]]
            then break
        fi 
        sleep 1
    done

    waydroid prop set persist.waydroid.suspend false
    waydroid prop set persist.waydroid.udev true
    waydroid prop set persist.waydroid.uevent true

    # We only want to add the controller if it's a steam input
    for d in /sys/devices/virtual/input/input*; do
        if [[ $(cat "$d"/id/vendor) == "$VALVE_INPUT_VENDOR_ID" ]];
            then echo add > "$d"/event*/uevent
        fi
    done
}&

# Open a thread to launch the app
{
    if [[ -n "$1" ]]; then
        sleep 10
        waydroid app launch "${1}"
        sleep 5
        waydroid show-full-ui
    fi
}&

# Now we open the full UI, threads are going to work on it
weston --shell="kiosk-shell.so" --width=3840 --height=2160 -- waydroid show-full-ui

waydroid session stop
