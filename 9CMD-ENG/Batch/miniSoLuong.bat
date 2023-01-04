rem Install %_cd% original
set /p _cd=<_cd.txt
rem Get data
set /p _node=<%_cd%\data\_node.txt
set /p _viA=<%_cd%\user\_viA.txt
rem Delete spaces
set _node=%_node: =%
set _viA=%_viA: =%
rem Select Node first
echo ==========
echo Select Node
echo.
call %_cd%\batch\miniChonNode.bat
rem Check balance wallet (A)
echo ==========
echo Take the wallet balance (A)
echo.
call %_cd%\batch\KTraSoDuCuaA.bat
rem Set value of A
set /p _crystalCuaA=<%_cd%\data\_crystal.txt
set /p _ncgCuaA=<%_cd%\data\_ncg.txt
rem Rounding NCG adn Crystal
set /a "_ncgCuaA=%_ncgCuaA%"
set /a "_crystalCuaA=%_crystalCuaA%"
rem Check wallet (A)
echo ==========
echo Check wallet (A)
echo.
if not [%_ncgCuaA%] == [] (timeout 3 && goto :SoLuong) else (echo Error 1: Wallet A incorrect, Enter wallet A again and try again... && color 4F && timeout 10 && exit /b)
:SoLuong
call :Background
echo.[1]Use node            : %_node%			NCG		CRYSTAL
echo.[2]Wallet sender (A)   : %_viA:~0,7%***		%_ncgCuaA%		%_crystalCuaA%
echo ==========
echo Enter the currency and amount you want to send
echo.
choice /c 12 /n /m "Send [1]NCG or [2]Crystal: "
if %errorlevel% equ 1 (set _currency=NCG)
if %errorlevel% equ 2 (set _currency=CRYSTAL)
echo %_currency% > %_cd%\data\_currency.txt
rem Amount want to send
set /p _soLuong="Amount: "
echo %_soLuong% > %_cd%\data\_soLuong.txt
goto :KTraSoLuong

:Background
cls
cd %_cd%
call %_cd%\Batch\TitleMini.bat 4
exit /b

:KTraSoLuong
rem Check amount
echo ==========
echo Check amount
echo.
if not [%_soLuong%] == [] (goto :KTraSoLuong2) else (echo Error 1: Number of empty, try again... && color 4F && timeout 3 && goto :SoLuong)
rem Check is number or not
:KTraSoLuong2
set "var="&for /f "delims=0123456789" %%i in ("%_soLuong%") do set var=%%i
if defined var (set /a _ktra=0) else (set /a _ktra=1)
if "%_ktra%" == "1" (goto :KTraSoLuong3) else (echo Error 2: Amount not numbers, try again... && color 4F && timeout 3 && goto :SoLuong)
rem Check is smaller than the balance or not
:KTraSoLuong3
if %_currency% == NCG (if %_soLuong% geq %_ncgCuaA% (set /a _ktra=0))
if %_currency% == CRYSTAL (if %_soLuong% geq %_crystalCuaA% (set /a _ktra=0))
if "%_ktra%" == "1" (timeout 1 && exit /b) else (echo Error 3: Amount exceeds the balance, try again... && color 4F && timeout 3 && goto :SoLuong)