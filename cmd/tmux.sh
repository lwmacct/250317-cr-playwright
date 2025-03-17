#!/usr/bin/env bash

# docs
# https://www.yuque.com/lwmacct/shell/declare
# https://www.yuque.com/lwmacct/terminal/tmux

__declare_x11vnc() {
  :
  while true; do
    x11vnc -display "$DISPLAY" -passwd "$VNC_PASSWORD" -forever -shared -auth /tmp/xvfb -rfbport "$VNC_PORT"
    sleep 1
  done
}

__declare_xvfb() {
  :
  while true; do
    Xvfb "$DISPLAY" -screen 0 "${VNC_RESOLUTION}x${VNC_DEPTH}" -auth /tmp/xvfb
    sleep 1
  done
}

__main() {
  tmux new-session -ds tmux # 主进程,避免 pkill 误杀
  {
    FUNC_NAME=__declare_xvfb # 这里需要修改为你的方法名
    FUNC_BASE64="$(declare -f $FUNC_NAME | sed "\$a $FUNC_NAME" | base64 -w0)"
    echo "tmux new-session -d -s $FUNC_NAME -e FUNC_BASE64=$FUNC_BASE64 'bash <(base64 -d <<<\$FUNC_BASE64)'"
  }

  {
    FUNC_NAME=__declare_x11vnc # 这里需要修改为你的方法名
    FUNC_BASE64="$(declare -f $FUNC_NAME | sed "\$a $FUNC_NAME" | base64 -w0)"
    echo "tmux new-session -d -s $FUNC_NAME -e FUNC_BASE64=$FUNC_BASE64 'bash <(base64 -d <<<\$FUNC_BASE64)'"
  }

}
__main
