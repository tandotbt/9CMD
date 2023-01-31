rem Install %_cd% original
set /p _cd=<_cd.txt
rem Receive variable
set /p _node=<%_cd%\data\_node.txt
rem Delete spaces
set _node=%_node: =%
rem Select Node first
echo ==========
echo Select Node hoạt động
echo.
call %_cd%\batch\miniChonNode.bat
call :Background
rem Enter wallet B
echo ==========
echo Enter wallet (B)
echo.
cd %_cd%\batch
set /p _viB="Enter wallet B: "
rem Delete spaces
set _viB=%_viB: =%
echo %_viB%> %_cd%\user\_viB.txt
rem Check balance
echo {"query":"query{stateQuery{agent(address:\"%_viB%\"){crystal}}goldBalance(address: \"%_viB%\" )}"} > input.json
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql > output.json
rem Filter the results of data
findstr /i errors output.json>nul
if %errorlevel% == 0 (echo Error 1: Wallet B wrong syntax, 'distinguishing both text upcase, lowcase', try again ... && color 4F && timeout 10 && goto :NhapViB)
jq "..|.crystal?|select(.)|tonumber" output.json > %_cd%\data\_crystalB.txt
jq "..|.goldBalance?|select(.)|tonumber" output.json > %_cd%\data\_ncgB.txt
rem Delete Input and Output file draft
cd %_cd%\batch
del *.json
cd %_cd%
:KTraViB
rem Check wallet B
echo ==========
echo Check wallet B
set /p _ncgCuaB=<%_cd%\data\_ncgB.txt
set /p _crystalCuaB=<%_cd%\data\_crystalB.txt
if not [%_ncgCuaB%] == [] (timeout 1 && exit /b) else (echo Error 1: Wallet B wrong syntax, 'distinguishing both text upcase, lowcase', try again... && color 4F && timeout 10 && goto :NhapViB)
:Background
cls
cd %_cd%
call %_cd%\Batch\TitleMini.bat 2
exit /b
:NhapViB
call :Background
echo ==========
echo Enter wallet (B)
echo.
cd %_cd%\batch
set /p _viB="Enter wallet B: "
echo %_viB% > %_cd%\user\_viB.txt
rem Check balance
echo {"query":"query{stateQuery{agent(address:\"%_viB%\"){crystal}}goldBalance(address: \"%_viB%\" )}"} > input.json
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql > output.json
rem Filter the results of data
jq "..|.crystal?|select(.)|tonumber" output.json > %_cd%\data\_crystalB.txt
jq "..|.goldBalance?|select(.)|tonumber" output.json > %_cd%\data\_ncgB.txt
rem Delete Input and Output file draft
cd %_cd%\batch
del *.json
cd %_cd%
goto :KTraViB