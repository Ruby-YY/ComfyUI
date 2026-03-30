@echo off
setlocal enabledelayedexpansion

rem Base directory for models
set "base=E:\yy\aigc\base\ComfyUI\models"

rem Ensure huggingface-cli is available (do not auto-install)
where huggingface-cli >nul 2>nul
if errorlevel 1 (
  echo 未找到命令：huggingface-cli
  echo 请先在全局安装 huggingface_hub，然后再运行本脚本：
  echo   py -m pip install --upgrade huggingface_hub
  exit /b 1
)

rem Create target directories if missing
set "checkpointsDir=%base%\checkpoints"
if not exist "%checkpointsDir%" mkdir "%checkpointsDir%"

set "motionModulesDir=%base%\motion_modules"
if not exist "%motionModulesDir%" mkdir "%motionModulesDir%"

set "ipAdapterDir=%base%\ipadapter"
if not exist "%ipAdapterDir%" mkdir "%ipAdapterDir%"

set "clipVisionDir=%base%\clip_vision"
if not exist "%clipVisionDir%" mkdir "%clipVisionDir%"

rem ===== Download SDXL =====
huggingface-cli download stabilityai/stable-diffusion-xl-base-1.0 ^
  --include "sd_xl_base_1.0.safetensors" ^
  --local-dir "%checkpointsDir%" ^
  --local-dir-use-symlinks False

rem ===== AnimateDiff =====
rem huggingface-cli download guoyww/animatediff ^
rem   --include "mm_sd_v15_v2.ckpt" ^
rem   --local-dir "%motionModulesDir%" ^
rem   --local-dir-use-symlinks False

rem ===== IPAdapter =====
rem huggingface-cli download h94/IP-Adapter ^
rem   --include "ip-adapter-plus_sdxl.safetensors" ^
rem   --local-dir "%ipAdapterDir%" ^
rem   --local-dir-use-symlinks False

rem ===== CLIP Vision =====
rem huggingface-cli download h94/IP-Adapter ^
rem   --include "models/image_encoder/model.safetensors" ^
rem   --local-dir "%clipVisionDir%" ^
rem   --local-dir-use-symlinks False