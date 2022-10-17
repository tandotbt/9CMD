echo ==========
echo Lưu trữ mật khẩu cho ví (A)
echo Lưu ý: Tắt unikey trước khi nhập
rem Cài %_cd% gốc
set /p _cd=<_cd.txt
set password=1
rem Gõ mật khẩu ẩn
set /P "=_" < NUL > "Enter password"
findstr /A:1E /V "^$" "Enter password" NUL > CON
del "Enter password"
set /P "password="
cls
color 0B
rem Gửi mật khẩu vào file _PASSWORD.txt
cd %_cd%
echo %PASSWORD%> %_cd%\PASSWORD\_PASSWORD.txt
echo 1 > %_cd%\PASSWORD\_YorN.txt