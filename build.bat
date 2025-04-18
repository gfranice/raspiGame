@echo off
tasklist /FI "IMAGENAME eq vcxsrv.exe" 2>NUL | find /I /N "vcxsrv.exe">NUL
if "%ERRORLEVEL%" neq "0" (
    REM modificar carpeta si es diferente
    start "" "C:\Program Files\VcXsrv\vcxsrv.exe" :0 -multiwindow -ac -clipboard
    timeout /t 2 /nobreak >nul
)

SET DISPLAY=host.docker.internal:0.0

docker build -t raspberry-asm-dev .

docker run -it --rm -e DISPLAY=%DISPLAY% -v "%CD%":/project raspberry-asm-dev