echo ==========
echo Kiểm tra số dư ví (A)
rem Cài %_cd% gốc
set /p _cd=<_cd.txt
cd %_cd%\batch
rem Nhận biến
set /p _viA=<%_cd%\user\_viA.txt
set /p _node=<%_cd%\data\_node.txt
rem Xóa khoảng trắng
set _viA=%_viA: =%
set _node=%_node: =%
rem Gán biến vào code
echo {"query":"query{stateQuery{agent(address:\"%_viA%\"){crystal}}goldBalance(address: \"%_viA%\" )}"} > input.json
echo Chờ 10 giây & timeout 10
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql > output.json
rem Lọc kết quả lấy dữ liệu
jq "..|.crystal?|select(.)|tonumber" output.json > %_cd%/data/_crystal.txt
jq "..|.goldBalance?|select(.)|tonumber" output.json > %_cd%/data/_ncg.txt
rem Xóa file nháp input và output
cd %_cd%\batch
del *.json