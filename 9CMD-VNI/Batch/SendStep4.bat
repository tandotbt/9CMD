echo off
echo ==========
echo Bước 4: Nhận stageTransaction
echo.
rem Cài %_cd% gốc
set /p _cd=<_cd.txt
cd %_cd%\batch
rem Nhận dữ liệu
set /p _node=<%_cd%\data\_node.txt
rem Nhận giá trị vượt quá 1024 kí tự
for %%A in (%_cd%\user\_signTransaction.txt) do for /f "usebackq delims=" %%B in ("%%A") do (
  set "_signTransaction=%%B"
  goto :break
)
:break
rem Xóa khoảng trắng
set _node=%_node: =%
set _signTransaction=%_signTransaction: =%
rem Gán biến vào code
cd %_cd%\batch
call %_cd%\batch\TaoInputJson.bat _signTransaction %_signTransaction% _codeStep4.txt > input.json
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql > output.json
rem Lọc kết quả lấy dữ liệu
echo ==========
echo Tìm stageTransaction...
echo.
cd %_cd%\batch
jq -r "..|.stageTransaction?|select(.)" output.json> %_cd%\user\_stageTransaction.txt
rem Xóa file nháp input và output
cd %_cd%\batch
del *.json
rem Xóa và action
del %_cd%\batch\action
exit /b