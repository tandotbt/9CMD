echo off
echo ==========
echo Step 2: Get unsignedTransaction
echo.
rem Install %_cd% original
set /p _cd=<_cd.txt
cd %_cd%\batch
rem Get data
set /p _node=<%_cd%\data\_node.txt
set /p _PublicKeyCuaA=<%_cd%\user\_PublicKeyCuaA.txt
set /p _transferAsset=<%_cd%\user\_transferAsset.txt
set /p _nextTxNonce=<%_cd%\user\_nextTxNonce.txt
rem Delete spaces
set _node=%_node: =%
set _PublicKeyCuaA=%_PublicKeyCuaA: =%
set _transferAsset=%_transferAsset: =%
set _nextTxNonce=%_nextTxNonce: =%
rem Set variable to code
cd %_cd%\batch
call %_cd%\batch\TaoInputJson.bat _PublicKeyCuaA %_PublicKeyCuaA% _codeStep2.txt > input1.json
call %_cd%\batch\TaoInputJson.bat _transferAsset %_transferAsset% input1.json > input2.json
call %_cd%\batch\TaoInputJson.bat _nextTxNonce %_nextTxNonce% input2.json > input.json
echo Wait 10 seconds & timeout 10
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql > output.json
rem Filter the results of data
echo ==========
echo Find unsignedTransaction...
echo.
cd %_cd%\batch
jq -r "..|.unsignedTransaction?|select(.)" output.json> %_cd%\user\_unsignedTransaction.txt
rem Delete Input and Output file draft
cd %_cd%\batch
del *.json
rem Go to step 3
call %_cd%\batch\SendStep3.bat