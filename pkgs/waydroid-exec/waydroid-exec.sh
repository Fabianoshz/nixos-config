#!/usr/bin/env bash

# Open a thread to launch the app
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

    if [[ -n "$1" ]]; then
        sleep 10
        waydroid app launch "${1}"
    fi
}&

# Now we open the full UI, the thread will work on it
weston --shell="kiosk-shell.so" --width=3840 --height=2160 -- waydroid show-full-ui

waydroid session stop
