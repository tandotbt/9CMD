rem Cài %_cd% gốc
set /p _cd=<_cd.txt
rem Nhận biến
set /p _node=<%_cd%\data\_node.txt
rem Xóa khoảng trắng
set _node=%_node: =%
rem Chon node trước
echo ==========
echo Chọn node hoạt động
echo.
call %_cd%\batch\miniChonNode.bat
rem Nhập
echo ==========
echo Nhập ví (A)
echo.
cd %_cd%\batch
set /p _viA="Nhập ví A: "
echo %_viA% > %_cd%\user\_viA.txt
rem Kiểm tra số dư
echo {"query":"query{stateQuery{agent(address:\"%_viA%\"){crystal}}goldBalance(address: \"%_viA%\" )}"} > input.json
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql > output.json
rem Lọc kết quả lấy dữ liệu
jq "..|.crystal?|select(.)|tonumber" output.json > %_cd%/data/_crystal.txt
jq "..|.goldBalance?|select(.)|tonumber" output.json > %_cd%/data/_ncg.txt
rem Xóa file nháp input và output
cd %_cd%\batch
del *.json
cd %_cd%
:KTraViA
rem Kiểm tra 
call :Background
echo ==========
echo Kiểm tra ví A
set /p _ncgCuaA=<%_cd%/data/_ncg.txt
set /p _crystalCuaA=<%_cd%/data/_crystal.txt
if not [%_ncgCuaA%] == [] (goto :NhapViOK) else (echo Lỗi 1: Ví A chưa đúng cú pháp 'phân biệt cả chữ hoa chữ thường', thử lại... && color 4F && timeout 10 && goto :NhapViA)
:NhapViOK
call :background
echo.[1]Sử dụng node        : %_node%			NCG		CRYSTAL
echo.[2]Ví người gửi (A)    : %_viA:~0,7%***		%_ncgCuaA%		%_crystalCuaA%
echo ==========
choice /c 12 /n /m "Nhập Public key ví (A):[1]9cscan [2]Planet"
if %errorlevel% equ 1 (goto :9cscanPublickey)
if %errorlevel% equ 2 (goto :PlanetPublickey)
:9cscanPublicKey
call :Background
echo ==========
echo Nhập Public Key của (A) bằng 9cscan
echo.
start https://9cscan.com/address/%_viA%
echo Đang mở 9cscan... bằng trình duyệt mặc định
echo Chọn 1 giao dịch mà ví (A) [SIGNED] KHÔNG PHẢI [INVOLVED]
echo Tìm đến mục Public key và copy
echo Lưu ý: Cách này cần chính xác, vì không tự động kiểm tra lại được Public Key!
echo Tùy chọn: nhập "waybackhome" để quay lại
set /p _PublicKeyCuaA="Dán Public key của A tại đây: "
if %_PublicKeyCuaA% == waybackhome goto :PPK
echo %_PublicKeyCuaA% > %_cd%\user\_PublicKeyCuaA.txt
echo ==========
echo Lấy Publick Key của ví (A) thành công
echo.
rem Đặt biến _IDKeyCuaA về 0 để lệnh lấy ignaturePlanet quay lại kiểm tra
set _IDKeyCuaA=0
echo %_IDKeyCuaA% > %_cd%\user\_IDKeyCuaA.txt
timeout 3
exit /b
:PlanetPublickey
rem Chon node trước
echo ==========
echo Chọn node hoạt động
echo.
call %_cd%\batch\miniChonNode.bat
call :background
echo ==========
echo Nhập Public Key của (A) bằng Planet
echo.
call %_cd%\batch\LayIDKeyCuaA.bat
echo ==========
echo Lấy Key ID của ví (A) thành công
echo.
call :background
rem Nhận biến
set /p _YorN=<%_cd%\PASSWORD\_YorN.txt
set /p _exit9cmd=<%_cd%\data\_exit9cmd.txt
set /p _IDKeyCuaA=<%_cd%\user\_IDKeyCuaA.txt
rem Xóa khoảng trắng
set _YorN=%_YorN: =%
set _exit9cmd=%_exit9cmd: =%
set _IDKeyCuaA=%_IDKeyCuaA: =%
rem Nếu không có file UTC, chương trình sẽ thoát
if "%_exit9cmd%"=="1" (set _exit9cmd=0 && echo %_exit9cmd% > %_cd%\data\_exit9cmd.txt && call :background && call %_cd%\batch\end9cmd.bat "Không thể tìm thấy file UTC, thoát chương trình sau 10s..." 10 && exit)
rem Lấy Publick key bằng Planet
call %_cd%\batch\LayPublicKeyPlanet.bat
rem Quay lại 9cscanPublickey
set /p _password=<%_cd%\PASSWORD\_PASSWORD.txt
if %_password% == waybackhome goto :SoLuongOK
set "_password="
rem Xóa file _KTraPPK.txt trong Planet
del /q %_cd%\planet\_KTraPPK.txt
rem Nhận Public Key
echo ==========
echo Lấy Public Key của ví (A) thành công
echo.
exit /b
:Background
cls
cd %_cd%
call %_cd%\Batch\TitleSendCurrency.bat
exit /b
:NhapViA
call :Background
echo ==========
echo Nhập ví (A)
echo.
cd %_cd%\batch
set /p _viA="Nhập ví A: "
echo %_viA% > %_cd%\user\_viA.txt
rem Kiểm tra số dư
echo {"query":"query{stateQuery{agent(address:\"%_viA%\"){crystal}}goldBalance(address: \"%_viA%\" )}"} > input.json
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql > output.json
rem Lọc kết quả lấy dữ liệu
jq "..|.crystal?|select(.)|tonumber" output.json > %_cd%/data/_crystal.txt
jq "..|.goldBalance?|select(.)|tonumber" output.json > %_cd%/data/_ncg.txt
rem Xóa file nháp input và output
cd %_cd%\batch
del *.json
cd %_cd%
goto :KTraViA