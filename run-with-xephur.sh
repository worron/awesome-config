#!/bin/bash

Xephyr :3 -ac -screen 1920x1080 &
XEPHYR_PID=$!
sleep 0.5

DISPLAY=:3 awesome -c rc-devel.lua
kill ${XEPHYR_PID}
