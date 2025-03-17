#!/usr/bin/env bash

while true; do
  x11vnc -display "$DISPLAY" -passwd "$VNC_PASSWORD" -forever -shared -auth /tmp/xvfb -rfbport "$VNC_PORT"
  sleep 1
done
