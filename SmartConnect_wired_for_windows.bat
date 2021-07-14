@ECHO OFF

chcp 65001
SETLOCAL ENABLEDELAYEDEXPANSION

:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------


sc config "dot3svc" start= auto
net Start dot3svc

netsh lan show interfaces
netsh lan show interfaces > interfaces.txt

for /f "tokens=*" %%a in (interfaces.txt) do (
  set line=%%a
  set line=!line: =%!
  echo|set /p=%1

  echo !line! | find "Name:" >nul
  if errorlevel 1 (
    echo|set /p=%1
  ) else (
    for /f "tokens=2 delims=:" %%b in ("!line!") do (
      set interface=%%b
      echo|set /p=%1
    )
  )

  echo !line! | find "Connected" >nul
  if errorlevel 1 (
    echo|set /p=%1
  ) else (
    echo|set /p=%1
    netsh lan add profile filename=Ethernet.xml interface=!interface!
    netsh lan reconnect interface=!interface!
  )
)

netsh lan show profiles

pause
