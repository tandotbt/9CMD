echo off
echo ==========
echo Step 4: Get stageTransaction
echo.
rem Install %_cd% original
set /p _cd=<_cd.txt
cd %_cd%\batch
rem Get data
set /p xoa_nhay=<%_cd%\batch\_Input.txt
set xoa_nhay=%xoa_nhay:~1,-558%
set /p _node=<%_cd%\data\_node.txt
set /p _signTransaction=<%_cd%\batch\xoa_nhay2.txt
rem Delete spaces
set _node=%_node: =%
set _signTransaction=%_signTransaction: =%
rem Set variable to code
cd %_cd%\batch
call %_cd%\batch\TaoInputJson.bat _signTransaction %_signTransaction% _codeStep4.txt > input1.json
call %_cd%\batch\TaoInputJson.bat _A %xoa_nhay% input1.json > input.json
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql > output.json
rem Filter the results of data
echo ==========
echo Find stageTransaction...
echo.
cd %_cd%\batch
call %_cd%\batch\ReadJson.bat stageTransaction output.json
call %_cd%\batch\XoaNhay.bat
copy %_cd%\user\_Output.txt %_cd%\user\_stageTransaction.txt
rem Delete Input and Output file draft
cd %_cd%\batch
del *.json
del /q %_cd%\batch\_Input.txt
del /q %_cd%\batch\xoa_nhay2.txt
rem Delete file py và action
del %_cd%\batch\TaoFileAction.py
del %_cd%\batch\action
rem Go to step 5
call %_cd%\batch\SendStep5.bat