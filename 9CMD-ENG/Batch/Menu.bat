rem Install %_cd% original
set /p _cd=<_cd.txt
title 9CMD - by tanbt
:Menu
call :background
echo.        TOoL fOr niNe ChRoniCleS
echo.
echo [1] Send NCG/Crystal
echo [2] Check for updates
echo.[3] Introduce
echo.
echo.           A product ra dẻ :v
echo.          ===Version: [0.3.1]===
choice /c 123 /n /m "Enter from the keyboard: "
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
type %_cd%\README.md
echo.
echo.Press any key to return to the Menu
pause>nul
goto :Menu