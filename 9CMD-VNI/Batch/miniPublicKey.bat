rem Cài %_cd% gốc
set /p _cd=<_cd.txt
rem Nhận dữ liệu
set /p _viA=<%_cd%\user\_viA.txt
rem Xóa khoảng trắng
set _viA=%_viA: =%
rem Sử dụng 9cscan hay Planet
:PPK
echo ==========
echo [1]Sử dụng 9cscan
echo [2]Sử dụng Planet
echo.
choice /c 12 /n /m "Nhập từ bàn phím: "
if %errorlevel% equ 1 (goto :9cscanPublicKey)
if %errorlevel% equ 2 (goto :PlanetPublickey)
rem Nhập PK
:9cscanPublicKey
call :Background
echo ==========
echo Nhập Public Key của (A) bằng 9cscan
echo.
cd %_cd%\batch
rem --ssl-no-revoke sửa lỗi
curl --ssl-no-revoke --header "Content-Type: application/json" https://api.9cscan.com/accounts/%_viA%/transactions?action=activate_account 2>nul|findstr /i signed> output.json 2>nul
if %errorlevel% == 0 (goto :9cscanPublicKey2)
:9cscanPublicKey1
curl --ssl-no-revoke --header "Content-Type: application/json" https://api.9cscan.com/accounts/%_viA%/transactions?action=activate_account2 2>nul|findstr /i signed> output.json 2>nul
:9cscanPublicKey2
rem Lọc kết quả lấy dữ liệu
echo ==========
echo Tìm publicKey của (A)...
echo.
cd %_cd%\batch
jq -r "..|.publicKey?|select(.)" output.json> %_cd%\user\_PublicKeyCuaA.txt
rem Xóa file nháp input và output
cd %_cd%\batch
del *.json
echo ==========
echo Lấy Public Key của ví (A) thành công
echo.
rem Đặt biến _IDKeyCuaA về 0 để lệnh lấy signaturePlanet quay lại kiểm tra
set _IDKeyCuaA=0
echo %_IDKeyCuaA% > %_cd%\user\_IDKeyCuaA.txt
timeout 3
exit /b
:Background
cls
cd %_cd%
call %_cd%\Batch\TitleMini.bat 3
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