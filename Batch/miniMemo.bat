rem Cài %_cd% gốc
set /p _cd=<_cd.txt
rem Nhập node
echo ==========
echo Nhập lời nhắn đi kèm
echo Lưu ý: Lời nhắn chỉ gồm A-Z, a-z, 0-9, # $ ' ( ) * + , - . ? @ [ ] _ ` { } ~
echo Sử dụng một vài ký tự đặc biệt khác hoặc khoảng trắng sẽ khiến tool crash!
echo.
del /q %_cd%\data\_memo.txt
set _memo=Send_currency
set /p _memo="Lời nhắn: "
echo %_memo%>%_cd%\data\_memo.txt <nul