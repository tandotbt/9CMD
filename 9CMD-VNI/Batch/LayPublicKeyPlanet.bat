rem Cài %_cd% gốc
set /p _cd=<_cd.txt
cd %_cd%\batch
rem Nhận biến
set /p _YorN=<%_cd%\PASSWORD\_YorN.txt
set /p _PASSWORD=<%_cd%\PASSWORD\_PASSWORD.txt
set /p _IDKeyCuaA=<%_cd%\user\_IDKeyCuaA.txt
rem Xóa khoảng trắng
set _IDKeyCuaA=%_IDKeyCuaA: =%
set _YorN=%_YorN: =%
set _PASSWORD=%_PASSWORD: =%
rem Kiểm tra đã lấy Key ID của ví (A) chưa
set /p _IDKeyCuaA=<%_cd%\user\_IDKeyCuaA.txt
set _IDKeyCuaA=%_IDKeyCuaA: =%
if "%_IDKeyCuaA%" == "0" (call %_cd%\batch\LayIDKeyCuaA.bat)
if "%_YorN%" == "0" (goto :tryagainWithPass) else (goto :tryagainNoPass)
:tryagainWithPass
call :background
set _password=1
set _ktra=0
set /p _IDKeyCuaA=<%_cd%\user\_IDKeyCuaA.txt
set _IDKeyCuaA=%_IDKeyCuaA: =%
echo Tùy chọn: nhập "waybackhome" để quay lại
echo Nhập mật khẩu thủ công: 
echo Lưu ý: Tắt unikey trước khi nhập
set /P "=_" < NUL > "Enter password"
findstr /A:1E /V "^$" "Enter password" NUL > CON
del "Enter password"
set /P "_password="
call :background
rem Quay lại 9cscanPublickey
if %_password% == waybackhome (echo waybackhome>%_cd%\PASSWORD\_PASSWORD.txt && exit /b)
if %_password% == checkcheck (start https://youtu.be/SRf8pTXPz9I?t=26s)
rem Lấy Public Key của A
cd %_cd%\planet
set _PublicKeyCuaA=^|planet key export --passphrase %_PASSWORD% --public-key --path %_cd%\user\utc %_IDKeyCuaA%
echo %_PublicKeyCuaA% > %_cd%\planet\_KTraPPK.txt
set "_PASSWORD="
goto :KTraPPK2
:tryagainNoPass
call :background
rem Lấy lại _IDKeyCuaA
set /p _IDKeyCuaA=<%_cd%\user\_IDKeyCuaA.txt
set _IDKeyCuaA=%_IDKeyCuaA: =%
echo Sử dụng mật khẩu đã lưu từ thư mục PASSWORD
cd %_cd%\planet
set _PublicKeyCuaA=^|planet key export --passphrase %_PASSWORD% --public-key --path %_cd%\user\utc %_IDKeyCuaA%
echo %_PublicKeyCuaA% > %_cd%\planet\_KTraPPK.txt
set "_PASSWORD="
goto :KTraPPK1
rem Kiểm tra xem có là Publick key hay không
:KTraPPK1
set "_KTraPPK="
set /p _KTraPPK=<%_cd%\planet\_KTraPPK.txt
if [%_KTraPPK%] == [] (echo Lỗi 1: Mật khẩu cài trong file PASSWORD chưa đúng, thử lại... && color 4F && set _YorN=0 && echo %_YorN% > %_cd%\PASSWORD\_YorN.txt && timeout 10 && goto :tryagainWithPass) else (goto :YesPPK)
:KTraPPK2
set "_KTraPPK="
set /p _KTraPPK=<%_cd%\planet\_KTraPPK.txt
if [%_KTraPPK%] == [] (echo Lỗi 2: Nhập sai mật khẩu, thử lại... && color 4F && set _YorN=0 && echo %_YorN% > %_cd%\PASSWORD\_YorN.txt && echo 0 > %_cd%\PASSWORD\_PASSWORD.txt && timeout 10 && goto :tryagainWithPass) else (goto :YesPPK)

:YesPPK
cd %_cd%
call %_cd%\Batch\TitleSendCurrency.bat
echo ==========
echo Nhập Public Key của (A) bằng Planet
echo.
echo ==========
echo Nhập Public Key của (A) thành công
echo %_KTraPPK% > %_cd%\user\_PublicKeyCuaA.txt
exit /b
:background
cd %_cd%
call %_cd%\Batch\TitleSendCurrency.bat
echo ==========
echo Nhập Public Key của (A) bằng Planet
echo.
echo ==========
echo Đang lấy Public Key của (A)
echo.