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
rem Create Action file with batch
setlocal enabledelayedexpansion
echo !_unsignedTransaction!> %_cd%\batch\temp.hex
call certutil -decodehex temp.hex str.txt >nul
copy %_cd%\batch\str.txt action
rem Delete draft
del %_cd%\batch\str.txt
del %_cd%\batch\temp.hex
endlocal
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
echo Get payload
echo.
echo After this step should not stop, complete the sending process is better
echo If interrupted, you need play 9C and do something like receiving AP, SWEEP, selling items...
echo.[1] Continue, automatically after 10 seconds
echo.[2] Back to the menu
choice /c 12 /n /t 10 /d 1 /m "Enter from the keyboard: "
if %errorlevel%==1 (goto :tieptucGui)
if %errorlevel%==2 (call %_cd%\batch\menu.bat)
:tieptucGui
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
jq -r "..|.signTransaction?|select(.)" output.json> %_cd%\user\_signTransaction.txt
rem Delete file draft input and output
cd %_cd%\batch
del *.json
rem Go to step 4
call %_cd%\batch\SendStep4.bat