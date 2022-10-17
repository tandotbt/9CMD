echo ==========
echo Save password for wallets (A)
echo Note: Turn off Unikey before entering
rem Install %_cd% original
set /p _cd=<_cd.txt
set password=1
rem Gõ mật khẩu ẩn
set /P "=_" < NUL > "Enter password"
findstr /A:1E /V "^$" "Enter password" NUL > CON
del "Enter password"
set /P "password="
cls
color 0B
rem Save to file _PASSWORD.txt
cd %_cd%
echo %PASSWORD%> %_cd%\PASSWORD\_PASSWORD.txt
echo 1 > %_cd%\PASSWORD\_YorN.txt