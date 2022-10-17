rem Cài %_cd% gốc
set /p _cd=<_cd.txt
rem Nhận biến
set /p _node=<%_cd%\data\_node.txt
rem Xóa khoảng trắng
set _node=%_node: =%
rem Chon node trước
echo ==========
echo Chọn node hoạt động
echo.
call %_cd%\batch\miniChonNode.bat
rem Nhập
echo ==========
echo Nhập ví (B)
echo.
cd %_cd%\batch
set /p _viB="Nhập ví B: "
echo %_viB% > %_cd%\user\_viB.txt
rem Kiểm tra số dư
echo {"query":"query{stateQuery{agent(address:\"%_viB%\"){crystal}}goldBalance(address: \"%_viB%\" )}"} > input.json
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql > output.json
rem Lọc kết quả lấy dữ liệu
jq "..|.crystal?|select(.)|tonumber" output.json > %_cd%\data\_crystalB.txt
jq "..|.goldBalance?|select(.)|tonumber" output.json > %_cd%\data\_ncgB.txt
rem Xóa file nháp input và output
cd %_cd%\batch
del *.json
cd %_cd%
:KTraViB
rem Kiểm tra 
echo ==========
echo Kiểm tra ví B
set /p _ncgCuaB=<%_cd%\data\_ncgB.txt
set /p _crystalCuaB=<%_cd%\data\_crystalB.txt
if not [%_ncgCuaB%] == [] (timeout 1 && exit /b) else (echo Lỗi 1: ví B chưa đúng cú pháp 'phân biệt cả chữ hoa chữ thường', thử lại... && color 4F && timeout 10 && goto :NhapViB)
:Background
cls
cd %_cd%
call %_cd%\Batch\TitleSendCurrency.bat
exit /b
:NhapViB
call :Background
echo ==========
echo Nhập ví (B)
echo.
cd %_cd%\batch
set /p _viB="Nhập ví B: "
echo %_viB% > %_cd%\user\_viB.txt
rem Kiểm tra số dư
echo {"query":"query{stateQuery{agent(address:\"%_viB%\"){crystal}}goldBalance(address: \"%_viB%\" )}"} > input.json
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql > output.json
rem Lọc kết quả lấy dữ liệu
jq "..|.crystal?|select(.)|tonumber" output.json > %_cd%\data\_crystalB.txt
jq "..|.goldBalance?|select(.)|tonumber" output.json > %_cd%\data\_ncgB.txt
rem Xóa file nháp input và output
cd %_cd%\batch
del *.json
cd %_cd%
goto :KTraViB