rem Install %_cd% original
set /p _cd=<_cd.txt
cd %_cd%\batch
rem Receive variable
set /p _YorN=<%_cd%\PASSWORD\_YorN.txt
set /p _PASSWORD=<%_cd%\PASSWORD\_PASSWORD.txt
set /p _IDKeyCuaA=<%_cd%\user\_IDKeyCuaA.txt
rem Delete spaces
set _IDKeyCuaA=%_IDKeyCuaA: =%
set _YorN=%_YorN: =%
set _PASSWORD=%_PASSWORD: =%
rem Check the Key ID of the wallet (A) have yes or no
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
echo Optional: Enter "waybackhome" to return
echo Enter the manual password: 
echo Note: Turn off Unikey before entering
set /P "=_" < NUL > "Enter password"
findstr /A:1E /V "^$" "Enter password" NUL > CON
del "Enter password"
set /P "_password="
call :background
rem Quay lại 9cscanPublickey
if %_password% == waybackhome (echo waybackhome>%_cd%\PASSWORD\_PASSWORD.txt && exit /b)
if %_password% == checkcheck (start https://youtu.be/SRf8pTXPz9I?t=26s)
rem Get Public Key of A
cd %_cd%\planet
set _PublicKeyCuaA=^|planet key export --passphrase %_PASSWORD% --public-key %_IDKeyCuaA%
echo %_PublicKeyCuaA% > %_cd%\planet\_KTraPPK.txt
set "_PASSWORD="
goto :KTraPPK2
:tryagainNoPass
call :background
echo Use the password saved from the PASSWORD folder
cd %_cd%\planet
set _PublicKeyCuaA=^|planet key export --passphrase %_PASSWORD% --public-key %_IDKeyCuaA%
echo %_PublicKeyCuaA% > %_cd%\planet\_KTraPPK.txt
set "_PASSWORD="
goto :KTraPPK1
rem Check whether it is Publick Key or not
:KTraPPK1
set /p _KTraPPK=<%_cd%\planet\_KTraPPK.txt
if [%_KTraPPK%] == [] (echo Error 1: The password saved in the PASSWORD file is not correct, try again... && color 4F && set _YorN=0 && echo %_YorN% > %_cd%\PASSWORD\_YorN.txt && timeout 10 && goto :tryagainWithPass) else (goto :YesPPK)
:KTraPPK2
set /p _KTraPPK=<%_cd%\planet\_KTraPPK.txt
if [%_KTraPPK%] == [] (echo Error 2: Enter the wrong password, try again... && color 4F && set _YorN=0 && echo %_YorN% > %_cd%\PASSWORD\_YorN.txt && echo 0 > %_cd%\PASSWORD\_PASSWORD.txt && timeout 10 && goto :tryagainWithPass) else (goto :YesPPK)

:YesPPK
cd %_cd%
call %_cd%\Batch\TitleSendCurrency.bat
echo ==========
echo Enter Public Key of (A) by Planet
echo.
echo ==========
echo Nhập Public Key của (A) thành công
echo %_KTraPPK% > %_cd%\user\_PublicKeyCuaA.txt
exit /b
:background
cd %_cd%
call %_cd%\Batch\TitleSendCurrency.bat
echo ==========
echo Enter Public Key of (A) by Planet
echo.
echo ==========
echo Taking Public Key of (A)
echo.