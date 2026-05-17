@echo off
chcp 65001 >nul
set "SCRIPT=%~dp0tcp_ctrl.ahk"
set "AHK="

if exist "%ProgramFiles%\AutoHotkey\v2\AutoHotkey64.exe" set "AHK=%ProgramFiles%\AutoHotkey\v2\AutoHotkey64.exe"
if exist "%LocalAppData%\Programs\AutoHotkey\v2\AutoHotkey64.exe" set "AHK=%LocalAppData%\Programs\AutoHotkey\v2\AutoHotkey64.exe"
if exist "%ProgramFiles%\AutoHotkey\AutoHotkey.exe" set "AHK=%ProgramFiles%\AutoHotkey\AutoHotkey.exe"

if "%AHK%"=="" (
    echo [错误] 未找到 AutoHotkey，请先安装 v2: https://www.autohotkey.com/
    pause
    exit /b 1
)

echo 使用: %AHK%
echo 脚本: %SCRIPT%
echo.
echo 若启动失败，窗口会显示报错；也可查看 tcp_ctrl.log
echo 成功时进程名一般为 AutoHotkey64.exe，托盘可能有绿色 H 图标（可能被折叠）
echo.

"%AHK%" /ErrorStdOut "%SCRIPT%"
echo.
echo 退出码: %ERRORLEVEL%
if exist "%~dp0tcp_ctrl.log" (
    echo.
    echo --- tcp_ctrl.log 最后几行 ---
    powershell -NoProfile -Command "Get-Content -LiteralPath '%~dp0tcp_ctrl.log' -Tail 15 -Encoding UTF8"
)
echo.
pause
