set /a _addressToJson=%_i%
set /a _addressToJson+=-1
echo ==========
echo Receive data NCG and Crystal %_addressToJson% wallet(s)
rem Install %_cd% origin
set /p _cd=<_cd.txt
cd %_cd%
rem Receive variable
set /p _node=<%_cd%\data\_node.txt
rem Delete spaces
set _node=%_node: =%
rem Delete old file
echo [{}> %_cd%\user\avatarAddress\oldData.json
rem Read each line to receive Address
cd %_cd%\user\avatarAddress
set _i=0
for /f "tokens=*" %%a in (oldData.txt) do (call :processline %%a)
del /q %_cd%\user\avatarAddress\_ncg.txt
del /q %_cd%\user\avatarAddress\_crystal.txt
echo ]>> %_cd%\user\avatarAddress\oldData.json
if %_i%==1 echo [{"vi":"null"}]> %_cd%\user\avatarAddress\oldData.json
echo.==========
echo.Successful receive data
timeout 5
goto :eof
:processline
set _vi=%* & set _vi1=%_vi:~0,42%
set /a _ncg=0 & set /a _crystal=0
cd %_cd%\batch
rem Check the balance
echo {"query":"query{stateQuery{agent(address:\"%_vi:~0,42%\"){crystal}}goldBalance(address: \"%_vi:~0,42%\" )}"} > input.json
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql > output.json
rem Filter the results of data
jq "..|.crystal?|select(.)|tonumber" output.json > %_cd%/user/avatarAddress/_crystal.txt
jq "..|.goldBalance?|select(.)|tonumber" output.json > %_cd%/user/avatarAddress/_ncg.txt
rem Delete the draft file input and output
cd %_cd%\batch
del *.json
set /p _ncg=<%_cd%/user/avatarAddress/_ncg.txt
set /p _crystal=<%_cd%/user/avatarAddress/_crystal.txt
del /q %_cd%\user\avatarAddress\_ncg.txt
del /q %_cd%\user\avatarAddress\_crystal.txt
if %_i%==0 (echo. & set /a _i+=1) else (echo Received wallet [%_i%] & echo ,{"vi":"%_vi:~0,42%","ncg":"%_ncg%","crystal":"%_crystal%"}>>%_cd%\user\avatarAddress\oldData.json & set /a _i+=1)
goto :eof
:eof