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
rem Kiểm tra đã lấy Key ID của ví (A) chưa
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
if %_password% == waybackhome (set "_password=" && call %_cd%\Batch\SendCurrency.bat && exit /b)
if %_password% == checkcheck (start https://youtu.be/SRf8pTXPz9I?t=26s)
rem Get Public Key of A
cd %_cd%\planet
set _signature=^|planet key sign --passphrase %_PASSWORD% %_IDKeyCuaA% %_cd%\Batch\action
echo %_signature% > %_cd%\planet\_KTraSignature.txt
set "_PASSWORD="
goto :KTraSignature2
:tryagainNoPass
call :background
rem Get _IDKeyCuaA
set /p _IDKeyCuaA=<%_cd%\user\_IDKeyCuaA.txt
set _IDKeyCuaA=%_IDKeyCuaA: =%
echo Use the password saved from the PASSWORD folder
cd %_cd%\planet
set _signature=^|planet key sign --passphrase %_PASSWORD% %_IDKeyCuaA% %_cd%\Batch\action
echo %_signature% > %_cd%\planet\_KTraSignature.txt
set "_PASSWORD="
goto :KTraSignature1
rem Check whether it is Publick Key or not
:KTraSignature1
set /p _KTraSignature=<%_cd%\planet\_KTraSignature.txt
if [%_KTraSignature%] == [] (echo Error 1: The password saved in the PASSWORD file is not correct, try again... && color 4F && set _YorN=0 && echo %_YorN% > %_cd%\PASSWORD\_YorN.txt && timeout 10 && goto :tryagainWithPass) else (goto :YesSignature)
:KTraSignature2
set /p _KTraSignature=<%_cd%\planet\_KTraSignature.txt
if [%_KTraSignature%] == [] (echo Error 2: Enter the wrong password, try again... && color 4F && set _YorN=0 && echo %_YorN% > %_cd%\PASSWORD\_YorN.txt && echo 0 > %_cd%\PASSWORD\_PASSWORD.txt && timeout 10 && goto :tryagainWithPass) else (goto :YesSignature)
:YesSignature
cd %_cd%
call %_cd%\Batch\TitleSendCurrency.bat
echo ==========
echo Enter Signature of (A) success
echo %_KTraSignature% > %_cd%\user\_signature.txt
exit /b
:background
cd %_cd%
call %_cd%\Batch\TitleSendCurrency.bat
echo ==========
echo Taking Signature of (A)
echo.