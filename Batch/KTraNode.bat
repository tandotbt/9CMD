rem Cài %_cd% gốc
set /p _cd=<_cd.txt
cd %_cd%\batch
rem Nhận biến
set /p _node=<%_cd%\data\_node.txt
rem Xóa khoảng trắng
set _node=%_node: =%
echo ==========
echo Kiểm tra node %_node%
rem Gán biến vào code
echo {"query":"query{nodeStatus{preloadEnded}}"} > input.json
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" http://9c-main-rpc-%_node%.nine-chronicles.com/graphql > %_cd%/data/_KTraNode.txt
rem Xóa file nháp input và output
cd %_cd%\batch
del *.json