import os
from pathlib import Path

ZH_DIR = Path("zh")          # 你的中文站目录（已生成的静态站）
OUT_ROOT = Path(".")         # 仓库根目录：在这里生成旧路径的跳转页
SKIP_PREFIXES = {"zh", "en", ".git"}  # 避免覆盖已有目录，可按需加

REDIRECT_TEMPLATE = """<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="refresh" content="0; url={target}">
  <link rel="canonical" href="{target}">
  <script>location.replace("{target}");</script>
</head>
<body>
  <p>Redirecting to <a href="{target}">{target}</a> ...</p>
</body>
</html>
"""

def should_skip(p: Path) -> bool:
    # 不处理 zh/en 内部（我们扫描的是 zh，但输出要避免覆盖）
    return any(part in SKIP_PREFIXES for part in p.parts)

def main():
    count = 0
    for src in ZH_DIR.rglob("*.html"):
        rel = src.relative_to(ZH_DIR)   # e.g. 1/xxx/index.html 或 assets/...
        # 只对内容页做兼容：通常你只需要 index.html 页面
        # 如果你希望所有 html 都兼容，把下面这一行注释掉
        if rel.name != "index.html":
            continue

        dst = OUT_ROOT / rel            # e.g. ./1/xxx/index.html
        if should_skip(dst):
            continue

        target = f"/zh/{rel.parent.as_posix()}/"  # 目标目录 URL
        dst.parent.mkdir(parents=True, exist_ok=True)
        dst.write_text(REDIRECT_TEMPLATE.format(target=target), encoding="utf-8")
        count += 1

    print(f"Generated {count} redirect pages.")

if __name__ == "__main__":
    main()
