#!/usr/bin/env bash

# docs
# https://www.yuque.com/lwmacct/shell/declare
# https://www.yuque.com/lwmacct/terminal/tmux

__x11vnc() {
  :
  exec x11vnc -display "$DISPLAY" -passwd "$VNC_PASSWORD" -forever -shared -auth /tmp/xvfb -rfbport "$VNC_PORT"
}

__xvfb() {
  :
  exec Xvfb "$DISPLAY" -screen 0 "${VNC_RESOLUTION}x${VNC_DEPTH}" -auth /tmp/xvfb
}

__main() {
  echo "Running main with params: $*"
  tmux new-session -d -s "tmux" "tail -f /dev/null"
  {
    while true; do
      for _app in x11vnc xvfb; do
        tmux new-session -d -s "$_app" "bash /apps/rund/entrypoint.sh $_app"
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
  x11vnc     启动 x11vnc
  xvfb       启动 xvfb
  help       显示帮助信息

Example:
  $0 main
  $0 x11vnc
  $0 xvfb
EOF
}

case "$1" in
main | vmagent | app)
  func="__${1}"
  shift # 移除已解析的命令参数
  $func "$@"
  ;;
-h | --help | help | *)
  __help
  exit 0
  ;;
esac
