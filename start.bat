@echo off
REM Run from project root (ASCII-only file: avoids cmd.exe misparsing UTF-8 Chinese on GBK systems)
cd /d "%~dp0"

REM First run: create venv and install deps (CUDA PyTorch then requirements.txt)
if not exist "venv\Scripts\activate.bat" (
  echo.
  echo [First run] Creating venv and installing dependencies, may take a long time...
  echo.
  python -m venv venv
  if not exist "venv\Scripts\activate.bat" (
    py -3 -m venv venv
  )
  if not exist "venv\Scripts\activate.bat" (
    echo [ERROR] Cannot create venv. Install Python 3 and ensure python or py is on PATH.
    pause
    exit /b 1
  )
  call venv\Scripts\activate.bat
  python -m pip install --upgrade pip
  echo.
  echo Installing CUDA PyTorch: torch, torchvision, torchaudio...
  pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
  if errorlevel 1 (
    echo [ERROR] CUDA PyTorch install failed. Check network or driver vs cu121 wheels.
    pause
    exit /b 1
  )
  echo.
  echo Installing requirements.txt...
  pip install -r requirements.txt
  if errorlevel 1 (
    echo [ERROR] requirements.txt install failed. Check network or errors above.
    pause
    exit /b 1
  )
  echo.
  echo [OK] Venv and dependencies are ready.
  echo.
)

call venv\Scripts\activate.bat
if errorlevel 1 (
  echo [ERROR] Cannot activate venv. Ensure venv folder exists and is valid.
  pause
  exit /b 1
)

echo.
echo Starting ComfyUI in a new window...
set HTTP_PROXY=http://127.0.0.1:7890
set HTTPS_PROXY=http://127.0.0.1:7890
start "ComfyUI" /D "%~dp0" cmd /k "call venv\Scripts\activate.bat && python main.py --enable-manager"

timeout /t 3 > nul

start http://127.0.0.1:8188

echo.
pause
