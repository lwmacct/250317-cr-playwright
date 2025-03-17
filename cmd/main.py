from playwright.sync_api import sync_playwright
import fake_useragent

import os

# 定义用户数据目录路径
user_data_dir = os.path.join(os.getcwd(), "/apps/data/browser_data")



# 确保目录存在
os.makedirs(user_data_dir, exist_ok=True)

# 设置当前进程环境变量
with sync_playwright() as p:
    # 从环境变量中获得 proxy_server
    proxy_server = os.getenv("PROXY_SERVER")
    user_agent = os.getenv("USER_AGENT")
    cdp_port = os.getenv("CDP_PORT")
    
    # 判断 user_agent 是否为空
    if user_agent == None or user_agent == "":
      ua = fake_useragent.UserAgent()
      user_agent = ua.chrome
      
    # 获取浏览器窗口大小
    width=os.getenv("VIEW_WIDTH")
    height=os.getenv("VIEW_HEIGHT")
    if width == None or width == "" or height == None or height == "":
        # width 和 height = VNC_RESOLUTION 使用 x 分割
        vnc_resolution = os.getenv("VNC_RESOLUTION")
        if vnc_resolution.find("x") != -1:
            width = int(vnc_resolution.split("x")[0])
            height = int(vnc_resolution.split("x")[1])
        else:
            width = 1200
            height = 1000

    # 启动浏览器
    browser = p.chromium.launch_persistent_context(
        viewport={"width": width, "height": height},
        user_data_dir=user_data_dir,
        headless=False,
        proxy={"server": proxy_server},
        args=[
            "--remote-debugging-port=" + str(cdp_port),
            "--disable-blink-features=AutomationControlled",  # 禁用自动化控制标识
            "--disable-gpu",
            "--use-fake-device-for-media-stream",
            "--use-fake-ui-for-media-stream",
        ],
        # 关键指纹修改参数
        ignore_default_args=["--enable-automation"],
        java_script_enabled=True,
        color_scheme="dark",
        user_agent=user_agent,
    )
    
    print("浏览器启动成功")
    browser.wait_for_event("close", timeout=0)

    # 关闭浏览器
    # browser.close()
