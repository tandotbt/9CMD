rem Install %_cd% original
set /p _cd=<_cd.txt
title 9CMD - by tanbt
:Menu
call :background
curl http://api.tanvpn.tk/eng/news --ssl-no-revoke --location > %_cd%\user\_temp.json 2>nul
%_cd%\batch\jq.exe -r ".news" %_cd%\user\_temp.json > %_cd%\user\_temp.txt 2>nul
set /p _temp=<%_cd%\user\_temp.txt
%_temp%
del /q %_cd%\user\_temp.json %_cd%\user\_temp.txt
echo [1] Have you entered the UTC file yet?
echo [2] Feature
echo [3] Introduce
echo [4] User guide
echo.
echo.           A product ra dẻ :v
echo.         === Version: [0.8] ===
choice /c 1234 /n /m "Enter from the keyboard: "
if %errorlevel% == 1 (call %_cd%\Batch\enterUTC.bat)
if %errorlevel% == 2 (goto :tinhNang)
if %errorlevel% == 3 (goto :GioiThieu)
if %errorlevel% == 4 (start https://9cmd.tanvpn.tk/ & goto :Menu)
:Background
cls
cd %_cd%
call %_cd%\Batch\Title9CMD.bat
exit /b
:GioiThieu
cls
cd %_cd%
call %_cd%\Batch\Titletanbt.bat
type %_cd%\README.md
echo.
echo.Press any key to return to the Menu
pause>nul
goto :Menu
:tinhNang
echo.
echo ==========
echo [1] Send NCG/Crystal
echo [2] Tracked Avatar
choice /c 12 /n /m "Enter from the keyboard: "
if %errorlevel% == 1 (call %_cd%\Batch\SendCurrency.bat)
if %errorlevel% == 2 (call %_cd%\Batch\avatarAddress\TrackedAvatar.bat)
goto :Menu