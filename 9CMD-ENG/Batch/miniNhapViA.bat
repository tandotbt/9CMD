rem Install %_cd% original
set /p _cd=<_cd.txt
rem Receive variable
set /p _node=<%_cd%\data\_node.txt
rem Delete spaces
set _node=%_node: =%
rem Select Node first
echo ==========
echo Select Node
echo.
call %_cd%\batch\miniChonNode.bat
call :Background
rem Enter wallet (A)
echo ==========
echo Enter wallet (A)
echo.
rem Showing wallet in UTC folder
cd %_cd%\planet
planet key --path %_cd%\user\utc> _allKey.txt
more _allKey.txt
del _allKey.txt
cd %_cd%\batch
echo.
set /p _viA="Enter wallet A: "
rem Delete spaces
set _viA=%_viA: =%
echo %_viA%> %_cd%\user\_viA.txt
rem Check balance
echo {"query":"query{stateQuery{agent(address:\"%_viA%\"){crystal}}goldBalance(address: \"%_viA%\" )}"} > input.json
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql > output.json
rem Filter the results of data
jq "..|.crystal?|select(.)|tonumber" output.json > %_cd%/data/_crystal.txt
jq "..|.goldBalance?|select(.)|tonumber" output.json > %_cd%/data/_ncg.txt
rem Delete Input and Output file draft
cd %_cd%\batch
del *.json
cd %_cd%
:KTraViA
rem Check for wallet A
call :Background
echo ==========
echo Check for wallet A
set /p _ncgCuaA=<%_cd%/data/_ncg.txt
set /p _crystalCuaA=<%_cd%/data/_crystal.txt
if not [%_ncgCuaA%] == [] (goto :NhapViOK) else (echo Error 1: Wallet A wrong syntax, 'distinguishing both text upcase, lowcase', try again... && color 4F && timeout 10 && goto :NhapViA)
:NhapViOK
call :background
echo.[1]Use node            : %_node%			NCG		CRYSTAL
echo.[2]Wallet sender (A)   : %_viA:~0,7%***		%_ncgCuaA%		%_crystalCuaA%
echo ==========
choice /c 12 /n /m "Enter Public key wallet (A):[1]9cscan [2]Planet"
if %errorlevel% equ 1 (goto :9cscanPublickey)
if %errorlevel% equ 2 (goto :PlanetPublickey)
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
exit /b
:PlanetPublickey
rem Select Node first
echo ==========
echo Select Node hoạt động
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
:Background
cls
cd %_cd%
call %_cd%\Batch\TitleMini.bat 2
exit /b
:NhapViA
call :Background
echo ==========
echo Enter wallet (A)
echo.
rem Showing wallet in UTC folder
cd %_cd%\planet
planet key --path %_cd%\user\utc> _allKey.txt
more _allKey.txt
del _allKey.txt
cd %_cd%\batch
echo.
set /p _viA="Enter wallet A: "
echo %_viA% > %_cd%\user\_viA.txt
rem Check balance
echo {"query":"query{stateQuery{agent(address:\"%_viA%\"){crystal}}goldBalance(address: \"%_viA%\" )}"} > input.json
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql > output.json
rem Filter the results of data
jq "..|.crystal?|select(.)|tonumber" output.json > %_cd%/data/_crystal.txt
jq "..|.goldBalance?|select(.)|tonumber" output.json > %_cd%/data/_ncg.txt
rem Delete Input and Output file draft
cd %_cd%\batch
del *.json
cd %_cd%
goto :KTraViA