rem Install %_cd% original
set /p _cd=<_cd.txt
rem Get data
set /p _viA=<%_cd%\user\_viA.txt
rem Delete spaces
set _viA=%_viA: =%
rem Use 9cscan or Planet
:PPK
echo ==========
echo [1]Use 9cscan
echo [2]Use Planet
echo.
choice /c 12 /n /m Enter from the keyboard: "
if %errorlevel% equ 1 (goto :9cscanPublicKey)
if %errorlevel% equ 2 (goto :PlanetPublickey)
rem Enter Public Key
:9cscanPublicKey
call :Background
echo ==========
echo Enter Public key of (A) by 9cscan
echo.
start https://9cscan.com/address/%_viA%
echo Open 9cscan... by default browser
echo Choose 1 transaction of wallet (A) [SIGNED] NOT [INVOLVED]
echo Find the Public key and copy
echo Note: This method needs to be accurate, because it does not automatically check the Public Key!
echo Optional: Enter "waybackhome" to return
set /p _PublicKeyCuaA="Paste Public Key here: "
if %_PublicKeyCuaA% == waybackhome goto :PPK
echo %_PublicKeyCuaA% > %_cd%\user\_PublicKeyCuaA.txt
echo ==========
echo Get the Public Key of the wallet (A) success
echo.
rem Set _IDKeyCuaA to 0
set _IDKeyCuaA=0
echo %_IDKeyCuaA% > %_cd%\user\_IDKeyCuaA.txt
timeout 3
exit /b
:Background
cls
cd %_cd%
call %_cd%\Batch\TitleSendCurrency.bat
exit /b
:PlanetPublickey
rem Select Node first
echo ==========
echo Select Node
echo.
call %_cd%\batch\miniChonNode.bat
call :background
echo ==========
echo Enter Public Key of (A) by Planet
echo.
call %_cd%\batch\LayIDKeyCuaA.bat
echo ==========
echo Get the Key ID of the wallet (A) success
echo.
call :background
rem Receive variable
set /p _YorN=<%_cd%\PASSWORD\_YorN.txt
set /p _IDKeyCuaA=<%_cd%\user\_IDKeyCuaA.txt
rem Delete spaces
set _YorN=%_YorN: =%
set _IDKeyCuaA=%_IDKeyCuaA: =%
rem Get Public Key by Planet
call %_cd%\batch\LayPublicKeyPlanet.bat
set "_password="
rem Return 9cscanPublickey
set /p _password=<%_cd%\PASSWORD\_PASSWORD.txt
if %_password% == waybackhome goto :SoLuongOK
rem Delete file _KTraPPK.txt
del /q %_cd%\planet\_KTraPPK.txt
rem Get Public Key
echo ==========
echo Get Public Key of wallet (A) succeed
echo.
timeout 3
exit /b