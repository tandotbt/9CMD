echo off
echo ==========
echo Step 4: Get stageTransaction
echo.
rem Install %_cd% original
set /p _cd=<_cd.txt
cd %_cd%\batch
rem Get data
set /p _node=<%_cd%\data\_node.txt
rem Get value exceeding 1024 characters
for %%A in (%_cd%\user\_signTransaction.txt) do for /f "usebackq delims=" %%B in ("%%A") do (
  set "_signTransaction=%%B"
  goto :break
)
:break
rem Delete spaces
set _node=%_node: =%
set _signTransaction=%_signTransaction: =%
rem Set variable to code
cd %_cd%\batch
call %_cd%\batch\TaoInputJson.bat _signTransaction %_signTransaction% _codeStep4.txt > input.json
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql > output.json
rem Filter the results of data
echo ==========
echo Find stageTransaction...
echo.
cd %_cd%\batch
jq -r "..|.stageTransaction?|select(.)" output.json> %_cd%\user\_stageTransaction.txt
rem Delete Input and Output file draft
cd %_cd%\batch
del *.json
rem Delete action file
del %_cd%\batch\action
exit /b