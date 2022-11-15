rem Cài %_cd% gốc
set /p _cd=<_cd.txt
title 9CMD - by tanbt
:Menu
call :background
echo.           TOoL cHo CHín cÊ
echo.
echo [1] Bạn đã nhập file UTC chưa?
echo [2] Tính năng
echo [3] Kiểm tra cập nhật ^& Giới thiệu
echo.
echo.       Một sản phẩm make color :v
echo.       === Phiên bản: [0.6]===
choice /c 123 /n /m "Nhập từ bàn phím: "
if %errorlevel% == 1 (call %_cd%\Batch\enterUTC.bat)
if %errorlevel% == 2 (goto :tinhNang)
if %errorlevel% == 3 (start https://github.com/tandotbt/9CMD/releases & goto :GioiThieu)
:Background
cls
cd %_cd%
call %_cd%\Batch\Title9CMD.bat
exit /b
:GioiThieu
cls
cd %_cd%
call %_cd%\Batch\Titletanbt.bat
type %_cd%\README.md
echo.
echo.Nhấn phím bất kỳ để quay lại Menu
pause>nul
goto :Menu
:tinhNang
echo.
echo ==========
echo [1] Gửi NCG/Crystal
echo [2] Theo dõi Avatar
choice /c 12 /n /m "Nhập từ bàn phím: "
if %errorlevel% == 1 (call %_cd%\Batch\SendCurrency.bat)
if %errorlevel% == 2 (call %_cd%\Batch\avatarAddress\TrackedAvatar.bat)