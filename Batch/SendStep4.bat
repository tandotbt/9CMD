echo off
echo ==========
echo Bước 4: Nhận stageTransaction
echo.
rem Cài %_cd% gốc
set /p _cd=<_cd.txt
cd %_cd%\batch
rem Nhận dữ liệu
set /p xoa_nhay=<%_cd%\batch\_Input.txt
set xoa_nhay=%xoa_nhay:~1,-558%
set /p _node=<%_cd%\data\_node.txt
set /p _signTransaction=<%_cd%\batch\xoa_nhay2.txt
rem Xóa khoảng trắng
set _node=%_node: =%
set _signTransaction=%_signTransaction: =%
rem Gán biến vào code
cd %_cd%\batch
call %_cd%\batch\TaoInputJson.bat _signTransaction %_signTransaction% _codeStep4.txt > input1.json
call %_cd%\batch\TaoInputJson.bat _A %xoa_nhay% input1.json > input.json
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql > output.json
rem Lọc kết quả lấy dữ liệu
echo ==========
echo Tìm stageTransaction...
echo.
cd %_cd%\batch
call %_cd%\batch\ReadJson.bat stageTransaction output.json
call %_cd%\batch\XoaNhay.bat
copy %_cd%\user\_Output.txt %_cd%\user\_stageTransaction.txt
rem Xóa file nháp input và output
cd %_cd%\batch
del *.json
del /q %_cd%\batch\_Input.txt
del /q %_cd%\batch\xoa_nhay2.txt
rem Xóa file py và action
del %_cd%\batch\TaoFileAction.py
del %_cd%\batch\action
rem Sang bước 5
call %_cd%\batch\SendStep5.bat