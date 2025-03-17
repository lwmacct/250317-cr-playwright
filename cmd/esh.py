import os
import subprocess


def esh(command: str, env_vars: dict = None, timeout: int = None) -> dict:
    # 合并当前环境变量和自定义环境变量
    env = os.environ.copy()
    if env_vars:
        env.update(env_vars)

    # 优先使用 /bin/bash，如果不存在则回退到 /bin/sh
    shell_executable = "/bin/bash" if os.path.exists(
        "/bin/bash") else "/bin/sh"

    try:
        result = subprocess.run(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            shell=True,
            executable=shell_executable,  # 指定使用的 shell
            env=env,
            timeout=timeout
        )
        return {
            "stdout": result.stdout,
            "stderr": result.stderr,
            "returncode": result.returncode,
        }
    except subprocess.TimeoutExpired as e:
        return {
            "stdout": e.stdout if e.stdout is not None else "",
            "stderr": f"TimeoutExpired: {e}",
            "returncode": -1,
        }
    except Exception as e:
        return {
            "stdout": "",
            "stderr": str(e),
            "returncode": -1,
        }


# 模块测试入口
if __name__ == "__main__":
    test_command = "echo 'Hello from improved execute_shell_command'"
    result = esh(test_command, timeout=5)
    print("测试命令输出:\n", result["stdout"])
