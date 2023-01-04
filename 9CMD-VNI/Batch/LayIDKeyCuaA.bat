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
planet key --path %_cd%\user\utc> _allKey.txt
type _allKey.txt
findstr /L %_viA% _allKey.txt >_IDKeyCuaA.txt
set "_IDKeyCuaA="
set /p _IDKeyCuaA=<_IDKeyCuaA.txt
rem Kiểm tra ID Key
echo ==========
echo Kiểm tra Key ID
echo.
if not "%_IDKeyCuaA%" == "" (goto :YesUTC) else (goto :NoUTC)


:utcFile
cd %_cd%\planet
set _utcfile=^|planet key --path %_cd%\user\utc 2>nul|findstr /i %_viA%>nul
if %errorlevel% equ 0 (goto :tryagain)
echo.
echo.Kéo thả file UTC hoặc thư mục chứa UTC của ví %_viA:~0,7%***
echo.Chú ý: nếu thư mục nhập có khoảng trắng sẽ không thành công!
echo.Nhập 'skip' để bỏ qua
echo.===
set /p _nhapUTC="Kéo thả và nhấn Enter để nhập: "
set _nhapUTC=%_nhapUTC: =%
if "%_nhapUTC%" == "skip" (set "_nhapUTC=" & goto :tryagain)
echo a | copy /-y "%_nhapUTC%" "%_cd%\user\UTC\">nul
goto :utcFile
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
planet key --path %_cd%\user\utc> _allKey.txt
type _allKey.txt
findstr /L %_viA% _allKey.txt >_IDKeyCuaA.txt
set "_IDKeyCuaA="
set /p _IDKeyCuaA=<_IDKeyCuaA.txt
rem Kiểm tra ID Key
echo ==========
echo Kiểm tra Key ID
echo.
if not "%_IDKeyCuaA%" == "" (goto :YesUTC) else (goto :NoUTC)

:NoUTC
echo ==========
echo Không tìm thấy file UTC của (A) trong thư mục UTC đã lưu
echo.
color 4F
cd %_cd%\planet
rem Xóa file txt trong planet
del *.txt
copy "%_cd%\data\_cd.txt" "%_cd%\planet\_cd.txt">nul
goto :errorUTC

:errorUTC
echo ==========
echo [1]Nhập file UTC và tìm kiếm Key ID lại
echo [2]Nhập lại ví (A)
echo [3]Thoát tool
choice /c 123 /n /m "Nhập từ bàn phím..."
if %errorlevel% equ 1 (color 0B & goto :utcFile)
if %errorlevel% equ 2 (color 0B && call %_cd%\batch\miniNhapViA.bat && exit /b)
if %errorlevel% equ 3 (call :background && call %_cd%\batch\end9cmd.bat "Không thể tìm thấy file UTC, thoát chương trình sau 10s..." 10 && exit)

:YesUTC
echo ==========
echo Lấy Key ID của ví (A) thành công
echo.
echo %_IDKeyCuaA:~0,36% > %_cd%\user\_IDKeyCuaA.txt
rem Xóa file txt trong planet
del *.txt
copy "%_cd%\data\_cd.txt" "%_cd%\planet\_cd.txt">nul
timeout 3
:Background
cls
cd %_cd%
call %_cd%\Batch\TitleSendCurrency.bat
exit /b