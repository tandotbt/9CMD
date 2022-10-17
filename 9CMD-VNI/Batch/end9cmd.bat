mode con:cols=100 lines=20
color 0B
rem Cài tiếng Việt Nam
chcp 65001
cls
rem Cài %_cd% gốc
set /p _cd=<_cd.txt
cd %_cd%
echo %1 && timeout %2