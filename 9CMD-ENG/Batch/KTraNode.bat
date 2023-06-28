rem Install %_cd% original
set /p _cd=<_cd.txt
cd %_cd%\batch
rem Receive variable
set /p _node=<%_cd%\data\_node.txt
rem Delete spaces
set _node=%_node: =%
echo ==========
echo Check node %_node%
rem Assign variables to code
echo {"query":"query{nodeStatus{preloadEnded}}"} > input.json
echo Wait 10 seconds & timeout 10
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" http://9c-main-rpc-%_node%.nine-chronicles.com/graphql > %_cd%/data/_KTraNode.txt
rem Delete file nháp input và output
cd %_cd%\batch
del *.json