rem Cài %_cd% gốc
set /p _cd=<_cd.txt
title 9CMD - by tanbt
:Menu
call :background
echo.           TOoL cHo CHín cÊ
echo.
echo [1] Gửi NCG/Crystal
echo [2] Kiểm tra cập nhật
echo.[3] Giới thiệu
echo.
echo.       Một sản phẩm make color :v
echo.         ==Phiên bản: [0.1]===
choice /c 123 /n /m "Nhập từ bàn phím: "
if %errorlevel% == 1 (call %_cd%\Batch\SendCurrency.bat && exit /b)
if %errorlevel% == 2 (start https://github.com/tandotbt/9CMD/releases && goto :Menu)
if %errorlevel% == 3 (goto :GioiThieu)
:Background
cls
cd %_cd%
call %_cd%\Batch\Title9CMD.bat
exit /b
:GioiThieu
cls
cd %_cd%
call %_cd%\Batch\Titletanbt.bat
echo.
echo.9CMD tạo bởi tanbt#9827
echo.
echo.Công cụ có sử dụng JQ để đọc file Json https://stedolan.github.io/jq/
echo.Planet 0.42.2 win x64 tại https://github.com/planetarium/libplanet/releases
echo.Vài đoạn mã lấy trên mạng như gõ mật khẩu ẩn, lấy dữ liệu từ kết quả của mã trước đó,... đã được xem qua và có vẻ an toàn :like:
echo.Theo dõi kênh Youtube của tôi để biết thêm vài mẹo hữu ích cho Nine Chronicles tại
echo.https://www.youtube.com/c/tanbt
echo.
echo.Thư mục PASSWORD và USER bạn có thể xóa, còn lại thì không :penguin: 
echo.Do tool cần nhập mật khẩu, tải ở github của tôi sẽ an toàn, tải tool ở nơi khác về bay acc xin phép không chịu trách nhiệm :v
echo.
echo.Gửi tôi cốc crystal qua ví 0x6374FE5F54CdeD72Ff334d09980270c61BC95186 :vv
echo.
echo ==========
echo.From Việt Nam, ưhit love!
echo.Nhấn phím bất kỳ để quay lại Menu
pause>nul
goto :Menu