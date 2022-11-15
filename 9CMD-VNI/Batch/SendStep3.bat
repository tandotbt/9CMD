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
rem Tạo file action bằng batch
setlocal enabledelayedexpansion
echo !_unsignedTransaction!> %_cd%\batch\temp.hex
call certutil -decodehex temp.hex str.txt >nul
copy %_cd%\batch\str.txt action
rem Xóa nháp
del %_cd%\batch\str.txt
del %_cd%\batch\temp.hex
endlocal
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
echo Lấy payload
echo.
echo Sau bước này không nên dừng lại mà hãy hoàn thành quy trình gửi
echo Nếu bị gián đoạn, bạn cần vào 9C và làm gì đó như nhận AP, sweep, bán item...
echo.[1] Tiếp tục, tự động sau 10s
echo.[2] Quay lại menu
choice /c 12 /n /t 10 /d 1 /m "Nhập từ bàn phím: "
if %errorlevel%==1 (goto :tieptucGui)
if %errorlevel%==2 (call %_cd%\batch\menu.bat)
:tieptucGui
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
jq -r "..|.signTransaction?|select(.)" output.json> %_cd%\user\_signTransaction.txt
rem Xóa file nháp input và output
cd %_cd%\batch
del *.json
rem Sang bước 4
call %_cd%\batch\SendStep4.bat