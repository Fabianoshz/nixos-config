#!/usr/bin/env bash

# Open a thread to fix the controller after the session starts
{
    while : ; do
        if [[ "$(waydroid status | grep Session: | awk '{print $2}')" == "RUNNING" ]]
            then break
        fi 
        sleep 1
    done

    sudo fix-controller
}&

# Open a thread to launch the app
{
    if [[ -n "$1" ]]; then
        sleep 10
        waydroid app launch ${1}
        sleep 5
        waydroid show-full-ui
    fi
}&

# Now we open the full UI, threads are going to work on it
cage -- bash -c "waydroid show-full-ui"

waydroid session stop
