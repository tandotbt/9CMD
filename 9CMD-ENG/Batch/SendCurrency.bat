echo off
chcp 65001
cls
rem Install %_cd% original
set /p _cd=<_cd.txt
cd %_cd%
rem Set title window
title Send NCG/Crystal
rem Reset value
set /a _hienInputPass=1
set /a _ktra=0
rem Select Node to use
:ChonNode
call :background
rem Reset value _node.txt
set "_node="
set /p _node="Use node number (Should choose from 1-10): "
echo %_node% > %_cd%\data\_node.txt
goto :KTraNode1
:LichSu
rem Menu send currency
call :background
echo [1]Create new, good progress 
echo [2]Using the previous data, can customize each indicator
echo [3]Back to the menu
echo ==========
echo.
choice /c 123 /n /m "[1]Newgame, [2]Continue or [3]Main Menu: "
if %errorlevel% equ 1 (goto :NhapViA)
if %errorlevel% equ 2 (goto :miniSendCurrency)
if %errorlevel% equ 3 (call %_cd%\batch\Menu.bat && exit /b)
rem Enter wallet (A)
:NhapViA
call :background
rem Showing wallet in UTC folder
cd %_cd%\planet
planet key --path %_cd%\user\utc> _allKey.txt
type _allKey.txt
cd %_cd%
echo.
rem Enter wallet (A)
echo.[1]Use node          : %_node%
echo.Type 'open' to open with Notepad
set /p _viA="Wallet sender (A): "
rem Delete spaces
set _viA=%_viA: =%
if "%_viA%" == "open" (start %_cd%\planet\_allKey.txt & goto :NhapViA)
echo %_viA%> %_cd%\user\_viA.txt
del /q %_cd%\planet\_allKey.txt
rem Check balance wallet (A)
call %_cd%\batch\KTraSoDuCuaA.bat
rem Save value A
set /p _crystalCuaA=<%_cd%\data\_crystal.txt
set /p _ncgCuaA=<%_cd%\data\_ncg.txt
rem Rounding number
set /a "_ncgCuaA=%_ncgCuaA%"
set /a "_crystalCuaA=%_crystalCuaA%"
goto :KTraViA
:NhapViB
rem Enter wallet B
call :background
echo.[1]Use node            : %_node%			NCG		CRYSTAL
echo.[2]Wallet sender (A)   : %_viA:~0,7%***		%_ncgCuaA%		%_crystalCuaA%
echo ==========
set /p _viB="Wallet receiver (B): "
echo %_viB% > %_cd%\user\_viB.txt
call %_cd%\batch\KTraSoDuCuaB.bat
rem Save value B
set /p _crystalCuaB=<%_cd%\data\_crystalB.txt
set /p _ncgCuaB=<%_cd%\data\_ncgB.txt
goto :KTraViB
:KTraViOK
rem Print the information screen
call :background
echo.[1]Use node            : %_node%			NCG		CRYSTAL
echo.[2]Wallet sender (A)   : %_viA:~0,7%***		%_ncgCuaA%		%_crystalCuaA%
echo.[3]Wallet receiver (B) : %_viB:~0,7%***		%_ncgCuaB%		%_crystalCuaB%
if "%_hienInputPass%"=="1" (goto :inputpassword) else (goto :KTraNode1)
:inputpassword
set /a _hienInputPass=0
echo ==========
choice /c 12 /n /m "Enter wallet password (A): [1]Ok [2]Skip"
if %errorlevel% equ 2 (echo 0 > %_cd%\PASSWORD\_YorN.txt && goto :ChonLoaiTienTe)
if %errorlevel% equ 1 (call %_cd%\batch\PASSWORD.bat && goto :ChonLoaiTienTe)
rem Choose currency and quantity
:ChonLoaiTienTe
call :background
echo.[1]Use node            : %_node%			NCG		CRYSTAL
echo.[2]Wallet sender (A)   : %_viA:~0,7%***		%_ncgCuaA%		%_crystalCuaA%
echo.[3]Wallet receiver (B) : %_viB:~0,7%***		%_ncgCuaB%		%_crystalCuaB%
echo ==========
rem Choose currency
choice /c 12 /n /m "Send [1]NCG or [2]Crystal: "
if %errorlevel% equ 1 (set _currency=NCG)
if %errorlevel% equ 2 (set _currency=CRYSTAL)
echo %_currency% > %_cd%\data\_currency.txt
rem Amount you want to send
set /p _soLuong="Amount: "
echo %_soLuong% > %_cd%\data\_soLuong.txt
rem Check the value
goto :KTraSoLuong
rem Bắt đầu gửi
:SoLuongOK
call :background
echo.[1]Use node            : %_node%			NCG		CRYSTAL
echo.[2]Wallet sender (A)   : %_viA:~0,7%***		%_ncgCuaA%		%_crystalCuaA%
echo.[3]Wallet receiver (B) : %_viB:~0,7%***		%_ncgCuaB%		%_crystalCuaB%
echo.[4]Send                : %_soLuong% %_currency%
echo ==========
choice /c 12 /n /m "Enter Public key wallet (A):[1]9cscan [2]Planet"
if %errorlevel% equ 1 (goto :9cscanPublickey)
if %errorlevel% equ 2 (goto :PlanetPublickey)
rem Enter Public Key
:9cscanPublicKey
call :Background
echo ==========
echo Enter Public key of (A) by 9cscan
echo.
cd %_cd%\batch
rem --ssl-no-revoke fixed
curl --ssl-no-revoke --header "Content-Type: application/json" https://api.9cscan.com/accounts/%_viA%/transactions?action=activate_account 2>nul|findstr /i signed> output.json 2>nul
if %errorlevel% == 0 (goto :9cscanPublicKey2)
:9cscanPublicKey1
curl --ssl-no-revoke --header "Content-Type: application/json" https://api.9cscan.com/accounts/%_viA%/transactions?action=activate_account2 2>nul|findstr /i signed> output.json 2>nul
:9cscanPublicKey2
rem Filter the results of data
echo ==========
echo Searching publicKey of (A)...
echo.
cd %_cd%\batch
jq -r "..|.publicKey?|select(.)" output.json> %_cd%\user\_PublicKeyCuaA.txt
rem Delete Input and Output draft
cd %_cd%\batch
del *.json
echo ==========
echo Get the Public Key of the wallet (A) success
echo.
rem Set the variable _IDKeyCuaA to 0
set _IDKeyCuaA=0
echo %_IDKeyCuaA% > %_cd%\user\_IDKeyCuaA.txt
timeout 3
goto :miniSendCurrency
:PlanetPublickey
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
goto :miniSendCurrency
:miniSendCurrency
rem Get data
set /p _node=<%_cd%\data\_node.txt
set /p _viA=<%_cd%\user\_viA.txt
set /p _viB=<%_cd%\user\_viB.txt
set /p _ncgCuaA=<%_cd%\data\_ncg.txt
set /p _ncgCuaB=<%_cd%\data\_ncgB.txt
set /p _crystalCuaA=<%_cd%\data\_crystal.txt
set /p _crystalCuaB=<%_cd%\data\_crystalB.txt
set /p _soLuong=<%_cd%\data\_soLuong.txt
set /p _currency=<%_cd%\data\_currency.txt
set /p _memo=<%_cd%\data\_memo.txt
set /p _PublicKeyCuaA=<%_cd%\user\_PublicKeyCuaA.txt
set /p _YorN=<%_cd%\PASSWORD\_YorN.txt
rem Delete spaces
set _node=%_node: =%
set _viA=%_viA: =%
set _viB=%_viB: =%
set _ncgCuaA=%_ncgCuaA: =%
set _ncgCuaB=%_ncgCuaB: =%
set _crystalCuaA=%_crystalCuaA: =%
set _crystalCuaB=%_crystalCuaB: =%
set _soLuong=%_soLuong: =%
set _currency=%_currency: =%
set _memo=%_memo: =%
set _PublicKeyCuaA=%_PublicKeyCuaA: =%
set _YorN=%_YorN: =%
rem Rounding NCG and Crystal
set /a "_ncgCuaA=%_ncgCuaA%"
set /a "_ncgCuaB=%_ncgCuaB%"
set /a "_crystalCuaA=%_crystalCuaA%"
set /a "_crystalCuaB=%_crystalCuaB%"
rem Make color :v
call :background
if %_currency% == NCG (color 06 &&  goto :Makecolor)
if %_currency% == CRYSTAL (color 0D && goto :Makecolor)
:Makecolor
echo ==========
echo.[1]Use node            : %_node%			NCG		CRYSTAL
echo.[2]Wallet sender (A)   : %_viA:~0,7%***		%_ncgCuaA%		%_crystalCuaA%
echo.[3]Wallet receiver (B) : %_viB:~0,7%***		%_ncgCuaB%		%_crystalCuaB%
echo.[4]Send                : %_soLuong% %_currency%
echo.[5]Public Key của (A)  : %_PublicKeyCuaA:~0,10%***
echo.[6]Message             : %_memo%_9CMD_TooL
if "%_YorN%"=="1" echo.[7]Saved PASSWORD (A)  : [X]
if "%_YorN%"=="0" echo.[7]Saved PASSWORD (A)  : [ ]
echo ==========
rem Reset _chinhSua
set /p _chinhSua=<%_cd%\data\_null.txt
set /p _chinhSua="Enter [0] to send, or enter [number] to update: "
rem Reform _chinhSua one number
set _chinhSua=%_chinhSua: =%
set _chinhSua=%_chinhSua:~-1%
rem Check _chinhSua is number or not
cd %_cd%
set "var="&for /f "delims=0123456789" %%i in ("%_chinhSua%") do set var=%%i
if defined var (echo Error 1: Wrong syntax, try again... && color 4F && timeout 3)
if "%_chinhSua%"=="0" (goto :BatDauGui)
if "%_chinhSua%"=="1" (call %_cd%\batch\miniChonNode.bat)
if "%_chinhSua%"=="2" (call %_cd%\batch\miniNhapViA.bat)
if "%_chinhSua%"=="3" (call %_cd%\batch\miniNhapViB.bat)
if "%_chinhSua%"=="4" (call %_cd%\batch\miniSoLuong.bat)
if "%_chinhSua%"=="5" (call %_cd%\batch\miniPublicKey.bat)
if "%_chinhSua%"=="6" (call %_cd%\batch\miniMemo.bat)
if "%_chinhSua%"=="7" (call %_cd%\batch\PASSWORD.bat)
if "%_chinhSua%" gtr "7" (echo Error 2: The value exceeds [7], try again... && color 4F && timeout 10)
set "_chinhSua="
goto :miniSendCurrency
:BatDauGui
rem Start sending transactions
call :Background
call %_cd%\batch\SendStep1.bat
:KTraGiaoDich
call :Background
color 0B
echo ==========
echo Completed, you can escape the tool
echo.
echo ==========
echo [1] Check transactions at 9cscan
echo [2] Check transaction by GraphQL
echo [3] Back to the menu
choice /c 123 /n /m "Enter from the keyboard...: "
if %errorlevel% equ 1 (goto :KTraGiaoDich9csan)
if %errorlevel% equ 2 (goto :KTraGiaoDichGraphQL)
if %errorlevel% equ 3 (goto :LichSu)
:KTraGiaoDichGraphQL
call %_cd%\batch\SendStep5.bat
call :background
set /p _txStatus=<%_cd%\user\_txStatus.txt
set _txStatus=%_txStatus: =%
if %_txStatus% == INVALID (echo Status: NOT FOUND && color 8F && goto :endKtraGDGraphQL)
if %_txStatus% == STAGING (echo Status: STAGING && color 0B && goto :endKtraGDGraphQL)
if %_txStatus% == SUCCESS (echo Status: SUCCESS && color 2F && goto :endKtraGDGraphQL)
if %_txStatus% == FAILURE (echo Status: FAILURE && color 4F && goto :endKtraGDGraphQL)
echo Error 1: The error is not determined, play game and do something then try to send it again... && color 4F && timeout 10 && goto :endKtraGDGraphQL
:endKtraGDGraphQL
echo.
echo ==========
echo.[1]Check again
echo.[2]Return
choice /c 12 /n /t 3 /d 1 /m "Automatically check later 3s: "
if %errorlevel% equ 1 (goto :KTraGiaoDichGraphQL)
if %errorlevel% equ 2 (goto :KTraGiaoDich)
:KTraGiaoDich9csan
set /p _stageTransaction=<%_cd%\user\_stageTransaction.txt
rem Delete spaces
set _stageTransaction=%_stageTransaction: =%
start https://9cscan.com/tx/%_stageTransaction%
timeout 10
goto :KTraGiaoDich
:Background
cls
cd %_cd%
call %_cd%\Batch\TitleSendCurrency.bat
exit /b
:background1
cls
call :Background
echo.
echo ==========
echo Check node %_node%
exit /b
:EnterToTiepTuc
set /p _enter= "Enter to continue..."
:KTraViA
rem Check wallet (A)
echo ==========
echo Check wallet (A)
echo.
if not [%_ncgCuaA%] == [] (goto :NhapViB) else (echo Error 1: Wallet A wrong syntax, 'distinguishing both text upcase, lowcase', try again... && color 4F && timeout 10 && goto :NhapViA)
:KtraViB
rem Check wallet (B)
echo ==========
echo Check wallet (B)
echo.
if not [%_ncgCuaB%] == [] (goto :KTraViOK) else (echo Error 1: Wallet B wrong syntax, 'distinguishing both text upcase, lowcase', try again... && color 4F && timeout 10 && goto :NhapViB)
rem Check if the node has been imported
:KTraNode1
rem Check node
echo ==========
echo Check node %_node%
echo.
if not [%_node%] == [] (goto :KTraNode2) else (echo Error 1: Not yet imported node, try again... && color 4F && timeout 3 && goto :ChonNode)
rem Check node is the number or not
:KTraNode2
cd %_cd%
set "var="&for /f "delims=0123456789" %%i in ("%_node%") do set var=%%i
if defined var (echo Error 2: Node is not a number format, try again... && color 4F && timeout 3 && goto :ChonNode) else (goto :KTraNode3)
rem Check node is active or not
:KTraNode3
cd %_cd%
call %_cd%\batch\KTraNode.bat
set /p _KTRaNode=<%_cd%/data/_KTraNode.txt
echo %_KTRaNode% |find /v "data" & set _ktra=%errorlevel%
call :background1
if "%_ktra%"=="0" (goto :LichSu) else (set /a _ktra=0 & echo Error 3: Node %_node% does not work, try again... && color 4F && timeout 5 && goto :ChonNode)
:KTraSoLuong
rem Check amount
echo ==========
echo Check amount
echo.
if not [%_soLuong%] == [] (goto :KTraSoLuong2) else (echo Error 1: Amount of empty, try again... && color 4F && timeout 3 && goto :ChonLoaiTienTe)
rem Check is number or not
:KTraSoLuong2
set "var="&for /f "delims=0123456789" %%i in ("%_soLuong%") do set var=%%i
if defined var (set /a _ktra=0) else (set /a _ktra=1)
if "%_ktra%" == "1" (goto :KTraSoLuong3) else (echo Error 2: Amount not numbers, try again... && color 4F && timeout 3 && goto :ChonLoaiTienTe)
rem Check is smaller than the balance or not
:KTraSoLuong3
if %_currency% == NCG (if %_soLuong% gtr %_ncgCuaA% (set /a _ktra=0))
if %_currency% == CRYSTAL (if %_soLuong% gtr %_crystalCuaA% (set /a _ktra=0))
if "%_ktra%" == "1" (goto :SoLuongOK) else (echo Error 3: Amount exceeds the balance, try again... && color 4F && timeout 3 && goto :ChonLoaiTienTe)