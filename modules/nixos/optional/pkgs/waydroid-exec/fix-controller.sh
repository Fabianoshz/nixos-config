#!/usr/bin/env bash

for i in $(ls /sys/devices/virtual/input/input*/event*/uevent); do
    bash -c "echo add > $i"
done
