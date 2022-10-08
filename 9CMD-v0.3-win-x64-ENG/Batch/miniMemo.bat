rem Install %_cd% original
set /p _cd=<_cd.txt
echo ==========
echo Enter the included message
echo Note: The message only includes A-Z, a-z, 0-9, # $ ' ( ) * + , - . ? @ [ ] _ ` { } ~
echo Use other special characters or spaces will crash tool!
echo.
del /q %_cd%\data\_memo.txt
set _memo=Send_currency
set /p _memo="Message: "
echo %_memo%>%_cd%\data\_memo.txt <nul