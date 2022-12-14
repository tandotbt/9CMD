echo off
mode con:cols=60 lines=25
color 0B
rem Install Vietnamese
chcp 65001
cls
set _stt=%1
set _vi=**********************
set _9cscanBlock=*******
set _canAuto=0
set /a _HanSuDung=0
set /a _chuyendoi=0
set /a _premiumTXOK=0 & set /a _passwordOK=0 & set /a _publickeyOK=0 & set /a _keyidOK=0 & set /a _canAutoOnOff=0 & set /a _utcFileOK=0 & set /a _autoRefillAP=0 & set /a _autoSweepOnOffAll=0
set /p _node=<%_cd%\data\_node.txt
set _node=%_node: =%
:BatDau
rem setlocal ENABLEDELAYEDEXPANSION
rem Set %_cd% origin
set /p _cd=<_cd.txt
set _stt=%_stt%
call :background
rem Check if there is a wallet folder yet
set _folder="%_cd%\User\trackedAvatar"
if not exist %_folder% (md %_cd%\User\trackedAvatar)
set _folderVi=vi%_stt%
set _folder="%_cd%\User\trackedAvatar\%_folderVi%"
if exist %_folder% (goto :yesFolder) else (echo.└── Processing ... & goto :noFolder)
:yesFolder
rem Get the wallet being saved
set /p _vi=<%_cd%\user\trackedAvatar\%_folderVi%\_vi.txt
call :background
echo.Existing folders vi%_stt% in memory
echo.[1] Still using old data, automatically select after 5s
echo.[2] Quit
echo.[3] Quit
echo.[4] Quit
echo.[5] Delete old and creat new wallet data
choice /c 12345 /n /t 5 /d 1 /m "Enter from the keyboard: "
echo.└── Processing ...
if %errorlevel%==2 (echo.└──── Quit after 5s ... & timeout 5 & exit)
if %errorlevel%==3 (echo.└──── Quit after 5s ... & timeout 5 & exit)
if %errorlevel%==4 (echo.└──── Quit after 5s ... & timeout 5 & exit)
if %errorlevel%==1 (goto :duLieuViCu)
if %errorlevel%==5 (rd /s /q %_cd%\User\trackedAvatar\%_folderVi%) 
:noFolder
rem Create folders to save wallet data
cd %_cd%\User\trackedAvatar\
md %_folderVi%
rem Save the wallet address
cd %_cd%\batch\avatarAddress
jq -r ".[%_stt%]|.vi" oldData.json> %_cd%\user\trackedAvatar\%_folderVi%\_vi.txt 2>nul & set /p _vi=<%_cd%\user\trackedAvatar\%_folderVi%\_vi.txt
:duLieuViCu
rem Create necessary files
copy "%_cd%\_cd.txt" "%_cd%\user\trackedAvatar\%_folderVi%\_cd.txt">nul
rem Get the current block
echo.└──── Get the current block ...
cd %_cd%\user\trackedAvatar\%_folderVi%
curl https://api.9cscan.com/transactions?limit=0 --ssl-no-revoke> _9cscanBlock.json 2>nul & set /p _9cscanBlock=<_9cscanBlock.json
del /q _9cscanBlock.json & set /a _9cscanBlock=%_9cscanBlock:~-11,-4%
rem Receive all character data
echo.└──── Get information all characters ...
cd %_cd%\batch\avatarAddress
curl https://api.9cscan.com/account?address=%_vi% --ssl-no-revoke> %_cd%\user\trackedAvatar\%_folderVi%\_allChar.json 2>nul
rem Take the number of characters
echo.└──── Take the number of characters ...
jq "length" %_cd%\user\trackedAvatar\%_folderVi%\_allChar.json > %_cd%\user\trackedAvatar\%_folderVi%\_length.txt 2>nul
set /p _length=<%_cd%\user\trackedAvatar\%_folderVi%\_length.txt
if not %_length% geq 1 (if %_length% leq 4 (echo. & echo Error 1: Wrong wallet or 9cscan error 404, try again ... & color 4F & timeout 5 & goto :BatDau))
set /a _length+=-1
rem Get Stake level to find AP consumption
echo.└──── Get the AP number consumed by Stake level ...
cd %_cd%\user\trackedAvatar\%_folderVi%
echo {"query":"query{stateQuery{stakeStates(addresses:\"%_vi%\"){deposit}}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json 2>nul
echo 5 > _stakeAP.txt
rem Filter the results of data
findstr /i null output.json> nul
if %errorlevel% == 1 ("%_cd%\batch\jq.exe" -r ".data.stateQuery.stakeStates|.[]|.deposit|tonumber|if . > 500000 then 3 elif . > 5000 then 4 else 5 end" output.json > _stakeAP.txt 2>nul)
set /p _stakeAP=<_stakeAP.txt & set /a _stakeAP=%_stakeAP% 2>nul
rem Delete the draft file input and output
del /q %_cd%\user\trackedAvatar\%_folderVi%\input.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\output.json 2>nul
rem Load old data if any
echo.└──── Load old data if any ...
rem Check if the UTC file is available or not
cd %_cd%\planet
set _utcfile=^|planet key --path %_cd%\user\utc 2>nul|findstr /i %_vi%>nul
if %errorlevel% equ 0 (set /a _utcFileOK=1)
set _file="%_cd%\user\trackedAvatar\%_folderVi%\premium\_premiumTX.txt"
if exist %_file% (set /p _premiumTX=<%_cd%\user\trackedAvatar\%_folderVi%\premium\_premiumTX.txt & set /a _premiumTXOK=1)
rem Try getting password
set _file="%_cd%\user\trackedAvatar\%_folderVi%\auto\password\_password.txt"
if exist %_file% (set /p _password=<%_cd%\user\trackedAvatar\%_folderVi%\auto\password\_password.txt & set /a _passwordOK=1)
rem Try to get public key
set _file="%_cd%\user\trackedAvatar\%_folderVi%\auto\publickey\_publickey.txt"
if exist %_file% (set /p _publickey=<%_cd%\user\trackedAvatar\%_folderVi%\auto\publickey\_publickey.txt & set /a _publickeyOK=1)
rem Try to get the Key ID
set _file="%_cd%\user\trackedAvatar\%_folderVi%\auto\KeyID\_KeyID.txt"
if exist %_file% (set /p _KeyID=<%_cd%\user\trackedAvatar\%_folderVi%\auto\KeyID\_KeyID.txt & set /a _keyidOK=1)
rem Filter each character
set _charCount=1
:locChar
echo.└──── Input data character %_charCount% ...
cd %_cd%\batch\avatarAddress
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%"
if not exist %_folder% (md %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%)
jq ".[%_charCount%]|del(.refreshBlockIndex)|del(.avatarAddress)|del(.address)|del(.goldBalance)|.[]|{address, name, level, actionPoint,timeCount: (.dailyRewardReceivedIndex+1700-%_9cscanBlock%)}" %_cd%\user\trackedAvatar\%_folderVi%\_allChar.json> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_infoChar.json 2>nul
jq "{sec: ((.timeCount*12)%%60),minute: ((((.timeCount*12)-(.timeCount*12)%%60)/60)%%60),hours: (((((.timeCount*12)-(.timeCount*12)%%60)/60)-(((.timeCount*12)-(.timeCount*12)%%60)/60%%60))/60)}" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_infoChar.json> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_infoCharAp.json 2>nul
jq -j """\(.hours):\(.minute):\(.sec)""" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_infoCharAp.json> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_infoCharAp.txt 2>nul
jq -r ".address" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_infoChar.json> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_address.txt 2>nul
jq -r ".name" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_infoChar.json> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_name.txt 2>nul
jq -r ".level" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_infoChar.json > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_level.txt 2>nul
jq -r ".actionPoint" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_infoChar.json > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_actionPoint.txt 2>nul
jq -r ".timeCount" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_infoChar.json> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_timeCount.txt 2>nul
rem Get opened stage
echo.└────── Get opened stage ...
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%
set /p _AddressChar=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_address.txt
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_AddressChar%\"){stageMap{count}}}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json 2>nul
rem Filter the results of data
"%_cd%\batch\jq.exe" -r "..|.count?|select(.)" output.json > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_stage.txt 2>nul
rem Delete the draft file input and output
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\input.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\output.json 2>nul
rem Create necessary files
set /p _stage=<_stage.txt
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep"
if not exist %_folder% (md %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep)
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_stageSweepRandom.txt"
if not exist %_file% (echo %_stage% > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_stageSweepRandom.txt)
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_howManyTurn.txt"
if not exist %_file% (echo 0 > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_howManyTurn.txt)
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_autoSweepOnOffChar.txt"
if not exist %_file% (echo 0 > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_autoSweepOnOffChar.txt)
rem Create URL links where item data saves each char
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_urlJson.txt"
if exist %_file% (goto :locChar1)
echo.└────── Create link jsonblob.com to view items ...
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep
curl -i -X "POST" -d "{}" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob --ssl-no-revoke 2>nul|findstr /i location>nul> _temp.txt 2>nul
set /p _temp=<_temp.txt
echo %_temp:~43,19%> _urlJson.txt 2>nul & set "_temp=" & del /q _temp.txt 2>nul
:locChar1
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\"
if exist %_folder% (goto :locChar2)
rem Create file index.html
echo.└────── Create html file to see items ...
xcopy "%_cd%\data\CheckItem\" "%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\" >nul
set /p _urlJson=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_urlJson.txt
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem
call "%_cd%\batch\TaoInputJson.bat" _IDapiJson %_urlJson% index-raw.html> index-raw2.html 2>nul
type index-raw1.html index-raw2.html index-raw3.html> index.html 2>nul
del /q index-raw1.html index-raw2.html index-raw3.html index-raw.html
:locChar2
rem Create file _itemEquip.json
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_itemEquip.json"
if exist %_file% (goto :locChar3)
echo.└────── Create file _itemEquip.json to view items ...
echo {"weapon":"","armor":"","belt":"","necklace":"","ring1":"","ring2":""}> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_itemEquip.json
:locChar3
if not "%_charCount%"=="%_length%" (set /a _charCount+=1 & goto :locChar)
:displayVi
call :background
set _charCount=1
:displayChar
call :background2 %_charCount%
if not "%_charCount%"=="%_length%" (set /a _charCount+=1 & goto :displayChar)
echo.[40;96m
echo.==========
if %_canAutoOnOff% == 1 (
	echo.[1] Update, automatically after 60s	[40;92m╔═══════════════╗[40;96m
	echo.[2] Setting Auto			[40;92m║4.Turn OFF Auto║[40;96m
	echo.[3] User guide				[40;92m╚═══════════════╝[40;96m
	) else (
		echo.[1] Update, automatically after 60s	[40;97m╔═══════════════╗[40;96m
		echo.[2] Setting Auto			[40;97m║4.Turn ON Auto ║[40;96m
		echo.[3] User guide				[40;97m╚═══════════════╝[40;96m
		)
choice /c 1234 /n /t 60 /d 1 /m "Enter the number from the keyboard: "
if %errorlevel% equ 1 (echo.└── Updating ... & goto :duLieuViCu)
if %errorlevel% equ 2 (goto :settingAuto)
if %errorlevel% equ 3 (goto :hdsd)
if %errorlevel% equ 4 (goto :canAutoOnOff)
goto :displayVi
:background
cd %_cd%
color 0B
title Wallet [%_stt%] [%_vi%]
cls
set /a _canAuto=%_premiumTXOK% + %_passwordOK% + %_publickeyOK% + %_KeyIDOK% + %_utcFileOK%
echo.╔═══════════════╗   ╔═══════════════╗   ╔═══════════════╗
if %_canAuto%==5 echo ║ID %_vi:~0,7%***	║   ║Block: %_9cscanBlock% ║   ║[40;92mCan Auto? [X]	[40;96m║
if not %_canAuto%==5 echo ║ID %_vi:~0,7%***	║   ║Block: %_9cscanBlock% ║   ║[40;97mCan Auto? [ ]	[40;96m║
echo.╚═══════════════╝   ╚═══════════════╝   ╚═══════════════╝
exit /b
:background2
set /a _charDisplay=%1
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%
set /p _name=<_name.txt & set /p _level=<_level.txt & set /p _stage=<_stage.txt & set /p _actionPoint=<_actionPoint.txt & set /p _infoCharAp=<_infoCharAp.txt & set /p _timeCount=<_timeCount.txt & set /p _address=<_address.txt
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%\settingSweep
rem Randomly select 1 Stage in _stageSweepRandom.txt
set INPUT_FILE="_stageSweepRandom.txt"
rem Count the number of lines in the text file and generate a random number
for /f "usebackq" %%a in (`find /V /C "" ^< %INPUT_FILE%`) do set lines=%%a
set /a randnum=%RANDOM% * lines / 32768 + 1, skiplines=randnum-1
rem Extract the line from the file
set skip=
if %skiplines% gtr 0 set skip=skip=%skiplines%
for /f "usebackq %skip% delims=" %%a in (%INPUT_FILE%) do set "randline=%%a" & goto continueBackground2
:continueBackground2
rem echo Line #%randnum% is:
echo/%randline% > _stageSweep.txt
set /p _stageSweep=<_stageSweep.txt & set /p _autoSweepOnOffChar=<_autoSweepOnOffChar.txt & set /p _howManyTurn=<_howManyTurn.txt 
set /a _stageSweep=%_stageSweep% 2>nul & set /a _autoSweepOnOffChar=%_autoSweepOnOffChar% 2>nul & set /a _howManyTurn=%_howManyTurn% 2>nul
if %_stageSweep% leq 50 (echo 1 > _world.txt 2>nul)
if %_stageSweep% leq 100 (if %_stageSweep% geq 51 (echo 2 > _world.txt 2>nul))
if %_stageSweep% leq 150 (if %_stageSweep% geq 101 (echo 3 > _world.txt 2>nul))
if %_stageSweep% leq 200 (if %_stageSweep% geq 151 (echo 4 > _world.txt 2>nul))
if %_stageSweep% leq 250 (if %_stageSweep% geq 201 (echo 5 > _world.txt 2>nul))
if %_stageSweep% leq 300 (if %_stageSweep% geq 251 (echo 6 > _world.txt 2>nul))
if %_stageSweep% leq 350 (if %_stageSweep% geq 301 (echo 7 > _world.txt 2>nul))
set /p _world=<_world.txt
set _name=                    %_name%
set _level=                    %_level%
set _stage=               %_stage%
set _actionPoint=               %_actionPoint%
set _infoCharAp=                    %_infoCharAp%
if %_timeCount% lss 0 (
	echo.[40;32m╔═══════════════════════════════════════════════════════╗
	echo.║Name	:%_name:~-20%	AP	:%_actionPoint:~-15%║
	echo.║Level	:%_level:~-20%	Stage	:%_stage:~-15%║
	echo.║Refill	:%_infoCharAp:~-20%	Sweep	: [%_autoSweepOnOffChar%][%_stageSweep% / %_howManyTurn%]	║
	echo.╚═══════════════════════════════════════════════════════╝[40;96m
	) else (
		echo.[40;96m╔═══════════════════════════════════════════════════════╗
		echo.║Name	:%_name:~-20%	AP	:%_actionPoint:~-15%║
		echo.║Level	:%_level:~-20%	Stage	:%_stage:~-15%║
		echo.║Refill	:%_infoCharAp:~-20%	Sweep	: [%_autoSweepOnOffChar%][%_stageSweep% / %_howManyTurn%]	║
		echo.╚═══════════════════════════════════════════════════════╝[40;96m
		)
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%		
set /p _name=<_name.txt & set /p _level=<_level.txt & set /p _stage=<_stage.txt & set /p _actionPoint=<_actionPoint.txt & set /p _infoCharAp=<_infoCharAp.txt & set /p _timeCount=<_timeCount.txt & set /p _address=<_address.txt
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%\settingSweep
rem Check can auto refill AP or not
if %_canAutoOnOff% == 1 (if %_timeCount% lss 0 (if %_canAuto% == 5 (if %_actionPoint% == 0 (if %_autoRefillAP% == 1 (call :autoRefillAP)))))
rem Check can Auto sweep or not
set /a _howManyAP=%_stakeAP%*%_howManyTurn%
if %_canAutoOnOff% == 1 (if %_autoSweepOnOffAll% == 1 (if %_autoSweepOnOffChar% == 1 (if %_howManyTurn% gtr 0 (if %_howManyAP% leq %_actionPoint% (call :autoSweep)))))
exit /b
:background3
call :background
set /a _charDisplay=%1
rem Check whether or not the character
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%"
if not exist %_folder% (goto :gotoSweep)
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%
set /p _name=<_name.txt & set /p _level=<_level.txt & set /p _stage=<_stage.txt & set /p _actionPoint=<_actionPoint.txt & set /p _infoCharAp=<_infoCharAp.txt & set /p _timeCount=<_timeCount.txt & set /p _address=<_address.txt
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%\settingSweep
rem Randomly select 1 Stage in _stageSweepRandom.txt
set INPUT_FILE="_stageSweepRandom.txt"
rem Count the number of lines in the text file and generate a random number
for /f "usebackq" %%a in (`find /V /C "" ^< %INPUT_FILE%`) do set lines=%%a
set /a randnum=%RANDOM% * lines / 32768 + 1, skiplines=randnum-1
rem Extract the line from the file
set skip=
if %skiplines% gtr 0 set skip=skip=%skiplines%
for /f "usebackq %skip% delims=" %%a in (%INPUT_FILE%) do set "randline=%%a" & goto continueBackground3
:continueBackground3
rem echo Line #%randnum% is:
echo/%randline% > _stageSweep.txt
set /p _stageSweep=<_stageSweep.txt & set /p _autoSweepOnOffChar=<_autoSweepOnOffChar.txt & set /p _howManyTurn=<_howManyTurn.txt 
set /a _stageSweep=%_stageSweep% 2>nul & set /a _autoSweepOnOffChar=%_autoSweepOnOffChar% 2>nul & set /a _howManyTurn=%_howManyTurn% 2>nul
if %_stageSweep% leq 50 (echo 1 > _world.txt 2>nul)
if %_stageSweep% leq 100 (if %_stageSweep% geq 51 (echo 2 > _world.txt 2>nul))
if %_stageSweep% leq 150 (if %_stageSweep% geq 101 (echo 3 > _world.txt 2>nul))
if %_stageSweep% leq 200 (if %_stageSweep% geq 151 (echo 4 > _world.txt 2>nul))
if %_stageSweep% leq 250 (if %_stageSweep% geq 201 (echo 5 > _world.txt 2>nul))
if %_stageSweep% leq 300 (if %_stageSweep% geq 251 (echo 6 > _world.txt 2>nul))
if %_stageSweep% leq 350 (if %_stageSweep% geq 301 (echo 7 > _world.txt 2>nul))
set /p _world=<_world.txt
set _name=                    %_name%
set _level=                    %_level%
set _stage=               %_stage%
set _actionPoint=               %_actionPoint%
set _infoCharAp=                    %_infoCharAp%
set _stageSweep=              Stage %_stageSweep%
set _howManyTurn=               %_howManyTurn%
echo.Nhân vật %_charDisplay%
if %_autoSweepOnOffChar% == 1 (
	echo.[40;32m╔═══════════════════════════════════════════════════════╗
	echo.║Name	:%_name:~-20%	AP	:%_actionPoint:~-15%║
	echo.║Level	:%_level:~-20%	Stage	:%_stage:~-15%║
	echo.║Sweep	:%_stageSweep:~-20%	Turn	:%_howManyTurn:~-15%║
	echo.╚═══════════════════════════════════════════════════════╝[40;96m
	) else (
		echo.[40;97m╔═══════════════════════════════════════════════════════╗
		echo.║Name	:%_name:~-20%	AP	:%_actionPoint:~-15%║
		echo.║Level	:%_level:~-20%	Stage	:%_stage:~-15%║
		echo.║Sweep	:%_stageSweep:~-20%	Turn	:%_howManyTurn:~-15%║
		echo.╚═══════════════════════════════════════════════════════╝[40;96m
		)
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%		
set /p _name=<_name.txt & set /p _level=<_level.txt & set /p _stage=<_stage.txt & set /p _actionPoint=<_actionPoint.txt & set /p _infoCharAp=<_infoCharAp.txt & set /p _timeCount=<_timeCount.txt & set /p _address=<_address.txt		
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%\settingSweep
set /p _stageSweep=<_stageSweep.txt & set /p _autoSweepOnOffChar=<_autoSweepOnOffChar.txt
set /a _stageSweep=%_stageSweep% 2>nul & set /a _autoSweepOnOffChar=%_autoSweepOnOffChar% 2>nul
exit /b
:settingAuto
if %_chuyendoi% == 0 (goto :gotoRefillAP)
if %_chuyendoi% == 1 (goto :gotoSweep)
:gotoRefillAP
set /a _chuyendoi=0
call :background
echo.==========
echo.╔═══════════════╗   ╔═══════════════╗   ╔═══════════════╗
echo ║1.Premium?[%_premiumTXOK%]	║   ║2.Password?[%_passwordOK%] ║   ║3.PublicKey?[%_publickeyOK%]║
echo.╚═══════════════╝   ╚═══════════════╝   ╚═══════════════╝
echo.╔═══════════════╗   ╔═══════════════╗
echo ║4.KeyID?[%_KeyIDOK%]	║   ║5.File UTC?[%_utcFileOK%] ║
echo.╚═══════════════╝   ╚═══════════════╝
echo.==========
echo.╔═══════════════╗   ╔═══════════════╗
echo ║AutoRefill?[%_autoRefillAP%] ║   ║AutoSweep?[%_autoSweepOnOffAll%]  ║
echo.╚═══════════════╝   ╚═══════════════╝
echo.==========
echo.[40;97mMenu Auto Refill AP[40;96m
echo.[1..5] Enter enough to auto
echo.==========
echo.[6, 7] Return
echo.[8] Turn on / off auto Refill AP main
echo.[9] Switch to settings [40;97mAuto Sweep[40;96m
choice /c 123456789 /n /m "Enter the number from the keyboard: "
if %errorlevel% equ 1 (goto :premium)
if %errorlevel% equ 2 (goto :password)
if %errorlevel% equ 3 (goto :publickey)
if %errorlevel% equ 4 (goto :KeyID)
if %errorlevel% equ 5 (goto :utcFile)
if %errorlevel% equ 6 (goto :displayVi)
if %errorlevel% equ 7 (goto :displayVi)
if %errorlevel% equ 8 (goto :autoRefillAPOnOff)
if %errorlevel% equ 9 (goto :gotoSweep)
goto :settingAuto
:gotoSweep
set /a _chuyendoi=1
set /a _charCount=1
:gotoSweep1
mode con:cols=60 lines=35
call :background3 %_charCount%
echo.[40;96m==========
echo.╔═══════════════╗ 
echo ║AP/turn: %_stakeAP%	║
echo.╚═══════════════╝
echo.==========
echo.╔═══════════════╗   ╔═══════════════╗
echo ║AutoRefill?[%_autoRefillAP%] ║   ║AutoSweep?[%_autoSweepOnOffAll%]  ║
echo.╚═══════════════╝   ╚═══════════════╝
echo.==========
echo.[40;97mMenu Auto Sweep[40;96m
echo.[1] Import equipment
echo.[2] Enter Stage you want Sweep
echo.[3] Enter the number of turn in each Sweep transaction
echo.==========
echo.[4] Switch to the next character
echo.[5] Turn on / off auto Sweep for [40;97m%_name%[40;96m
echo.==========
echo.[6] ...
echo.==========
echo.[7] Return
echo.[8] Turn on / off auto Sweep main
echo.[9] Switch to settings [40;97mAuto Refill AP[40;96m
choice /c 123456789 /n /m "Enter the number from the keyboard: "
if %errorlevel% equ 1 (mode con:cols=60 lines=25 & goto :importTrangBi)
if %errorlevel% equ 2 (mode con:cols=60 lines=25 & goto :pickSweep)
if %errorlevel% equ 3 (mode con:cols=60 lines=25 & goto :howManyTurn)
if %errorlevel% equ 4 (mode con:cols=60 lines=25 & set /a _charCount+=1 &goto :gotoSweep1)
if %errorlevel% equ 5 (mode con:cols=60 lines=25 & goto :charSweepOnOff)
if %errorlevel% equ 6 (mode con:cols=60 lines=25 & goto :displayVi)
if %errorlevel% equ 7 (mode con:cols=60 lines=25 & goto :displayVi)
if %errorlevel% equ 8 (mode con:cols=60 lines=25 & goto :autoSweepOnOffAll)
if %errorlevel% equ 9 (mode con:cols=60 lines=25 & goto :gotoRefillAP)
goto :gotoSweep1
:charSweepOnOff
if %_autoSweepOnOffChar% == 0 (set /a _autoSweepOnOffChar=1) else (set /a _autoSweepOnOffChar=0)
echo %_autoSweepOnOffChar% > %_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%\settingSweep\_autoSweepOnOffChar.txt
goto :gotoSweep1
:howManyTurn
call :background3 %_charCount%
echo.[40;96m==========
set /a _maxTurn=120/%_stakeAP%
set _maxTurn=  %_maxTurn%
echo.╔═══════════════╗   ╔═══════════════╗
echo ║AP/turn: %_stakeAP%	║   ║Max turn:	%_maxTurn:~-2%%  ║
echo.╚═══════════════╝   ╚═══════════════╝
set /a _maxTurn=120/%_stakeAP%
echo.
echo.==========
rem Reset _pickHowManyTurn
set "_pickHowManyTurn="
echo.Enter "waybackhome" to return
set /p _pickHowManyTurn="Enter the number of turn in each Sweep transaction: "
echo.
if "%_pickHowManyTurn%" == "waybackhome" (set "_pickHowManyTurn=" & goto :gotoSweep1)
rem Check whether it is empty or not
if [%_pickHowManyTurn%] == [] (echo Error 1: Enter empty, try again ... & color 4F & timeout 5 & set "_pickHowManyTurn=" & goto :howManyTurn)
rem Check whether the turn is the number or not
set "var="&for /f "delims=0123456789" %%i in ("%_pickHowManyTurn%") do set var=%%i
if defined var (echo Error 2: Wrong type input, try again ... & color 4F & timeout 5 & set "_pickHowManyTurn=" & goto :howManyTurn)
rem Check if the turn is > the max turn or not
if %_pickHowManyTurn% gtr %_maxTurn% (echo Error 3: %_pickHowManyTurn% larger than %_maxTurn% turn can sweep, try again ... & color 4F & timeout 5 & set "_pickHowManyTurn=" & goto :howManyTurn)
echo %_pickHowManyTurn% > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_howManyTurn.txt
goto :gotoSweep1
:pickSweep
call :background3 %_charCount%
echo.[40;96m==========
echo.
echo.The Stage(s) are saved:
type %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_stageSweepRandom.txt
echo.==========
echo.
rem Reset _pickSweep
set "_pickSweep="
echo.Enter "waybackhome" to return
set /p _pickSweep="Nhập stage bạn muốn sweep: "
echo.
if "%_pickSweep%" == "waybackhome" (set "_pickSweep=" & goto :gotoSweep1)
rem Check whether it is empty or not
if [%_pickSweep%] == [] (echo Error 1: Enter empty, try again ... & color 4F & timeout 5 & set "_pickSweep=" & goto :pickSweep)
rem Check whether the sweep is the number or not
set "var="&for /f "delims=0123456789" %%i in ("%_pickSweep%") do set var=%%i
if defined var (echo Error 2: Wrong type input, try again ... & color 4F & timeout 5 & set "_pickSweep=" & goto :pickSweep)
rem Check if the stage is > the stage that the character has opened or not
if %_pickSweep% gtr %_stage% (echo Error 3: Stage %_pickSweep% larger than the stage allowed to sweep, try again ... & color 4F & timeout 5 & set "_pickSweep=" & goto :pickSweep)
echo %_pickSweep% >> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_stageSweepRandom.txt
call :background3 %_charCount%
echo.[40;96m==========
echo.
echo.The Stage(s) are saved:
type %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_stageSweepRandom.txt
echo.==========
echo.
echo.By default 9CMD will randomly select one of the stage(s)
echo.saved to sweep
echo.[1] Only save Stage %_pickSweep% permanent
echo.[2] Input more Stage
echo.==========
echo.[3] Return
choice /c 123 /n /m "Enter the number from the keyboard: "
if %errorlevel% equ 1 (echo %_pickSweep% > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_stageSweepRandom.txt & goto :pickSweep)
if %errorlevel% equ 2 (goto :pickSweep)
if %errorlevel% equ 3 (goto :gotoSweep1)
goto :gotoSweep1
:importTrangBi
rem Refresh data
set "_weapon=" & set "_armor=" & set "_belt=" & set "_necklace=" & set "_ring1=" & set "_ring2="
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep
"%_cd%\batch\jq.exe" -r ".weapon" _itemEquip.json> _weapon.txt & set /p _weapon=<_weapon.txt & del /q _weapon.txt
"%_cd%\batch\jq.exe" -r ".armor" _itemEquip.json> _armor.txt & set /p _armor=<_armor.txt & del /q _armor.txt
"%_cd%\batch\jq.exe" -r ".belt" _itemEquip.json> _belt.txt & set /p _belt=<_belt.txt & del /q _belt.txt
"%_cd%\batch\jq.exe" -r ".necklace" _itemEquip.json> _necklace.txt & set /p _necklace=<_necklace.txt & del /q _necklace.txt
"%_cd%\batch\jq.exe" -r ".ring1" _itemEquip.json> _ring1.txt & set /p _ring1=<_ring1.txt & del /q _ring1.txt
"%_cd%\batch\jq.exe" -r ".ring2" _itemEquip.json> _ring2.txt & set /p _ring2=<_ring2.txt & del /q _ring2.txt
call :background
echo.Equipment for next Sweep:
echo.==========
echo.[1] Weapon	:	%_weapon%
echo.[2] Armor	:	%_armor%
echo.[3] Belt	:	%_belt%
echo.[4] Necklace	:	%_necklace%
echo.[5] Ring1	:	%_ring1%
echo.[6] Ring2	:	%_ring2%
echo.==========
echo.[7] Return
echo.[8] Open the website to get ID item
echo.[9] Quick import equipment is being Equipped
choice /c 123456789 /n /m "Enter the number from the keyboard: "
if %errorlevel% equ 1 (goto :importTrangBiWeapon)
if %errorlevel% equ 2 (goto :importTrangBiArmor)
if %errorlevel% equ 3 (goto :importTrangBiBelt)
if %errorlevel% equ 4 (goto :importTrangBiNecklace)
if %errorlevel% equ 5 (goto :importTrangBiRing1)
if %errorlevel% equ 6 (goto :importTrangBiRing2)
if %errorlevel% equ 7 (goto :gotoSweep1)
if %errorlevel% equ 8 (start "" "%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\index.html" & goto :importTrangBi)
if %errorlevel% equ 9 (goto :importTrangBiEquipped)
goto :importTrangBi
:importTrangBiEquipped
echo.└── Taking equipped ID item(s) ...
set /p _address=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_address.txt
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_address%\"){inventory{equipments{grade,id,itemSubType,elementalType,equipped,itemId,level,statsMap{aTK,hP,dEF,sPD,hIT,cRI},skills{elementalType,chance,power},stat{value,type}}}}}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output1.json 2>nul
rem Filter the results of data
%_cd%\batch\jq.exe -r -f filterEQUIPPED.txt output1.json> output.json 2>nul
rem Push file output.json to https://jsonblob.com
set /p _urlJson=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_urlJson.txt
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlJson% --ssl-no-revoke >nul 2>nul
rem Filter for equipment if Equipped
%_cd%\batch\jq.exe -r -f filterEQUIPPED2.txt output.json> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_itemEquip.json 2>nul
rem Delete the draft file input and output
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\input.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\output1.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\output.json 2>nul
echo.└──── Successful get equipped ID item(s) ...
timeout 3
goto :importTrangBi
:importTrangBiWeapon
echo.└── Taking weapon ID item(s) ...
set /p _address=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_address.txt
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_address%\"){inventory{equipments{grade,id,itemSubType,elementalType,equipped,itemId,level,statsMap{aTK,hP,dEF,sPD,hIT,cRI},skills{elementalType,chance,power},stat{value,type}}}}}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output1.json 2>nul
rem Filter the results of data
%_cd%\batch\jq.exe -r -f filterWEAPON.txt output1.json> output.json 2>nul
rem Push file output.json to https://jsonblob.com
set /p _urlJson=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_urlJson.txt
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlJson% --ssl-no-revoke >nul 2>nul
rem Delete the draft file input and output
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\input.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\output1.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\output.json 2>nul
:importTrangBiWeapon1
call :background3 %_charCount%
echo.
echo.Refresh the website to apply the equipment Weapon
echo.==========
echo.
echo.[1] Enter the ID of Weapon
echo.[2] Open the website to check
echo.[3] Return
choice /c 123 /n /m "Enter the number from the keyboard: "
if %errorlevel% equ 3 (goto :importTrangBi)
if %errorlevel% equ 2 (start "" "%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\index.html" & goto :importTrangBiWeapon1)
if %errorlevel% equ 1 (
	SETLOCAL EnableDelayedExpansion
	set "_weapon="
	echo.
	set /p _weapon="Enter the item of equipment: "
	cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\
	%_cd%\batch\jq.exe "{weapon: \"!_weapon!\",armor,belt,necklace,ring1,ring2}" _itemEquip.json> _temp.json
	copy _temp.json _itemEquip.json>nul
	del /q _temp.json
	endlocal
	)
goto :importTrangBi
:importTrangBiArmor
echo.└── Taking armor ID item(s) ...
set /p _address=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_address.txt
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_address%\"){inventory{equipments{grade,id,itemSubType,elementalType,equipped,itemId,level,statsMap{aTK,hP,dEF,sPD,hIT,cRI},skills{elementalType,chance,power},stat{value,type}}}}}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output1.json 2>nul
rem Filter the results of data
%_cd%\batch\jq.exe -r -f filterARMOR.txt output1.json> output.json 2>nul
rem Push file output.json to https://jsonblob.com
set /p _urlJson=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_urlJson.txt
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlJson% --ssl-no-revoke >nul 2>nul
rem Delete the draft file input and output
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\input.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\output1.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\output.json 2>nul
:importTrangBiArmor1
call :background3 %_charCount%
echo.
echo.Refresh the website to apply the equipment Armor
echo.==========
echo.
echo.[1] Enter the ID of Armor
echo.[2] Open the website to check
echo.[3] Return
choice /c 123 /n /m "Enter the number from the keyboard: "
if %errorlevel% equ 3 (goto :importTrangBi)
if %errorlevel% equ 2 (start "" "%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\index.html" & goto :importTrangBiArmor1)
if %errorlevel% equ 1 (
	SETLOCAL EnableDelayedExpansion
	set "_armor="
	echo.
	set /p _armor="Enter the item of equipment: "
	cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\
	%_cd%\batch\jq.exe "{weapon,armor: \"!_armor!\",belt,necklace,ring1,ring2}" _itemEquip.json> _temp.json 2>nul
	copy _temp.json _itemEquip.json>nul
	del /q _temp.json
	endlocal
	)
goto :importTrangBi
:importTrangBiBelt
echo.└── Taking belt ID item(s) ...
set /p _address=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_address.txt
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_address%\"){inventory{equipments{grade,id,itemSubType,elementalType,equipped,itemId,level,statsMap{aTK,hP,dEF,sPD,hIT,cRI},skills{elementalType,chance,power},stat{value,type}}}}}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output1.json 2>nul
rem Filter the results of data
%_cd%\batch\jq.exe -r -f filterBELT.txt output1.json> output.json 2>nul
rem Push file output.json to https://jsonblob.com
set /p _urlJson=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_urlJson.txt
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlJson% --ssl-no-revoke >nul 2>nul
rem Delete the draft file input and output
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\input.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\output1.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\output.json 2>nul
:importTrangBiBelt1
call :background3 %_charCount%
echo.
echo.Refresh the website to apply the equipment Belt
echo.==========
echo.
echo.[1] Enter the ID of Belt
echo.[2] Open the website to check
echo.[3] Return
choice /c 123 /n /m "Enter the number from the keyboard: "
if %errorlevel% equ 3 (goto :importTrangBi)
if %errorlevel% equ 2 (start "" "%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\index.html" & goto :importTrangBiBelt1)
if %errorlevel% equ 1 (
	SETLOCAL EnableDelayedExpansion
	set "_belt="
	echo.
	set /p _belt="Enter the item of equipment: "
	cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\
	%_cd%\batch\jq.exe "{weapon,armor,belt: \"!_belt!\",necklace,ring1,ring2}" _itemEquip.json> _temp.json 2>nul
	copy _temp.json _itemEquip.json>nul
	del /q _temp.json
	endlocal
	)
goto :importTrangBi
:importTrangBiNecklace
echo.└── Taking necklace ID item(s) ...
set /p _address=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_address.txt
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_address%\"){inventory{equipments{grade,id,itemSubType,elementalType,equipped,itemId,level,statsMap{aTK,hP,dEF,sPD,hIT,cRI},skills{elementalType,chance,power},stat{value,type}}}}}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output1.json 2>nul
rem Filter the results of data
%_cd%\batch\jq.exe -r -f filterNECKLACE.txt output1.json> output.json 2>nul
rem Push file output.json to https://jsonblob.com
set /p _urlJson=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_urlJson.txt
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlJson% --ssl-no-revoke >nul 2>nul
rem Delete the draft file input and output
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\input.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\output1.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\output.json 2>nul
:importTrangBiNecklace1
call :background3 %_charCount%
echo.
echo.Refresh the website to apply the equipment Necklace
echo.==========
echo.
echo.[1] Enter the ID of Necklace
echo.[2] Open the website to check
echo.[3] Return
choice /c 123 /n /m "Enter the number from the keyboard: "
if %errorlevel% equ 3 (goto :importTrangBi)
if %errorlevel% equ 2 (start "" "%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\index.html" & goto :importTrangBiNecklace1)
if %errorlevel% equ 1 (
	SETLOCAL EnableDelayedExpansion
	set "_necklace="
	echo.
	set /p _necklace="Enter the item of equipment: "
	cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\
	%_cd%\batch\jq.exe "{weapon,armor,belt,necklace: \"!_necklace!\",ring1,ring2}" _itemEquip.json> _temp.json 2>nul
	copy _temp.json _itemEquip.json>nul
	del /q _temp.json
	endlocal
	)
goto :importTrangBi
:importTrangBiRing1
echo.└── Taking ring1 ID item(s) ...
set /p _address=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_address.txt
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_address%\"){inventory{equipments{grade,id,itemSubType,elementalType,equipped,itemId,level,statsMap{aTK,hP,dEF,sPD,hIT,cRI},skills{elementalType,chance,power},stat{value,type}}}}}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output1.json 2>nul
rem Filter the results of data
%_cd%\batch\jq.exe -r -f filterRING.txt output1.json> output.json 2>nul
rem Push file output.json to https://jsonblob.com
set /p _urlJson=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_urlJson.txt
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlJson% --ssl-no-revoke >nul 2>nul
rem Delete the draft file input and output
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\input.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\output1.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\output.json 2>nul
:importTrangBiRing11
call :background3 %_charCount%
echo.
echo.Refresh the website to apply the equipment Ring1
echo.==========
echo.
echo.[1] Enter the ID of Ring1
echo.[2] Open the website to check
echo.[3] Return
choice /c 123 /n /m "Enter the number from the keyboard: "
if %errorlevel% equ 3 (goto :importTrangBi)
if %errorlevel% equ 2 (start "" "%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\index.html" & goto :importTrangBiRing11)
if %errorlevel% equ 1 (goto :importTrangBiRing12)
:importTrangBiRing12
SETLOCAL EnableDelayedExpansion
set "_ring1="
echo.
set /p _ring1="Enter the item of equipment: "
if "!_ring1!" equ "%_ring2%" (
	if not "!_ring1!" equ "" (
		echo.
		echo Lỗi 1.1: Ring1 coincides with Ring2 ...
		color 4F
		cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\
		%_cd%\batch\jq.exe "{weapon,armor,belt,necklace,ring1,ring2}" _itemEquip.json> _temp.json 2>nul
		copy _temp.json _itemEquip.json>nul
		del /q _temp.json
		endlocal
		timeout 5
		goto :importTrangBi
		)
	)
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\
%_cd%\batch\jq.exe "{weapon,armor,belt,necklace,ring1: \"!_ring1!\",ring2}" _itemEquip.json> _temp.json 2>nul
copy _temp.json _itemEquip.json>nul
del /q _temp.json
endlocal
goto :importTrangBi
:importTrangBiRing2
echo.└── Taking ring2 ID item(s) ...
set /p _address=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_address.txt
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_address%\"){inventory{equipments{grade,id,itemSubType,elementalType,equipped,itemId,level,statsMap{aTK,hP,dEF,sPD,hIT,cRI},skills{elementalType,chance,power},stat{value,type}}}}}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output1.json 2>nul
rem Filter the results of data
%_cd%\batch\jq.exe -r -f filterRING.txt output1.json> output.json 2>nul
rem Push file output.json to https://jsonblob.com
set /p _urlJson=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_urlJson.txt
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlJson% --ssl-no-revoke >nul 2>nul
rem Delete the draft file input and output
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\input.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\output1.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\output.json 2>nul
:importTrangBiRing21
call :background3 %_charCount%
echo.
echo.Refresh the website to apply the equipment Ring2
echo.==========
echo.
echo.[1] Enter the ID of Ring2
echo.[2] Open the website to check
echo.[3] Return
choice /c 123 /n /m "Enter the number from the keyboard: "
if %errorlevel% equ 3 (goto :importTrangBi)
if %errorlevel% equ 2 (start "" "%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\index.html" & goto :importTrangBiRing21)
if %errorlevel% equ 1 (goto :importTrangBiRing22)
:importTrangBiRing22
SETLOCAL EnableDelayedExpansion
set "_ring2="
echo.
set /p _ring2="Enter the item of equipment: "
if "!_ring2!" equ "%_ring1%" (
	if not "!_ring2!" equ "" (
		echo.
		echo Lỗi 1.2: Ring2 coincides with Ring1 ...
		color 4F
		cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\
		%_cd%\batch\jq.exe "{weapon,armor,belt,necklace,ring1,ring2}" _itemEquip.json> _temp.json 2>nul
		copy _temp.json _itemEquip.json>nul
		del /q _temp.json
		endlocal
		timeout 5
		goto :importTrangBi
		)
	)
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\
%_cd%\batch\jq.exe "{weapon,armor,belt,necklace,ring1,ring2: \"!_ring2!\"}" _itemEquip.json> _temp.json 2>nul
copy _temp.json _itemEquip.json>nul
del /q _temp.json
endlocal
goto :importTrangBi
:hdsd
mode con:cols=60 lines=50
call :background
echo.[40;92mAuto Refill AP?[40;96m
echo.─── Need to enter the parameters from 1 - 5, turn on
echo.─── switch Auto main, auto Refill AP main switch and
echo.─── return to the main screen, each 60 seconds will
echo.─── refresh the character data.
echo.─── When the character [40;91m0AP[40;96m
echo.─── and [40;91menough time[40;96m to refill, character 
echo.─── will be Auto Refill AP in turn.
echo.
echo.[40;92mAuto Sweep?[40;96m
echo.─── Sign [[40;91ma[40;96m][[40;91mb[40;96m / [40;91mc[40;96m] in there:
echo.─── [[40;91ma[40;96m] [40;91m0[40;96m / [40;91m1[40;96m is turn on / off auto sweep
echo.─── separately character
echo.─── [[40;91mb[40;96m / [40;91mc[40;96m] is 
echo.─── [[40;91mStage will auto[40;96m / [40;91mturns in each sweep transaction[40;96m]
echo.─── You still need to enter the parameters from 1 - 5
echo.─── turn on Auto Sweep main switch, a separate switch
echo.─── for each char that you want to Auto sweep and
echo.─── return to the main screen.
echo.
echo.==========
echo.[40;92mWhat is Premium code?[40;96m
echo.─── Is tx code (Transaction Hash) of transactions
echo.─── sent NCG from you to my wallet:
echo.─── [40;91m0x6374FE5F54CdeD72Ff334d09980270c61BC95186[40;96m
echo.─── Use for registration automatic [40;91mDonater[40;96m
echo.─── After successful registration, enter the
echo.─── Premium code is [40;91mdonater[40;96m instead of
echo.─── enter tx Code for each use 9CMD.
echo.
echo.[40;92mUse until?[40;96m
echo.─── Calculated from Block buy premium + 216000
echo.─── with 12s / 1 block
echo.─── equivalent [40;91m1 wallet / 30 days of use[40;96m 9CMD.
echo.
echo.==========
echo.You want to become Donater or feedback bug
echo.Contact me ...
echo.
echo.[1] Discord tanbt#9827
echo.[2] Telegram @tandotbt
echo.[3] Discord Plantarium - #unofficial-mods
echo.[4] Youtube tanbt
echo.[5] Web gitbook User guide
echo.
echo.==========
choice /c 123456 /n /m "Enter [6] to return: "
if %errorlevel% equ 1 (start https://discordapp.com/users/466271401796567071 & goto :hdsd)
if %errorlevel% equ 2 (start https://t.me/tandotbt & goto :hdsd)
if %errorlevel% equ 3 (start https://discord.com/channels/539405872346955788/1035354979709485106 & goto :hdsd)
if %errorlevel% equ 4 (start https://www.youtube.com/c/tanbt & goto :hdsd)
if %errorlevel% equ 5 (start https://9cmd.tanvpn.tk/ & goto :hdsd)
if %errorlevel% equ 6 (mode con:cols=60 lines=25 & goto :displayVi)
goto :displayVi
:utcFile
echo.└── Checking had the UTC of the wallet %_vi:~0,7%*** or not ...
cd %_cd%\planet
set _utcfile=^|planet key --path %_cd%\user\utc 2>nul|findstr /i %_vi%>nul
if %errorlevel% equ 0 (set /a _utcFileOK=1 & goto :settingAuto)
echo.
echo.Drag the UTC file or folder containing UTC of the wallet %_vi:~0,7%***
echo.Note: If the input folder has a white space will not succeed!
echo.Enter 'waybackhome' to return
echo.===
set /p _nhapUTC="Drag and press Enter to enter: "
set _nhapUTC=%_nhapUTC: =%
if "%_nhapUTC%" == "waybackhome" (set "_nhapUTC=" & goto :settingAuto)
echo a | copy /-y "%_nhapUTC%" "%_cd%\user\UTC\">nul
goto :utcFile
:canAutoOnOff
if %_canAutoOnOff% == 0 (set /a _canAutoOnOff=1) else (set /a _canAutoOnOff=0)
echo.└── Updating ... & goto :duLieuViCu
:autoRefillAPOnOff
if %_autoRefillAP% == 0 (set /a _autoRefillAP=1) else (set /a _autoRefillAP=0)
goto :settingAuto
:autoSweepOnOffAll
if %_autoSweepOnOffAll% == 0 (set /a _autoSweepOnOffAll=1) else (set /a _autoSweepOnOffAll=0)
goto :gotoSweep1
:KeyID
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\auto\KeyID"
if not exist %_folder% (md %_cd%\user\trackedAvatar\%_folderVi%\auto\KeyID & goto :KeyID2)
set /p _KeyID=<%_cd%\user\trackedAvatar\%_folderVi%\auto\KeyID\_KeyID.txt
set _KeyID=%_KeyID: =%
call :background
echo.
echo.Old Key ID detection
echo.[1] Reuse
echo.[2] Delete old Key ID data
echo.[3] Return
echo.[4] Show old Key ID
choice /c 1234 /n /m "Enter the number from the keyboard: "
if %errorlevel% equ 1 (set /a _KeyIDOK=1 & goto :settingAuto)
if %errorlevel% equ 2 (set /a _KeyIDOK=0 & rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\auto\KeyID & goto :KeyID)
if %errorlevel% equ 3 (goto :settingAuto)
if %errorlevel% equ 4 (echo The ID Key saved is:%_KeyID% & timeout 10 & goto :settingAuto)
:KeyID2
echo ==========
echo Taking the key ID of the wallet %_vi:~0,7%*** ...
cd %_cd%\planet
planet key --path %_cd%\user\utc> %_cd%\user\trackedAvatar\%_folderVi%\auto\_allKey.json 2>nul
findstr /L /i %_vi% %_cd%\user\trackedAvatar\%_folderVi%\auto\_allKey.json > %_cd%\user\trackedAvatar\%_folderVi%\auto\_KeyID.json 2>nul
set "_KeyID="
set /p _KeyID=<%_cd%\user\trackedAvatar\%_folderVi%\auto\_KeyID.json
rem Check ID Key
echo.└── Check Key ID ...
if not "%_KeyID%" == "" (goto :YesUTC) else (goto :NoUTC)
:NoUTC
echo.└──── Can't find UTC file of wallet %_vi:~0,7%*** in the saved UTC folder
color 4F
set /a _KeyIDOK=0
cd %_cd%\user\trackedAvatar\%_folderVi%\auto
rem Delete file json
del *.json
timeout 5
call :background
cd %_cd%\planet
set _utcfile=^|planet key --path %_cd%\user\utc 2>nul|findstr /i %_vi%>nul
if %errorlevel% equ 0 (set /a _utcFileOK=1 & goto :settingAuto)
echo.
echo.Drag the UTC file or folder containing UTC of the wallet %_vi:~0,7%***
echo.Note: If the input folder has a white space will not succeed!
echo.Enter 'waybackhome' to return
echo.===
set /p _nhapUTC="Drag and press Enter to enter: "
set _nhapUTC=%_nhapUTC: =%
if "%_nhapUTC%" == "waybackhome" (set "_nhapUTC=" & rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\auto\KeyID & goto :settingAuto)
echo a | copy /-y "%_nhapUTC%" "%_cd%\user\UTC\">nul
goto :KeyID2
:YesUTC
echo.└──── Get Key ID of wallet %_vi:~0,7%*** successful
echo %_KeyID:~0,36%> %_cd%\user\trackedAvatar\%_folderVi%\auto\KeyID\_KeyID.txt 2>nul
cd %_cd%\user\trackedAvatar\%_folderVi%\auto
rem Delete file json
del *.json
set /a _KeyIDOK=1
timeout 5
goto :settingAuto

:publickey
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\auto\publickey"
if not exist %_folder% (md %_cd%\user\trackedAvatar\%_folderVi%\auto\publickey & goto :publickey2)
set /p _publickey=<%_cd%\user\trackedAvatar\%_folderVi%\auto\publickey\_publickey.txt
set _publickey=%_publickey: =%
call :background
echo.
echo.Old Public Key detection
echo.[1] Reuse
echo.[2] Delete old Public Key data
echo.[3] Return
echo.[4] Show old Public Key
choice /c 1234 /n /m "Enter the number from the keyboard: "
if %errorlevel% equ 1 (set /a _publickeyOK=1 & goto :settingAuto)
if %errorlevel% equ 2 (set /a _publickeyOK=0 & rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\auto\publickey & goto :publickey)
if %errorlevel% equ 3 (goto :settingAuto)
if %errorlevel% equ 4 (echo.========== & echo. & echo Public Key saved is: %_publickey% & timeout 10 & goto :settingAuto)
:publickey2
echo ==========
echo [1]Use 9cscan
echo [2]Use Planet
echo.
choice /c 12 /n /m "Enter from the keyboard: "
if %errorlevel% equ 1 (goto :9cscanPublicKey)
if %errorlevel% equ 2 (goto :PlanetPublickey)
rem Import Public Key
:9cscanPublicKey
echo.
echo ==========
echo Enter Public Key of wallet %_vi:~0,7%*** via 9cscan ...
rem --ssl-no-revoke fixes
curl --ssl-no-revoke --header "Content-Type: application/json" https://api.9cscan.com/accounts/%_vi%/transactions?action=activate_account 2>nul|findstr /i signed> %_cd%\user\trackedAvatar\%_folderVi%\auto\output.json 2>nul
if %errorlevel% == 0 (goto :9cscanPublicKey2)
:9cscanPublicKey1
curl --ssl-no-revoke --header "Content-Type: application/json" https://api.9cscan.com/accounts/%_vi%/transactions?action=activate_account2 2>nul|findstr /i signed> %_cd%\user\trackedAvatar\%_folderVi%\auto\output.json 2>nul
:9cscanPublicKey2
rem Filter the results of data
echo.└── Find Public Key of the wallet %_vi:~0,7%*** ...
call :ReadJsonbat publicKey
copy %_cd%\user\trackedAvatar\%_folderVi%\auto\ReadJsonbat.json %_cd%\user\trackedAvatar\%_folderVi%\auto\publickey\_publickey.txt> nul
set /p _publickey=<%_cd%\user\trackedAvatar\%_folderVi%\auto\publickey\_publickey.txt
del /q %_cd%\user\trackedAvatar\%_folderVi%\auto\ReadJsonbat.json
echo.└──── Get Public Key of wallet %_vi:~0,7%*** successful
echo.
set /a _publickeyOK=1
timeout 5
goto :settingAuto
:PlanetPublickey
echo.
echo ==========
echo Enter Public Key of wallet %_vi:~0,7%*** via Planet ...
echo.
if %_keyidOK% == 0 (color 4F & echo.Enter the Key ID of the wallet %_vi:~0,7%*** & echo.before using this feature! & rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\auto\publickey & timeout 10 & goto :settingAuto)
if "%_passwordOK%" == "0" (goto :tryagainWithPass) else (goto :tryagainNoPass)
:tryagainWithPass
call :background
set _password=1
set /p _KeyID=<%_cd%\user\trackedAvatar\%_folderVi%\auto\KeyID\_KeyID.txt
set _KeyID=%_KeyID: =%
echo Option: Enter "waybackhome" to return
echo Enter the manual password: 
echo Note: Turn off Unikey before entering
set /P "=_" < NUL > "Enter password"
findstr /A:1E /V "^$" "Enter password" NUL > CON
del "Enter password"
set /P "_password="
call :background
echo ==========
echo Enter Public Key of wallet %_vi:~0,7%*** via Planet ...
rem Return
if %_password% == waybackhome (set /a _publickeyOK=0 & rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\auto\publickey & goto :settingAuto)
if %_password% == checkcheck (start https://youtu.be/SRf8pTXPz9I?t=26s)
rem Find Public Key
cd %_cd%\planet
set _PublicKey=^|planet key export --passphrase %_PASSWORD% --public-key --path %_cd%\user\utc %_KeyID%
echo %_PublicKey%> %_cd%\user\trackedAvatar\%_folderVi%\auto\_KTraPPK.txt 2>nul
set "_PASSWORD="
goto :KTraPPK2
:tryagainNoPass
call :background
rem Set _KeyID
set /p _KeyID=<%_cd%\user\trackedAvatar\%_folderVi%\auto\KeyID\_KeyID.txt
set _KeyID=%_KeyID: =%
set /p _password=<%_cd%\user\trackedAvatar\%_folderVi%\auto\password\_password.txt
echo └── Using the previously saved password ...
cd %_cd%\planet
set _PublicKey=^|planet key export --passphrase %_PASSWORD% --public-key --path %_cd%\user\utc %_KeyID%
echo %_PublicKey% > %_cd%\user\trackedAvatar\%_folderVi%\auto\_KTraPPK.txt 2>nul
set "_PASSWORD="
call :background
echo ==========
echo Enter Public Key of wallet %_vi:~0,7%*** via Planet ...
goto :KTraPPK1
rem Check whether it is Public Key or not
:KTraPPK1
set "_KTraPPK="
set /p _KTraPPK=<%_cd%\user\trackedAvatar\%_folderVi%\auto\_KTraPPK.txt
del /q %_cd%\user\trackedAvatar\%_folderVi%\auto\_KTraPPK.txt
if [%_KTraPPK%] == [] (echo Error 1: The password saved incorrect, try again ... & color 4F & set /a _passwordOK=0 & rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\auto\password & timeout 10 & goto :tryagainWithPass) else (goto :YesPPK)
:KTraPPK2
set "_KTraPPK="
set /p _KTraPPK=<%_cd%\user\trackedAvatar\%_folderVi%\auto\_KTraPPK.txt
del /q %_cd%\user\trackedAvatar\%_folderVi%\auto\_KTraPPK.txt
if [%_KTraPPK%] == [] (echo Error 2: The password incorrect, try again ... & color 4F & timeout 10 & goto :tryagainWithPass) else (goto :YesPPK)
:YesPPK
cd %_cd%
echo.└── Enter Public Key of wallet %_vi:~0,7%*** successful
rem Saving public key
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\auto\publickey"
if not exist %_folder% (md %_cd%\user\trackedAvatar\%_folderVi%\auto\publickey)
echo %_KTraPPK%> %_cd%\user\trackedAvatar\%_folderVi%\auto\publickey\_publickey.txt 2>nul
set /p _publickey=<%_cd%\user\trackedAvatar\%_folderVi%\auto\publickey\_publickey.txt
set /a _publickeyOK=1
timeout 5
goto :settingAuto
:password
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\auto\password"
if not exist %_folder% (md %_cd%\user\trackedAvatar\%_folderVi%\auto\password & goto :password2)
set /p _password=<%_cd%\user\trackedAvatar\%_folderVi%\auto\password\_password.txt
set _password=%_password: =%
call :background
echo.
echo.Old password detection
echo.[1] Reuse
echo.[2] Delete old password data
echo.[3] Return
echo.[4] Show old password data
echo.[5] Check the password by take Public Key via Planet
choice /c 12345 /n /m "Enter the number from the keyboard: "
if %errorlevel% equ 1 (set /a _passwordOK=1 & goto :settingAuto)
if %errorlevel% equ 2 (set /a _passwordOK=0 & rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\auto\password & goto :password)
if %errorlevel% equ 3 (goto :settingAuto)
if %errorlevel% equ 4 (echo.========== & echo. & echo Mật khẩu đang lưu là: %_password% & timeout 10 & goto :settingAuto)
if %errorlevel% equ 5 (goto :PlanetPublickey)
:password2
echo.
echo ==========
echo Save Password for wallets %_vi:~0,7%***
echo Note: Turn off Unikey before entering
rem Type hidden password
set /P "=_" < NUL > "Enter password"
findstr /A:1E /V "^$" "Enter password" NUL > CON
del "Enter password"
set /P "password="
cls
color 0B
rem Saving Password
cd %_cd%
echo %PASSWORD%> %_cd%\user\trackedAvatar\%_folderVi%\auto\password\_PASSWORD.txt 2>nul
set /a _passwordOK=1
goto :settingAuto
:premium
rem Create Premium folder to save data
cd %_cd%\batch\avatarAddress
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\premium"
if not exist %_folder% (md %_cd%\user\trackedAvatar\%_folderVi%\premium)
rem Number of NCG you need to send to my wallet 0x6374FE5F54CdeD72Ff334d09980270c61BC95186
curl https://api.9cscan.com/price --ssl-no-revoke 2>nul|"%_cd%\batch\avatarAddress\jq" ".[]?|select(.USD)?|.USD|(1/(.price))+1"> %_cd%\user\trackedAvatar\%_folderVi%\premium\_pricePremium.txt 2>nul
set /p _pricePremium=<%_cd%\user\trackedAvatar\%_folderVi%\premium\_pricePremium.txt
del /q %_cd%\user\trackedAvatar\%_folderVi%\premium\_pricePremium.txt
set /a _pricePremium=%_pricePremium% 2>nul & set /a _pricePremium2=%_pricePremium% + 2 2>nul
set _file="%_cd%\user\trackedAvatar\%_folderVi%\premium\_premiumTX.txt"
if not exist %_file% (
	call :background
	echo.╔═══════════════════════════════╗
	echo.║Price premium: [40;33m%_pricePremium2% NCG[40;96m/30days	║
	echo.╚═══════════════════════════════╝
	echo.
	set _premiumTX=null
	echo.Enter 'donater' if you have entered the Premium code
	echo or register the previous Donater
	set /p _premiumTX="Premium code: "
	echo %_premiumTX%> %_cd%\user\trackedAvatar\%_folderVi%\premium\_premiumTX.txt 2>nul
	goto :premium2
	)
set /p _premiumTX=<%_cd%\user\trackedAvatar\%_folderVi%\premium\_premiumTX.txt
set _premiumTX=%_premiumTX: =%
rem Find your wallet ID in Premium code
set _senderBuy=^|curl https://api.9cscan.com/transactions/%_premiumTX% --ssl-no-revoke 2>nul|jq -r ".updatedAddresses|.[0]"> %_cd%\user\trackedAvatar\%_folderVi%\premium\_senderBuy.txt 2>nul & set /p _senderBuy=<%_cd%\user\trackedAvatar\%_folderVi%\premium\_senderBuy.txt & del /q %_cd%\user\trackedAvatar\%_folderVi%\premium\_senderBuy.txt
call :background
echo.╔═══════════════════════════════╗
echo.║Price premium: [40;33m%_pricePremium2% NCG[40;96m/30days	║
echo.╚═══════════════════════════════╝
echo.
if "%_premiumTX%" == "donater" (echo.Detecting Premium code is 'donater'?) else (echo.Detecting the old premium code of the wallet %_senderBuy:~0,7%***)
if not %_HanSuDung% lss 1700 (echo.Premium code [40;92m%_HanSuDung%[40;96m blocks left) else (echo.Premium code [40;91m%_HanSuDung%[40;96m blocks left)
echo.[1] Reuse
echo.[2] Delete old Premium Code data
echo.[3] Copy and display old Premium code
echo.[4] Return
choice /c 1234 /n /m "Enter the number from the keyboard: "
if %errorlevel% equ 1 (goto :premium2)
if %errorlevel% equ 2 (set /a _premiumTXOK=0 & set "_senderBuy=***********" & rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\premium & goto :premium)
if %errorlevel% equ 3 (echo Premium code đang lưu: %_premiumTX% & echo %_premiumTX%|clip & timeout 10 & goto :premium)
if %errorlevel% equ 4 (goto :settingAuto)
:premium2
set /a _premiumTXOK=0
echo.└── Cheking Premium code ...
echo %_premiumTX%> %_cd%\user\trackedAvatar\%_folderVi%\premium\_premiumTX.txt 2>nul
if "%_premiumTX%" == "donater" (goto :ktraDonater)
cd %_cd%\batch\avatarAddress
set _pricePremium=^|curl https://api.9cscan.com/price --ssl-no-revoke 2>nul|jq ".[]?|select(.USD)?|.USD|(1/(.price))+2"> %_cd%\user\trackedAvatar\%_folderVi%\premium\_pricePremium.txt 2>nul & set /p _pricePremium=<%_cd%\user\trackedAvatar\%_folderVi%\premium\_pricePremium.txt & del /q %_cd%\user\trackedAvatar\%_folderVi%\premium\_pricePremium.txt
set /a _pricePremium=%_pricePremium% 2>nul
set _premiumTX=%_premiumTX: =%
rem Basic test Premium code
set _typeBuy=^|curl https://api.9cscan.com/transactions/%_premiumTX% --ssl-no-revoke 2>nul|findstr transfer_asset|findstr NCG|findstr /i 0x6374fe5f54cded72ff334d09980270c61bc95186|findstr /i SUCCESS>nul
if %errorlevel%==1 (echo. & echo Error 1: Not Premium Code, try again ... & color 4F & timeout 5 & goto :premium)
cd %_cd%\batch\avatarAddress
rem Premium code advanced test
set _senderBuy=^|curl https://api.9cscan.com/transactions/%_premiumTX% --ssl-no-revoke 2>nul|jq -r ".updatedAddresses|.[0]"> %_cd%\user\trackedAvatar\%_folderVi%\premium\_senderBuy.txt 2>nul & set /p _senderBuy=<%_cd%\user\trackedAvatar\%_folderVi%\premium\_senderBuy.txt & del /q %_cd%\user\trackedAvatar\%_folderVi%\premium\_senderBuy.txt
set _senderBuy=^|echo %_senderBuy%|findstr /i %_vi%>nul
if %errorlevel%==1 (echo. & echo Error 2.1: Premium code of wallets & echo %_senderBuy%, try again ... & color 4F & timeout 5 & goto :premium)
set _receiveBuy=^|curl https://api.9cscan.com/transactions/%_premiumTX% --ssl-no-revoke 2>nul|jq -r ".updatedAddresses|.[1]"> %_cd%\user\trackedAvatar\%_folderVi%\premium\_receiveBuy.txt 2>nul & set /p _receiveBuy=<%_cd%\user\trackedAvatar\%_folderVi%\premium\_receiveBuy.txt & del /q %_cd%\user\trackedAvatar\%_folderVi%\premium\_receiveBuy.txt
set _receiveBuy=^|echo %_receiveBuy%|findstr /i 0x6374fe5f54cded72ff334d09980270c61bc95186>nul
if %errorlevel%==1 (echo. & echo Error 2.2: Premium code didn't sent to my wallet & echo is 0x6374FE5F54CdeD72Ff334d09980270c61BC95186, try again ... & color 4F & timeout 5 & goto :premium)
set _statusBuy=^|curl https://api.9cscan.com/transactions/%_premiumTX% --ssl-no-revoke 2>nul|jq -r "[..]|.[6]"> %_cd%\user\trackedAvatar\%_folderVi%\premium\_statusBuy.txt 2>nul & set /p _statusBuy=<%_cd%\user\trackedAvatar\%_folderVi%\premium\_statusBuy.txt & del /q %_cd%\user\trackedAvatar\%_folderVi%\premium\_statusBuy.txt
set _statusBuy=^|echo %_statusBuy%|findstr /i SUCCESS>nul
if %errorlevel%==1 (echo. & echo Error 2.3: Premium code has not been successfully sent, try again ... & color 4F & timeout 5 & goto :premium)
set _blockBuy=^|curl https://api.9cscan.com/transactions/%_premiumTX% --ssl-no-revoke 2>nul|jq -r "[..]|.[8]"> %_cd%\user\trackedAvatar\%_folderVi%\premium\_blockBuy.txt 2>nul & set /p _blockBuy=<%_cd%\user\trackedAvatar\%_folderVi%\premium\_blockBuy.txt & del /q %_cd%\user\trackedAvatar\%_folderVi%\premium\_blockBuy.txt
set /a _blockBuy+=216000 2>nul
if %_blockBuy% lss %_9cscanBlock% (echo. & echo Error 2.4: Premium code has expired, try again ... & color 4F & timeout 5 & goto :premium)
set /a _HanSuDung= %_blockBuy% - %_9cscanBlock% 2>nul
set _NCGbuy=^|curl https://api.9cscan.com/transactions/%_premiumTX% --ssl-no-revoke 2>nul|jq -r "[..]|.[14]"> %_cd%\user\trackedAvatar\%_folderVi%\premium\_NCGbuy.json 2>nul
cd %_cd%\user\trackedAvatar\%_folderVi%\premium
set /a _NCGbuyi=1
for /f "tokens=*" %%a in (_NCGbuy.json) do call :_NCGbuyi %%a
set /a _NCGbuyi=1
for /f "tokens=*" %%a in (_NCGbuy.json) do call :_NCGbuyi %%a
findstr /i NCG %_cd%\user\trackedAvatar\%_folderVi%\premium\_NCGticker.txt>nul
if %errorlevel%==1 (del /q %_cd%\user\trackedAvatar\%_folderVi%\premium\_NCGticker.txt & del /q %_cd%\user\trackedAvatar\%_folderVi%\premium\_NCGticker.txt & echo. & echo Error 2.5: Premium Code is not sent NCG, try again ... & color 4F & timeout 5 & goto :premium)
if %_NCGbuy% lss %_pricePremium% (color 4F & echo. & echo Error 2.6: Premium code sended smaller than [41;33m%_pricePremium% NCG[41;97m, & echo. try again ... & timeout 5 & goto :premium)
del /q %_cd%\user\trackedAvatar\%_folderVi%\premium\_NCGbuy.json
set /a _premiumTXOK=1
goto :settingAuto
:ktraDonater
set /a _premiumTXOK=0
rem Check if the wallet is Donater or not
cd %_cd%\user\trackedAvatar\%_folderVi%
echo {"vi":"%_vi%"}> _vi.json
"%_cd%\batch\jq.exe" -r ".vi|ascii_downcase" _vi.json> _viLowcase.txt 2>nul & set /p _viLowcase=<_viLowcase.txt
del /q _vi.json & del /q _viLowcase.txt
curl --ssl-no-revoke --header "Content-Type: application/json" https://api.tanvpn.tk/donater?vi=%_viLowcase%> _KtraDonater.json 2>nul
findstr /i %_viLowcase% _KtraDonater.json>nul
if %errorlevel%==1 (echo. & echo Error 1: You are not Donater, try again ... & del /q _KtraDonater.json & color 4F & timeout 5 & goto :premium)
"%_cd%\batch\jq.exe" -r ".[].block" _KtraDonater.json> _HanSuDung.txt 2>nul
set /p _HanSuDung=<_HanSuDung.txt & del /q _HanSuDung.txt & del /q _KtraDonater.json
set /a _premiumTXOK=1
goto :settingAuto
:_NCGbuyi
rem Find the number of NCG in Premium Code
if %_NCGbuyi%==8 echo %*> _NCGticker.txt 2>nul
if %_NCGbuyi%==10 echo %*> _NCGbuy.txt 2>nul & set /p _NCGbuy=<_NCGbuy.txt & set /a _NCGbuy=%_NCGbuy:~0,-2% & del /q _NCGbuy.txt
set /a _NCGbuyi+=1
exit /b
:idCheckStatus
rem Check each transaction
curl https://api.9cscan.com/transactions/%*/status --ssl-no-revoke>nul 
exit /b
:ReadJsonbat
"%_cd%\batch\jq" -r "..|.%1?|select(.)" %_cd%\user\trackedAvatar\%_folderVi%\auto\output.json> %_cd%\user\trackedAvatar\%_folderVi%\auto\ReadJsonbat.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\auto\output.json
exit /b
:autoRefillAP
echo.└── Start Auto Refill AP character: %_name% ...
rem Create data saving folders
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%\autoRefillAP"
if exist %_folder% (rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%\autoRefillAP)
md %_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%\autoRefillAP
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%\autoRefillAP
copy "%_cd%\batch\jq.exe" "jq.exe"> nul
echo off
echo Step 0: Check previous Refill AP transactions
rem Check whether the previous transactions are successful or not
curl https://api.9cscan.com/accounts/%_vi%/transactions?action=daily_reward6^&limit=6 --ssl-no-revoke 2>nul|jq -r ".transactions|.[].id"> _idCheckStatus.txt 2>nul
set "_idCheckStatus="
for /f "tokens=*" %%a in (_idCheckStatus.txt) do call :idCheckStatus %%a
echo.└──── Complete step 0
rem Send your information to my server
echo ==========
echo Step 1: Get unsignedTransaction
echo {"vi":"%_vi%","publicKey":"%_publickey%","char":"%_address%","stt":%_charDisplay%,"premiumTX":"%_premiumTX%"}> input.json 2>nul
curl -X POST -H "accept: application/json" -H "Content-Type: application/json" --data "@input.json" https://api.tanvpn.tk/refillAP --ssl-no-revoke --location> output.json 2>nul
findstr /i kqua output.json> nul
if %errorlevel% equ 1 (color 4F & echo.└── Error 0: Unknown error & echo.─── wait 10 minutes and try again, ... & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto :duLieuViCu)
jq -r ".checkqua" output.json> _checkqua.txt 2>nul & set /p _checkqua=<_checkqua.txt
jq -r ".kqua" output.json> _kqua.txt 2>nul & set /p _kqua=<_kqua.txt
if %_checkqua% == 0 (echo.└── %_kqua%, turn off Auto ... & set /a _canAutoOnOff=0 & color 4F & timeout 100 & goto :displayVi)
echo.└──── Get unsignedTransaction successful
echo ==========
echo Step 2: Get Signature
rem Create Action File
call certutil -decodehex _kqua.txt action >nul
rem Get _IDKey
echo.└── Using the previously saved password ...
set /p _KeyID=<%_cd%\user\trackedAvatar\%_folderVi%\auto\KeyID\_KeyID.txt
set _KeyID=%_KeyID: =%
set /p _password=<%_cd%\user\trackedAvatar\%_folderVi%\auto\password\_password.txt
"%_cd%\planet\planet" key sign --passphrase %_PASSWORD% --store-path %_cd%\user\utc %_KeyID% action> _signature.txt 2>nul
set "_PASSWORD="
goto :KTraSignature1
:KTraSignature1
set "_signature="
set /p _signature=<_signature.txt
if [%_signature%] == [] (echo.└──── Error 1: The password saved incorrect, turn off Auto ... & set /a _canAutoOnOff=0 & color 4F & set /a _passwordOK=0 & rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\auto\password & timeout 100 & goto :displayVi)
echo.└──── Get Signature successful
echo ==========
echo Step 3: Get signTransaction
echo.
echo.[1] Continue refill AP, automatic after 10s
echo.[2] Return menu and turn off Auto
choice /c 12 /n /t 10 /d 1 /m "Enter from the keyboard: "
if %errorlevel%==1 (goto :tieptucAutoRefillAP)
if %errorlevel%==2 (set /a _canAutoOnOff=0 & goto :displayVi)
:tieptucAutoRefillAP
call %_cd%\batch\TaoInputJson.bat _unsignedTransaction %_kqua% %_cd%\batch\_codeStep3.txt> input1.json 2>nul
call %_cd%\batch\TaoInputJson.bat _signature %_signature% input1.json> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json  2>nul
echo.└── Find signTransaction ...
jq -r "..|.signTransaction?|select(.)" output.json> _signTransaction.txt 2>nul
echo.└──── Get signTransaction successful
echo ==========
echo Step 4: Get stageTransaction
echo.
set /p _signTransaction=<_signTransaction.txt
call %_cd%\batch\TaoInputJson.bat _signTransaction %_signTransaction% %_cd%\batch\_codeStep4.txt> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json  2>nul
echo.└── Find stageTransaction ...
jq -r "..|.stageTransaction?|select(.)" output.json> _stageTransaction.txt 2>nul
echo.└──── Get stageTransaction successful
set /a _countKtraAuto=0
:ktraAutoRefillAP
set /a _countKtraAuto+=1
color 0B
cls
echo.╔═══════════════╗   ╔═══════════════╗   ╔═══════════════╗
if %_canAuto%==5 echo ║ID %_vi:~0,7%***	║   ║Block: %_9cscanBlock% ║   ║[40;92mCan Auto? [X]	[40;96m║
if not %_canAuto%==5 echo ║ID %_vi:~0,7%***	║   ║Block: %_9cscanBlock% ║   ║[40;97mCan Auto? [ ]	[40;96m║
echo.╚═══════════════╝   ╚═══════════════╝   ╚═══════════════╝
echo ==========
echo Step 5: Checking auto Refill AP character: %_name%
set /p _stageTransaction=<_stageTransaction.txt
call %_cd%\batch\TaoInputJson.bat _stageTransaction %_stageTransaction% %_cd%\batch\_codeStep5.txt> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json 2>nul
echo.└── Find txStatus ...
jq -r "..|.txStatus?|select(.)" output.json> _txStatus.txt 2>nul
set /p _txStatus=<_txStatus.txt
if "%_txStatus%" == "STAGING" (color 0B & echo.─── Status: Auto Refill AP happenning & echo.─── check again after 15s ... & set /a _countKtraAuto=0 & timeout /t 15 /nobreak>nul & goto :ktraAutoRefillAP)
if "%_txStatus%" == "FAILURE" (color 4F & echo.─── Status: Auto Refill AP failure & echo.─── wait 10 minutes after trying again & echo.───  auto Refill AP, ... & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto :duLieuViCu)
if "%_txStatus%" == "INVALID" (if %_countKtraAuto% lss 4 (color 8F & echo.─── Status: Auto Refill AP temporary failure & echo.─── check again %_countKtraAuto% times after 15s ... & timeout /t 15 /nobreak>nul & goto :ktraAutoRefillAP))
if "%_txStatus%" == "INVALID" (if %_countKtraAuto% geq 4 (color 8F & echo.─── Status: Auto Refill AP failure & echo.─── turn off Auto ... & set /a _canAutoOnOff=0 & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto :duLieuViCu))
if "%_txStatus%" == "SUCCESS" (color 2F & echo.─── Status: Auto Refill AP successful & echo.─── return menu ... & timeout /t 20 /nobreak & echo.└──── Updating ... & goto :duLieuViCu)
if %_countKtraAuto% lss 4 (color 4F & echo.─── Error 2.1: Unknown error & echo.─── check again %_countKtraAuto% times after 15s ... & timeout /t 15 /nobreak>nul & goto :ktraAutoRefillAP)
if %_countKtraAuto% geq 4 (color 4F & echo.─── Error 2.2: Unknown error & echo.─── turn off Auto ... & set /a _canAutoOnOff=0 & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto :duLieuViCu)
goto :duLieuViCu
:autoSweep
echo.└── Đang Auto Sweep nhân vật: %_name% ... &
rem Create data saving folders
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%\autoSweep"
if exist %_folder% (rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%\autoSweep)
md %_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%\autoSweep
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%\autoSweep
copy "%_cd%\batch\jq.exe" "jq.exe"> nul
jq --compact-output "[.weapon,.armor,.belt,.necklace,.ring1,.ring2]" %_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%\settingSweep\_itemEquip.json> _itemIDList.json 2>nul
set /p _itemIDList=<_itemIDList.json
echo off
echo Step 0: Check previous Sweep transactions
rem Check whether the previous transactions are successful or not
curl https://api.9cscan.com/accounts/%_vi%/transactions?action=hack_and_slash_sweep8^&limit=6 --ssl-no-revoke 2>nul|jq -r ".transactions|.[].id"> _idCheckStatus.txt 2>nul
set "_idCheckStatus="
for /f "tokens=*" %%a in (_idCheckStatus.txt) do call :idCheckStatus %%a
echo.└──── Complete step 0
rem Send your information to my server
echo ==========
echo Step 1: Get unsignedTransaction
echo {"vi":"%_vi%","publicKey":"%_publickey%","char":"%_address%","stt":%_charDisplay%,"premiumTX":"%_premiumTX%","world": "%_world%","stageSweep": "%_stageSweep%","howManyAP": "%_howManyAP%","itemIDList": %_itemIDList%}> input.json 2>nul
curl -X POST -H "accept: application/json" -H "Content-Type: application/json" --data "@input.json" https://api.tanvpn.tk/autoSweep --ssl-no-revoke --location> output.json 2>nul
findstr /i kqua output.json> nul
if %errorlevel% equ 1 (color 4F & echo.└── Error 0: Unknown error & echo.─── wait 10 minutes and try again, ... & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto :duLieuViCu)
jq -r ".checkqua" output.json> _checkqua.txt 2>nul & set /p _checkqua=<_checkqua.txt
jq -r ".kqua" output.json> _kqua.txt 2>nul
rem Get the value exceeds 1024 characters
for %%A in (_kqua.txt) do for /f "usebackq delims=" %%B in ("%%A") do (
  set "_kqua=%%B"
  goto :autoSweep1
)
:autoSweep1
if %_checkqua% == 0 (echo.└── %_kqua%, turn off auto ... & set /a _canAutoOnOff=0 & color 4F & timeout 100 & goto :displayVi)
echo.└──── Get unsignedTransaction successful
echo ==========
echo Step 2: Get Signature
rem Create Action File
call certutil -decodehex _kqua.txt action >nul
rem Get _IDKeyCuaA
echo.└── Using the previously saved password ...
set /p _KeyID=<%_cd%\user\trackedAvatar\%_folderVi%\auto\KeyID\_KeyID.txt
set _KeyID=%_KeyID: =%
set /p _password=<%_cd%\user\trackedAvatar\%_folderVi%\auto\password\_password.txt
"%_cd%\planet\planet" key sign --passphrase %_PASSWORD% --store-path %_cd%\user\utc %_KeyID% action> _signature.txt 2>nul
set "_PASSWORD="
goto :KTraSignature2
:KTraSignature2
set "_signature="
rem Get the value exceeds 1024 characters
for %%A in (_signature.txt) do for /f "usebackq delims=" %%B in ("%%A") do (
  set "_signature=%%B"
  goto :autoSweep2
)
:autoSweep2
if [%_signature%] == [] (echo.└──── Error 1: The password saved incorrect, turn off Auto ... & set /a _canAutoOnOff=0 & color 4F & set /a _passwordOK=0 & rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\auto\password & timeout 100 & goto :displayVi)
echo.└──── Get Signature successful
echo ==========
echo Step 3: Get signTransaction
echo.
echo.[1] Continue sweep, automatic after 10s
echo.[2] Return menu and turn off Auto
choice /c 12 /n /t 10 /d 1 /m "Enter from the keyboard: "
if %errorlevel%==1 (goto :tieptucAutoSweep)
if %errorlevel%==2 (set /a _canAutoOnOff=0 & goto :displayVi)
:tieptucAutoSweep
call %_cd%\batch\TaoInputJson.bat _unsignedTransaction %_kqua% %_cd%\batch\_codeStep3.txt> input1.json 2>nul
call %_cd%\batch\TaoInputJson.bat _signature %_signature% input1.json> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json  2>nul
echo.└── Find signTransaction ...
jq -r "..|.signTransaction?|select(.)" output.json> _signTransaction.txt 2>nul
echo.└──── Get signTransaction successful
echo ==========
echo Step 4: Get stageTransaction
echo.
rem Get the value exceeds 1024 characters
for %%A in (_signTransaction.txt) do for /f "usebackq delims=" %%B in ("%%A") do (
  set "_signTransaction=%%B"
  goto :autoSweep3
)
:autoSweep3
call %_cd%\batch\TaoInputJson.bat _signTransaction %_signTransaction% %_cd%\batch\_codeStep4.txt> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json  2>nul
echo.└── Find stageTransaction ...
jq -r "..|.stageTransaction?|select(.)" output.json> _stageTransaction.txt 2>nul
echo.└──── Get stageTransaction successful
set /a _countKtraAuto=0
:ktraAutoSweep
set /a _countKtraAuto+=1
color 0B
cls
echo.╔═══════════════╗   ╔═══════════════╗   ╔═══════════════╗
if %_canAuto%==5 echo ║ID %_vi:~0,7%***	║   ║Block: %_9cscanBlock% ║   ║[40;92mCan Auto? [X]	[40;96m║
if not %_canAuto%==5 echo ║ID %_vi:~0,7%***	║   ║Block: %_9cscanBlock% ║   ║[40;97mCan Auto? [ ]	[40;96m║
echo.╚═══════════════╝   ╚═══════════════╝   ╚═══════════════╝
echo ==========
echo Step 5: Checking auto Refill AP character: %_name%
set /p _stageTransaction=<_stageTransaction.txt
call %_cd%\batch\TaoInputJson.bat _stageTransaction %_stageTransaction% %_cd%\batch\_codeStep5.txt> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json 2>nul
echo.└── Find txStatus ...
jq -r "..|.txStatus?|select(.)" output.json> _txStatus.txt 2>nul
set /p _txStatus=<_txStatus.txt
if "%_txStatus%" == "STAGING" (color 0B & echo.─── Status: Auto Sweep happenning & echo.─── check again after 15s ... & set /a _countKtraAuto=0 & timeout /t 15 /nobreak>nul & goto :ktraAutoSweep)
if "%_txStatus%" == "FAILURE" (color 4F & echo.─── Status: Auto Sweep failure & echo.─── wait 10 minutes after trying again & echo.───  auto Sweep, ... & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto :duLieuViCu)
if "%_txStatus%" == "INVALID" (if %_countKtraAuto% lss 4 (color 8F & echo.─── Status: Auto Sweep temporary failure & echo.─── check again %_countKtraAuto% times after 15s ... & timeout /t 15 /nobreak>nul & goto :ktraAutoSweep))
if "%_txStatus%" == "INVALID" (if %_countKtraAuto% geq 4 (color 8F & echo.─── Status: Auto Sweep failure & echo.─── turn off Auto ... & set /a _canAutoOnOff=0 & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto :duLieuViCu))
if "%_txStatus%" == "SUCCESS" (color 2F & echo.─── Status: Auto Sweep successful & echo.─── return menu ... & timeout /t 20 /nobreak & echo.└──── Updating ... & goto :duLieuViCu)
if %_countKtraAuto% lss 4 (color 4F & echo.─── Error 2.1: Unknown error & echo.─── check again %_countKtraAuto% times after 15s ... & timeout /t 15 /nobreak>nul & goto :ktraAutoSweep)
if %_countKtraAuto% geq 4 (color 4F & echo.─── Error 2.2: Unknown error & echo.─── turn off Auto ... & set /a _canAutoOnOff=0 & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto :duLieuViCu)
goto :duLieuViCu