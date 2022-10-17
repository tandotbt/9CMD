rem Install %_cd% original
set /p _cd=<_cd.txt
rem Enter node
echo ==========
echo Select Node
echo.
set _node=<%_cd%\data\_null.txt
set /p _node="Use node number (Should choose from 1-10): "
echo %_node% > %_cd%\data\_node.txt
rem Check node
echo ==========
echo Check node %_node%
rem Check if the node has been imported
:KTraNode1
if not [%_node%] == [] (goto :KTraNode2) else (echo Error 1: Not yet imported node, try again... && color 4F && timeout 3 && goto :ChonNode)
rem Check node is the number or not
:KTraNode2
cd %_cd%
set "var="&for /f "delims=0123456789" %%i in ("%_node%") do set var=%%i
if defined var (echo Error 2: Node is not a number format, try again... && color 4F && timeout 3 && goto :ChonNode) else (goto :KTraNode3)
rem Check node is active or not
:KTraNode3
cd %_cd%
call :KTraNode
set /p _KTRaNode=<%_cd%/data/_KTraNode.txt
echo %_KTRaNode% |find /v "data" && set _ktra=0
call :background1
echo %_KTRaNode% |find /v "data" || set _ktra=1
call :background1
if "%_ktra%"=="1" (timeout 1 && exit /b) else (echo Error 3: Node %_node% does not work, try again... && color 4F && timeout 5 && goto :ChonNode)
:KTraNode
cd %_cd%\batch
echo {"query":"query{nodeStatus{preloadEnded}}"} > input.json
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" http://9c-main-rpc-%_node%.nine-chronicles.com/graphql > %_cd%/data/_KTraNode.txt
rem Delete file nháp input và output
cd %_cd%\batch
del *.json
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
:ChonNode
call :Background
echo ==========
echo Select Node
echo.
set _node=<%_cd%\data\_null.txt
set /p _node="Use node number (Should choose from 1-10): "
echo %_node% > %_cd%\data\_node.txt
rem Check node
echo ==========
echo Check node %_node%
goto :KTraNode1