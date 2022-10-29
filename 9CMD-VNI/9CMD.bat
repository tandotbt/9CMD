echo  off
mode con:cols=39 lines=20
color 0B
rem Cài tiếng Việt Nam
chcp 65001
cls
rem Tạo _cd.txt
echo ==========
echo Cài file cd
echo.Lưu ý: Tên thư mục chứa 9CMD
echo.KHÔNG ĐƯỢC CÓ KHOẢNG TRẮNG
echo.có thì không chạy được :vv
set _cd=%cd%
echo %_cd%>_cd.txt
rem Copy _cd.txt cho tất cả thư mục
copy "%_cd%\_cd.txt" "%_cd%\batch\_cd.txt">nul
copy "%_cd%\_cd.txt" "%_cd%\planet\_cd.txt">nul
copy "%_cd%\_cd.txt" "%_cd%\user\_cd.txt">nul
copy "%_cd%\_cd.txt" "%_cd%\PASSWORD\_cd.txt">nul
copy "%_cd%\_cd.txt" "%_cd%\data\_cd.txt">nul
copy "%_cd%\_cd.txt" "%_cd%\data\avatarAddress\_cd.txt">nul
copy "%_cd%\_cd.txt" "%_cd%\batch\avatarAddress\_cd.txt">nul
copy "%_cd%\_cd.txt" "%_cd%\user\avatarAddress\_cd.txt">nul
timeout 20
call %_cd%\batch\enterUTC.bat