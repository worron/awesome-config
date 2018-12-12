#!/bin/bash

Xephyr :5 -ac -screen 1920x1080 &
XEPHYR_PID=$!
sleep 0.2

# DISPLAY=:5 awesome -c rc-colorless.lua
DISPLAY=:5 awesome -c rc-devel.lua
kill $XEPHYR_PID
