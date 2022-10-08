echo off
echo ==========
echo Bước 3: Nhận signTransaction
echo.
rem Cài %_cd% gốc
set /p _cd=<_cd.txt
cd %_cd%\batch
rem Nhận dữ liệu
set /p _node=<%_cd%\data\_node.txt
set /p _unsignedTransaction=<%_cd%\user\_unsignedTransaction.txt
rem Xóa khoảng trắng
set _node=%_node: =%
set _unsignedTransaction=%_unsignedTransaction: =%
rem Tạo file action
echo ==========
echo Đang tạo file action
echo.
call %_cd%\batch\TaoInputJson.bat _unsignedTransaction %_unsignedTransaction% _codeFileAction.txt > TaoFileAction.py
TaoFileAction.py
rem Lấy signature
echo ==========
echo Lấy Signature
echo.
call %_cd%\batch\LaySignaturePlanet.bat
rem Nhận dữ liệu
set /p _signature=<%_cd%\user\_signature.txt
set _signature=%_signature: =%
rem Xóa file _KTraSignature.txt trong Planet
del /q %_cd%\planet\_KTraSignature.txt
echo ==========
echo Lấy Signature
echo.
echo Sau bước này không nên dừng lại mà hãy hoàn thành quy trình gửi
echo Nếu bị gián đoạn, bạn cần vào 9C và làm gì đó như nhận AP, sweep, bán item...
set /p _enter="Nhấn [Enter] để tiếp tục gửi"
rem Gán biến vào code
cd %_cd%\batch
call %_cd%\batch\TaoInputJson.bat _unsignedTransaction %_unsignedTransaction% _codeStep3.txt > input1.json
call %_cd%\batch\TaoInputJson.bat _signature %_signature% input1.json > input.json
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql > output.json
rem Lọc kết quả lấy dữ liệu
echo ==========
echo Tìm signTransaction...
echo.
call %_cd%\batch\ReadJson.bat signTransaction output.json
call %_cd%\batch\XoaNhay2.bat
copy %_cd%\user\_Output.txt %_cd%\user\_signTransaction.txt
rem Xóa file nháp input và output
cd %_cd%\batch
del *.json
rem Sang bước 4
call %_cd%\batch\SendStep4.bat