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
cd %_cd%\batch
curl --header "Content-Type: application/json" https://api.9cscan.com/accounts/%_viA%/transactions?action=activate_account^&action=activate_account2^&action=unlock_equipment_recipe^&action=grinding^&limit=1> output.json
rem Lọc kết quả lấy dữ liệu
echo ==========
echo Tìm publicKey của (A)...
echo.
cd %_cd%\batch
call %_cd%\batch\ReadJson.bat publicKey output.json
call %_cd%\batch\XoaNhay.bat
copy %_cd%\user\_Output.txt %_cd%\user\_PublicKeyCuaA.txt
rem Xóa file nháp input và output
cd %_cd%\batch
del *.json
echo ==========
echo Lấy Public Key của ví (A) thành công
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
set /p _IDKeyCuaA=<%_cd%\user\_IDKeyCuaA.txt
rem Xóa khoảng trắng
set _YorN=%_YorN: =%
set _IDKeyCuaA=%_IDKeyCuaA: =%
rem Lấy Publick key bằng Planet
call %_cd%\batch\LayPublicKeyPlanet.bat
set "_password="
rem Quay lại 9cscanPublickey
set /p _password=<%_cd%\PASSWORD\_PASSWORD.txt
if %_password% == waybackhome goto :SoLuongOK
rem Xóa file _KTraPPK.txt trong Planet
del /q %_cd%\planet\_KTraPPK.txt
rem Nhận Public Key
echo ==========
echo Lấy Public Key của ví (A) thành công
echo.
timeout 3
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