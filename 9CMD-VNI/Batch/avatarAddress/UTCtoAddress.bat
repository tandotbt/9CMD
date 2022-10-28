echo ==========
echo Xuất địa chỉ ví từ thư mục UTC
rem Cài %_cd% gốc
set /p _cd=<_cd.txt
cd %_cd%
rem Nhận biến
set /p _node=<%_cd%\data\_node.txt
rem Xóa khoảng trắng
set _node=%_node: =%
rem Chuyển tất cả UTC thành Address
cd %_cd%\user\avatarAddress
set _i=1
for /f "tokens=*" %%a in (utc.txt) do (call :processline %%a)
exit /b
goto :eof
:processline
set _vi=%* & set _vi1=%_vi:~-43,-1%
echo %_vi:~-43,-1%  >> %_cd%\user\avatarAddress\oldData.txt & set /a _i+=1
goto :eof
:eof