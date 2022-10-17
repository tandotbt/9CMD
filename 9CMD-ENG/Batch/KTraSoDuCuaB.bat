echo ==========
echo Check the wallet balance (B)
rem Install %_cd% original
set /p _cd=<_cd.txt
cd %_cd%\batch
rem Receive variable
set /p _viB=<%_cd%\user\_viB.txt
set /p _node=<%_cd%\data\_node.txt
rem Delete spaces
set _viB=%_viB: =%
set _node=%_node: =%
rem Assign variables to code
echo {"query":"query{stateQuery{agent(address:\"%_viB%\"){crystal}}goldBalance(address: \"%_viB%\" )}"} > input.json
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql > output.json
rem Filter the results of data
jq "..|.crystal?|select(.)|tonumber" output.json > %_cd%/data/_crystalB.txt
jq "..|.goldBalance?|select(.)|tonumber" output.json > %_cd%/data/_ncgB.txt
rem Delete file nháp input và output
cd %_cd%\batch
del *.json
