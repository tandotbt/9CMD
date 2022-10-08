mode con:cols=100 lines=20
color 0B
rem Install Vietnamese
chcp 65001
cls
rem Install %_cd% original
set /p _cd=<_cd.txt
cd %_cd%
echo %1 && timeout %2