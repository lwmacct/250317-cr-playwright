#!/usr/bin/env bash

while true; do
  Xvfb "$DISPLAY" -screen 0 "${VNC_RESOLUTION}x${VNC_DEPTH}" -auth /tmp/xvfb
  sleep 1
done
