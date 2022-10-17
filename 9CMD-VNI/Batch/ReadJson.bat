rem Cài %_cd% gốc
set /p _cd=<_cd.txt
echo ==========
echo Đọc file Json
jq "..|.%1?|select(.)" %2 > %_cd%\user\_Input.txt