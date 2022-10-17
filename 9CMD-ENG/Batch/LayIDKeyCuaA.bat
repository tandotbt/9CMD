rem Install %_cd% original
set /p _cd=<_cd.txt
rem Receive variable
set /p _viA=<%_cd%\user\_viA.txt
rem Delete spaces
set _viA=%_viA: =%
echo ==========
echo Taking the Key id of (A)
echo.
cd %_cd%\planet
planet key > _allKey.txt
sort _allKey.txt
findstr /L %_viA% _allKey.txt >_IDKeyCuaA.txt
set "_IDKeyCuaA="
set /p _IDKeyCuaA=<_IDKeyCuaA.txt
rem Check ID Key
echo ==========
echo Check Key ID
echo.
if not "%_IDKeyCuaA%" == "" (goto :YesUTC) else (goto :NoUTC)

:tryagain
cls
cd %_cd%
call %_cd%\Batch\TitleSendCurrency.bat
echo ==========
echo Enter Public Key of (A) by Planet
echo.
echo ==========
echo Take the Key ID of (A), wait a bit...
cd %_cd%\planet
planet key > _allKey.txt
sort _allKey.txt
findstr /L %_viA% _allKey.txt >_IDKeyCuaA.txt
set "_IDKeyCuaA="
set /p _IDKeyCuaA=<_IDKeyCuaA.txt
rem Check ID Key
echo ==========
echo Check Key ID
echo.
if not "%_IDKeyCuaA%" == "" (goto :YesUTC) else (goto :NoUTC)

:NoUTC
echo ==========
echo No UTC file of (A) is found in the keystore folder
echo.
color 4F
cd %_cd%\planet
rem Delete file txt trong planet
del *.txt
copy "%_cd%\data\_cd.txt" "%_cd%\planet\_cd.txt"
goto :errorUTC

:errorUTC
echo ==========
echo Check again the keystore folder and ...
echo [1]Try searching for Key ID
echo [2]Enter the wallet (A) again
echo [3]Quit tool
choice /c 123 /n /m "Enter from the keyboard..."
if %errorlevel% equ 1 (goto :tryagain)
if %errorlevel% equ 2 (color 0B && call %_cd%\batch\miniNhapViA.bat && exit /b)
if %errorlevel% equ 3 (call :background && call %_cd%\batch\end9cmd.bat "UTC file cannot be found, exit after 10 seconds ..." 10 && exit)

:YesUTC
echo ==========
echo Get Key ID of wallet (A) succeed
echo.
echo %_IDKeyCuaA:~0,36% > %_cd%\user\_IDKeyCuaA.txt
rem Delete file txt in folder planet
del *.txt
copy "%_cd%\data\_cd.txt" "%_cd%\planet\_cd.txt"
timeout 3
:Background
cls
cd %_cd%
call %_cd%\Batch\TitleSendCurrency.bat
exit /b