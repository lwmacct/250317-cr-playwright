#!/usr/bin/env bash

__main() {

  {
    # 镜像准备
    _image1="ghcr.io/lwmacct/250317-cr-playwright:v1.50.0-t2503171"
    _image2="$(docker images -q $_image1)"
    if [[ "$_image2" == "" ]]; then
      docker pull $_image1
      _image2="$(docker images -q $_image1)"
    fi
  }

  _apps_name="${_apps_name:-"250317-playwright"}"
  _apps_data="/data/$_apps_name"
  cat <<EOF | docker compose -p "$_apps_name" -f - up -d --remove-orphans
services:
  main:
    container_name: $_apps_name
    image: "$_image2"
    restart: always
    network_mode: host
    volumes:
      - $_apps_data:/apps/data
    environment:
      - TZ=Asia/Shanghai
      - CDP_PORT=50011
      - DISPLAY=:50010
      - VNC_PORT=50010
      - VNC_PASSWORD=bad_password
      - VNC_RESOLUTION=1200x1000
      - VNC_DEPTH=24
      - PROXY_SERVER=socks5://172.22.13.20:10086
      - USER_AGENT=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36
      
    command:
      - /bin/bash
      - -c
      - |
        if [[ ! -d "/apps/repo" ]]; then
          git clone https://github.com/lwmacct/250317-cr-playwright.git /apps/repo
        fi
        cd /apps/repo || exit 1
        bash /apps/repo/cmd/tmux.sh
        /apps/venv/bin/python /apps/repo/cmd/main.py
        tail -f /dev/null
EOF
}

__help() {
  cat <<EOF

EOF
}

__main
