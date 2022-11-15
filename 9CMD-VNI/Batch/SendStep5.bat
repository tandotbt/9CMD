echo off
echo ==========
echo Bước 5: Kiểm tra giao dịch
echo.
rem Cài %_cd% gốc
set /p _cd=<_cd.txt
cd %_cd%\batch
rem Nhận dữ liệu
set /p _node=<%_cd%\data\_node.txt
set /p _stageTransaction=<%_cd%\user\_stageTransaction.txt
rem Xóa khoảng trắng
set _node=%_node: =%
set _stageTransaction=%_stageTransaction: =%
rem Gán biến vào code
cd %_cd%\batch
call %_cd%\batch\TaoInputJson.bat _stageTransaction %_stageTransaction% _codeStep5.txt > input.json
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql > output.json
rem Lọc kết quả lấy dữ liệu
echo ==========
echo Tìm txStatus...
echo.
cd %_cd%\batch
jq -r "..|.txStatus?|select(.)" output.json> %_cd%\user\_txStatus.txt
rem Xóa file nháp input và output
cd %_cd%\batch
del *.json
exit /b