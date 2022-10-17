echo off
mode con:cols=100 lines=20
color 0B
rem Cài tiếng Việt Nam
chcp 65001
cls
echo ==========
echo Bước 1: Nhận transferAsset và nextTxNonce
echo.
rem Cài %_cd% gốc
set /p _cd=<_cd.txt
cd %_cd%\batch
rem Nhận dữ liệu
set /p _node=<%_cd%\data\_node.txt
set /p _viA=<%_cd%\user\_viA.txt
set /p _viB=<%_cd%\user\_viB.txt
set /p _soLuong=<%_cd%\data\_soLuong.txt
set /p _currency=<%_cd%\data\_currency.txt
set /p _PublicKeyCuaA=<%_cd%\user\_PublicKeyCuaA.txt
set /p _memo=<%_cd%\data\_memo.txt
rem Xóa khoảng trắng
set _node=%_node: =%
set _viA=%_viA: =%
set _viB=%_viB: =%
set _soLuong=%_soLuong: =%
set _currency=%_currency: =%
set _PublicKeyCuaA=%_PublicKeyCuaA: =%
set _memo=%_memo: =%
rem Gán biến vào code
cd %_cd%\batch
call %_cd%\batch\TaoInputJson.bat _viA %_viA% _codeStep1.txt > input1.json
call %_cd%\batch\TaoInputJson.bat _viB %_viB% input1.json > input2.json
call %_cd%\batch\TaoInputJson.bat _soLuong %_soLuong% input2.json > input3.json
call %_cd%\batch\TaoInputJson.bat _currency %_currency% input3.json > input4.json
call %_cd%\batch\TaoInputJson.bat _memo %_memo%_9CMD_TooL input4.json > input.json
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql > output.json
rem Lọc kết quả lấy dữ liệu
echo ==========
echo Tìm transferAsset...
echo.
cd %_cd%\batch
call %_cd%\batch\ReadJson.bat transferAsset output.json
call %_cd%\batch\XoaNhay.bat
copy %_cd%\user\_Output.txt %_cd%\user\_transferAsset.txt
echo ==========
echo Tìm nextTxNonce...
echo.
cd %_cd%\batch
call %_cd%\batch\ReadJson.bat nextTxNonce output.json
call %_cd%\batch\XoaNhay.bat
copy %_cd%\user\_Output.txt %_cd%\user\_nextTxNonce.txt
rem Xóa file nháp input và output
cd %_cd%\batch
del *.json
rem Sang bước 2
call %_cd%\batch\SendStep2.bat