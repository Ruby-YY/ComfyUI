import argparse
import shutil
import subprocess
import sys
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "下载 Hugging Face 仓库到 ComfyUI/models 下指定目录。"
            "示例: py tools/hf_cli.py Wan-AI/Wan2.1-I2V-14B-480P diffusion_models *.safetensors"
        )
    )
    parser.add_argument("repo_id", help='Hugging Face 仓库 ID，例如 "Wan-AI/Wan2.1-I2V-14B-480P"')
    parser.add_argument(
        "models_subdir",
        help='models 下的子目录，例如 "diffusion_models"（会下载到 models/diffusion_models）',
    )
    parser.add_argument(
        "include_pattern",
        nargs="?",
        default="*.safetensors",
        help='可选：第三个参数，指定要下载的文件名或通配符，默认 "*.safetensors"',
    )
    parser.add_argument(
        "--include",
        action="append",
        default=[],
        help="可选：追加多个下载匹配模式，可重复传入多次",
    )
    parser.add_argument(
        "--all-files",
        action="store_true",
        help="下载仓库全部文件（关闭默认 *.safetensors 过滤）",
    )
    return parser.parse_args()


def resolve_project_root() -> Path:
    # 当前文件在 tools/hf_cli.py，项目根目录是上一级的上一级
    return Path(__file__).resolve().parent.parent


def resolve_hf_command() -> str:
    # huggingface-cli 已逐步废弃，优先使用 hf
    if shutil.which("hf"):
        return "hf"
    if shutil.which("huggingface-cli"):
        return "huggingface-cli"
    raise FileNotFoundError(
        "未找到 huggingface-cli 或 hf 命令，请先安装 huggingface_hub：\n"
        "  py -m pip install --upgrade huggingface_hub"
    )


def build_command(cli: str, repo_id: str, target_dir: Path, includes: list[str]) -> list[str]:
    cmd = [cli, "download", repo_id, "--local-dir", str(target_dir)]
    if cli == "huggingface-cli":
        cmd += ["--local-dir-use-symlinks", "False"]
    for pattern in includes:
        cmd += ["--include", pattern]
    return cmd


def main() -> int:
    args = parse_args()
    project_root = resolve_project_root()
    repo_name = args.repo_id.rstrip("/").split("/")[-1]
    target_dir = project_root / "models" / args.models_subdir / repo_name
    target_dir.mkdir(parents=True, exist_ok=True)

    try:
        cli = resolve_hf_command()
    except FileNotFoundError as exc:
        print(exc)
        return 1

    includes = [] if args.all_files else [args.include_pattern] + list(args.include)

    command = build_command(cli, args.repo_id, target_dir, includes)
    print("执行命令：")
    print(" ".join(f'"{part}"' if " " in part else part for part in command))
    print(f"下载目录：{target_dir}")

    completed = subprocess.run(command, cwd=str(project_root))
    return completed.returncode


if __name__ == "__main__":
    sys.exit(main())
