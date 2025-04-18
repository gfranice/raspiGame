@echo off
SET DISPLAY=host.docker.internal:0.0

docker build -t raspberry-asm-dev .

docker run -it --rm -e DISPLAY=%DISPLAY% -v "%CD%":/project raspberry-asm-dev