#!/bin/bash
# Admin https://yuque.com/lwmacct
# document https://www.yuque.com/lwmacct/docker/buildx

__main() {
  {
    # _sh_path=$(realpath "$(ps -p $$ -o args= 2>/dev/null | awk '{print $2}')") # 当前脚本路径
    _sh_path=$(realpath "${BASH_SOURCE[0]}")                     # 当前脚本路径 (依赖 bash)
    _pro_name=$(echo "$_sh_path" | awk -F '/' '{print $(NF-2)}') # 当前项目名
    _dir_name=$(echo "$_sh_path" | awk -F '/' '{print $(NF-1)}') # 当前目录名
    _image="${_pro_name}:$_dir_name"
  }

  _dockerfile=$(
    # 双引号不转义
    cat <<"EOF"
FROM ghcr.io/lwmacct/250209-cr-ubuntu:noble-t2502090

# https://playwright.dev/python/
# https://github.com/microsoft/playwright-python
# https://mcr.microsoft.com/en-us/artifact/mar/playwright/python/about


RUN set -eux; \
    echo "apt-pkgs"; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    python3 python3-pip python3-venv python3-dotenv \
    node-playwright libnss3 libnspr4 libgbm1 libasound2t64 \
    xvfb x11vnc dbus-x11 \
    ;


RUN set -eux; \
    echo "apt-pkgs"; \
    apt-get install -y --no-install-recommends \
      x264 \
      flite \
      libgtk-4-1 \
      libgstreamer-plugins-base1.0-0 \
      libvulkan1 \
      libgraphene-1.0-0 \
      libatomic1 \
      libxslt1.1 \
      libvpx9 \
      libevent-2.1-7 \
      libopus0 \
      libwebpdemux2 \
      libavif16 \
      libharfbuzz-icu0 \
      libwebpmux3 \
      libenchant-2-2 \
      libsecret-1-0 \
      libhyphen0 \
      libmanette-0.2-0 \
      libgles2 \
      libflite1 \
      libgstreamer-gl1.0-0 \
      libgstreamer-plugins-bad1.0-0 \
      libwoff1 \
      ;

RUN set -eux; \
    echo "playwright"; \
    python3 -m venv /apps/venv; \
    /apps/venv/bin/pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple; \
    /apps/venv/bin/pip install pytest-playwright; \
    /apps/venv/bin/playwright install; \
    /apps/venv/bin/playwright install-deps; \
    echo;

RUN set -eux; \
    echo "fake-useragent"; \
    /apps/venv/bin/pip install fake-useragent;

ENTRYPOINT ["tini", "--"]
CMD ["bash"]

LABEL org.opencontainers.image.source=$_ghcr_source
LABEL org.opencontainers.image.description=""
LABEL org.opencontainers.image.licenses=MIT
EOF
  )
  {
    cd "$(dirname "$_sh_path")" || exit 1
    echo "$_dockerfile" >Dockerfile

    _ghcr_source=$(sed 's|git@github.com:|https://github.com/|' ../.git/config | grep url | sed 's|.git$||' | awk '{print $NF}')
    _ghcr_source=${_ghcr_source:-"https://github.com/lwmacct/250210-cr-buildx"}
    sed -i "s|\$_ghcr_source|$_ghcr_source|g" Dockerfile
  }

  {
    if command -v sponge >/dev/null 2>&1; then
      jq 'del(.credsStore)' ~/.docker/config.json | sponge ~/.docker/config.json
    else
      jq 'del(.credsStore)' ~/.docker/config.json >~/.docker/config.json.tmp && mv ~/.docker/config.json.tmp ~/.docker/config.json
    fi
  }
  {
    _registry="ghcr.io/lwmacct" # 托管平台, 如果是 docker.io 则可以只填写用户名
    _repository="$_registry/$_image"
    echo "image: $_repository"
    docker buildx build --builder default --platform linux/amd64 -t "$_repository" --network host --progress plain --load . && {
      _image_id=$(docker images "$_repository" --format "{{.ID}}")
      if false; then
        docker rm -f sss 2>/dev/null
        docker run -itd --name=sss \
          --restart=always \
          --network=host \
          --privileged=false \
          "$_image_id"
        docker exec -it sss bash
      fi
    }
    docker push "$_repository"

  }
}

__main

__help() {
  cat >/dev/null <<"EOF"
这里可以写一些备注

ghcr.io/lwmacct/250317-cr-playwright:v1.50.0-t2503171

EOF
}
