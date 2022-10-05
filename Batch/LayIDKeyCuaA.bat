rem Cài %_cd% gốc
set /p _cd=<_cd.txt
rem Nhận biến
set /p _viA=<%_cd%\user\_viA.txt
rem Xóa khoảng trắng
set _viA=%_viA: =%
echo ==========
echo Đang lấy ID Key của (A)
echo.
cd %_cd%\planet
planet key > _allKey.txt
sort _allKey.txt
findstr /L %_viA% _allKey.txt >_IDKeyCuaA.txt
set /p _IDKeyCuaA=<_IDKeyCuaA.txt
rem Kiểm tra ID Key
echo ==========
echo Kiểm tra Key ID
echo.
If "%_IDKeyCuaA%" NEQ "" (goto :YesUTC) else (goto :NoUTC)

:tryagain
cls
cd %_cd%
call %_cd%\Batch\TitleSendCurrency.bat
echo ==========
echo Nhập Public Key của (A) bằng Planet
echo.
echo ==========
echo Đang lấy Key ID của (A), chờ một chút...
cd %_cd%\planet
planet key > _allKey.txt
sort _allKey.txt
findstr %_viA% _allKey.txt>_IDKeyCuaA.txt
set /p _IDKeyCuaA=<_IDKeyCuaA.txt
If "%_IDKeyCuaA%" NEQ "" (goto :YesUTC) else (goto :NoUTC)


:NoUTC
echo ==========
echo Không tìm thấy file UTC của (A) trong thư mục Keystore
echo.
color 4F
cd %_cd%\planet
rem Xóa file txt trong planet
del *.txt
copy "%_cd%\data\_cd.txt" "%_cd%\planet\_cd.txt"
goto :errorUTC

:errorUTC
echo ==========
echo Kiểm tra lại thư mục Keystore và...
echo [1]Thử lại tìm kiếm Key ID
echo [2]Nhập lại ví (A)
echo [3]Thoát tool
choice /c 123 /n /m "Nhập từ bàn phím..."
if %errorlevel% equ 1 (goto :tryagain)
if %errorlevel% equ 2 (color 0B && call %_cd%\batch\miniNhapViA.bat && exit /b)
if %errorlevel% equ 3 (echo 1 > %_cd%\data\_exit9cmd.txt && exit /b)

:YesUTC
echo ==========
echo Lấy Key ID của ví (A) thành công
echo.
echo %_IDKeyCuaA:~0,36% > %_cd%\user\_IDKeyCuaA.txt
echo 0 > %_cd%\data\_exit9cmd.txt
rem Xóa file txt trong planet
del *.txt
copy "%_cd%\data\_cd.txt" "%_cd%\planet\_cd.txt"
timeout 10
goto :eof