echo off
echo ==========
echo Step 3: Take signTransaction
echo.
rem Install %_cd% original
set /p _cd=<_cd.txt
cd %_cd%\batch
rem Receive data
set /p _node=<%_cd%\data\_node.txt
set /p _unsignedTransaction=<%_cd%\user\_unsignedTransaction.txt
rem Delete spaces
set _node=%_node: =%
set _unsignedTransaction=%_unsignedTransaction: =%
rem Create Action File
echo ==========
echo Creating files action
echo.
call %_cd%\batch\TaoInputJson.bat _unsignedTransaction %_unsignedTransaction% _codeFileAction.txt > TaoFileAction.py
TaoFileAction.py
rem Get signature
echo ==========
echo Get Signature
echo.
call %_cd%\batch\LaySignaturePlanet.bat
rem Receive data
set /p _signature=<%_cd%\user\_signature.txt
set _signature=%_signature: =%
rem Delete file _KTraSignature.txt in Planet
del /q %_cd%\planet\_KTraSignature.txt
echo ==========
echo Get Signature
echo.
echo After this step should not stop, complete the sending process is better
echo If interrupted, you need play 9C and do something like receiving AP, SWEEP, selling items...
set /p _enter="Press [Enter] to continue sending"
rem Assign variables to code
cd %_cd%\batch
call %_cd%\batch\TaoInputJson.bat _unsignedTransaction %_unsignedTransaction% _codeStep3.txt > input1.json
call %_cd%\batch\TaoInputJson.bat _signature %_signature% input1.json > input.json
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql > output.json
rem Filter the results of data
echo ==========
echo Searching signTransaction...
echo.
call %_cd%\batch\ReadJson.bat signTransaction output.json
call %_cd%\batch\XoaNhay2.bat
copy %_cd%\user\_Output.txt %_cd%\user\_signTransaction.txt
rem Delete file draft input and output
cd %_cd%\batch
del *.json
rem Go to step 4
call %_cd%\batch\SendStep4.bat