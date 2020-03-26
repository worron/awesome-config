#!/bin/bash

Xephyr :3 -ac -screen 3840x2160 &
XEPHYR_PID=$!
sleep 0.5

DISPLAY=:3 awesome -c rc-devel.lua
kill ${XEPHYR_PID}
