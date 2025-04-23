#!/usr/bin/env bash

# docs
# https://www.yuque.com/lwmacct/shell/declare
# https://www.yuque.com/lwmacct/terminal/tmux

__xvfb() {
  :
  exec Xvfb "$DISPLAY" -screen 0 "${VNC_RESOLUTION}x${VNC_DEPTH}" -auth /tmp/xvfb
}

__x11vnc() {
  :
  exec x11vnc -display "$DISPLAY" -passwd "$VNC_PASSWORD" -forever -shared -auth /tmp/xvfb -rfbport "$VNC_PORT"
}

__playwright() {
  :
  /apps/venv/bin/python /apps/repo/cmd/main.py
}

__main() {
  echo "Running main with params: $*"
  tmux new-session -d -s "tmux" "tail -f /dev/null"
  {
    while true; do
      for _app in xvfb x11vnc playwright; do
        echo "$_app"
        tmux new-session -d -s "$_app" "bash /apps/repo/cmd/main.sh $_app"
      done
      sleep 1
    done
  } >/dev/null 2>&1
}

__help() {
  cat <<EOF
Usage: ${0##*/} [command] [options]

Available commands:
  main       主程序入口
  xvfb       启动 xvfb
  x11vnc     启动 x11vnc
  playwright 启动 playwright
  help       显示帮助信息

Example:
  $0 main
  $0 xvfb
  $0 x11vnc
  $0 playwright
EOF
}

case "$1" in
main | xvfb | x11vnc | playwright)
  func="__${1}"
  shift # 移除已解析的命令参数
  $func "$@"
  ;;
-h | --help | help | *)
  __help
  exit 0
  ;;
esac
