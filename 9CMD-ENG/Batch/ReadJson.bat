rem Install %_cd% original
set /p _cd=<_cd.txt
echo ==========
echo Read file Json
jq "..|.%1?|select(.)" %2 > %_cd%\user\_Input.txt