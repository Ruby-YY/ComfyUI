@echo off
setlocal enabledelayedexpansion

rem Base directory for models
set "base=E:\yy\aigc\base\ComfyUI\models"

rem Prefer `hf download` to avoid huggingface-cli deprecation warning
where hf >nul 2>nul
if errorlevel 1 (
  rem Fallback to huggingface-cli if hf is not available
  where huggingface-cli >nul 2>nul
  if errorlevel 1 (
    echo 未找到命令：hf / huggingface-cli
    echo 请先在全局安装 huggingface_hub，然后再运行本脚本：
    echo   py -m pip install --upgrade huggingface_hub
    exit /b 1
  )
  set "USE_HF=0"
) else (
  set "USE_HF=1"
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

rem ===== Download SDXL VAE =====
if "%USE_HF%"=="1" (
  hf download stabilityai/sdxl-vae ^
    --include "sdxl_vae.safetensors" ^
    --local-dir "%checkpointsDir%"
) else (
  huggingface-cli download stabilityai/sdxl-vae ^
    --include "sdxl_vae.safetensors" ^
    --local-dir "%checkpointsDir%" ^
    --local-dir-use-symlinks False
)

rem ===== AnimateDiff =====
rem hf download guoyww/animatediff ^
rem   --include "mm_sd_v15_v2.ckpt" ^
rem   --local-dir "%motionModulesDir%" ^

rem ===== IPAdapter =====
rem hf download h94/IP-Adapter ^
rem   --include "ip-adapter-plus_sdxl.safetensors" ^
rem   --local-dir "%ipAdapterDir%" ^

rem ===== CLIP Vision =====
rem hf download h94/IP-Adapter ^
rem   --include "models/image_encoder/model.safetensors" ^
rem   --local-dir "%clipVisionDir%" ^