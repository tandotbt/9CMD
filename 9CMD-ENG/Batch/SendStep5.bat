echo off
echo ==========
echo Step 5: Check transaction
echo.
rem Install %_cd% original
set /p _cd=<_cd.txt
cd %_cd%\batch
rem Get data
set /p _node=<%_cd%\data\_node.txt
set /p _stageTransaction=<%_cd%\user\_stageTransaction.txt
rem Delete spaces
set _node=%_node: =%
set _stageTransaction=%_stageTransaction: =%
rem Set variable to code
cd %_cd%\batch
call %_cd%\batch\TaoInputJson.bat _stageTransaction %_stageTransaction% _codeStep5.txt > input.json
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql > output.json
rem Filter the results of data
echo ==========
echo Find txStatus...
echo.
cd %_cd%\batch
jq -r "..|.txStatus?|select(.)" output.json> %_cd%\user\_txStatus.txt
rem Delete Input and Output file draft
cd %_cd%\batch
del *.json
exit /b