rem Cài %_cd% gốc
set /p _cd=<_cd.txt
rem Nhập node
echo ==========
echo Chọn Node
echo.
set _node=<%_cd%\data\_null.txt
set /p _node="Sử dụng node số (Nên chọn từ 1-10): "
echo %_node% > %_cd%\data\_node.txt
rem Kiểm tra node
echo ==========
echo Kiểm tra node %_node%
rem Kiểm tra đã nhập node hay chưa
:KTraNode1
if not [%_node%] == [] (goto :KTraNode2) else (echo Lỗi 1: Chưa nhập node, thử lại... && color 4F && timeout 3 && goto :ChonNode)
rem Kiểm tra node có là số hay không
:KTraNode2
cd %_cd%
set "var="&for /f "delims=0123456789" %%i in ("%_node%") do set var=%%i
if defined var (echo Lỗi 2: Node chưa là định dạng số, thử lại... && color 4F && timeout 3 && goto :ChonNode) else (goto :KTraNode3)
rem Kiểm tra node có hoạt động hay không
:KTraNode3
cd %_cd%
call :KTraNode
set /p _KTRaNode=<%_cd%/data/_KTraNode.txt
echo %_KTRaNode% |find /v "data" & set _ktra=%errorlevel%
call :background1
if "%_ktra%"=="0" (timeout 1 & exit /b) else (set /a _ktra=0 & echo Lỗi 3: Node %_node% không hoạt động, thử lại... && color 4F && timeout 5 && goto :ChonNode)
:KTraNode
cd %_cd%\batch
echo {"query":"query{nodeStatus{preloadEnded}}"} > input.json
echo Chờ 10 giây & timeout 10
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" http://9c-main-rpc-%_node%.nine-chronicles.com/graphql > %_cd%/data/_KTraNode.txt
rem Xóa file nháp input và output
cd %_cd%\batch
del *.json
:Background
cls
cd %_cd%
call %_cd%\Batch\TitleMini.bat 1
exit /b
:background1
cls
call :Background
echo.
echo ==========
echo Kiểm tra node %_node%
exit /b
:ChonNode
call :Background
echo ==========
echo Chọn Node
echo.
set _node=<%_cd%\data\_null.txt
set /p _node="Sử dụng node số (Nên chọn từ 1-10): "
echo %_node% > %_cd%\data\_node.txt
rem Kiểm tra node
echo ==========
echo Kiểm tra node %_node%
goto :KTraNode1