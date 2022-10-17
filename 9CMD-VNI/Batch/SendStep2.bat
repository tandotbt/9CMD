echo off
echo ==========
echo Bước 2: Nhận unsignedTransaction
echo.
rem Cài %_cd% gốc
set /p _cd=<_cd.txt
cd %_cd%\batch
rem Nhận dữ liệu
set /p _node=<%_cd%\data\_node.txt
set /p _PublicKeyCuaA=<%_cd%\user\_PublicKeyCuaA.txt
set /p _transferAsset=<%_cd%\user\_transferAsset.txt
set /p _nextTxNonce=<%_cd%\user\_nextTxNonce.txt
rem Xóa khoảng trắng
set _node=%_node: =%
set _PublicKeyCuaA=%_PublicKeyCuaA: =%
set _transferAsset=%_transferAsset: =%
set _nextTxNonce=%_nextTxNonce: =%
rem Gán biến vào code
cd %_cd%\batch
call %_cd%\batch\TaoInputJson.bat _PublicKeyCuaA %_PublicKeyCuaA% _codeStep2.txt > input1.json
call %_cd%\batch\TaoInputJson.bat _transferAsset %_transferAsset% input1.json > input2.json
call %_cd%\batch\TaoInputJson.bat _nextTxNonce %_nextTxNonce% input2.json > input.json
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql > output.json
rem Lọc kết quả lấy dữ liệu
echo ==========
echo Tìm unsignedTransaction...
echo.
cd %_cd%\batch
call %_cd%\batch\ReadJson.bat unsignedTransaction output.json
call %_cd%\batch\XoaNhay.bat
copy %_cd%\user\_Output.txt %_cd%\user\_unsignedTransaction.txt
rem Xóa file nháp input và output
cd %_cd%\batch
del *.json
rem Sang bước 3
call %_cd%\batch\SendStep3.bat