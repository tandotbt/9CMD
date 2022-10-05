rem Cài %_cd% gốc
set /p _cd=<_cd.txt
rem Nhận dữ liệu
set /p _node=<%_cd%\data\_node.txt
set /p _viA=<%_cd%\user\_viA.txt
rem Xóa khoảng trắng
set _node=%_node: =%
set _viA=%_viA: =%
rem Chon node trước
echo ==========
echo Chọn node hoạt động
echo.
call %_cd%\batch\miniChonNode.bat
rem Kiểm tra số dư ví (A)
echo ==========
echo Lấy số dư ví (A)
echo.
call %_cd%\batch\KTraSoDuCuaA.bat
rem Ghi giá trị của A
set /p _crystalCuaA=<%_cd%\data\_crystal.txt
set /p _ncgCuaA=<%_cd%\data\_ncg.txt
rem Làm tròn số NCG và Crystal
set /a "_ncgCuaA=%_ncgCuaA%"
set /a "_crystalCuaA=%_crystalCuaA%"
rem Kiểm tra ví (A)
echo ==========
echo Kiểm tra ví (A)
echo.
if not [%_ncgCuaA%] == [] (timeout 3 && goto :SoLuong) else (echo Lỗi 1: Ví A chưa đúng, nhập lại ví A sau đó thử lại... && color 4F && timeout 10 && exit /b)
:SoLuong
call :Background
echo.[1]Sử dụng node        : %_node%			NCG		CRYSTAL
echo.[2]Ví người gửi (A)    : %_viA:~0,7%***		%_ncgCuaA%		%_crystalCuaA%
echo ==========
echo Nhập loại tiền tệ và số lượng bạn muốn gửi đi
echo.
choice /c 12 /n /m "Gửi [1]NCG hoặc [2]Crystal: "
if %errorlevel% equ 1 (set _currency=NCG)
if %errorlevel% equ 2 (set _currency=CRYSTAL)
echo %_currency% > %_cd%\data\_currency.txt
rem Số lượng muốn gửi
set /p _soLuong="Số lượng: "
echo %_soLuong% > %_cd%\data\_soLuong.txt
goto :KTraSoLuong

:Background
cls
cd %_cd%
call %_cd%\Batch\TitleSendCurrency.bat
exit /b

:KTraSoLuong
rem Kiểm tra số lượng
echo ==========
echo Kiểm tra số lượng
echo.
if not [%_soLuong%] == [] (goto :KTraSoLuong2) else (echo Lỗi 1: Số lượng trống, thử lại... && color 4F && timeout 3 && goto :SoLuong)
rem Kiểm tra có là số hay không
:KTraSoLuong2
set "var="&for /f "delims=0123456789" %%i in ("%_soLuong%") do set var=%%i
if defined var (set /a _ktra=0) else (set /a _ktra=1)
if "%_ktra%" == "1" (goto :KTraSoLuong3) else (echo Lỗi 2: Số lượng không phải dạng số, thử lại... && color 4F && timeout 3 && goto :SoLuong)
rem Kiểm tra có nhỏ hơn số dư hay không
:KTraSoLuong3
if %_currency% == NCG (if %_soLuong% gtr %_ncgCuaA% (set /a _ktra=0))
if %_currency% == CRYSTAL (if %_soLuong% gtr %_crystalCuaA% (set /a _ktra=0))
if "%_ktra%" == "1" (timeout 1 && exit /b) else (echo Lỗi 3: Số lượng vượt quá số dư, thử lại... && color 4F && timeout 3 && goto :SoLuong)