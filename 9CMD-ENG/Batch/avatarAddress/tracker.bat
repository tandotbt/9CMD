echo off
mode con:cols=60 lines=25
color 0B
rem Install Vietnamese
chcp 65001
cls
rem Set %_cd% origin
set /p _cd=<_cd.txt
set _stt=%1
set _vi=**********************
set _9cscanBlock=*******
set _canAuto=0
set /a _HanSuDung=0
set /a _chuyendoi=0
set /a _premiumTXOK=0 & set /a _passwordOK=0 & set /a _publickeyOK=0 & set /a _keyidOK=0 & set /a _canAutoOnOff=0 & set /a _utcFileOK=0 & set /a _autoRefillAP=0 & set /a _autoSweepOnOffAll=0 & set /a _autoRepeatOnOffAll=0
set /p _node=<%_cd%\data\_node.txt
set _node=%_node: =%
:BatDau
rem setlocal ENABLEDELAYEDEXPANSION
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
echo.[3] Open location save data
echo.[4] Quit
echo.[5] Delete old and creat new wallet data
choice /c 12345 /n /t 5 /d 1 /m "Enter from the keyboard: "
echo.└── Processing ...
if %errorlevel%==2 (echo.└──── Quit after 5s ... & timeout 5 & exit)
if %errorlevel%==3 (start %_cd%\User\trackedAvatar\%_folderVi% & goto :BatDau)
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
if not %_length% geq 1 (if not %_length% leq 3 (echo. & echo Error 1: Wrong wallet, no character & echo.or 9cscan error, try again ... & color 4F & timeout 5 & goto :BatDau))
rem Get Stake level to find AP consumption
echo.└──── Get the AP number consumed by Stake level ...
cd %_cd%\user\trackedAvatar\%_folderVi%
echo {"query":"query{stateQuery{stakeStates(addresses:\"%_vi%\"){deposit}}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json 2>nul
echo 5 > _stakeAP.txt
rem Filter the results of data
findstr /i null output.json> nul
if %errorlevel% == 1 ("%_cd%\batch\jq.exe" -r ".data.stateQuery.stakeStates|.[]|.deposit|tonumber|if . >= 500000 then 3 elif . >= 5000 then 4 else 5 end" output.json > _stakeAP.txt 2>nul)
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
set "_temp="
set /a _temp=%_charCount%-1
jq ".[%_temp%]|del(.refreshBlockIndex)|del(.avatarAddress)|del(.address)|del(.goldBalance)|.[]|{address, name, level, actionPoint,timeCount: (.dailyRewardReceivedIndex+1700-%_9cscanBlock%)}" %_cd%\user\trackedAvatar\%_folderVi%\_allChar.json> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_infoChar.json 2>nul
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
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_AddressChar%\"){actionPoint,dailyRewardReceivedIndex,level,stageMap{count}}}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json 2>nul
rem Filter the results of data
"%_cd%\batch\jq.exe" -r "..|.count?|select(.)" output.json > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_stage.txt 2>nul
echo.└────── Get AP and the time of refill AP ...
"%_cd%\batch\jq.exe" -r ".data.stateQuery.avatar.actionPoint" output.json > _actionPoint.txt 2>nul
"%_cd%\batch\jq.exe" -r ".data.stateQuery.avatar|.dailyRewardReceivedIndex+1700-%_9cscanBlock%" output.json > _timeCount.txt 2>nul
"%_cd%\batch\jq.exe" -r ".data.stateQuery.avatar|.dailyRewardReceivedIndex+1700-%_9cscanBlock%|{sec: ((.*12)%%60),minute: ((((.*12)-(.*12)%%60)/60)%%60),hours: (((((.*12)-(.*12)%%60)/60)-(((.*12)-(.*12)%%60)/60%%60))/60)}" output.json > _infoCharAp.json 2>nul
"%_cd%\batch\jq.exe" -j """\(.hours):\(.minute):\(.sec)""" _infoCharAp.json> _infoCharAp.txt 2>nul
"%_cd%\batch\jq.exe" -r ".data.stateQuery.avatar.level" output.json> _level.txt 2>nul
rem Delete the draft file input and output
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\input.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\output.json 2>nul
set /a _stage=0
set /p _stage=<_stage.txt
if %_stage% == 0 (echo.Error 1.1: Opened stage not found & echo.the cause is node broken & echo.use node 1 and try again ... & %_cd%\data\flashError.exe & set /a _node=1 & color 4F & timeout 5 & goto :BatDau)
rem Create necessary files
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_autoSweepRepeatOnOffChar.txt"
if not exist %_file% (echo 0 > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_autoSweepRepeatOnOffChar.txt)
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep"
if not exist %_folder% (md %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep)
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_stageRandom.txt"
if not exist %_file% (echo %_stage% > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_stageRandom.txt)
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_stage.txt"
if not exist %_file% (echo 0 > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_stage.txt)
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_howManyTurn.txt"
if not exist %_file% (echo 0 > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_howManyTurn.txt)

set _folder="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\module"
if not exist %_folder% (md %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\module)
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\module\_autoOpenMapOnOff.txt"
if not exist %_file% (echo 0 > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\module\_autoOpenMapOnOff.txt)
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\module\_autoUseAPPotionOnOff.txt"
if not exist %_file% (echo 0 > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\module\_autoUseAPPotionOnOff.txt)
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\module\_repeatXturn.txt"
if not exist %_file% (echo 1 > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\module\_repeatXturn.txt)

set _folder="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat"
if not exist %_folder% (md %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat)
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\_stageRandom.txt"
if not exist %_file% (echo %_stage% > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\_stageRandom.txt)
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\_stage.txt"
if not exist %_file% (echo 0 > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\_stage.txt)
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\_howManyTurn.txt"
if not exist %_file% (echo 0 > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\_howManyTurn.txt)
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\_typeRepeat.txt"
if not exist %_file% (echo 1 > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\_typeRepeat.txt)

set _folder="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment"
if not exist %_folder% (md %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment)
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\module"
if not exist %_folder% (md %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\module)
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\module\_autoOpenMapOnOff.txt"
if not exist %_file% (echo 0 > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\module\_autoOpenMapOnOff.txt)
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\module\_autoUseAPPotionOnOff.txt"
if not exist %_file% (echo 0 > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\module\_autoUseAPPotionOnOff.txt)
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\module\_repeatXturn.txt"
if not exist %_file% (echo 1 > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\module\_repeatXturn.txt)
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
echo $.getJSON("https://jsonblob.com/api/jsonBlob/%_urlJson%",> index-raw2.html 2>nul
type index-raw1.html index-raw2.html index-raw3.html> index.html 2>nul
del /q index-raw1.html index-raw2.html index-raw3.html index-raw.html
:locChar2
rem Create file _itemEquip.json
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_itemEquip.json"
if exist %_file% (goto :locChar3)
echo.└────── Create file _itemEquip.json to view items for Sweep ...
echo {"weapon":"","armor":"","belt":"","necklace":"","ring1":"","ring2":""}> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_itemEquip.json
:locChar3
rem Tạo file _itemEquip.json
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\0.json"
if exist %_file% (goto :locChar4)
echo.└────── Tạo file 0.json xem vật phẩm cho Repeat...
echo {"weapon":"","armor":"","belt":"","necklace":"","ring1":"","ring2":""}> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\0.json
:locChar4
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\888888.json"
if not exist %_file% (
echo.└────── Tạo file 888888.json xem vật phẩm cho Repeat ...
echo {"weapon":"","armor":"","belt":"","necklace":"","ring1":"","ring2":""}> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\888888.json
)
if %_charCount% lss %_length% (set /a _charCount+=1 & goto :locChar)
:displayVi
echo.───── Complete!
timeout 2 >nul
call :background
set _hdsdRepeat=0
set _msgRefillAP=0
rem Display information
set _charCount=1
:displayChar
call :background2
if %_charCount% lss %_length% (set /a _charCount+=1 & goto :displayChar)
rem Try auto Refill AP
set _charCount=1
:displayChar1
call :tryRefillAP
if %_canAutoOnOff% == 1 (if %_timeCount% lss 0 (if %_canAuto% == 5 (if %_actionPoint% lss %_stakeAP% (if %_autoRefillAP% == 1 (call :autoRefillAP & goto :duLieuViCu)))))
if %_canAutoOnOff% == 1 (if %_timeCount% lss 0 (set _msgRefillAP=1))
if %_charCount% lss %_length% (set /a _charCount+=1 & goto :displayChar1)
rem Try auto Sweep
set _charCount=1
:displayChar2
call :tryAutoSweep
set "_temp="
set _temp=%_howManyTurn%
if %_howManyTurn% == 0 (set /a _temp=%_actionPoint%/%_stakeAP%)
set /a _howManyAP=%_stakeAP%*%_temp%
if %_canAutoOnOff% == 1 (if %_autoSweepOnOffAll% == 1 (if %_autoSweepRepeatOnOffChar% == 1 (if %_howManyAP% leq %_actionPoint% (if %_actionPoint% geq %_stakeAP% (call :autoSweep & goto :duLieuViCu)))))
if %_charCount% lss %_length% (set /a _charCount+=1 & goto :displayChar2)
rem Try auto Repeat
set _charCount=1
:displayChar3
call :tryAutoRepeat
set "_temp="
set _temp=%_howManyTurn%
if %_howManyTurn% == 0 (set /a _temp=%_actionPoint%/%_stakeAP%)
set /a _howManyAP=%_stakeAP%*%_temp%
if %_canAutoOnOff% == 1 (if %_autoRepeatOnOffAll% == 1 (if %_autoSweepRepeatOnOffChar% == 2 (if %_autoUseAPPotionOnOff% == 1 (if %_actionPoint% lss %_stakeAP% (call :tryAutoUseAPpotion & goto :duLieuViCu)))))
if %_canAutoOnOff% == 1 (if %_autoRepeatOnOffAll% == 1 (if %_autoSweepRepeatOnOffChar% == 2 (if %_howManyAP% leq %_actionPoint% (if %_actionPoint% geq %_stakeAP% (call :autoRepeat & goto :duLieuViCu)))))
if %_charCount% lss %_length% (set /a _charCount+=1 & goto :displayChar3)
if %_hdsdRepeat% == 1 (echo [40;95mType Repeat[40;96m / [40;94mAuto Open World [40;93mAuto AP potion [40;92mRepert x turn[40;96m) else (echo.)
echo.[40;96m==========
if %_msgRefillAP% == 0 (goto :displayChar6)
set /a _tempCountDisplay=0
:msgDisplayChar
set /a _tempCountDisplay+=1
rem Display information
set _charCount=1
:displayChar4
call :background
:displayChar5
call :background2
if %_charCount% lss %_length% (set /a _charCount+=1 & goto :displayChar5)
timeout 1 >nul
%_cd%\data\flashError.exe
color 6F
if %_tempCountDisplay% gtr 20 (goto :duLieuViCu)
choice /c 12 /n /t 1 /d 1 /m "└── Can refill AP, press [2] to escape ..."
if %errorlevel%==1 (goto :msgDisplayChar)
if %errorlevel%==2 (set _canAutoOnOff=0 & echo.└── Updating ... & goto :duLieuViCu)
:displayChar6
if %_canAutoOnOff% == 1 (
	echo.[1] Update, automatically after 60s	[40;92m╔═ [%_autoRefillAP%] [%_autoSweepOnOffAll%] [%_autoRepeatOnOffAll%] ═╗[40;96m
	echo.[2] Setting Auto			[40;92m║4.Turn OFF Auto║[40;96m
	echo.[3] User guide				[40;92m╚═══════════════╝[40;96m
	) else (
		echo.[1] Update, automatically after 60s	[40;97m╔═ [%_autoRefillAP%] [%_autoSweepOnOffAll%] [%_autoRepeatOnOffAll%] ═╗[40;96m
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
set _temp=       %_9cscanBlock%
echo.╔═══════════════╗   ╔═══════════════╗   ╔═══════════════╗
if %_canAuto%==5 echo ║ID %_vi:~0,7%***	║   ║Block: %_temp:~-7% ║   ║[40;92mCan Auto? [X]	[40;96m║
if not %_canAuto%==5 echo ║ID %_vi:~0,7%***	║   ║Block: %_temp:~-7% ║   ║[40;97mCan Auto? [ ]	[40;96m║
echo.╚═══════════════╝   ╚═══════════════╝   ╚═══════════════╝
exit /b
:background2
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%
set /p _name=<_name.txt & set /p _level=<_level.txt & set /p _stage=<_stage.txt & set /p _actionPoint=<_actionPoint.txt & set /p _infoCharAp=<_infoCharAp.txt & set /p _timeCount=<_timeCount.txt & set /p _address=<_address.txt
set /p _autoSweepRepeatOnOffChar=<_autoSweepRepeatOnOffChar.txt
set /a _autoSweepRepeatOnOffChar=%_autoSweepRepeatOnOffChar% 2>nul
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep
if %_autoSweepRepeatOnOffChar% == 2 (cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat)
set /p _stageSweepOrRepeat=<_stage.txt & set /p _howManyTurn=<_howManyTurn.txt 
set /a _stageSweepOrRepeat=%_stageSweepOrRepeat% 2>nul & set /a _howManyTurn=%_howManyTurn% 2>nul
if %_stageSweepOrRepeat% == 0 (goto :continue2Background2)
rem Randomly select 1 Stage in _stageRandom.txt
set INPUT_FILE="_stageRandom.txt"
rem Count the number of lines in the text file and generate a random number
for /f "usebackq" %%a in (`find /V /C "" ^< %INPUT_FILE%`) do set lines=%%a
set /a randnum=%RANDOM% * lines / 32768 + 1, skiplines=randnum-1
rem Extract the line from the file
set skip=
if %skiplines% gtr 0 set skip=skip=%skiplines%
for /f "usebackq %skip% delims=" %%a in (%INPUT_FILE%) do set "randline=%%a" & goto continueBackground2
:continueBackground2
rem echo Line #%randnum% is:
echo/%randline% > _stage.txt
:continue2Background2
set /p _typeRepeat=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\_typeRepeat.txt
set _typeRepeat=%_typeRepeat: =%
set _name=                    %_name%
set _level=                    %_level%
set _stage=               %_stage%
set _actionPoint=               %_actionPoint%
set _infoCharAp=                    %_infoCharAp%
set _stageSweepOrRepeat=   %_stageSweepOrRepeat%
set _howManyTurn=  %_howManyTurn%
set "_SweepOrRepeatNow=Idle			"
set /p _autoOpenMapOnOff=<%cd%\module\_autoOpenMapOnOff.txt
set /p _autoUseAPPotionOnOff=<%cd%\module\_autoUseAPPotionOnOff.txt
set /p _repeatXturn=<%cd%\module\_repeatXturn.txt
set /a _autoOpenMapOnOff=%_autoOpenMapOnOff% 2>nul
set /a _autoUseAPPotionOnOff=%_autoUseAPPotionOnOff% 2>nul
set /a _repeatXturn=%_repeatXturn% 2>nul
if %_autoSweepRepeatOnOffChar% == 1 (set _SweepOrRepeatNow=[40;33mSweep [40;96m	: [%_stageSweepOrRepeat:~-3%/%_howManyTurn:~-2%]	)
if %_autoSweepRepeatOnOffChar% == 2 (set _SweepOrRepeatNow=[40;35mRepeat[40;96m	:[%_stageSweepOrRepeat:~-3%/%_howManyTurn:~-2%][[40;95m%_typeRepeat%[40;96m/[40;94m%_autoOpenMapOnOff%[40;93m%_autoUseAPPotionOnOff%[40;92m%_repeatXturn%[40;96m])
if %_timeCount% lss 0 (
	echo.╔═══════════════════════════════════════════════════════╗
	echo.║Name	:%_name:~-20%	AP	:%_actionPoint:~-15%║
	echo.║Level	:%_level:~-20%	Stage	:%_stage:~-15%║
	echo.║[40;32mRefill	:%_infoCharAp:~-20%[40;96m	%_SweepOrRepeatNow%║
	echo.╚═══════════════════════════════════════════════════════╝
	) else (
		echo.╔═══════════════════════════════════════════════════════╗
		echo.║Name	:%_name:~-20%	AP	:%_actionPoint:~-15%║
		echo.║Level	:%_level:~-20%	Stage	:%_stage:~-15%║
		echo.║Refill	:%_infoCharAp:~-20%	%_SweepOrRepeatNow%║
		echo.╚═══════════════════════════════════════════════════════╝
		)
goto:eof
:tryRefillAP
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%
set /p _name=<_name.txt & set /p _level=<_level.txt & set /p _stage=<_stage.txt & set /p _actionPoint=<_actionPoint.txt & set /p _infoCharAp=<_infoCharAp.txt & set /p _timeCount=<_timeCount.txt & set /p _address=<_address.txt
goto:eof
:tryAutoSweep
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%
set /p _name=<_name.txt & set /p _level=<_level.txt & set /p _stage=<_stage.txt & set /p _actionPoint=<_actionPoint.txt & set /p _infoCharAp=<_infoCharAp.txt & set /p _timeCount=<_timeCount.txt & set /p _address=<_address.txt
set /p _autoSweepRepeatOnOffChar=<_autoSweepRepeatOnOffChar.txt
set /a _autoSweepRepeatOnOffChar=%_autoSweepRepeatOnOffChar% 2>nul
if not %_autoSweepRepeatOnOffChar% == 1 (exit /b)
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep
set /p _stageSweepOrRepeat=<_stage.txt & set /p _howManyTurn=<_howManyTurn.txt 
set /a _stageSweepOrRepeat=%_stageSweepOrRepeat% 2>nul & set /a _howManyTurn=%_howManyTurn% 2>nul
if %_stageSweepOrRepeat% == 0 (goto :continue2tryAutoSweep)
rem Randomly select 1 Stage in _stageRandom.txt
set INPUT_FILE="_stageRandom.txt"
rem Count the number of lines in the text file and generate a random number
for /f "usebackq" %%a in (`find /V /C "" ^< %INPUT_FILE%`) do set lines=%%a
set /a randnum=%RANDOM% * lines / 32768 + 1, skiplines=randnum-1
rem Extract the line from the file
set skip=
if %skiplines% gtr 0 set skip=skip=%skiplines%
for /f "usebackq %skip% delims=" %%a in (%INPUT_FILE%) do set "randline=%%a" & goto continuetryAutoSweep
:continuetryAutoSweep
rem echo Line #%randnum% is:
echo/%randline% > _stage.txt
:continue2tryAutoSweep
set /p _typeRepeat=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\_typeRepeat.txt
set _typeRepeat=%_typeRepeat: =%
set /p _autoOpenMapOnOff=<%cd%\module\_autoOpenMapOnOff.txt
set /p _autoUseAPPotionOnOff=<%cd%\module\_autoUseAPPotionOnOff.txt
set /p _repeatXturn=<%cd%\module\_repeatXturn.txt
set /a _autoOpenMapOnOff=%_autoOpenMapOnOff% 2>nul
set /a _autoUseAPPotionOnOff=%_autoUseAPPotionOnOff% 2>nul
set /a _repeatXturn=%_repeatXturn% 2>nul
goto:eof
:tryAutoRepeat
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%
set /p _name=<_name.txt & set /p _level=<_level.txt & set /p _stage=<_stage.txt & set /p _actionPoint=<_actionPoint.txt & set /p _infoCharAp=<_infoCharAp.txt & set /p _timeCount=<_timeCount.txt & set /p _address=<_address.txt
set /p _autoSweepRepeatOnOffChar=<_autoSweepRepeatOnOffChar.txt
set /a _autoSweepRepeatOnOffChar=%_autoSweepRepeatOnOffChar% 2>nul
if not %_autoSweepRepeatOnOffChar% == 2 (exit /b)
set _hdsdRepeat=1
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat
set /p _stageSweepOrRepeat=<_stage.txt & set /p _howManyTurn=<_howManyTurn.txt 
set /a _stageSweepOrRepeat=%_stageSweepOrRepeat% 2>nul & set /a _howManyTurn=%_howManyTurn% 2>nul
if %_stageSweepOrRepeat% == 0 (goto :continue2tryAutoRepeat)
rem Randomly select 1 Stage in _stageRandom.txt
set INPUT_FILE="_stageRandom.txt"
rem Count the number of lines in the text file and generate a random number
for /f "usebackq" %%a in (`find /V /C "" ^< %INPUT_FILE%`) do set lines=%%a
set /a randnum=%RANDOM% * lines / 32768 + 1, skiplines=randnum-1
rem Extract the line from the file
set skip=
if %skiplines% gtr 0 set skip=skip=%skiplines%
for /f "usebackq %skip% delims=" %%a in (%INPUT_FILE%) do set "randline=%%a" & goto continuetryAutoRepeat
:continuetryAutoRepeat
rem echo Line #%randnum% is:
echo/%randline% > _stage.txt
:continue2tryAutoRepeat
set /p _typeRepeat=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\_typeRepeat.txt
set _typeRepeat=%_typeRepeat: =%
set /p _autoOpenMapOnOff=<%cd%\module\_autoOpenMapOnOff.txt
set /p _autoUseAPPotionOnOff=<%cd%\module\_autoUseAPPotionOnOff.txt
set /p _repeatXturn=<%cd%\module\_repeatXturn.txt
set /a _autoOpenMapOnOff=%_autoOpenMapOnOff% 2>nul
set /a _autoUseAPPotionOnOff=%_autoUseAPPotionOnOff% 2>nul
set /a _repeatXturn=%_repeatXturn% 2>nul
goto:eof
:background3
call :background
rem Check whether or not the character
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%"
if not exist %_folder% (goto :settingAuto)
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%
set /p _name=<_name.txt & set /p _level=<_level.txt & set /p _stage=<_stage.txt & set /p _actionPoint=<_actionPoint.txt & set /p _infoCharAp=<_infoCharAp.txt & set /p _timeCount=<_timeCount.txt & set /p _address=<_address.txt
set /p _autoSweepRepeatOnOffChar=<_autoSweepRepeatOnOffChar.txt
set /a _autoSweepRepeatOnOffChar=%_autoSweepRepeatOnOffChar% 2>nul
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep
if %_chuyendoi% == 2 (cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat)
set /p _stageSweepOrRepeat=<_stage.txt & set /p _howManyTurn=<_howManyTurn.txt 
set /a _stageSweepOrRepeat=%_stageSweepOrRepeat% 2>nul & set /a _howManyTurn=%_howManyTurn% 2>nul
if %_stageSweepOrRepeat% == 0 (goto :continue2Background3)
rem Randomly select 1 Stage in _stageRandom.txt
set INPUT_FILE="_stageRandom.txt"
rem Count the number of lines in the text file and generate a random number
for /f "usebackq" %%a in (`find /V /C "" ^< %INPUT_FILE%`) do set lines=%%a
set /a randnum=%RANDOM% * lines / 32768 + 1, skiplines=randnum-1
rem Extract the line from the file
set skip=
if %skiplines% gtr 0 set skip=skip=%skiplines%
for /f "usebackq %skip% delims=" %%a in (%INPUT_FILE%) do set "randline=%%a" & goto continueBackground3
:continueBackground3
rem echo Line #%randnum% is:
echo/%randline% > _stage.txt
:continue2Background3
set /p _stageSweepOrRepeat=<_stage.txt & set /p _autoSweepRepeatOnOffChar=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_autoSweepRepeatOnOffChar.txt & set /p _howManyTurn=<_howManyTurn.txt 
set /a _stageSweepOrRepeat=%_stageSweepOrRepeat% 2>nul & set /a _autoSweepRepeatOnOffChar=%_autoSweepRepeatOnOffChar% 2>nul & set /a _howManyTurn=%_howManyTurn% 2>nul
echo.Character %_charCount%	[40;33mSweep on[40;96m	[40;35mRepeat on[40;96m
set /p _typeRepeat=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\_typeRepeat.txt
set _typeRepeat=%_typeRepeat: =%
set _name=                    %_name%
set _level=                    %_level%
set _stage=               %_stage%
set _actionPoint=               %_actionPoint%
set _infoCharAp=                    %_infoCharAp%
set _stageSweepOrRepeat=              Stage %_stageSweepOrRepeat%
set _howManyTurn=               %_howManyTurn%
set "_SweepOrRepeatNow=Sweep "
set /p _autoOpenMapOnOff=<%cd%\module\_autoOpenMapOnOff.txt
set /p _autoUseAPPotionOnOff=<%cd%\module\_autoUseAPPotionOnOff.txt
set /p _repeatXturn=<%cd%\module\_repeatXturn.txt
set /a _autoOpenMapOnOff=%_autoOpenMapOnOff% 2>nul
set /a _autoUseAPPotionOnOff=%_autoUseAPPotionOnOff% 2>nul
set /a _repeatXturn=%_repeatXturn% 2>nul
if %_chuyendoi% == 2 (set _SweepOrRepeatNow=Repeat)
set "_temp="
set /a _temp=%_chuyendoi%*%_autoSweepRepeatOnOffChar%
if %_temp% == 1 (
	echo.[40;33m╔═══════════════════════════════════════════════════════╗
	echo.║Name	:%_name:~-20%	AP	:%_actionPoint:~-15%║
	echo.║Level	:%_level:~-20%	Stage	:%_stage:~-15%║
	echo.║%_SweepOrRepeatNow%	:%_stageSweepOrRepeat:~-20%	Turn	:%_howManyTurn:~-15%║
	echo.╚═══════════════════════════════════════════════════════╝[40;96m
	) else ( if %_temp% == 4 (
				echo.[40;35m╔═══════════════════════════════════════════════════════╗
				echo.║Name	:%_name:~-20%	AP	:%_actionPoint:~-15%║
				echo.║Level	:%_level:~-20%	Stage	:%_stage:~-15%║
				echo.║%_SweepOrRepeatNow%	:%_stageSweepOrRepeat:~-20%	Turn	:%_howManyTurn:~-15%║
				echo.╚═══════════════════════════════════════════════════════╝[40;96m
				) else (
					echo.[40;97m╔═══════════════════════════════════════════════════════╗
					echo.║Name	:%_name:~-20%	AP	:%_actionPoint:~-15%║
					echo.║Level	:%_level:~-20%	Stage	:%_stage:~-15%║
					echo.║%_SweepOrRepeatNow%	:%_stageSweepOrRepeat:~-20%	Turn	:%_howManyTurn:~-15%║
					echo.╚═══════════════════════════════════════════════════════╝[40;96m
				)
			)
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%		
set /p _name=<_name.txt & set /p _level=<_level.txt & set /p _stage=<_stage.txt & set /p _actionPoint=<_actionPoint.txt & set /p _infoCharAp=<_infoCharAp.txt & set /p _timeCount=<_timeCount.txt & set /p _address=<_address.txt		
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep
if %_chuyendoi% == 2 (cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat)
set /p _stageSweepOrRepeat=<_stage.txt
set /a _stageSweepOrRepeat=%_stageSweepOrRepeat% 2>nul
goto:eof
:settingAuto
if %_chuyendoi% == 0 (goto :gotoRefillAP)
if %_chuyendoi% == 1 (goto :gotoSweep)
if %_chuyendoi% == 2 (goto :gotoClimbingChilling)
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
echo.╔════════════════╗   ╔══════════════╗   ╔═══════════════╗
echo ║[40;91m8[40;96m.Refill main[%_autoRefillAP%]║   ║Sweep main [%_autoSweepOnOffAll%]║   ║Repeat main [%_autoRepeatOnOffAll%]║
echo.╚════════════════╝   ╚══════════════╝   ╚═══════════════╝
echo.==========
echo.[40;97mMenu Auto Refill AP[40;96m
echo.[1..5] Enter enough to auto
echo.==========
echo.[6] Module Auto Craft
echo.==========
echo.[7] Return
echo.[8] Turn on / off auto Refill AP main
echo.[9] Switch to settings Auto Sweep
choice /c 123456789 /n /m "Enter the number from the keyboard: "
if %errorlevel% equ 1 (goto :premium)
if %errorlevel% equ 2 (goto :password)
if %errorlevel% equ 3 (goto :publickey)
if %errorlevel% equ 4 (goto :KeyID)
if %errorlevel% equ 5 (goto :utcFile)
if %errorlevel% equ 6 (goto :modulePlus)
if %errorlevel% equ 7 (goto :displayVi)
if %errorlevel% equ 8 (goto :autoRefillAPOnOff)
if %errorlevel% equ 9 (goto :gotoSweep)
goto :settingAuto
:gotoSweep
set /a _chuyendoi=1
set /a _charCount=1
:gotoSweep1
mode con:cols=60 lines=35
call :background3
set "_temp="
set /a _temp=%_actionPoint%/%_stakeAP%
set _temp=  %_temp%
set "_temp1="
set /a _temp1=%_stage%
set /a _temp1+=0
set _temp=  %_temp%
set _temp1=   %_temp1%
set _temp2=   %_stakeAP%
echo.[40;96m==========
echo.╔═════════════════════╗   ╔════════════════════════════╗
echo ║Need AP each turn:%_temp2:~-3%║   ║Stage 0 / Turn 0 - %_temp1:~-3% / %_temp:~-2% ║
echo.╚═════════════════════╝   ╚════════════════════════════╝
echo.==========
echo.╔══════════════╗   ╔═════════════════╗   ╔══════════════╗
echo ║Refill main[%_autoRefillAP%]║   ║[40;91m8[40;96m.Sweep main [%_autoSweepOnOffAll%] ║   ║Repeat main[%_autoRepeatOnOffAll%]║
echo.╚══════════════╝   ╚═════════════════╝   ╚══════════════╝
echo.==========
echo.[40;97mMenu Auto Sweep[40;96m
echo.[1] Import equipment
echo.[2] Enter Stage
echo.[3] Enter turn
echo.==========
echo.[4] Switch to the next character
echo.[5] Turn on / off auto Sweep for [40;97m%_name%[40;96m
echo [6] Turn on / off Stage 0
echo.==========
echo.[7] Return
echo.[8] Turn on / off auto Sweep main
echo.[9] Switch to settings Auto Climbing Chilling
choice /c 123456789 /n /m "Enter the number from the keyboard: "
if %errorlevel% equ 1 (mode con:cols=60 lines=25 & goto :importTrangBi)
if %errorlevel% equ 2 (mode con:cols=60 lines=25 & goto :pickStage)
if %errorlevel% equ 3 (mode con:cols=60 lines=25 & goto :howManyTurn)
if %errorlevel% equ 4 (mode con:cols=60 lines=25 & set /a _charCount+=1 &goto :gotoSweep1)
if %errorlevel% equ 5 (mode con:cols=60 lines=25 & goto :charSweepOnOff)
if %errorlevel% equ 6 (mode con:cols=60 lines=25 & goto :stageZero)
if %errorlevel% equ 7 (mode con:cols=60 lines=25 & goto :displayVi)
if %errorlevel% equ 8 (mode con:cols=60 lines=25 & goto :autoSweepOnOffAll)
if %errorlevel% equ 9 (mode con:cols=60 lines=25 & goto :gotoClimbingChilling)
goto :gotoSweep1
:gotoClimbingChilling
set /a _chuyendoi=2
set /a _charCount=1
:gotoClimbingChilling1
mode con:cols=60 lines=35
call :background3
set "_temp="
set /a _temp=%_actionPoint%/%_stakeAP%
set "_temp1="
set /a _temp1=%_stage%
set /a _temp1+=1
set _temp=  %_temp%
set _temp1=   %_temp1%
set _temp2=   %_stakeAP%
echo.[40;96m==========
echo.╔═════════════════════╗   ╔════════════════════════════╗
echo ║Need AP each turn:%_temp2:~-3%║   ║Stage 0 / Turn 0 - %_temp1:~-3% / %_temp:~-2% ║
echo.╚═════════════════════╝   ╚════════════════════════════╝
echo.==========
echo.╔══════════════╗   ╔═════════════╗   ╔══════════════════╗
echo ║Refill main[%_autoRefillAP%]║   ║Sweep main[%_autoSweepOnOffAll%]║   ║[40;91m8[40;96m.Repeat main [%_autoRepeatOnOffAll%] ║
echo.╚══════════════╝   ╚═════════════╝   ╚══════════════════╝
echo.==========
echo.[40;97mMenu Auto Climbing Chilling[40;96m
echo.[1] Import equipment [40;95mtype %_typeRepeat%[40;96m
echo.[2] Enter stage
echo.[3] Enter turn
echo.==========
echo.[4] Switch to the next character
echo.[5] Turn on / off auto Repeat for [40;97m%_name%[40;96m
echo [6] Module [[40;95m%_typeRepeat%[40;96m/[40;94m%_autoOpenMapOnOff%[40;93m%_autoUseAPPotionOnOff%[40;92m%_repeatXturn%[40;96m]
echo.==========
echo.[7] Return
echo.[8] Turn on / off auto Repeat main
echo.[9] Switch to settings Auto Refill AP
choice /c 123456789 /n /m "Nhập số từ bàn phím: "
if %errorlevel% equ 1 (mode con:cols=60 lines=25 & goto :importTrangBiType)
if %errorlevel% equ 2 (mode con:cols=60 lines=25 & goto :pickStage)
if %errorlevel% equ 3 (mode con:cols=60 lines=25 & goto :howManyTurn)
if %errorlevel% equ 4 (mode con:cols=60 lines=25 & set /a _charCount+=1 &goto :gotoClimbingChilling1)
if %errorlevel% equ 5 (mode con:cols=60 lines=25 & goto :charRepeatOnOff)
if %errorlevel% equ 6 (mode con:cols=60 lines=25 & goto :moduleRepeat)
if %errorlevel% equ 7 (mode con:cols=60 lines=25 & goto :displayVi)
if %errorlevel% equ 8 (mode con:cols=60 lines=25 & goto :autoRepeatOnOffAll)
if %errorlevel% equ 9 (mode con:cols=60 lines=25 & goto :gotoRefillAP)
goto :settingAuto
:modulePlus
echo.Module Plus for wallets %_stt%
echo.Using node %_node%
echo.
echo.[1] Auto craft / upgrade equipment
rem choice /c 12 /n /m "Nhập số từ bàn phím: "
rem if %errorlevel% == 1 (set /a _temp1=1)
rem if %errorlevel% == 2 (set /a _temp1=1)
choice /c 123 /m "Choose character: "
set _temp2=%errorlevel%
set _folder="%_cd%\User\trackedAvatar\%_folderVi%\char%_temp2%"
if not exist %_folder% (echo.Character's data saving folder not found %_temp2% & timeout 3 >nul & goto :modulePlus)
start %_cd%\batch\avatarAddress\autoCraft.bat %_stt% %_temp2%
goto :settingAuto
:importTrangBiType
call :background
set /p _typeRepeat=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\_typeRepeat.txt
set _typeRepeat=%_typeRepeat: =%
echo.Get equipment [40;95mtype %_typeRepeat%[40;96m
echo.
echo.Type [1]: Fix 1 setup
echo.└── Always use 0.json equipment setup
echo.
echo.Type [2]: Semi-automatic
echo.└── Auto use the equipment user setup
echo.─── previous by character level
echo. 
echo.Type [3]: Automatic
echo.└── 9CMD will choose the outfit
echo.─── with the highest CP by character level
echo.[40;91m─── If there are items crafting (upgrading)
echo.─── or being sold (expired) on shop
echo.─── use type 3 may not be success
echo.─── Request ALL ITEMS can be equipped![40;96m
echo.
echo.==========
echo.[4] Select type
echo.[5] Return
echo.
choice /c 12345 /n /m "Enter the number from the keyboard: "
if %errorlevel% equ 1 (set _typeRepeat=1 & echo 1 > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\_typeRepeat.txt & goto :importTrangBi)
if %errorlevel% equ 2 (goto :importTrangBiType2)
if %errorlevel% equ 3 (set _typeRepeat=3 & echo 3 > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\_typeRepeat.txt & goto :importTrangBi)
if %errorlevel% equ 4 (goto :pickTypeRepeat)
if %errorlevel% equ 5 (goto :gotoClimbingChilling1)
:pickTypeRepeat
choice /c 123 /m "└── Type ... "
if %errorlevel% equ 1 (set _typeRepeat=1 & echo 1 > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\_typeRepeat.txt & goto :importTrangBiType)
if %errorlevel% equ 2 (set _typeRepeat=2 & echo 2 > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\_typeRepeat.txt & goto :importTrangBiType)
if %errorlevel% equ 3 (set _typeRepeat=3 & echo 3 > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\_typeRepeat.txt & goto :importTrangBiType)
goto :importTrangBiType
:importTrangBiType2
echo.
echo.==========
echo.The equipment user setup previous by level of character %_charCount%
echo.
dir /b %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment
echo.
echo.[1] Import / editing
echo.[2] Open location sava data
echo.[3] Return
choice /c 123 /n /m "Enter the number from the keyboard: "
if %errorlevel% equ 1 (goto :importTrangBiType22)
if %errorlevel% equ 2 (start %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment & goto :importTrangBiType2)
if %errorlevel% equ 3 (goto :importTrangBiType)
:importTrangBiType22
set /p "_sttEquipSet=└── Select a level to import / editing: "
rem Check is the number or not
set "var="&for /f "delims=0123456789" %%i in ("%_sttEquipSet%") do set var=%%i
if defined var (echo Error 1: Not a number, try again ... & color 4F & timeout 5 & goto :importTrangBiType)
echo.==========
echo.Picked file %_sttEquipSet%.json
echo.
echo.[1] Create / edit
echo.[2] Delete
choice /c 12 /n /m "Enter the number from the keyboard: "
if %errorlevel% equ 1 (
set _typeRepeat=2
echo 2 > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\_typeRepeat.txt 
goto :importTrangBi
)
if %errorlevel% equ 2 (
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\%_sttEquipSet%.json"
if exist %_file% (if not %_sttEquipSet% == 0 (del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\%_sttEquipSet%.json))
goto :importTrangBiType
)
:moduleRepeat
call :background
echo Character %_charCount% - Module Repeat
echo [[40;94mAuto Open World [40;93mAuto AP potion [40;92mRepert x turn[40;96m]
echo [[40;94m%_autoOpenMapOnOff%[40;93m%_autoUseAPPotionOnOff%[40;92m%_repeatXturn%[40;96m]
echo.==========
echo.
if %_stageSweepOrRepeat% == 0 (echo.[40;32m[1][40;96m Is on Stage 0) else (echo.[1] Is off Stage 0)
if %_autoOpenMapOnOff% == 0 (echo.[2] Is off auto open map with crystal) else (echo.[40;32m[2][40;96m Is on auto open map with crystal)
if %_autoUseAPPotionOnOff% == 0 (echo.[3] Is off Auto use AP potion) else (echo.[40;32m[3][40;96m Is on Auto use AP potion)
echo.[4] Auto repeat [40;32m%_repeatXturn%[40;96m time(s) when level ^< stage
echo.==========
echo.[5] Return
echo.
choice /c 12345 /n /m "Enter the number from the keyboard: "
if %errorlevel% equ 1 (goto :stageZero)
if %errorlevel% equ 2 (goto :autoOpenMap)
if %errorlevel% equ 3 (goto :autoUseAP)
if %errorlevel% equ 4 (goto :repeatXturn)
if %errorlevel% equ 5 (goto :gotoClimbingChilling1)
goto :gotoClimbingChilling1
:repeatXturn
set /p "_repeatXturn=└── The turn you want when level < stage: "
rem Check is the number or not
set "var="&for /f "delims=0123456789" %%i in ("%_repeatXturn%") do set var=%%i
if defined var (echo Error 1: Not a number, try again ... & color 4F & timeout 5 & goto :repeatXturn)
echo %_repeatXturn% > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\module\_repeatXturn.txt
goto :gotoClimbingChilling1
:autoUseAP
echo.└── Processing ...
cd %_cd%\user\trackedAvatar\%_folderVi%\
rem Check quantity AP potion
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_address%\"){inventory{items(inventoryItemId:500000){id,itemType,count}}}}}"} > input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql > output.json 2>nul
rem Filter the results of data
%_cd%\batch\jq.exe -r ".data.stateQuery.avatar.inventory.items|(if ([.[].count]|add) == null then 0 else ([.[].count]|add) end)" output.json > _countAPPotion.txt 2>nul
set /p _countAPPotion=<_countAPPotion.txt
set /a _countAPPotion=%_countAPPotion% 2>nul
del /q input.json output.json _countAPPotion.txt
echo.==========
echo Character	:	%_charCount%
echo Name		:	%_name%
echo Stage		:	%_stage%
if %_countAPPotion% leq 0 (echo Have		:	[40;91m%_countAPPotion%[40;96m AP Potion) else (echo Have		:	[40;32m%_countAPPotion%[40;96m AP Potion)
echo [1] Turn on / off auto use AP potion
echo [2] Return
choice /c 12 /n /m "Enter number from the keyboard: "
if %errorlevel% == 1 (
	if %_autoUseAPPotionOnOff% == 0 (echo 1 > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\module\_autoUseAPPotionOnOff.txt & goto :gotoClimbingChilling1) else (echo 0 > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\module\_autoUseAPPotionOnOff.txt & goto :gotoClimbingChilling1)
)
if %errorlevel% == 2 (goto :gotoClimbingChilling1)
goto :gotoClimbingChilling1
:autoOpenMap
echo.└── Processing ...
cd %_cd%\user\trackedAvatar\%_folderVi%\
rem Check the balance
echo {"query":"query{stateQuery{agent(address:\"%_vi%\"){crystal}}goldBalance(address: \"%_vi%\" )}"} > input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql > output.json 2>nul
rem Filter the results of data
%_cd%\batch\jq.exe "..|.crystal?|select(.)|tonumber" output.json > _crystal.txt 2>nul
%_cd%\batch\jq.exe "..|.goldBalance?|select(.)|tonumber" output.json > _ncg.txt 2>nul
set /p _ncg=<_ncg.txt
set /p _crystal=<_crystal.txt
set /a _ncg=%_ncg% 2>nul
set /a _crystal=%_crystal% 2>nul
set "_temp=" & set "_temp1=" & set "_temp2=" & set "_temp3=" & set "_temp4=" & set "_temp5=8888888888"
set /a _temp=%_stage%
if %_temp% leq 50 (set _temp1=1 & set _temp2=Yggdrasil)
if %_temp% leq 100 (if %_temp% geq 51 (set _temp1=2 & set _temp2=Alfheim))
if %_temp% leq 150 (if %_temp% geq 101 (set _temp1=3 & set _temp2=Svartalfheim))
if %_temp% leq 200 (if %_temp% geq 151 (set _temp1=4 & set _temp2=Asgard))
if %_temp% leq 250 (if %_temp% geq 201 (set _temp1=5 & set _temp2=Muspelheim))
if %_temp% leq 300 (if %_temp% geq 251 (set _temp1=6 & set _temp2=Jotunheim))
if %_temp% leq 350 (if %_temp% geq 301 (set _temp1=7 & set _temp2=NoData))
set /a _temp=%_temp1% + 1
set _temp4=NoData
if %_temp% == 2 (set /a _temp5=500 & set _temp4=Alfheim)
if %_temp% == 3 (set /a _temp5=2500 & set _temp4=Svartalfheim)
if %_temp% == 4 (set /a _temp5=50000 & set _temp4=Asgard)
if %_temp% == 5 (set /a _temp5=100000 & set _temp4=Muspelheim)
if %_temp% == 6 (set /a _temp5=1000000 & set _temp4=Jotunheim)
del /q input.json output.json _crystal.txt _ncg.txt
echo.==========
echo Balance	:	%_ncg% NCG	%_crystal% CRYSTAL
echo Character	:	%_charCount%
echo Name		:	%_name%
echo Stage		:	%_stage%
echo World		:	%_temp2%
echo Next world %_temp4% need [40;97m%_temp5% CRYSTAL[40;96m
echo.==========
echo.
set /a _temp=%_temp5%-%_crystal%
if %_temp5% geq %_crystal% (
echo.Need %_temp% CRYSTAL to unlock next world)
echo [1] Turn on / off Auto open map with crystal
echo [2] Return
choice /c 12 /n /m "Enter number from the keyboard: "
if %errorlevel% == 1 (
	if %_autoOpenMapOnOff% == 0 (echo 1 > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\module\_autoOpenMapOnOff.txt & goto :gotoClimbingChilling1) else (echo 0 > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\module\_autoOpenMapOnOff.txt & goto :gotoClimbingChilling1)
)
if %errorlevel% == 2 (goto :gotoClimbingChilling1)
goto :gotoClimbingChilling1
:stageZero
if %_chuyendoi% == 1 (
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep
if %_stageSweepOrRepeat% == 0 (echo 1 > _stage.txt) else (echo 0 > _stage.txt)
goto :gotoSweep1
)
if %_chuyendoi% == 2 (
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat
if %_stageSweepOrRepeat% == 0 (echo 1 > _stage.txt) else (echo 0 > _stage.txt)
goto :gotoClimbingChilling1)
:charRepeatOnOff
if not %_autoSweepRepeatOnOffChar% == 2 (set /a _autoSweepRepeatOnOffChar=2) else (set /a _autoSweepRepeatOnOffChar=0)
echo %_autoSweepRepeatOnOffChar% > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_autoSweepRepeatOnOffChar.txt
goto :gotoClimbingChilling1
:charSweepOnOff
if not %_autoSweepRepeatOnOffChar% == 1 (set /a _autoSweepRepeatOnOffChar=1) else (set /a _autoSweepRepeatOnOffChar=0)
echo %_autoSweepRepeatOnOffChar% > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_autoSweepRepeatOnOffChar.txt
goto :gotoSweep1
:howManyTurn
call :background3
echo.[40;96m==========
set /a _maxTurn=120/%_stakeAP%
set _maxTurn=  %_maxTurn%
set _temp=  %_stakeAP%
echo.╔═════════════════════╗   ╔═════════════════════════╗
echo ║Need AP each turn:%_temp:~-3%║   ║Max turn with 120 AP: %_maxTurn:~-2% ║
echo.╚═════════════════════╝   ╚═════════════════════════╝
set /a _maxTurn=120/%_stakeAP%
echo.
echo.==========
rem Reset _pickHowManyTurn
set "_pickHowManyTurn="
echo.Enter "waybackhome" to return
set /p _pickHowManyTurn="Enter the number of turn: "
echo.
if "%_pickHowManyTurn%" == "waybackhome" (if %_chuyendoi% == 1 (set "_pickHowManyTurn=" & goto :gotoSweep1))
if "%_pickHowManyTurn%" == "waybackhome" (if %_chuyendoi% == 2 (set "_pickHowManyTurn=" & goto :gotoClimbingChilling1))
rem Check whether it is empty or not
if [%_pickHowManyTurn%] == [] (echo Error 1: Enter empty, try again ... & color 4F & timeout 5 & set "_pickHowManyTurn=" & goto :howManyTurn)
rem Check whether the turn is the number or not
set "var="&for /f "delims=0123456789" %%i in ("%_pickHowManyTurn%") do set var=%%i
if defined var (echo Error 2: Wrong type input, try again ... & color 4F & timeout 5 & set "_pickHowManyTurn=" & goto :howManyTurn)
rem Check if the turn is > the max turn or not
if %_pickHowManyTurn% gtr %_maxTurn% (echo Error 3: %_pickHowManyTurn% bigger %_maxTurn% turn, try again ... & color 4F & timeout 5 & set "_pickHowManyTurn=" & goto :howManyTurn)
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep
if %_chuyendoi% == 2 (cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat)
echo %_pickHowManyTurn% > _howManyTurn.txt
if %_chuyendoi% == 1 (goto :gotoSweep1)
if %_chuyendoi% == 2 (goto :gotoClimbingChilling1)
:pickStage
call :background3
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep
if %_chuyendoi% == 2 (cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat)
echo.[40;96m==========
echo.
echo.The Stage(s) are saved:
type _stageRandom.txt
echo.==========
echo.
rem Reset _pickStage
set "_pickStage="
echo.Enter "waybackhome" to return
set /p _pickStage=="Enter Stage you want: "
echo.
if "%_pickStage%" == "waybackhome" (if %_chuyendoi% == 1 (set "_pickStage=" & goto :gotoSweep1))
if "%_pickStage%" == "waybackhome" (if %_chuyendoi% == 2 (set "_pickStage=" & goto :gotoClimbingChilling1))
rem Check whether it is empty or not
if [%_pickStage%] == [] (echo Error 1: Enter empty, try again ... & color 4F & timeout 5 & set "_pickStage=" & goto :pickStage)
rem Check whether the sweep is the number or not
set "var="&for /f "delims=0123456789" %%i in ("%_pickStage%") do set var=%%i
if defined var (echo Error 2: Wrong type input, try again ... & color 4F & timeout 5 & set "_pickStage=" & goto :pickStage)
rem Check if the stage is > the stage that the character has opened or not
set "_temp="
set /a _temp=%_stage%+1
if %_chuyendoi% == 1 (if %_pickStage% gtr %_stage% (echo Error 3: Stage %_pickStage% larger than the stage allowed to sweep, try again ... & color 4F & timeout 5 & set "_pickStage=" & goto :pickStage))
if %_chuyendoi% == 2 (if %_pickStage% gtr %_temp% (echo Error 3: Stage %_pickStage% larger than the stage allowed to repeat, try again ... & color 4F & timeout 5 & set "_pickStage=" & goto :pickStage))
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep
if %_chuyendoi% == 2 (cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat)
echo %_pickStage% >> _stageRandom.txt
:pickStage1
call :background3
echo.[40;96m==========
echo.
echo.The Stage(s) are saved:
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep
if %_chuyendoi% == 2 (cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat)
type _stageRandom.txt
echo.==========
echo.
echo.By default 9CMD will randomly select one stage of list stage(s)
echo.saved to sweep
echo.[1] Only save Stage %_pickStage%
echo.[2] Import more Stage
echo.[3] Open by Notepad
echo.==========
echo.[4] Return
choice /c 1234 /n /m "Enter the number from the keyboard: "
if %errorlevel% equ 1 (echo %_pickStage% > _stageRandom.txt & goto :pickStage)
if %errorlevel% equ 2 (goto :pickStage)
if %errorlevel% equ 3 (start _stageRandom.txt & goto :pickStage1)
if %errorlevel% equ 4 (
if %_chuyendoi% == 1 (goto :gotoSweep1)
if %_chuyendoi% == 2 (goto :gotoClimbingChilling1)
)
:importTrangBi
call :background
rem Refresh data
set "_weapon=" & set "_armor=" & set "_belt=" & set "_necklace=" & set "_ring1=" & set "_ring2="
if %_chuyendoi% == 1 (goto :importTrangBiSweep)
if %_typeRepeat% == 1 (goto :importTrangBiRepeatType1)
if %_typeRepeat% == 2 (goto :importTrangBiRepeatType2)
if %_typeRepeat% == 3 (goto :importTrangBiRepeatType3)
:importTrangBiRepeatType1
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment
"%_cd%\batch\jq.exe" -r ".weapon" 0.json> _weapon.txt & set /p _weapon=<_weapon.txt & del /q _weapon.txt
"%_cd%\batch\jq.exe" -r ".armor" 0.json> _armor.txt & set /p _armor=<_armor.txt & del /q _armor.txt
"%_cd%\batch\jq.exe" -r ".belt" 0.json> _belt.txt & set /p _belt=<_belt.txt & del /q _belt.txt
"%_cd%\batch\jq.exe" -r ".necklace" 0.json> _necklace.txt & set /p _necklace=<_necklace.txt & del /q _necklace.txt
"%_cd%\batch\jq.exe" -r ".ring1" 0.json> _ring1.txt & set /p _ring1=<_ring1.txt & del /q _ring1.txt
"%_cd%\batch\jq.exe" -r ".ring2" 0.json> _ring2.txt & set /p _ring2=<_ring2.txt & del /q _ring2.txt
echo.Repeat - Type 1 - Character %_charCount%
echo.
goto :importTrangBiMain
:importTrangBiRepeatType2
if not defined _sttEquipSet (set _sttEquipSet=0)
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\%_sttEquipSet%.json"
if not exist %_file% (echo {"weapon":"","armor":"","belt":"","necklace":"","ring1":"","ring2":""}> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\%_sttEquipSet%.json)
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment
"%_cd%\batch\jq.exe" -r ".weapon" %_sttEquipSet%.json> _weapon.txt & set /p _weapon=<_weapon.txt & del /q _weapon.txt
"%_cd%\batch\jq.exe" -r ".armor" %_sttEquipSet%.json> _armor.txt & set /p _armor=<_armor.txt & del /q _armor.txt
"%_cd%\batch\jq.exe" -r ".belt" %_sttEquipSet%.json> _belt.txt & set /p _belt=<_belt.txt & del /q _belt.txt
"%_cd%\batch\jq.exe" -r ".necklace" %_sttEquipSet%.json> _necklace.txt & set /p _necklace=<_necklace.txt & del /q _necklace.txt
"%_cd%\batch\jq.exe" -r ".ring1" %_sttEquipSet%.json> _ring1.txt & set /p _ring1=<_ring1.txt & del /q _ring1.txt
"%_cd%\batch\jq.exe" -r ".ring2" %_sttEquipSet%.json> _ring2.txt & set /p _ring2=<_ring2.txt & del /q _ring2.txt
echo.Repeat - Type 2 - Character %_charCount% - %_sttEquipSet%.json
echo.
goto :importTrangBiMain
:importTrangBiRepeatType3
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment
"%_cd%\batch\jq.exe" -r ".weapon" 888888.json> _weapon.txt & set /p _weapon=<_weapon.txt & del /q _weapon.txt
"%_cd%\batch\jq.exe" -r ".armor" 888888.json> _armor.txt & set /p _armor=<_armor.txt & del /q _armor.txt
"%_cd%\batch\jq.exe" -r ".belt" 888888.json> _belt.txt & set /p _belt=<_belt.txt & del /q _belt.txt
"%_cd%\batch\jq.exe" -r ".necklace" 888888.json> _necklace.txt & set /p _necklace=<_necklace.txt & del /q _necklace.txt
"%_cd%\batch\jq.exe" -r ".ring1" 888888.json> _ring1.txt & set /p _ring1=<_ring1.txt & del /q _ring1.txt
"%_cd%\batch\jq.exe" -r ".ring2" 888888.json> _ring2.txt & set /p _ring2=<_ring2.txt & del /q _ring2.txt
echo.Repeat - Type 3 - Character %_charCount% - 888888.json
echo.
goto :importTrangBiMain
:importTrangBiSweep
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep
"%_cd%\batch\jq.exe" -r ".weapon" _itemEquip.json> _weapon.txt & set /p _weapon=<_weapon.txt & del /q _weapon.txt
"%_cd%\batch\jq.exe" -r ".armor" _itemEquip.json> _armor.txt & set /p _armor=<_armor.txt & del /q _armor.txt
"%_cd%\batch\jq.exe" -r ".belt" _itemEquip.json> _belt.txt & set /p _belt=<_belt.txt & del /q _belt.txt
"%_cd%\batch\jq.exe" -r ".necklace" _itemEquip.json> _necklace.txt & set /p _necklace=<_necklace.txt & del /q _necklace.txt
"%_cd%\batch\jq.exe" -r ".ring1" _itemEquip.json> _ring1.txt & set /p _ring1=<_ring1.txt & del /q _ring1.txt
"%_cd%\batch\jq.exe" -r ".ring2" _itemEquip.json> _ring2.txt & set /p _ring2=<_ring2.txt & del /q _ring2.txt
:importTrangBiMain
echo.Enter equipment by itemID:
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
if %errorlevel% equ 7 (
if %_chuyendoi% == 1 (goto :gotoSweep1)
if %_chuyendoi% == 2 (goto :gotoClimbingChilling1)
)
if %errorlevel% equ 8 (start "" "%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\index.html" & goto :importTrangBi)
if %errorlevel% equ 9 (goto :importTrangBiEquipped)
goto :importTrangBi
:importTrangBiEquipped
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep
:importTrangBiEquippedMain
echo.└── Taking equipped ID item(s) ...
set /p _address=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_address.txt
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_address%\"){inventory{equipments{grade,id,itemSubType,elementalType,equipped,itemId,level,statsMap{aTK,hP,dEF,sPD,hIT,cRI},skills{elementalType,chance,power},stat{value,type}}}}}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output1.json 2>nul
rem Filter the results of data
%_cd%\batch\jq.exe -r -f %_cd%\data\avatarAddress\filterEQUIPPED.txt output1.json> output2.json 2>nul
%_cd%\batch\jq.exe -r -f %_cd%\data\avatarAddress\filterStageUnlockAndLevelReq.txt output2.json> output3.json 2>nul
%_cd%\batch\jq.exe -r "group_by(.id)|.[]|select(length == 2)" output3.json> output4.json 2>nul
%_cd%\batch\jq.exe -r -s "[.[]|{image: .[0].image,level: .[0].level,elementalType: .[0].elementalType,itemId: .[0].itemId,index: .[0].index,skills: .[0].skills,grade: .[0].grade,equipped: .[0].equipped,stat: .[0].stat,CP: .[0].CP,elementalTypeId: .[0].elementalTypeId,id: .[0].id,name: .[1].name,unlock_stage: .[1].unlock_stage,level_req: .[1].level_req,picked: 1}]" output4.json> output.json 2>nul
rem Push file output.json to https://jsonblob.com
set /p _urlJson=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_urlJson.txt
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlJson% --ssl-no-revoke >nul 2>nul
rem Filter for equipment if Equipped
%_cd%\batch\jq.exe -r -f %_cd%\data\avatarAddress\filterEQUIPPED2.txt output2.json> _temp.json 2>nul
if %_chuyendoi% == 1 (
	copy _temp.json %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_itemEquip.json>nul
	goto :importTrangBiEquippedEnd
)
if %_chuyendoi% == 2 (
	if %_typeRepeat% == 1 (
	copy _temp.json %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\0.json>nul
	goto :importTrangBiEquippedEnd
	)
	if %_typeRepeat% == 2 (
	copy _temp.json %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\%_sttEquipSet%.json>nul
	goto :importTrangBiEquippedEnd
	)
	if %_typeRepeat% == 3 (
	copy _temp.json %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\888888.json>nul
	goto :importTrangBiEquippedEnd
	)
)
:importTrangBiEquippedEnd
rem Delete the draft file input and output
del /q _temp.json input.json output.json output1.json output2.json output3.json output4.json 2>nul
echo.└──── Successful get equipped ID item(s) ...
timeout 3 >nul
goto :importTrangBi
:importTrangBiWeapon
set "_weapon="
if %_chuyendoi% == 1 (
	cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep
	"%_cd%\batch\jq.exe" -r ".weapon" _itemEquip.json> _weapon.txt & set /p _weapon=<_weapon.txt & del /q _weapon.txt
	goto :importTrangBiWeaponMain
)
if %_chuyendoi% == 2 (
	if %_typeRepeat% == 1 (
	cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment
	"%_cd%\batch\jq.exe" -r ".weapon" 0.json> _weapon.txt & set /p _weapon=<_weapon.txt & del /q _weapon.txt
	goto :importTrangBiWeaponMain
	)
	if %_typeRepeat% == 2 (
	cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment
	"%_cd%\batch\jq.exe" -r ".weapon" %_sttEquipSet%.json> _weapon.txt & set /p _weapon=<_weapon.txt & del /q _weapon.txt
	goto :importTrangBiWeaponMain
	)
	if %_typeRepeat% == 3 (
	cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment
	"%_cd%\batch\jq.exe" -r ".weapon" 888888.json> _weapon.txt & set /p _weapon=<_weapon.txt & del /q _weapon.txt
	goto :importTrangBiWeaponMain
	)
)
:importTrangBiWeaponMain
echo.└── Taking weapon ID item(s) ...
set /p _address=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_address.txt
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_address%\"){inventory{equipments{grade,id,itemSubType,elementalType,equipped,itemId,level,statsMap{aTK,hP,dEF,sPD,hIT,cRI},skills{elementalType,chance,power},stat{value,type}}}}}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output1.json 2>nul
rem Filter the results of data
%_cd%\batch\jq.exe -r -f %_cd%\data\avatarAddress\filterWEAPON.txt output1.json> output2.json 2>nul
%_cd%\batch\jq.exe -r -f %_cd%\data\avatarAddress\filterStageUnlockAndLevelReq.txt output2.json> output3.json 2>nul
%_cd%\batch\jq.exe -r "group_by(.id)|.[]|select(length == 2)" output3.json> output4.json 2>nul
%_cd%\batch\jq.exe -r -s "[.[]|{image: .[0].image,level: .[0].level,elementalType: .[0].elementalType,itemId: .[0].itemId,index: .[0].index,skills: .[0].skills,grade: .[0].grade,equipped: .[0].equipped,stat: .[0].stat,CP: .[0].CP,elementalTypeId: .[0].elementalTypeId,id: .[0].id,name: .[1].name,unlock_stage: .[1].unlock_stage,level_req: .[1].level_req}]" output4.json> output5.json 2>nul
%_cd%\batch\jq.exe -r "[.[]|{image,level,elementalType,itemId,index,skills,grade,equipped,stat,name,unlock_stage,level_req,CP,picked: (if .itemId == \"%_weapon%\" then 1 else 0 end)}]" output5.json> output.json 2>nul
rem Push file output.json to https://jsonblob.com
set /p _urlJson=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_urlJson.txt
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlJson% --ssl-no-revoke >nul 2>nul
rem Delete the draft file input and output
del /q input.json output.json output1.json output2.json output3.json output4.json output5.json 2>nul
:importTrangBiWeapon1
echo.└── Get the current block ...
curl https://api.9cscan.com/transactions?limit=0 --ssl-no-revoke> _9cscanBlock.json 2>nul & set /p _9cscanBlock=<_9cscanBlock.json
del /q _9cscanBlock.json & set /a _9cscanBlock=%_9cscanBlock:~-11,-4%
call :background3
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
	set "_weapon= "
	echo.
	set /p _weapon="Enter the item of equipment: "
	set _weapon=!_weapon: =!
	%_cd%\batch\jq.exe -c "(if (.slot1_block > %_9cscanBlock%) then {itemId: .slot1_item} else empty end),(if (.slot2_block > %_9cscanBlock%) then {itemId: .slot2_item} else empty end),(if (.slot3_block > %_9cscanBlock%) then {itemId: .slot3_item} else empty end),(if (.slot4_block > %_9cscanBlock%) then {itemId: .slot4_item} else empty end)" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingCraft\_infoSlot.json 2>nul| findstr /i !_weapon!>nul
	if !errorlevel! == 0 (
		echo.
		echo Error 1: This equipment may be being craft / upgrade ...
		color 4F
		endlocal
		timeout 5
		goto :importTrangBiWeapon1
		)
	if %_chuyendoi% == 1 (
		cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\
		%_cd%\batch\jq.exe "{weapon: \"!_weapon!\",armor,belt,necklace,ring1,ring2}" _itemEquip.json> _temp.json
		copy _temp.json _itemEquip.json>nul
		goto :importTrangBiWeaponEnd
	)
	if %_chuyendoi% == 2 (
		if %_typeRepeat% == 1 (
			cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\
			%_cd%\batch\jq.exe "{weapon: \"!_weapon!\",armor,belt,necklace,ring1,ring2}" 0.json> _temp.json
			copy _temp.json 0.json>nul
			goto :importTrangBiWeaponEnd
			)
		if %_typeRepeat% == 2 (
			cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\
			%_cd%\batch\jq.exe "{weapon: \"!_weapon!\",armor,belt,necklace,ring1,ring2}" %_sttEquipSet%.json> _temp.json
			copy _temp.json %_sttEquipSet%.json>nul
			goto :importTrangBiWeaponEnd
			)
		if %_typeRepeat% == 3 (
			cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\
			%_cd%\batch\jq.exe "{weapon: \"!_weapon!\",armor,belt,necklace,ring1,ring2}" 888888.json> _temp.json
			copy _temp.json 888888.json>nul
			goto :importTrangBiWeaponEnd
			)
	)
)	
:importTrangBiWeaponEnd
del /q _temp.json
endlocal
goto :importTrangBiWeapon
:importTrangBiArmor
set "_armor="
if %_chuyendoi% == 1 (
	cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep
	"%_cd%\batch\jq.exe" -r ".armor" _itemEquip.json> _armor.txt & set /p _armor=<_armor.txt & del /q _armor.txt
	goto :importTrangBiArmorMain
)
if %_chuyendoi% == 2 (
	if %_typeRepeat% == 1 (
	cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment
	"%_cd%\batch\jq.exe" -r ".armor" 0.json> _armor.txt & set /p _armor=<_armor.txt & del /q _armor.txt
	goto :importTrangBiArmorMain
	)
	if %_typeRepeat% == 2 (
	cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment
	"%_cd%\batch\jq.exe" -r ".armor" %_sttEquipSet%.json> _armor.txt & set /p _armor=<_armor.txt & del /q _armor.txt
	goto :importTrangBiArmorMain
	)
	if %_typeRepeat% == 3 (
	cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment
	"%_cd%\batch\jq.exe" -r ".armor" 888888.json> _armor.txt & set /p _armor=<_armor.txt & del /q _armor.txt
	goto :importTrangBiArmorMain
	)
)
:importTrangBiArmorMain
echo.└── Taking armor ID item(s) ...
set /p _address=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_address.txt
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_address%\"){inventory{equipments{grade,id,itemSubType,elementalType,equipped,itemId,level,statsMap{aTK,hP,dEF,sPD,hIT,cRI},skills{elementalType,chance,power},stat{value,type}}}}}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output1.json 2>nul
rem Filter the results of data
%_cd%\batch\jq.exe -r -f %_cd%\data\avatarAddress\filterARMOR.txt output1.json> output2.json 2>nul
%_cd%\batch\jq.exe -r -f %_cd%\data\avatarAddress\filterStageUnlockAndLevelReq.txt output2.json> output3.json 2>nul
%_cd%\batch\jq.exe -r "group_by(.id)|.[]|select(length == 2)" output3.json> output4.json 2>nul
%_cd%\batch\jq.exe -r -s "[.[]|{image: .[0].image,level: .[0].level,elementalType: .[0].elementalType,itemId: .[0].itemId,index: .[0].index,skills: .[0].skills,grade: .[0].grade,equipped: .[0].equipped,stat: .[0].stat,CP: .[0].CP,elementalTypeId: .[0].elementalTypeId,id: .[0].id,name: .[1].name,unlock_stage: .[1].unlock_stage,level_req: .[1].level_req}]" output4.json> output5.json 2>nul
%_cd%\batch\jq.exe -r "[.[]|{image,level,elementalType,itemId,index,skills,grade,equipped,stat,name,unlock_stage,level_req,CP,picked: (if .itemId == \"%_armor%\" then 1 else 0 end)}]" output5.json> output.json 2>nul
rem Push file output.json to https://jsonblob.com
set /p _urlJson=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_urlJson.txt
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlJson% --ssl-no-revoke >nul 2>nul
rem Delete the draft file input and output
del /q input.json output.json output1.json output2.json output3.json output4.json output5.json 2>nul
:importTrangBiArmor1
echo.└── Get the current block ...
curl https://api.9cscan.com/transactions?limit=0 --ssl-no-revoke> _9cscanBlock.json 2>nul & set /p _9cscanBlock=<_9cscanBlock.json
del /q _9cscanBlock.json & set /a _9cscanBlock=%_9cscanBlock:~-11,-4%
call :background3
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
	set "_armor= "
	echo.
	set /p _armor="Enter the item of equipment: "
	set _armor=!_armor: =!
	%_cd%\batch\jq.exe -c "(if (.slot1_block > %_9cscanBlock%) then {itemId: .slot1_item} else empty end),(if (.slot2_block > %_9cscanBlock%) then {itemId: .slot2_item} else empty end),(if (.slot3_block > %_9cscanBlock%) then {itemId: .slot3_item} else empty end),(if (.slot4_block > %_9cscanBlock%) then {itemId: .slot4_item} else empty end)" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingCraft\_infoSlot.json 2>nul| findstr /i !_armor!>nul
	if !errorlevel! == 0 (
		echo.
		echo Error 1: This equipment may be being craft / upgrade ...
		color 4F
		endlocal
		timeout 5
		goto :importTrangBiArmor1
		)
	if %_chuyendoi% == 1 (
		cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\
		%_cd%\batch\jq.exe "{weapon,armor: \"!_armor!\",belt,necklace,ring1,ring2}" _itemEquip.json> _temp.json 2>nul
		copy _temp.json _itemEquip.json>nul
		goto :importTrangBiArmorEnd
	)
	if %_chuyendoi% == 2 (
		if %_typeRepeat% == 1 (
			cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\
			%_cd%\batch\jq.exe "{weapon,armor: \"!_armor!\",belt,necklace,ring1,ring2}" 0.json> _temp.json 2>nul
			copy _temp.json 0.json>nul
			goto :importTrangBiArmorEnd
			)
		if %_typeRepeat% == 2 (
			cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\
			%_cd%\batch\jq.exe "{weapon,armor: \"!_armor!\",belt,necklace,ring1,ring2}" %_sttEquipSet%.json> _temp.json
			copy _temp.json %_sttEquipSet%.json>nul
			goto :importTrangBiArmorEnd
			)
		if %_typeRepeat% == 3 (
			cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\
			%_cd%\batch\jq.exe "{weapon,armor: \"!_armor!\",belt,necklace,ring1,ring2}" 888888.json> _temp.json
			copy _temp.json 888888.json>nul
			goto :importTrangBiArmorEnd
			)
	)
)
:importTrangBiArmorEnd
del /q _temp.json
endlocal
goto :importTrangBiArmor
:importTrangBiBelt
set "_belt="
if %_chuyendoi% == 1 (
	cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep
	"%_cd%\batch\jq.exe" -r ".belt" _itemEquip.json> _belt.txt & set /p _belt=<_belt.txt & del /q _belt.txt
	goto :importTrangBiBeltMain
)
if %_chuyendoi% == 2 (
	if %_typeRepeat% == 1 (
	cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment
	"%_cd%\batch\jq.exe" -r ".belt" 0.json> _belt.txt & set /p _belt=<_belt.txt & del /q _belt.txt
	goto :importTrangBiBeltMain
	)
	if %_typeRepeat% == 2 (
	cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment
	"%_cd%\batch\jq.exe" -r ".belt" %_sttEquipSet%.json> _belt.txt & set /p _belt=<_belt.txt & del /q _belt.txt
	goto :importTrangBiBeltMain
	)
	if %_typeRepeat% == 3 (
	cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment
	"%_cd%\batch\jq.exe" -r ".belt" 888888.json> _belt.txt & set /p _belt=<_belt.txt & del /q _belt.txt
	goto :importTrangBiBeltMain
	)
)
:importTrangBiBeltMain
echo.└── Taking belt ID item(s) ...
set /p _address=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_address.txt
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_address%\"){inventory{equipments{grade,id,itemSubType,elementalType,equipped,itemId,level,statsMap{aTK,hP,dEF,sPD,hIT,cRI},skills{elementalType,chance,power},stat{value,type}}}}}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output1.json 2>nul
%_cd%\batch\jq.exe -r -f %_cd%\data\avatarAddress\filterBELT.txt output1.json> output2.json 2>nul
%_cd%\batch\jq.exe -r -f %_cd%\data\avatarAddress\filterStageUnlockAndLevelReq.txt output2.json> output3.json 2>nul
%_cd%\batch\jq.exe -r "group_by(.id)|.[]|select(length == 2)" output3.json> output4.json 2>nul
%_cd%\batch\jq.exe -r -s "[.[]|{image: .[0].image,level: .[0].level,elementalType: .[0].elementalType,itemId: .[0].itemId,index: .[0].index,skills: .[0].skills,grade: .[0].grade,equipped: .[0].equipped,stat: .[0].stat,CP: .[0].CP,elementalTypeId: .[0].elementalTypeId,id: .[0].id,name: .[1].name,unlock_stage: .[1].unlock_stage,level_req: .[1].level_req}]" output4.json> output5.json 2>nul
%_cd%\batch\jq.exe -r "[.[]|{image,level,elementalType,itemId,index,skills,grade,equipped,stat,name,unlock_stage,level_req,CP,picked: (if .itemId == \"%_belt%\" then 1 else 0 end)}]" output5.json> output.json 2>nul
rem Push file output.json to https://jsonblob.com
set /p _urlJson=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_urlJson.txt
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlJson% --ssl-no-revoke >nul 2>nul
rem Delete the draft file input and output
del /q input.json output.json output1.json output2.json output3.json output4.json output5.json 2>nul
:importTrangBiBelt1
echo.└── Get the current block ...
curl https://api.9cscan.com/transactions?limit=0 --ssl-no-revoke> _9cscanBlock.json 2>nul & set /p _9cscanBlock=<_9cscanBlock.json
del /q _9cscanBlock.json & set /a _9cscanBlock=%_9cscanBlock:~-11,-4%
call :background3
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
	set "_belt= "
	echo.
	set /p _belt="Enter the item of equipment: "
	set _belt=!_belt: =!
	%_cd%\batch\jq.exe -c "(if (.slot1_block > %_9cscanBlock%) then {itemId: .slot1_item} else empty end),(if (.slot2_block > %_9cscanBlock%) then {itemId: .slot2_item} else empty end),(if (.slot3_block > %_9cscanBlock%) then {itemId: .slot3_item} else empty end),(if (.slot4_block > %_9cscanBlock%) then {itemId: .slot4_item} else empty end)" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingCraft\_infoSlot.json 2>nul| findstr /i !_belt!>nul
	if !errorlevel! == 0 (
		echo.
		echo Error 1: This equipment may be being craft / upgrade ...
		color 4F
		endlocal
		timeout 5
		goto :importTrangBiBelt1
		)
	if %_chuyendoi% == 1 (
		cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\
		%_cd%\batch\jq.exe "{weapon,armor,belt: \"!_belt!\",necklace,ring1,ring2}" _itemEquip.json> _temp.json 2>nul
		copy _temp.json _itemEquip.json>nul
		goto :importTrangBiBeltEnd
	)
	if %_chuyendoi% == 2 (
		if %_typeRepeat% == 1 (
			cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\
			%_cd%\batch\jq.exe "{weapon,armor,belt: \"!_belt!\",necklace,ring1,ring2}" 0.json> _temp.json 2>nul
			copy _temp.json 0.json>nul
			goto :importTrangBiBeltEnd
			)
		if %_typeRepeat% == 2 (
			cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\
			%_cd%\batch\jq.exe "{weapon,armor,belt: \"!_belt!\",necklace,ring1,ring2}" %_sttEquipSet%.json> _temp.json
			copy _temp.json %_sttEquipSet%.json>nul
			goto :importTrangBiBeltEnd
			)
		if %_typeRepeat% == 3 (
			cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\
			%_cd%\batch\jq.exe "{weapon,armor,belt: \"!_belt!\",necklace,ring1,ring2}" 888888.json> _temp.json
			copy _temp.json 888888.json>nul
			goto :importTrangBiBeltEnd
			)
	)
)
:importTrangBiBeltEnd
del /q _temp.json
endlocal
goto :importTrangBiBelt
:importTrangBiNecklace
set "_necklace="
if %_chuyendoi% == 1 (
	cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep
	"%_cd%\batch\jq.exe" -r ".necklace" _itemEquip.json> _necklace.txt & set /p _necklace=<_necklace.txt & del /q _necklace.txt
	goto :importTrangBiNecklaceMain
)
if %_chuyendoi% == 2 (
	if %_typeRepeat% == 1 (
	cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment
	"%_cd%\batch\jq.exe" -r ".necklace" 0.json> _necklace.txt & set /p _necklace=<_necklace.txt & del /q _necklace.txt
	goto :importTrangBiNecklaceMain
	)
	if %_typeRepeat% == 2 (
	cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment
	"%_cd%\batch\jq.exe" -r ".necklace" %_sttEquipSet%.json> _necklace.txt & set /p _necklace=<_necklace.txt & del /q _necklace.txt
	goto :importTrangBiNecklaceMain
	)
	if %_typeRepeat% == 3 (
	cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment
	"%_cd%\batch\jq.exe" -r ".necklace" 888888.json> _necklace.txt & set /p _necklace=<_necklace.txt & del /q _necklace.txt
	goto :importTrangBiNecklaceMain
	)
)
:importTrangBiNecklaceMain
echo.└── Taking necklace ID item(s) ...
set /p _address=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_address.txt
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_address%\"){inventory{equipments{grade,id,itemSubType,elementalType,equipped,itemId,level,statsMap{aTK,hP,dEF,sPD,hIT,cRI},skills{elementalType,chance,power},stat{value,type}}}}}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output1.json 2>nul
rem Filter the results of data
%_cd%\batch\jq.exe -r -f %_cd%\data\avatarAddress\filterNECKLACE.txt output1.json> output2.json 2>nul
%_cd%\batch\jq.exe -r -f %_cd%\data\avatarAddress\filterStageUnlockAndLevelReq.txt output2.json> output3.json 2>nul
%_cd%\batch\jq.exe -r "group_by(.id)|.[]|select(length == 2)" output3.json> output4.json 2>nul
%_cd%\batch\jq.exe -r -s "[.[]|{image: .[0].image,level: .[0].level,elementalType: .[0].elementalType,itemId: .[0].itemId,index: .[0].index,skills: .[0].skills,grade: .[0].grade,equipped: .[0].equipped,stat: .[0].stat,CP: .[0].CP,elementalTypeId: .[0].elementalTypeId,id: .[0].id,name: .[1].name,unlock_stage: .[1].unlock_stage,level_req: .[1].level_req}]" output4.json> output5.json 2>nul
%_cd%\batch\jq.exe -r "[.[]|{image,level,elementalType,itemId,index,skills,grade,equipped,stat,name,unlock_stage,level_req,CP,picked: (if .itemId == \"%_necklace%\" then 1 else 0 end)}]" output5.json> output.json 2>nul
rem Push file output.json to https://jsonblob.com
set /p _urlJson=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_urlJson.txt
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlJson% --ssl-no-revoke >nul 2>nul
rem Delete the draft file input and output
del /q input.json output.json output1.json output2.json output3.json output4.json output5.json 2>nul
:importTrangBiNecklace1
echo.└── Get the current block ...
curl https://api.9cscan.com/transactions?limit=0 --ssl-no-revoke> _9cscanBlock.json 2>nul & set /p _9cscanBlock=<_9cscanBlock.json
del /q _9cscanBlock.json & set /a _9cscanBlock=%_9cscanBlock:~-11,-4%
call :background3
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
	set "_necklace= "
	echo.
	set /p _necklace="Enter the item of equipment: "
	set _necklace=!_necklace: =!
	%_cd%\batch\jq.exe -c "(if (.slot1_block > %_9cscanBlock%) then {itemId: .slot1_item} else empty end),(if (.slot2_block > %_9cscanBlock%) then {itemId: .slot2_item} else empty end),(if (.slot3_block > %_9cscanBlock%) then {itemId: .slot3_item} else empty end),(if (.slot4_block > %_9cscanBlock%) then {itemId: .slot4_item} else empty end)" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingCraft\_infoSlot.json 2>nul| findstr /i !_necklace!>nul
	if !errorlevel! == 0 (
		echo.
		echo Error 1: This equipment may be being craft / upgrade ...
		color 4F
		endlocal
		timeout 5
		goto :importTrangBiNecklace1
		)
	if %_chuyendoi% == 1 (
		cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\
		%_cd%\batch\jq.exe "{weapon,armor,belt,necklace: \"!_necklace!\",ring1,ring2}" _itemEquip.json> _temp.json 2>nul
		copy _temp.json _itemEquip.json>nul
		goto :importTrangBiNecklaceEnd
	)
	if %_chuyendoi% == 2 (
		if %_typeRepeat% == 1 (
			cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\
			%_cd%\batch\jq.exe "{weapon,armor,belt,necklace: \"!_necklace!\",ring1,ring2}" 0.json> _temp.json 2>nul
			copy _temp.json 0.json>nul
			goto :importTrangBiNecklaceEnd
			)
		if %_typeRepeat% == 2 (
			cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\
			%_cd%\batch\jq.exe "{weapon,armor,belt,necklace: \"!_necklace!\",ring1,ring2}" %_sttEquipSet%.json> _temp.json
			copy _temp.json %_sttEquipSet%.json>nul
			goto :importTrangBiNecklaceEnd
			)
		if %_typeRepeat% == 3 (
			cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\
			%_cd%\batch\jq.exe "{weapon,armor,belt,necklace: \"!_necklace!\",ring1,ring2}" 888888.json> _temp.json
			copy _temp.json 888888.json>nul
			goto :importTrangBiNecklaceEnd
			)
	)
)
:importTrangBiNecklaceEnd
del /q _temp.json
endlocal
goto :importTrangBiNecklace
:importTrangBiRing1
set "_ring1=" & set "_ring2="
if %_chuyendoi% == 1 (
	cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep
	"%_cd%\batch\jq.exe" -r ".ring1" _itemEquip.json> _ring1.txt & set /p _ring1=<_ring1.txt & del /q _ring1.txt
	"%_cd%\batch\jq.exe" -r ".ring2" _itemEquip.json> _ring2.txt & set /p _ring2=<_ring2.txt & del /q _ring2.txt
	goto :importTrangBiRing1Main
)
if %_chuyendoi% == 2 (
	if %_typeRepeat% == 1 (
	cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment
	"%_cd%\batch\jq.exe" -r ".ring1" 0.json> _ring1.txt & set /p _ring1=<_ring1.txt & del /q _ring1.txt
	"%_cd%\batch\jq.exe" -r ".ring2" 0.json> _ring2.txt & set /p _ring2=<_ring2.txt & del /q _ring2.txt
	goto :importTrangBiRing1Main
	)
	if %_typeRepeat% == 2 (
	cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment
	"%_cd%\batch\jq.exe" -r ".ring1" %_sttEquipSet%.json> _ring1.txt & set /p _ring1=<_ring1.txt & del /q _ring1.txt
	"%_cd%\batch\jq.exe" -r ".ring2" %_sttEquipSet%.json> _ring2.txt & set /p _ring2=<_ring2.txt & del /q _ring2.txt
	goto :importTrangBiRing1Main
	)
	if %_typeRepeat% == 3 (
	cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment
	"%_cd%\batch\jq.exe" -r ".ring1" 888888.json> _ring1.txt & set /p _ring1=<_ring1.txt & del /q _ring1.txt
	"%_cd%\batch\jq.exe" -r ".ring2" 888888.json> _ring2.txt & set /p _ring2=<_ring2.txt & del /q _ring2.txt
	goto :importTrangBiRing1Main
	)
)
:importTrangBiRing1Main
echo.└── Taking ring1 ID item(s) ...
set /p _address=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_address.txt
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_address%\"){inventory{equipments{grade,id,itemSubType,elementalType,equipped,itemId,level,statsMap{aTK,hP,dEF,sPD,hIT,cRI},skills{elementalType,chance,power},stat{value,type}}}}}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output1.json 2>nul
rem Filter the results of data
%_cd%\batch\jq.exe -r -f %_cd%\data\avatarAddress\filterRING.txt output1.json> output2.json 2>nul
%_cd%\batch\jq.exe -r -f %_cd%\data\avatarAddress\filterStageUnlockAndLevelReq.txt output2.json> output3.json 2>nul
%_cd%\batch\jq.exe -r "group_by(.id)|.[]|select(length == 2)" output3.json> output4.json 2>nul
%_cd%\batch\jq.exe -r -s "[.[]|{image: .[0].image,level: .[0].level,elementalType: .[0].elementalType,itemId: .[0].itemId,index: .[0].index,skills: .[0].skills,grade: .[0].grade,equipped: .[0].equipped,stat: .[0].stat,CP: .[0].CP,elementalTypeId: .[0].elementalTypeId,id: .[0].id,name: .[1].name,unlock_stage: .[1].unlock_stage,level_req: .[1].level_req}]" output4.json> output5.json 2>nul
%_cd%\batch\jq.exe -r "[.[]|{image,level,elementalType,itemId,index,skills,grade,equipped,stat,name,unlock_stage,level_req,CP,picked: (if .itemId == \"%_ring1%\" then 1 elif .itemId == \"%_ring2%\" then 1 else 0 end)}]" output5.json> output.json 2>nul
rem Push file output.json to https://jsonblob.com
set /p _urlJson=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_urlJson.txt
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlJson% --ssl-no-revoke >nul 2>nul
rem Delete the draft file input and output
del /q input.json output.json output1.json output2.json output3.json output4.json output5.json 2>nul
:importTrangBiRing11
echo.└── Get the current block ...
curl https://api.9cscan.com/transactions?limit=0 --ssl-no-revoke> _9cscanBlock.json 2>nul & set /p _9cscanBlock=<_9cscanBlock.json
del /q _9cscanBlock.json & set /a _9cscanBlock=%_9cscanBlock:~-11,-4%
call :background3
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
set "_ring1= "
echo.
set /p _ring1="Enter the item of equipment: "
set _ring1=!_ring1: =!
%_cd%\batch\jq.exe -c "(if (.slot1_block > %_9cscanBlock%) then {itemId: .slot1_item} else empty end),(if (.slot2_block > %_9cscanBlock%) then {itemId: .slot2_item} else empty end),(if (.slot3_block > %_9cscanBlock%) then {itemId: .slot3_item} else empty end),(if (.slot4_block > %_9cscanBlock%) then {itemId: .slot4_item} else empty end)" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingCraft\_infoSlot.json 2>nul| findstr /i !_ring1!>nul
if !errorlevel! == 0 (
	echo.
	echo Error 1: This equipment may be being craft / upgrade ...
	color 4F
	endlocal
	timeout 5
	goto :importTrangBiRing12
	)
if "!_ring1!" equ "!_ring2!" (
	if not "!_ring1!" equ "" (
		echo.
		echo Error 1.1: Ring1 coincides with Ring2 ...
		color 4F
		endlocal
		timeout 5
		goto :importTrangBiRing11
		)
	)
if %_chuyendoi% == 1 (
	cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\
	%_cd%\batch\jq.exe "{weapon,armor,belt,necklace,ring1: \"!_ring1!\",ring2}" _itemEquip.json> _temp.json 2>nul
	copy _temp.json _itemEquip.json>nul
	goto :importTrangBiRing1End
)
if %_chuyendoi% == 2 (
	if %_typeRepeat% == 1 (
		cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\
		%_cd%\batch\jq.exe "{weapon,armor,belt,necklace,ring1: \"!_ring1!\",ring2}" 0.json> _temp.json
		copy _temp.json 0.json>nul
		goto :importTrangBiRing1End
		)
	if %_typeRepeat% == 2 (
		cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\
		%_cd%\batch\jq.exe "{weapon,armor,belt,necklace,ring1: \"!_ring1!\",ring2}" %_sttEquipSet%.json> _temp.json
		copy _temp.json %_sttEquipSet%.json>nul
		goto :importTrangBiRing1End
		)
	if %_typeRepeat% == 3 (
		cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\
		%_cd%\batch\jq.exe "{weapon,armor,belt,necklace,ring1: \"!_ring1!\",ring2}" 888888.json> _temp.json
		copy _temp.json %_sttEquipSet%.json>nul
		goto :importTrangBiRing1End
		)
)
:importTrangBiRing1End
del /q _temp.json
endlocal
goto :importTrangBiRing1
:importTrangBiRing2
if %_chuyendoi% == 1 (
	cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep
	"%_cd%\batch\jq.exe" -r ".ring1" _itemEquip.json> _ring1.txt & set /p _ring1=<_ring1.txt & del /q _ring1.txt
	"%_cd%\batch\jq.exe" -r ".ring2" _itemEquip.json> _ring2.txt & set /p _ring2=<_ring2.txt & del /q _ring2.txt
	goto :importTrangBiRing2Main
)
if %_chuyendoi% == 2 (
	if %_typeRepeat% == 1 (
	cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment
	"%_cd%\batch\jq.exe" -r ".ring1" 0.json> _ring1.txt & set /p _ring1=<_ring1.txt & del /q _ring1.txt
	"%_cd%\batch\jq.exe" -r ".ring2" 0.json> _ring2.txt & set /p _ring2=<_ring2.txt & del /q _ring2.txt
	goto :importTrangBiRing2Main
	)
	if %_typeRepeat% == 2 (
	cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment
	"%_cd%\batch\jq.exe" -r ".ring1" %_sttEquipSet%.json> _ring1.txt & set /p _ring1=<_ring1.txt & del /q _ring1.txt
	"%_cd%\batch\jq.exe" -r ".ring2" %_sttEquipSet%.json> _ring2.txt & set /p _ring2=<_ring2.txt & del /q _ring2.txt
	goto :importTrangBiRing2Main
	)
	if %_typeRepeat% == 3 (
	cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment
	"%_cd%\batch\jq.exe" -r ".ring1" 888888.json> _ring1.txt & set /p _ring1=<_ring1.txt & del /q _ring1.txt
	"%_cd%\batch\jq.exe" -r ".ring2" 888888.json> _ring2.txt & set /p _ring2=<_ring2.txt & del /q _ring2.txt
	goto :importTrangBiRing2Main
	)
)
:importTrangBiRing2Main
echo.└── Taking ring2 ID item(s) ...
set /p _address=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_address.txt
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_address%\"){inventory{equipments{grade,id,itemSubType,elementalType,equipped,itemId,level,statsMap{aTK,hP,dEF,sPD,hIT,cRI},skills{elementalType,chance,power},stat{value,type}}}}}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output1.json 2>nul
rem Filter the results of data
%_cd%\batch\jq.exe -r -f %_cd%\data\avatarAddress\filterRING.txt output1.json> output2.json 2>nul
%_cd%\batch\jq.exe -r -f %_cd%\data\avatarAddress\filterStageUnlockAndLevelReq.txt output2.json> output3.json 2>nul
%_cd%\batch\jq.exe -r "group_by(.id)|.[]|select(length == 2)" output3.json> output4.json 2>nul
%_cd%\batch\jq.exe -r -s "[.[]|{image: .[0].image,level: .[0].level,elementalType: .[0].elementalType,itemId: .[0].itemId,index: .[0].index,skills: .[0].skills,grade: .[0].grade,equipped: .[0].equipped,stat: .[0].stat,CP: .[0].CP,elementalTypeId: .[0].elementalTypeId,id: .[0].id,name: .[1].name,unlock_stage: .[1].unlock_stage,level_req: .[1].level_req}]" output4.json> output5.json 2>nul
%_cd%\batch\jq.exe -r "[.[]|{image,level,elementalType,itemId,index,skills,grade,equipped,stat,name,unlock_stage,level_req,CP,picked: (if .itemId == \"%_ring1%\" then 1 elif .itemId == \"%_ring2%\" then 1 else 0 end)}]" output5.json> output.json 2>nul
rem Push file output.json to https://jsonblob.com
set /p _urlJson=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_urlJson.txt
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlJson% --ssl-no-revoke >nul 2>nul
rem Delete the draft file input and output
del /q input.json output.json output1.json output2.json output3.json output4.json output5.json 2>nul
:importTrangBiRing21
echo.└── Get the current block ...
curl https://api.9cscan.com/transactions?limit=0 --ssl-no-revoke> _9cscanBlock.json 2>nul & set /p _9cscanBlock=<_9cscanBlock.json
del /q _9cscanBlock.json & set /a _9cscanBlock=%_9cscanBlock:~-11,-4%
call :background3
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
set "_ring2= "
echo.
set /p _ring2="Enter the item of equipment: "
set _ring2=!_ring2: =!
%_cd%\batch\jq.exe -c "(if (.slot1_block > %_9cscanBlock%) then {itemId: .slot1_item} else empty end),(if (.slot2_block > %_9cscanBlock%) then {itemId: .slot2_item} else empty end),(if (.slot3_block > %_9cscanBlock%) then {itemId: .slot3_item} else empty end),(if (.slot4_block > %_9cscanBlock%) then {itemId: .slot4_item} else empty end)" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingCraft\_infoSlot.json 2>nul| findstr /i !_ring2!>nul
if !errorlevel! == 0 (
	echo.
	echo Error 1: This equipment may be being craft / upgrade ...
	color 4F
	endlocal
	timeout 5
	goto :importTrangBiRing12
	)
if "!_ring2!" equ "%_ring1%" (
	if not "!_ring2!" equ "" (
		echo.
		echo Error 1.2: Ring2 coincides with Ring1 ...
		color 4F
		endlocal
		timeout 5
		goto :importTrangBiRing21
		)
	)
if %_chuyendoi% == 1 (
	cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\
	%_cd%\batch\jq.exe "{weapon,armor,belt,necklace,ring1,ring2: \"!_ring2!\"}" _itemEquip.json> _temp.json 2>nul
	copy _temp.json _itemEquip.json>nul
	goto :importTrangBiRing2End
)
if %_chuyendoi% == 2 (
	if %_typeRepeat% == 1 (
		cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\
		%_cd%\batch\jq.exe "{weapon,armor,belt,necklace,ring1,ring2: \"!_ring2!\"}" 0.json> _temp.json 2>nul
		copy _temp.json 0.json>nul
		goto :importTrangBiRing2End
		)
	if %_typeRepeat% == 2 (
		cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\
		%_cd%\batch\jq.exe "{weapon,armor,belt,necklace,ring1,ring2: \"!_ring2!\"}" %_sttEquipSet%.json> _temp.json
		copy _temp.json %_sttEquipSet%.json>nul
		goto :importTrangBiRing2End
		)
	if %_typeRepeat% == 3 (
		cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\
		%_cd%\batch\jq.exe "{weapon,armor,belt,necklace,ring1,ring2: \"!_ring2!\"}" 888888.json> _temp.json
		copy _temp.json 888888.json>nul
		goto :importTrangBiRing2End
		)
)
:importTrangBiRing2End
del /q _temp.json
endlocal
goto :importTrangBiRing2
:hdsd
mode con:cols=60 lines=36
call :background
echo.[40;92mAuto Refill AP?[40;96m
echo.─── Link tutorial: ...
echo.
echo.[40;92mAuto Sweep?[40;96m
echo.─── Link tutorial: ...
echo.
echo.[40;92mAuto Repeat?[40;96m
echo.─── Link tutorial: ...
echo.
echo.[40;92mAuto open World?[40;96m
echo.─── Link tutorial: ...
echo.
echo.[40;92mAuto use AP potion?[40;96m
echo.─── Link tutorial: ...
echo.==========
echo.
echo.[40;92mWhat is Premium code?[40;96m
echo.─── Link tutorial: ...
echo.
echo.[40;92mUse until?[40;96m
echo.─── Link tutorial: ...
echo.
echo.==========
echo.
echo.Contact me!
echo.
echo.[1] Discord tanbt#9827
echo.[2] Telegram @tandotbt
echo.[3] Discord Plantarium - #unofficial-mods
echo.[4] Youtube tanbt
echo.[5] Web gitbook User guide
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
:autoRepeatOnOffAll
if %_autoRepeatOnOffAll% == 0 (set /a _autoRepeatOnOffAll=1) else (set /a _autoRepeatOnOffAll=0)
goto :gotoClimbingChilling1
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
"%_cd%\batch\jq" -r "..|.publicKey?|select(.)" %_cd%\user\trackedAvatar\%_folderVi%\auto\output.json> %_cd%\user\trackedAvatar\%_folderVi%\auto\publickey\_publickey.txt 2>nul
set /p _publickey=<%_cd%\user\trackedAvatar\%_folderVi%\auto\publickey\_publickey.txt
del /q %_cd%\user\trackedAvatar\%_folderVi%\auto\output.json
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
cd %_cd%\user\trackedAvatar\%_folderVi%
echo {"vi":"%_vi%"}> _vi.json
"%_cd%\batch\jq.exe" -r ".vi|ascii_downcase" _vi.json> _viLowcase.txt 2>nul & set /p _viLowcase=<_viLowcase.txt
del /q _vi.json & del /q _viLowcase.txt
curl --ssl-no-revoke --header "Content-Type: application/json" https://api.tanvpn.tk/donater?vi=%_viLowcase%> _KtraDonater.json 2>nul
findstr /i %_viLowcase% _KtraDonater.json>nul
if %errorlevel%==1 (set /a _HanSuDung=0 & goto :premium1)
"%_cd%\batch\jq.exe" -r ".[].block-%_9cscanBlock%" _KtraDonater.json> _HanSuDung.txt 2>nul
set /p _HanSuDung=<_HanSuDung.txt & del /q _HanSuDung.txt & del /q _KtraDonater.json
set /a _premiumTXOK=1
:premium1
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
"%_cd%\batch\jq.exe" -r ".[].block-%_9cscanBlock%" _KtraDonater.json> _HanSuDung.txt 2>nul
set /p _HanSuDung=<_HanSuDung.txt & del /q _HanSuDung.txt & del /q _KtraDonater.json
set /a _premiumTXOK=1
goto :settingAuto
:_NCGbuyi
rem Find the number of NCG in Premium Code
if %_NCGbuyi%==8 echo %*> _NCGticker.txt 2>nul
if %_NCGbuyi%==10 echo %*> _NCGbuy.txt 2>nul & set /p _NCGbuy=<_NCGbuy.txt & set /a _NCGbuy=%_NCGbuy:~0,-2% & del /q _NCGbuy.txt
set /a _NCGbuyi+=1
exit /b
:autoRefillAP
echo.└── Start Auto Refill AP character: %_name% ...
rem Create data saving folders
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\autoRefillAP"
if exist %_folder% (rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\autoRefillAP)
md %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\autoRefillAP
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\autoRefillAP
copy "%_cd%\batch\jq.exe" "jq.exe"> nul
echo off
rem Check whether the previous transactions are successful or not
echo ==========
echo Step 0: Check previous Sweep transactions
curl https://api.9cscan.com/accounts/%_vi%/transactions?action=daily_reward6^&limit=6 --ssl-no-revoke 2>nul|jq -r ".transactions|.[].id"> _idCheckStatus.txt 2>nul
set "_idCheckStatus="
for /f "tokens=*" %%a in (_idCheckStatus.txt) do (curl https://api.9cscan.com/transactions/%%a/status --ssl-no-revoke)
echo.
curl https://api.9cscan.com/accounts/%_vi%/transactions?action=daily_reward6^&limit=6 --ssl-no-revoke 2>nul | jq -r ".transactions|.[].status" | findstr -i success>nul
if %errorlevel% equ 1 (color 4F & echo.└── Error 1: No SUCCESS transaction found & echo.─── wait 10 minutes and try again, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto:eof)
echo.└──── Complete step 0
rem Send your information to my server
echo ==========
echo Step 1: Get unsignedTransaction
echo {"vi":"%_vi%","publicKey":"%_publickey%","char":"%_address%","stt":%_charCount%,"premiumTX":"%_premiumTX%"}> input.json 2>nul
curl -X POST -H "accept: application/json" -H "Content-Type: application/json" --data "@input.json" https://api.tanvpn.tk/refillAP --ssl-no-revoke --location> output.json 2>nul
findstr /i Micro output.json> nul
if %errorlevel% equ 0 (echo.└── Error 0.1: Server timeout & echo.─── wait 10 seconds after trying again, ... & %_cd%\data\flashError.exe & timeout /t 10 /nobreak & echo.└──── Updating ... & goto:eof)
findstr /i kqua output.json> nul
if %errorlevel% equ 1 (color 4F & echo.└── Error 0: Unknown error & echo.─── wait 10 minutes and try again, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto:eof)
jq -r ".checkqua" output.json> _checkqua.txt 2>nul & set /p _checkqua=<_checkqua.txt
jq -r ".kqua" output.json> _kqua.txt 2>nul & set /p _kqua=<_kqua.txt
if %_checkqua% == 0 (echo.└── %_kqua%, ... & echo.─── wait 10 minutes after trying again, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto:eof)
echo.└──── Get unsignedTransaction successful
echo ==========
echo Step 2: Get Signature
rem Create Action File
call certutil -decodehex _kqua.txt action >nul
echo.└── Using the previously saved password ...
"%_cd%\planet\planet" key sign --passphrase %_PASSWORD% --store-path %_cd%\user\utc %_KeyID% action> _signature.txt 2>nul
goto :KTraSignature1
:KTraSignature1
set "_signature="
set /p _signature=<_signature.txt
if [%_signature%] == [] (echo.└──── Error 1: The password saved incorrect, ... & echo.─── wait 10 minutes and try again, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto:eof)
echo.└──── Get Signature successful
echo ==========
echo Step 3: Get signTransaction
echo.
echo.[1] Continue refill AP, automatic after 10s
echo.[2] Return menu and turn off Auto
choice /c 12 /n /t 10 /d 1 /m "Enter from the keyboard: "
if %errorlevel%==1 (goto :tieptucAutoRefillAP)
if %errorlevel%==2 (set /a _canAutoOnOff=0 & goto:eof)
:tieptucAutoRefillAP
echo {"query":"query{transaction{signTransaction(unsignedTransaction:\"%_kqua%\",signature:\"%_signature%\")}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json  2>nul
echo.└── Find signTransaction ...
jq -r "..|.signTransaction?|select(.)" output.json> _signTransaction.txt 2>nul
echo.└──── Get signTransaction successful
echo ==========
echo Step 4: Get stageTransaction
echo.
set /p _signTransaction=<_signTransaction.txt
echo {"query":"mutation{stageTransaction(payload:\"%_signTransaction%\")}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json  2>nul
echo.└── Find stageTransaction ...
jq -r "..|.stageTransaction?|select(.)" output.json> _stageTransaction.txt 2>nul
echo.└──── Get stageTransaction successful
set /a _countKtraAuto=0
set /a _countKtraStaging=0
:ktraAutoRefillAP
set /a _countKtraAuto+=1
set /a _countKtraStaging+=1
color 0B
cls
set _temp=       %_9cscanBlock%
echo.╔═══════════════╗   ╔═══════════════╗   ╔═══════════════╗
if %_canAuto%==5 echo ║ID %_vi:~0,7%***	║   ║Block: %_temp:~-7% ║   ║[40;92mCan Auto? [X]	[40;96m║
if not %_canAuto%==5 echo ║ID %_vi:~0,7%***	║   ║Block: %_temp:~-7% ║   ║[40;97mCan Auto? [ ]	[40;96m║
echo.╚═══════════════╝   ╚═══════════════╝   ╚═══════════════╝
echo ==========
echo Step 5: Checking auto Refill AP character: %_name%
echo.─── Check %_countKtraStaging% time(s)
if %_countKtraStaging% gtr 50 (color 8F & echo.─── Status: Auto Refill AP failure & echo.─── the cause is node broken & echo.─── use node 1 and try again ... & %_cd%\data\flashError.exe & set /a _node=1 & timeout /t 20 /nobreak & echo.└──── Updating ... & goto:eof)
set /p _stageTransaction=<_stageTransaction.txt
echo {"query":"query{transaction{transactionResult(txId:\"%_stageTransaction%\"){txStatus}}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json 2>nul
echo.└── Find txStatus ...
jq -r "..|.txStatus?|select(.)" output.json> _txStatus.txt 2>nul
set /p _txStatus=<_txStatus.txt
if "%_txStatus%" == "STAGING" (color 0B & echo.─── Status: Auto Refill AP happenning & echo.─── check again after 15s ... & set /a _countKtraAuto=0 & timeout /t 15 /nobreak>nul & goto :ktraAutoRefillAP)
if "%_txStatus%" == "FAILURE" (color 4F & echo.─── Status: Auto Refill AP failure & echo.─── wait 10 minutes after trying again & echo.───  auto Refill AP, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto:eof)
if "%_txStatus%" == "INVALID" (if %_countKtraAuto% lss 4 (color 8F & echo.─── Status: Auto Refill AP temporary failure & echo.─── check again %_countKtraAuto% times after 15s ... & timeout /t 15 /nobreak>nul & goto :ktraAutoRefillAP))
if "%_txStatus%" == "INVALID" (if %_countKtraAuto% geq 4 (color 8F & echo.─── Status: Auto Refill AP failure & echo.─── wait 10 minutes after try again auto Refill AP, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto:eof))
if "%_txStatus%" == "SUCCESS" (color 2F & echo.─── Status: Auto Refill AP successful & echo.─── return menu ... & timeout /t 20 /nobreak & echo.└──── Updating ... & goto:eof)
if %_countKtraAuto% lss 4 (color 4F & echo.─── Error 2.1: Unknown error & echo.─── check again %_countKtraAuto% times after 15s ... & timeout /t 15 /nobreak>nul & goto :ktraAutoRefillAP)
if %_countKtraAuto% geq 4 (color 4F & echo.─── Error 2.2: Unknown error & echo.─── wait 10 minutes after try again auto Refill AP, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto:eof)
goto:eof
:autoSweep
echo.└── Start Auto Sweep Character: %_name% ...
rem Create data saving folders
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\autoSweep"
if exist %_folder% (rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\autoSweep)
md %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\autoSweep
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\autoSweep
copy "%_cd%\batch\jq.exe" "jq.exe"> nul
jq --compact-output "[.weapon,.armor,.belt,.necklace,.ring1,.ring2]" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_itemEquip.json> _itemIDList.json 2>nul
set /p _itemIDList=<_itemIDList.json
echo off
rem Check whether the previous transactions are successful or not
echo ==========
echo Step 0: Check previous Sweep transactions
curl https://api.9cscan.com/accounts/%_vi%/transactions?action=hack_and_slash_sweep8^&limit=6 --ssl-no-revoke 2>nul|jq -r ".transactions|.[].id"> _idCheckStatus.txt 2>nul
set "_idCheckStatus="
for /f "tokens=*" %%a in (_idCheckStatus.txt) do (curl https://api.9cscan.com/transactions/%%a/status --ssl-no-revoke)
echo.
curl https://api.9cscan.com/accounts/%_vi%/transactions?action=hack_and_slash_sweep8^&limit=6 --ssl-no-revoke 2>nul | jq -r ".transactions|.[].status" | findstr -i success>nul
if %errorlevel% equ 1 (color 4F & echo.└── Error 1: No SUCCESS transaction found & echo.─── wait 10 minutes and try again, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto:eof)
echo.└──── Complete step 0
rem Send your information to my server
echo ==========
echo Step 1: Get unsignedTransaction
set "_temp="
set /a _temp=%_stageSweepOrRepeat%
if %_stageSweepOrRepeat% == 0 (set /a _temp=%_stage% 2>nul)
if %_temp% leq 50 (echo 1 > _world.txt 2>nul)
if %_temp% leq 100 (if %_temp% geq 51 (echo 2 > _world.txt 2>nul))
if %_temp% leq 150 (if %_temp% geq 101 (echo 3 > _world.txt 2>nul))
if %_temp% leq 200 (if %_temp% geq 151 (echo 4 > _world.txt 2>nul))
if %_temp% leq 250 (if %_temp% geq 201 (echo 5 > _world.txt 2>nul))
if %_temp% leq 300 (if %_temp% geq 251 (echo 6 > _world.txt 2>nul))
if %_temp% leq 350 (if %_temp% geq 301 (echo 7 > _world.txt 2>nul))
set /p _world=<_world.txt
echo {"vi":"%_vi%","publicKey":"%_publickey%","char":"%_address%","stt":%_charCount%,"premiumTX":"%_premiumTX%","world": "%_world%","stageSweep": "%_temp%","howManyAP": "%_howManyAP%","itemIDList": %_itemIDList%}> input.json 2>nul
curl -X POST -H "accept: application/json" -H "Content-Type: application/json" --data "@input.json" https://api.tanvpn.tk/autoSweep --ssl-no-revoke --location> output.json 2>nul
findstr /i Micro output.json> nul
if %errorlevel% equ 0 (echo.└── Error 0.1: Server timeout & echo.─── wait 10 seconds after trying again, ... & %_cd%\data\flashError.exe & timeout /t 10 /nobreak & echo.└──── Updating ... & goto:eof)
findstr /i kqua output.json> nul
if %errorlevel% equ 1 (color 4F & echo.└── Error 0: Unknown error & echo.─── wait 10 minutes and try again, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto:eof)
jq -r ".checkqua" output.json> _checkqua.txt 2>nul & set /p _checkqua=<_checkqua.txt
jq -r ".kqua" output.json> _kqua.txt 2>nul
rem Get the value exceeds 1024 characters
for %%A in (_kqua.txt) do for /f "usebackq delims=" %%B in ("%%A") do (
  set "_kqua=%%B"
  goto :autoSweep1
)
:autoSweep1
if %_checkqua% == 0 (echo.└── %_kqua%, ... & echo.─── wait 10 minutes after trying again, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto:eof)
echo.└──── Get unsignedTransaction successful
echo ==========
echo Step 2: Get Signature
rem Create Action File
call certutil -decodehex _kqua.txt action >nul
echo.└── Using the previously saved password ...
"%_cd%\planet\planet" key sign --passphrase %_PASSWORD% --store-path %_cd%\user\utc %_KeyID% action> _signature.txt 2>nul
goto :KTraSignature2
:KTraSignature2
set "_signature="
rem Get the value exceeds 1024 characters
for %%A in (_signature.txt) do for /f "usebackq delims=" %%B in ("%%A") do (
  set "_signature=%%B"
  goto :autoSweep2
)
:autoSweep2
if [%_signature%] == [] (echo.└──── Error 1: The password saved incorrect, ...  & echo.─── wait 10 minutes after trying again, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto:eof)
echo.└──── Get Signature successful
echo ==========
echo Step 3: Get signTransaction
echo.
echo.[1] Continue sweep, automatic after 10s
echo.[2] Return menu and turn off Auto
choice /c 12 /n /t 10 /d 1 /m "Enter from the keyboard: "
if %errorlevel%==1 (goto :tieptucAutoSweep)
if %errorlevel%==2 (set /a _canAutoOnOff=0 & goto:eof)
:tieptucAutoSweep
echo {"query":"query{transaction{signTransaction(unsignedTransaction:\"%_kqua%\",signature:\"%_signature%\")}}"}> input.json 2>nul
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
echo {"query":"mutation{stageTransaction(payload:\"%_signTransaction%\")}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json  2>nul
echo.└── Find stageTransaction ...
jq -r "..|.stageTransaction?|select(.)" output.json> _stageTransaction.txt 2>nul
echo.└──── Get stageTransaction successful
set /a _countKtraAuto=0
set /a _countKtraStaging=0
:ktraAutoSweep
set /a _countKtraAuto+=1
set /a _countKtraStaging+=1
color 0B
cls
set _temp=       %_9cscanBlock%
echo.╔═══════════════╗   ╔═══════════════╗   ╔═══════════════╗
if %_canAuto%==5 echo ║ID %_vi:~0,7%***	║   ║Block: %_temp:~-7% ║   ║[40;92mCan Auto? [X]	[40;96m║
if not %_canAuto%==5 echo ║ID %_vi:~0,7%***	║   ║Block: %_temp:~-7% ║   ║[40;97mCan Auto? [ ]	[40;96m║
echo.╚═══════════════╝   ╚═══════════════╝   ╚═══════════════╝
echo ==========
echo Step 5: Checking auto Sweep character: %_name%
echo.─── Check %_countKtraStaging% time(s)
if %_countKtraStaging% gtr 50 (color 8F & echo.─── Status: Auto Sweep failure & echo.─── the cause is node broken & echo.─── use node 1 and try again ... & %_cd%\data\flashError.exe & set /a _node=1 & timeout /t 20 /nobreak & echo.└──── Updating ... & goto:eof)
set /p _stageTransaction=<_stageTransaction.txt
echo {"query":"query{transaction{transactionResult(txId:\"%_stageTransaction%\"){txStatus}}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json 2>nul
echo.└── Find txStatus ...
jq -r "..|.txStatus?|select(.)" output.json> _txStatus.txt 2>nul
set /p _txStatus=<_txStatus.txt
if "%_txStatus%" == "STAGING" (color 0B & echo.─── Status: Auto Sweep happenning & echo.─── check again after 15s ... & set /a _countKtraAuto=0 & timeout /t 15 /nobreak>nul & goto :ktraAutoSweep)
if "%_txStatus%" == "FAILURE" (color 4F & echo.─── Status: Auto Sweep failure & echo.─── wait 10 minutes after trying again & echo.───  auto Sweep, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto:eof)
if "%_txStatus%" == "INVALID" (if %_countKtraAuto% lss 4 (color 8F & echo.─── Status: Auto Sweep temporary failure & echo.─── check again %_countKtraAuto% times after 15s ... & timeout /t 15 /nobreak>nul & goto :ktraAutoSweep))
if "%_txStatus%" == "INVALID" (if %_countKtraAuto% geq 4 (color 8F & echo.─── Status: Auto Sweep failure & echo.─── wait 10 minutes after trying again, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto:eof))
if "%_txStatus%" == "SUCCESS" (color 2F & echo.─── Status: Auto Sweep successful & echo.─── return menu ... & timeout /t 20 /nobreak & echo.└──── Updating ... & goto:eof)
if %_countKtraAuto% lss 4 (color 4F & echo.─── Error 2.1: Unknown error & echo.─── check again %_countKtraAuto% times after 15s ... & timeout /t 15 /nobreak>nul & goto :ktraAutoSweep)
if %_countKtraAuto% geq 4 (color 4F & echo.─── Error 2.2: Unknown error & echo.─── wait 10 minutes after trying again, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto:eof)
goto:eof
:autoRepeat
echo.└── Start Auto Repeat character: %_name% ...
rem Create data saving folders
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\autoRepeat"
if exist %_folder% (rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\autoRepeat)
md %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\autoRepeat
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\autoRepeat
copy "%_cd%\batch\jq.exe" "jq.exe"> nul
rem Select the repeat type
echo.Picked [40;95mtype %_typeRepeat%[40;96m
echo Type [1]: Fix 1 setup
echo Type [2]: Semi-automatic
echo Type [3]: Automatic
echo.
choice /c 123 /n /t 5 /d %_typeRepeat% /m "Continue to repeat after 5s: "
if %errorlevel% == 1 (set _typeRepeat=1 & goto :autoRepeat1)
if %errorlevel% == 2 (set _typeRepeat=2 & goto :autoRepeat1)
if %errorlevel% == 3 (set _typeRepeat=3 & goto :autoRepeat1)
:autoRepeat1
if %_typeRepeat% == 2 (goto :autoRepeat2)
if %_typeRepeat% == 3 (goto :autoRepeat3)
echo Level character	:	%_level%
echo Picked setup	:	0.json
jq --compact-output "[.weapon,.armor,.belt,.necklace,.ring1,.ring2]" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\0.json> _itemIDList.json 2>nul
goto :autoRepeat4
:autoRepeat2
setlocal enabledelayedexpansion
set max=0
rem Get setup equipment by level
for %%x in (%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\*.json) do (
  set "FileEquipType2=%%~nx"
  if !FileEquipType2! gtr !max! (if !FileEquipType2! leq !_level! (set max=!FileEquipType2!))
)
echo Level character	:	%_level%
echo Picked setup	:	%max%.json
jq --compact-output "[.weapon,.armor,.belt,.necklace,.ring1,.ring2]" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\%max%.json> _itemIDList.json 2>nul
endlocal
goto :autoRepeat4
:autoRepeat3
echo Level character	:	%_level%
echo Picked setup	:	888888.json
echo.└── Get the current block ...
curl https://api.9cscan.com/transactions?limit=0 --ssl-no-revoke> _9cscanBlock.json 2>nul & set /p _9cscanBlock=<_9cscanBlock.json
del /q _9cscanBlock.json & set /a _9cscanBlock=%_9cscanBlock:~-11,-4%
echo {"weapon":"","armor":"","belt":"","necklace":"","ring1":"","ring2":""}> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\888888.json
echo.└── Taking equipment data ...
set /p _address=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_address.txt
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_address%\"){inventory{equipments{grade,id,itemSubType,elementalType,equipped,itemId,level,statsMap{aTK,hP,dEF,sPD,hIT,cRI},skills{elementalType,chance,power},stat{value,type}}}}}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json 2>nul
rem Filter the results of data
echo.───── Choose Weapon ...
%_cd%\batch\jq.exe -r -f %_cd%\data\avatarAddress\filterWEAPON.txt output.json> output11.json 2>nul
%_cd%\batch\jq.exe -r ".[]" output11.json> output12.json 2>nul
%_cd%\batch\jq.exe -c "(if (.slot1_block > %_9cscanBlock%) then {itemId: .slot1_item} else empty end),(if (.slot2_block > %_9cscanBlock%) then {itemId: .slot2_item} else empty end),(if (.slot3_block > %_9cscanBlock%) then {itemId: .slot3_item} else empty end),(if (.slot4_block > %_9cscanBlock%) then {itemId: .slot4_item} else empty end)"  %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json> output13.json 2>nul
type output12.json output13.json> output14.json 2>nul
%_cd%\batch\jq.exe -s "[group_by(.itemId)|.[]|select(length == 1)|.[]|select(length > 1)]" output14.json> output1.json 2>nul
if %_level% leq 19 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output1.json > _weapon.txt 2>nul)
if %_level% leq 39 (if %_level% geq 20 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 2)),(select(.grade == 2)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output1.json > _weapon.txt 2>nul))
if %_level% leq 49 (if %_level% geq 40 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 3)),(select(.grade == 2)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output1.json > _weapon.txt 2>nul))
if %_level% leq 89 (if %_level% geq 50 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 3)),(select(.grade == 2)|select(.elementalTypeId <= 2)),(select(.grade == 3)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output1.json > _weapon.txt 2>nul))
if %_level% leq 99 (if %_level% geq 90 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 2)),(select(.grade == 3)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output1.json > _weapon.txt 2>nul))
if %_level% leq 119 (if %_level% geq 100 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 3)),(select(.grade == 3)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output1.json > _weapon.txt 2>nul))
if %_level% leq 159 (if %_level% geq 120 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 3)),(select(.grade == 3)|select(.elementalTypeId <= 2)),(select(.grade == 3.5)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output1.json > _weapon.txt 2>nul))
if %_level% leq 179 (if %_level% geq 160 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 2)),(select(.grade == 3.5)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output1.json > _weapon.txt 2>nul))
if %_level% leq 189 (if %_level% geq 180 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 3)),(select(.grade == 3.5)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output1.json > _weapon.txt 2>nul))
if %_level% leq 209 (if %_level% geq 190 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 3.5)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output1.json > _weapon.txt 2>nul))
if %_level% leq 219 (if %_level% geq 210 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 3.5)|select(.elementalTypeId <= 3))]|max_by(.CP).itemId|select(.)" output1.json > _weapon.txt 2>nul))
if %_level% leq 239 (if %_level% geq 220 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 3.5)|select(.elementalTypeId <= 4))]|max_by(.CP).itemId|select(.)" output1.json > _weapon.txt 2>nul))
if %_level% leq 249 (if %_level% geq 240 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 3.5)|select(.elementalTypeId <= 4)),(select(.grade == 4)|select(.elementalTypeId = 1))]|max_by(.CP).itemId|select(.)" output1.json > _weapon.txt 2>nul))
if %_level% leq 259 (if %_level% geq 250 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 3.5)|select(.elementalTypeId <= 4)),(select(.grade == 4)|select((.elementalTypeId >= 1)and(.elementalTypeId <= 2)))]|max_by(.CP).itemId|select(.)" output1.json > _weapon.txt 2>nul))
if %_level% leq 269 (if %_level% geq 260 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 3.5)|select(.elementalTypeId <= 4)),(select(.grade == 4)|select((.elementalTypeId >= 1)and(.elementalTypeId <= 3)))]|max_by(.CP).itemId|select(.)" output1.json > _weapon.txt 2>nul))
if %_level% leq 289 (if %_level% geq 270 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 3.5)|select(.elementalTypeId <= 4)),(select(.grade == 4)|select((.elementalTypeId >= 1)and(.elementalTypeId <= 4)))]|max_by(.CP).itemId|select(.)" output1.json > _weapon.txt 2>nul))
if %_level% leq 999 (if %_level% geq 290 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 3.5)|select(.elementalTypeId <= 4)),(select(.grade == 4)|select(.elementalTypeId <= 4))]|max_by(.CP).itemId|select(.)" output1.json > _weapon.txt 2>nul))
set "_weapon= "
set _file=_weapon.txt
if exist %_file% (set /p _weapon=<_weapon.txt)
set _weapon=%_weapon: =%
echo.─────── Selected %_weapon%
%_cd%\batch\jq.exe "{weapon: \"%_weapon%\",armor,belt,necklace,ring1,ring2}" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\888888.json> _temp.json
copy _temp.json %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\888888.json>nul
del /q _temp.json 2>nul

echo.───── Choose Armor ...
%_cd%\batch\jq.exe -r -f %_cd%\data\avatarAddress\filterARMOR.txt output.json> output21.json 2>nul
%_cd%\batch\jq.exe -r ".[]" output21.json> output22.json 2>nul
%_cd%\batch\jq.exe -c "(if (.slot1_block > %_9cscanBlock%) then {itemId: .slot1_item} else empty end),(if (.slot2_block > %_9cscanBlock%) then {itemId: .slot2_item} else empty end),(if (.slot3_block > %_9cscanBlock%) then {itemId: .slot3_item} else empty end),(if (.slot4_block > %_9cscanBlock%) then {itemId: .slot4_item} else empty end)"  %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json> output23.json 2>nul
type output22.json output23.json> output24.json 2>nul
%_cd%\batch\jq.exe -s "[group_by(.itemId)|.[]|select(length == 1)|.[]|select(length > 1)]" output24.json> output2.json 2>nul
if %_level% leq 29 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output2.json > _armor.txt 2>nul)
if %_level% leq 49 (if %_level% geq 30 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 2)),(select(.grade == 2)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output2.json > _armor.txt 2>nul))
if %_level% leq 59 (if %_level% geq 50 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 3)),(select(.grade == 2)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output2.json > _armor.txt 2>nul))
if %_level% leq 99 (if %_level% geq 60 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 3)),(select(.grade == 2)|select(.elementalTypeId <= 2)),(select(.grade == 3)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output2.json > _armor.txt 2>nul))
if %_level% leq 109 (if %_level% geq 100 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 2)),(select(.grade == 3)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output2.json > _armor.txt 2>nul))
if %_level% leq 129 (if %_level% geq 110 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 3)),(select(.grade == 3)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output2.json > _armor.txt 2>nul))
if %_level% leq 169 (if %_level% geq 130 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 3)),(select(.grade == 3)|select(.elementalTypeId <= 2)),(select(.grade == 3.5)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output2.json > _armor.txt 2>nul))
if %_level% leq 189 (if %_level% geq 170 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 2)),(select(.grade == 3.5)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output2.json > _armor.txt 2>nul))
if %_level% leq 199 (if %_level% geq 190 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 3)),(select(.grade == 3.5)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output2.json > _armor.txt 2>nul))
if %_level% leq 219 (if %_level% geq 200 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 3.5)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output2.json > _armor.txt 2>nul))
if %_level% leq 229 (if %_level% geq 220 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 3.5)|select(.elementalTypeId <= 3))]|max_by(.CP).itemId|select(.)" output2.json > _armor.txt 2>nul))
if %_level% leq 244 (if %_level% geq 230 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 3.5)|select(.elementalTypeId <= 4))]|max_by(.CP).itemId|select(.)" output2.json > _armor.txt 2>nul))
if %_level% leq 254 (if %_level% geq 245 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 3.5)|select(.elementalTypeId <= 4)),(select(.grade == 4)|select(.elementalTypeId = 1))]|max_by(.CP).itemId|select(.)" output2.json > _armor.txt 2>nul))
if %_level% leq 264 (if %_level% geq 255 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 3.5)|select(.elementalTypeId <= 4)),(select(.grade == 4)|select((.elementalTypeId >= 1)and(.elementalTypeId <= 2)))]|max_by(.CP).itemId|select(.)" output2.json > _armor.txt 2>nul))
if %_level% leq 272 (if %_level% geq 265 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 3.5)|select(.elementalTypeId <= 4)),(select(.grade == 4)|select((.elementalTypeId >= 1)and(.elementalTypeId <= 3)))]|max_by(.CP).itemId|select(.)" output2.json > _armor.txt 2>nul))
if %_level% leq 284 (if %_level% geq 273 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 3.5)|select(.elementalTypeId <= 4)),(select(.grade == 4)|select((.elementalTypeId >= 1)and(.elementalTypeId <= 4)))]|max_by(.CP).itemId|select(.)" output2.json > _armor.txt 2>nul))
if %_level% leq 999 (if %_level% geq 285 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 3.5)|select(.elementalTypeId <= 4)),(select(.grade == 4)|select(.elementalTypeId <= 4))]|max_by(.CP).itemId|select(.)" output2.json > _armor.txt 2>nul))
set "_armor= "
set _file=_armor.txt
if exist %_file% (set /p _armor=<_armor.txt)
set _armor=%_armor: =%
echo.─────── Selected %_armor%
%_cd%\batch\jq.exe "{weapon,armor: \"%_armor%\",belt,necklace,ring1,ring2}" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\888888.json> _temp.json
copy _temp.json %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\888888.json>nul
del /q _temp.json 2>nul

echo.───── Choose Belt ...
%_cd%\batch\jq.exe -r -f %_cd%\data\avatarAddress\filterBELT.txt output.json> output31.json 2>nul
%_cd%\batch\jq.exe -r ".[]" output31.json> output32.json 2>nul
%_cd%\batch\jq.exe -c "(if (.slot1_block > %_9cscanBlock%) then {itemId: .slot1_item} else empty end),(if (.slot2_block > %_9cscanBlock%) then {itemId: .slot2_item} else empty end),(if (.slot3_block > %_9cscanBlock%) then {itemId: .slot3_item} else empty end),(if (.slot4_block > %_9cscanBlock%) then {itemId: .slot4_item} else empty end)"  %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json> output33.json 2>nul
type output32.json output33.json> output34.json 2>nul
%_cd%\batch\jq.exe -s "[group_by(.itemId)|.[]|select(length == 1)|.[]|select(length > 1)]" output34.json> output3.json 2>nul
if %_level% leq 29 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output3.json > _belt.txt 2>nul)
if %_level% leq 59 (if %_level% geq 30 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 2)),(select(.grade == 2)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output3.json > _belt.txt 2>nul))
if %_level% leq 79 (if %_level% geq 60 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 3)),(select(.grade == 2)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output3.json > _belt.txt 2>nul))
if %_level% leq 119 (if %_level% geq 80 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 3)),(select(.grade == 2)|select(.elementalTypeId <= 2)),(select(.grade == 3)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output3.json > _belt.txt 2>nul))
if %_level% leq 149 (if %_level% geq 120 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 2)),(select(.grade == 3)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output3.json > _belt.txt 2>nul))
if %_level% leq 169 (if %_level% geq 150 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 3)),(select(.grade == 3)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output3.json > _belt.txt 2>nul))
if %_level% leq 179 (if %_level% geq 170 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 3)),(select(.grade == 3)|select(.elementalTypeId <= 2)),(select(.grade == 4)|select(.elementalTypeId <= 0))]|max_by(.CP).itemId|select(.)" output3.json > _belt.txt 2>nul))
if %_level% leq 189 (if %_level% geq 180 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 3)),(select(.grade == 3)|select(.elementalTypeId <= 2)),(select(.grade == 4)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output3.json > _belt.txt 2>nul))
if %_level% leq 199 (if %_level% geq 190 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 2)),(select(.grade == 4)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output3.json > _belt.txt 2>nul))
if %_level% leq 229 (if %_level% geq 200 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 3)),(select(.grade == 4)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output3.json > _belt.txt 2>nul))
if %_level% leq 239 (if %_level% geq 230 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 3)),(select(.grade == 4)|select(.elementalTypeId <= 4))]|max_by(.CP).itemId|select(.)" output3.json > _belt.txt 2>nul))
if %_level% leq 244 (if %_level% geq 240 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 4)|select(.elementalTypeId <= 4))]|max_by(.CP).itemId|select(.)" output3.json > _belt.txt 2>nul))
if %_level% leq 253 (if %_level% geq 245 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 4)|select(.elementalTypeId <= 4)),(select(.grade == 4.5)|select(.elementalTypeId = 1))]|max_by(.CP).itemId|select(.)" output3.json > _belt.txt 2>nul))
if %_level% leq 262 (if %_level% geq 254 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 4)|select(.elementalTypeId <= 4)),(select(.grade == 4.5)|select((.elementalTypeId >= 1)and(.elementalTypeId <= 2)))]|max_by(.CP).itemId|select(.)" output3.json > _belt.txt 2>nul))
if %_level% leq 271 (if %_level% geq 263 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 4)|select(.elementalTypeId <= 4)),(select(.grade == 4.5)|select((.elementalTypeId >= 1)and(.elementalTypeId <= 3)))]|max_by(.CP).itemId|select(.)" output3.json > _belt.txt 2>nul))
if %_level% leq 285 (if %_level% geq 272 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 4)|select(.elementalTypeId <= 4)),(select(.grade == 4.5)|select((.elementalTypeId >= 1)and(.elementalTypeId <= 4)))]|max_by(.CP).itemId|select(.)" output3.json > _belt.txt 2>nul))
if %_level% leq 999 (if %_level% geq 286 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 4)|select(.elementalTypeId <= 4)),(select(.grade == 4.5)|select(.elementalTypeId <= 4))]|max_by(.CP).itemId|select(.)" output3.json > _belt.txt 2>nul))
set "_belt= "
set _file=_belt.txt
if exist %_file% (set /p _belt=<_belt.txt)
set _belt=%_belt: =%
echo.─────── Selected %_belt%
%_cd%\batch\jq.exe "{weapon,armor,belt: \"%_belt%\",necklace,ring1,ring2}" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\888888.json> _temp.json
copy _temp.json %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\888888.json>nul
del /q _temp.json 2>nul

echo.───── Choose Necklace ...
%_cd%\batch\jq.exe -r -f %_cd%\data\avatarAddress\filterNECKLACE.txt output.json> output41.json 2>nul
%_cd%\batch\jq.exe -r ".[]" output41.json> output42.json 2>nul
%_cd%\batch\jq.exe -c "(if (.slot1_block > %_9cscanBlock%) then {itemId: .slot1_item} else empty end),(if (.slot2_block > %_9cscanBlock%) then {itemId: .slot2_item} else empty end),(if (.slot3_block > %_9cscanBlock%) then {itemId: .slot3_item} else empty end),(if (.slot4_block > %_9cscanBlock%) then {itemId: .slot4_item} else empty end)"  %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json> output43.json 2>nul
type output42.json output43.json> output44.json 2>nul
%_cd%\batch\jq.exe -s "[group_by(.itemId)|.[]|select(length == 1)|.[]|select(length > 1)]" output44.json> output4.json 2>nul
if %_level% leq 39 (if %_level% geq 10 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output4.json > _necklace.txt 2>nul))
if %_level% leq 69 (if %_level% geq 40 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 2)),(select(.grade == 2)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output4.json > _necklace.txt 2>nul))
if %_level% leq 89 (if %_level% geq 70 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 3)),(select(.grade == 2)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output4.json > _necklace.txt 2>nul))
if %_level% leq 139 (if %_level% geq 90 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 3)),(select(.grade == 2)|select(.elementalTypeId <= 2)),(select(.grade == 3)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output4.json > _necklace.txt 2>nul))
if %_level% leq 159 (if %_level% geq 140 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 2)),(select(.grade == 3)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output4.json > _necklace.txt 2>nul))
if %_level% leq 189 (if %_level% geq 160 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 3)),(select(.grade == 3)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output4.json > _necklace.txt 2>nul))
if %_level% leq 199 (if %_level% geq 190 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 2))]|max_by(.CP).itemId|select(.)" output4.json > _necklace.txt 2>nul))
if %_level% leq 219 (if %_level% geq 200 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 3))]|max_by(.CP).itemId|select(.)" output4.json > _necklace.txt 2>nul))
if %_level% leq 229 (if %_level% geq 220 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4))]|max_by(.CP).itemId|select(.)" output4.json > _necklace.txt 2>nul))
if %_level% leq 239 (if %_level% geq 230 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 4)|select(.elementalTypeId <= 4))]|max_by(.CP).itemId|select(.)" output4.json > _necklace.txt 2>nul))
if %_level% leq 248 (if %_level% geq 240 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 4)|select(.elementalTypeId <= 4)),(select(.grade == 4.5)|select(.elementalTypeId = 1))]|max_by(.CP).itemId|select(.)" output4.json > _necklace.txt 2>nul))
if %_level% leq 258 (if %_level% geq 249 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 4)|select(.elementalTypeId <= 4)),(select(.grade == 4.5)|select((.elementalTypeId >= 1)and(.elementalTypeId <= 2)))]|max_by(.CP).itemId|select(.)" output4.json > _necklace.txt 2>nul))
if %_level% leq 268 (if %_level% geq 259 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 4)|select(.elementalTypeId <= 4)),(select(.grade == 4.5)|select((.elementalTypeId >= 1)and(.elementalTypeId <= 3)))]|max_by(.CP).itemId|select(.)" output4.json > _necklace.txt 2>nul))
if %_level% leq 282 (if %_level% geq 269 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 4)|select(.elementalTypeId <= 4)),(select(.grade == 4.5)|select((.elementalTypeId >= 1)and(.elementalTypeId <= 4)))]|max_by(.CP).itemId|select(.)" output4.json > _necklace.txt 2>nul))
if %_level% leq 999 (if %_level% geq 283 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 4)|select(.elementalTypeId <= 4)),(select(.grade == 4.5)|select(.elementalTypeId <= 4))]|max_by(.CP).itemId|select(.)" output4.json > _necklace.txt 2>nul))
set "_necklace= "
set _file=_necklace.txt
if exist %_file% (set /p _necklace=<_necklace.txt)
set _necklace=%_necklace: =%
echo.─────── Selected %_necklace%
%_cd%\batch\jq.exe "{weapon,armor,belt,necklace: \"%_necklace%\",ring1,ring2}" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\888888.json> _temp.json
copy _temp.json %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\888888.json>nul
del /q _temp.json 2>nul

echo.───── Choose Ring1 and Ring2 ...
%_cd%\batch\jq.exe -r -f %_cd%\data\avatarAddress\filterRING.txt output.json> output51.json 2>nul
%_cd%\batch\jq.exe -r ".[]" output51.json> output52.json 2>nul
%_cd%\batch\jq.exe -c "(if (.slot1_block > %_9cscanBlock%) then {itemId: .slot1_item} else empty end),(if (.slot2_block > %_9cscanBlock%) then {itemId: .slot2_item} else empty end),(if (.slot3_block > %_9cscanBlock%) then {itemId: .slot3_item} else empty end),(if (.slot4_block > %_9cscanBlock%) then {itemId: .slot4_item} else empty end)"  %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json> output53.json 2>nul
type output52.json output53.json> output54.json 2>nul
%_cd%\batch\jq.exe -s "[group_by(.itemId)|.[]|select(length == 1)|.[]|select(length > 1)]" output54.json> output5.json 2>nul
if %_level% leq 39 (if %_level% geq 13 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 2))]|sort_by(.CP)|reverse|.[0].itemId|select(.)" output5.json > _ring1.txt 2>nul))
if %_level% leq 79 (if %_level% geq 40 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 2)),(select(.grade == 2)|select(.elementalTypeId <= 2))]|sort_by(.CP)|reverse|.[0].itemId|select(.)" output5.json > _ring1.txt 2>nul))
if %_level% leq 109 (if %_level% geq 80 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 3)),(select(.grade == 2)|select(.elementalTypeId <= 2))]|sort_by(.CP)|reverse|.[0].itemId|select(.)" output5.json > _ring1.txt 2>nul))
if %_level% leq 159 (if %_level% geq 110 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 3)),(select(.grade == 2)|select(.elementalTypeId <= 2)),(select(.grade == 3)|select(.elementalTypeId <= 2))]|sort_by(.CP)|reverse|.[0].itemId|select(.)" output5.json > _ring1.txt 2>nul))
if %_level% leq 179 (if %_level% geq 160 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 2)),(select(.grade == 3)|select(.elementalTypeId <= 2))]|sort_by(.CP)|reverse|.[0].itemId|select(.)" output5.json > _ring1.txt 2>nul))
if %_level% leq 189 (if %_level% geq 180 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 3)),(select(.grade == 3)|select(.elementalTypeId <= 2))]|sort_by(.CP)|reverse|.[0].itemId|select(.)" output5.json > _ring1.txt 2>nul))
if %_level% leq 209 (if %_level% geq 190 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 2))]|sort_by(.CP)|reverse|.[0].itemId|select(.)" output5.json > _ring1.txt 2>nul))
if %_level% leq 229 (if %_level% geq 210 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 3))]|sort_by(.CP)|reverse|.[0].itemId|select(.)" output5.json > _ring1.txt 2>nul))
if %_level% leq 241 (if %_level% geq 230 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4))]|sort_by(.CP)|reverse|.[0].itemId|select(.)" output5.json > _ring1.txt 2>nul))
if %_level% leq 251 (if %_level% geq 242 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 4)|select(.elementalTypeId = 1))]|sort_by(.CP)|reverse|.[0].itemId|select(.)" output5.json > _ring1.txt 2>nul))
if %_level% leq 259 (if %_level% geq 252 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 4)|select((.elementalTypeId >= 1)and(.elementalTypeId <= 2)))]|sort_by(.CP)|reverse|.[0].itemId|select(.)" output5.json > _ring1.txt 2>nul))
if %_level% leq 269 (if %_level% geq 260 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 4)|select((.elementalTypeId >= 1)and(.elementalTypeId <= 3)))]|sort_by(.CP)|reverse|.[0].itemId|select(.)" output5.json > _ring1.txt 2>nul))
if %_level% leq 287 (if %_level% geq 270 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 4)|select((.elementalTypeId >= 1)and(.elementalTypeId <= 4)))]|sort_by(.CP)|reverse|.[0].itemId|select(.)" output5.json > _ring1.txt 2>nul))
if %_level% leq 999 (if %_level% geq 288 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 4)|select(.elementalTypeId <= 4))]|sort_by(.CP)|reverse|.[0].itemId|select(.)" output5.json > _ring1.txt 2>nul))

if %_level% leq 79 (if %_level% geq 46 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 2)),(select(.grade == 2)|select(.elementalTypeId <= 2))]|sort_by(.CP)|reverse|.[1].itemId|select(.)" output5.json > _ring2.txt 2>nul))
if %_level% leq 109 (if %_level% geq 80 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 3)),(select(.grade == 2)|select(.elementalTypeId <= 2))]|sort_by(.CP)|reverse|.[1].itemId|select(.)" output5.json > _ring2.txt 2>nul))
if %_level% leq 159 (if %_level% geq 110 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 3)),(select(.grade == 2)|select(.elementalTypeId <= 2)),(select(.grade == 3)|select(.elementalTypeId <= 2))]|sort_by(.CP)|reverse|.[1].itemId|select(.)" output5.json > _ring2.txt 2>nul))
if %_level% leq 179 (if %_level% geq 160 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 2)),(select(.grade == 3)|select(.elementalTypeId <= 2))]|sort_by(.CP)|reverse|.[1].itemId|select(.)" output5.json > _ring2.txt 2>nul))
if %_level% leq 189 (if %_level% geq 180 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 3)),(select(.grade == 3)|select(.elementalTypeId <= 2))]|sort_by(.CP)|reverse|.[1].itemId|select(.)" output5.json > _ring2.txt 2>nul))
if %_level% leq 209 (if %_level% geq 190 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 2))]|sort_by(.CP)|reverse|.[1].itemId|select(.)" output5.json > _ring2.txt 2>nul))
if %_level% leq 229 (if %_level% geq 210 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 3))]|sort_by(.CP)|reverse|.[1].itemId|select(.)" output5.json > _ring2.txt 2>nul))
if %_level% leq 241 (if %_level% geq 230 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4))]|sort_by(.CP)|reverse|.[1].itemId|select(.)" output5.json > _ring2.txt 2>nul))
if %_level% leq 251 (if %_level% geq 242 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 4)|select(.elementalTypeId = 1))]|sort_by(.CP)|reverse|.[1].itemId|select(.)" output5.json > _ring2.txt 2>nul))
if %_level% leq 259 (if %_level% geq 252 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 4)|select((.elementalTypeId >= 1)and(.elementalTypeId <= 2)))]|sort_by(.CP)|reverse|.[1].itemId|select(.)" output5.json > _ring2.txt 2>nul))
if %_level% leq 269 (if %_level% geq 260 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 4)|select((.elementalTypeId >= 1)and(.elementalTypeId <= 3)))]|sort_by(.CP)|reverse|.[1].itemId|select(.)" output5.json > _ring2.txt 2>nul))
if %_level% leq 287 (if %_level% geq 270 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 4)|select((.elementalTypeId >= 1)and(.elementalTypeId <= 4)))]|sort_by(.CP)|reverse|.[1].itemId|select(.)" output5.json > _ring2.txt 2>nul))
if %_level% leq 999 (if %_level% geq 288 (jq -r "[.[]|(select(.grade == 1)|select(.elementalTypeId <= 4)),(select(.grade == 2)|select(.elementalTypeId <= 4)),(select(.grade == 3)|select(.elementalTypeId <= 4)),(select(.grade == 4)|select(.elementalTypeId <= 4))]|sort_by(.CP)|reverse|.[1].itemId|select(.)" output5.json > _ring2.txt 2>nul))
set "_ring1= "
set "_ring2= "
set _file=_ring1.txt
if exist %_file% (set /p _ring1=<_ring1.txt)
set _file=_ring2.txt
if exist %_file% (set /p _ring2=<_ring2.txt)
set _ring1=%_ring1: =%
set _ring2=%_ring2: =%
echo.─────── Selected %_ring1%
echo.─────── Selected %_ring2%
%_cd%\batch\jq.exe "{weapon,armor,belt,necklace,ring1: \"%_ring1%\",ring2: \"%_ring2%\"}" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\888888.json> _temp.json
copy _temp.json %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\888888.json>nul
del /q _temp.json 2>nul
set /a _temp=%_stageSweepOrRepeat%
if %_stageSweepOrRepeat% == 0 (set /a _temp=%_stage%+1 2>nul)
echo.==========
echo.[1] Continue
echo.[2] Back to menu and turn off auto
choice /c 12 /n /t 15 /d 1 /m "└── Automatically select [1] after 15s: "
if %errorlevel% == 2 (set /a _canAutoOnOff=0 & goto:eof)
if %errorlevel% == 1 (jq --compact-output "[.weapon,.armor,.belt,.necklace,.ring1,.ring2]" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingRepeat\equipment\888888.json> _itemIDList.json 2>nul & goto :autoRepeat4)
:autoRepeat4
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\autoRepeat
set /p _itemIDList=<_itemIDList.json
echo off
rem Check whether the previous transactions are successful or not
echo ==========
echo Step 0: Check previous Repeat transactions
curl https://api.9cscan.com/accounts/%_vi%/transactions?action=hack_and_slash19^&limit=6 --ssl-no-revoke 2>nul|jq -r ".transactions|.[].id"> _idCheckStatus.txt 2>nul
set "_idCheckStatus="
for /f "tokens=*" %%a in (_idCheckStatus.txt) do (curl https://api.9cscan.com/transactions/%%a/status --ssl-no-revoke)
echo.
curl https://api.9cscan.com/accounts/%_vi%/transactions?action=hack_and_slash19^&limit=6 --ssl-no-revoke 2>nul | jq -r ".transactions|.[].status" | findstr -i success>nul
if %errorlevel% equ 1 (color 4F & echo.└── Error 1: Not found SUCCESS transactions & echo.─── wait 10 minutes and try again, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto:eof)
echo.└──── Complete step 0
rem Send your information to my server
echo ==========
echo Step 1: Get unsignedTransaction
set "_temp="
set /a _temp=%_stageSweepOrRepeat%
if %_stageSweepOrRepeat% == 0 (set /a _temp=%_stage%+1 2>nul)
if %_temp% leq 50 (echo 1 > _world.txt 2>nul)
if %_temp% leq 100 (if %_temp% geq 51 (echo 2 > _world.txt 2>nul))
if %_temp% leq 150 (if %_temp% geq 101 (echo 3 > _world.txt 2>nul))
if %_temp% leq 200 (if %_temp% geq 151 (echo 4 > _world.txt 2>nul))
if %_temp% leq 250 (if %_temp% geq 201 (echo 5 > _world.txt 2>nul))
if %_temp% leq 300 (if %_temp% geq 251 (echo 6 > _world.txt 2>nul))
if %_temp% leq 350 (if %_temp% geq 301 (echo 7 > _world.txt 2>nul))
set /p _world=<_world.txt
rem Auto open World
set _world=%_world: =%
echo.└── Check world %_world% ...
if %_world% equ 1 (echo.─── World %_world% opened & goto :skipOpenWorld)
echo {"query":"query{stateQuery{unlockedWorldIds(avatarAddress:\"%_address%\")}}"} > input.json
set _temp=^|curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql 2>nul|findstr /i %_world%]>nul
if %errorlevel% equ 0 (echo.─── World %_world% opened & goto :skipOpenWorld)
call :autoOpenWorld & goto :duLieuViCu
:skipOpenWorld
set "_temp1=" & set "_temp2=" & set "_temp3="
set /a _temp1=%_stageSweepOrRepeat%
if %_stageSweepOrRepeat% == 0 (set /a _temp1=%_stage%+1 2>nul)
set /a _temp2=%_howManyAP%/%_stakeAP%
set /a _temp3=%_repeatXturn%*%_stakeAP%
if %_level% lss %_temp1% (if %_temp3% leq %_actionPoint% (set /a _temp2=%_repeatXturn% 2>nul))
echo {"vi":"%_vi%","publicKey":"%_publickey%","char":"%_address%","stt":%_charCount%,"premiumTX":"%_premiumTX%","world": "%_world%","stageCC": "%_temp1%","howManyTurn": "%_temp2%","itemIDList": %_itemIDList%}> input.json 2>nul
curl -X POST -H "accept: application/json" -H "Content-Type: application/json" --data "@input.json" https://api.tanvpn.tk/ClimbingChilling --ssl-no-revoke --location> output.json 2>nul
findstr /i Micro output.json> nul
if %errorlevel% equ 0 (echo.└── Error 0.1: Server timeout & echo.─── wait 10 seconds after trying again, ... & %_cd%\data\flashError.exe & timeout /t 10 /nobreak & echo.└──── Updating ... & goto:eof)
findstr /i kqua output.json> nul
if %errorlevel% equ 1 (color 4F & echo.└── Error 0: Unknown error & echo.─── wait 10 minutes and try again, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto:eof)
jq -r ".checkqua" output.json> _checkqua.txt 2>nul & set /p _checkqua=<_checkqua.txt
jq -r ".kqua" output.json> _kqua.txt 2>nul
rem Get value exceeding 1024 characters
for %%A in (_kqua.txt) do for /f "usebackq delims=" %%B in ("%%A") do (
  set "_kqua=%%B"
  goto :autoRepeat5
)
:autoRepeat5
if %_checkqua% == 0 (echo.└── %_kqua% ... & echo.─── wait 10 minutes and try again, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto:eof)
echo.└──── Get unsignedTransaction successful
echo ==========
echo Step 2: Get Signature
rem Create Action File
call certutil -decodehex _kqua.txt action >nul
echo.└── Using the previously saved password ...
"%_cd%\planet\planet" key sign --passphrase %_PASSWORD% --store-path %_cd%\user\utc %_KeyID% action> _signature.txt 2>nul
set "_signature="
rem Get value exceeding 1024 characters
for %%A in (_signature.txt) do for /f "usebackq delims=" %%B in ("%%A") do (
  set "_signature=%%B"
  goto :autoRepeat6
)
:autoRepeat6
if [%_signature%] == [] (echo.└──── Error 1: The password is not right ... & echo.─── wait 10 minutes and try again, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto:eof)
echo.└──── Get Signature successful
echo ==========
echo Step 3: Get signTransaction
echo.[40;97mStage %_temp1%, %_temp2% turn(s) với [40;95mtype %_typeRepeat%[40;96m
echo.
echo.[1] Continue repeat, automatic after 10s
echo.[2] Back to menu and turn off Auto
choice /c 12 /n /t 10 /d 1 /m "Enter number from the keyboard: "
if %errorlevel%==1 (goto :autoRepeat7)
if %errorlevel%==2 (set /a _canAutoOnOff=0 & goto:eof)
:autoRepeat7
echo {"query":"query{transaction{signTransaction(unsignedTransaction:\"%_kqua%\",signature:\"%_signature%\")}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json  2>nul
echo.└── Find signTransaction ...
jq -r "..|.signTransaction?|select(.)" output.json> _signTransaction.txt 2>nul
echo.└──── Get signTransaction successful
echo ==========
echo Step 4: Get stageTransaction
echo.
rem Get value exceeding 1024 characters
for %%A in (_signTransaction.txt) do for /f "usebackq delims=" %%B in ("%%A") do (
  set "_signTransaction=%%B"
  goto :autoRepeat8
)
:autoRepeat8
echo {"query":"mutation{stageTransaction(payload:\"%_signTransaction%\")}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json  2>nul
echo.└── Find stageTransaction ...
jq -r "..|.stageTransaction?|select(.)" output.json> _stageTransaction.txt 2>nul
echo.└──── Get stageTransaction successful
set /a _countKtraAuto=0
set /a _countKtraStaging=0
:ktraAutoRepeat
set /a _countKtraAuto+=1
set /a _countKtraStaging+=1
color 0B
cls
set _temp=       %_9cscanBlock%
echo.╔═══════════════╗   ╔═══════════════╗   ╔═══════════════╗
if %_canAuto%==5 echo ║ID %_vi:~0,7%***	║   ║Block: %_temp:~-7% ║   ║[40;92mCan Auto? [X]	[40;96m║
if not %_canAuto%==5 echo ║ID %_vi:~0,7%***	║   ║Block: %_temp:~-7% ║   ║[40;97mCan Auto? [ ]	[40;96m║
echo.╚═══════════════╝   ╚═══════════════╝   ╚═══════════════╝
echo ==========
echo Step 5: Check auto Repeat character: %_name%
echo [40;97mStage %_temp1%, %_temp2% turn(s) with [40;95mtype %_typeRepeat%[40;96m
echo.─── Check %_countKtraStaging% time(s)
if %_countKtraStaging% gtr 50 (color 8F & echo.─── Status: Auto Repeat failure & echo.─── the cause is node broken & echo.─── use node 1 and try again ... & %_cd%\data\flashError.exe & set /a _node=1 & timeout /t 20 /nobreak & echo.└──── Updating ... & goto:eof)
set /p _stageTransaction=<_stageTransaction.txt
echo {"query":"query{transaction{transactionResult(txId:\"%_stageTransaction%\"){txStatus}}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json 2>nul
echo.└── Find txStatus ...
jq -r "..|.txStatus?|select(.)" output.json> _txStatus.txt 2>nul
set /p _txStatus=<_txStatus.txt
if "%_txStatus%" == "STAGING" (color 0B & echo.─── Status: Auto Repeat is taking place & echo.─── check again after 15s ... & set /a _countKtraAuto=0 & timeout /t 15 /nobreak>nul & goto :ktraAutoRepeat)
if "%_txStatus%" == "FAILURE" (color 4F & echo.─── Status: Auto Repeat failure & echo.─── wait 10 minutes and try again auto Repeat, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto:eof)
if "%_txStatus%" == "INVALID" (if %_countKtraAuto% lss 4 (color 8F & echo.─── Status: Auto Repeat temporary failure & echo.─── check again %_countKtraAuto% time(s) after 15s ... & timeout /t 15 /nobreak>nul & goto :ktraAutoRepeat))
if "%_txStatus%" == "INVALID" (if %_countKtraAuto% geq 4 (color 8F & echo.─── Status: Auto Repeat failure & echo.─── wait 10 minutes and try again auto Repeat, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto:eof))
if "%_txStatus%" == "SUCCESS" (color 2F & echo.─── Status: Auto Repeat successful & echo.─── return menu ... & timeout /t 20 /nobreak & echo.└──── Updating ... & goto:eof)
if %_countKtraAuto% lss 4 (color 4F & echo.─── Error 2.1: Unknown error & echo.─── check again %_countKtraAuto% time(s) after 15s ... & timeout /t 15 /nobreak>nul & goto :ktraAutoRepeat)
if %_countKtraAuto% geq 4 (color 4F & echo.─── Error 2.2: Unknown error & echo.─── wait 10 minutes and try again auto Repeat, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto:eof)
goto:eof

:autoOpenWorld
echo.─── World %_world% not unlocked
if %_autoOpenMapOnOff% == 1 (goto :tryOpenWorld0) else (color 4F & echo.─── you need unlock world %_world% & echo.─── try again after 60s, ... & %_cd%\data\flashError.exe & timeout 60 & echo.└──── Updating ... & goto :duLieuViCu)
:tryOpenWorld0
echo ==========
echo.└── Start auto unlock World %_world%
rem Check the balance
echo {"query":"query{stateQuery{agent(address:\"%_vi%\"){crystal}}goldBalance(address: \"%_vi%\" )}"} > input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql > output.json 2>nul
rem Filter the results of data
jq "..|.crystal?|select(.)|tonumber" output.json > _crystal.txt 2>nul
jq "..|.goldBalance?|select(.)|tonumber" output.json > _ncg.txt 2>nul
set /p _ncg=<_ncg.txt
set /p _crystal=<_crystal.txt
set /a _ncg=%_ncg% 2>nul
set /a _crystal=%_crystal% 2>nul
set "_temp=" & set "_temp1=" & set "_temp2=" & set "_temp3=" & set "_temp4=" & set "_temp5=8888888888"
set /a _temp=%_stage%
if %_temp% leq 50 (set _temp1=1 & set _temp2=Yggdrasil)
if %_temp% leq 100 (if %_temp% geq 51 (set _temp1=2 & set _temp2=Alfheim))
if %_temp% leq 150 (if %_temp% geq 101 (set _temp1=3 & set _temp2=Svartalfheim))
if %_temp% leq 200 (if %_temp% geq 151 (set _temp1=4 & set _temp2=Asgard))
if %_temp% leq 250 (if %_temp% geq 201 (set _temp1=5 & set _temp2=Muspelheim))
if %_temp% leq 300 (if %_temp% geq 251 (set _temp1=6 & set _temp2=Jotunheim))
if %_temp% leq 350 (if %_temp% geq 301 (set _temp1=7 & set _temp2=NoData))
set /a _temp=%_temp1% + 1
set _temp4=NoData
if %_temp% == 2 (set /a _temp5=500 & set _temp4=Alfheim)
if %_temp% == 3 (set /a _temp5=2500 & set _temp4=Svartalfheim)
if %_temp% == 4 (set /a _temp5=50000 & set _temp4=Asgard)
if %_temp% == 5 (set /a _temp5=100000 & set _temp4=Muspelheim)
if %_temp% == 6 (set /a _temp5=1000000 & set _temp4=Jotunheim)
echo.==========
echo Balance	:	%_ncg% NCG	%_crystal% CRYSTAL
echo Character	:	%_charCount%
echo Name		:	%_name%
echo Stage		:	%_stage%
echo World		:	%_temp2%
echo Next world %_temp4% need [40;97m%_temp5% CRYSTAL[40;96m
set /a _temp=%_temp5%-%_crystal%
if %_temp5% geq %_crystal% (
echo.Need %_temp% CRYSTAL to unlock next world
color 4F & echo.─── wait 10 minutes and try again, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto:eof
)
:tryOpenWorld1
echo.└──── Start aotu open the world %_world%
echo ==========
echo Step 1: Get unlockWorld and nextTxNonce
echo {"query":"query{actionQuery{unlockWorld(avatarAddress:\"%_address%\",worldIds:%_world%)}transaction{nextTxNonce(address:\"%_vi%\")}}"} > input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql > output.json 2>nul
rem Filter the results of data
echo.└── Find unlockWorld ...
jq -r "..|.unlockWorld?|select(.)" output.json > _unlockWorld.txt 2>nul
set /p _unlockWorld=<_unlockWorld.txt
echo.└── Find nextTxNonce ...
jq -r "..|.nextTxNonce?|select(.)" output.json > _nextTxNonce.txt 2>nul
set /p _nextTxNonce=<_nextTxNonce.txt
echo.└──── Get unlockWorld and nextTxNonce successful
echo ==========
echo Step 2: Get unsignedTransaction
echo {"query":"query{transaction{unsignedTransaction(publicKey:\"%_publickey%\",plainValue:\"%_unlockWorld%\",nonce:%_nextTxNonce%)}}"} > input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql > output.json 2>nul
rem Filter the results of data
echo.└── Find unsignedTransaction ...
%_cd%\batch\jq.exe -r "..|.unsignedTransaction?|select(.)" output.json> _unsignedTransaction.txt 2>nul
rem Get value exceeding 1024 characters
for %%A in (_unsignedTransaction.txt) do for /f "usebackq delims=" %%B in ("%%A") do (
  set "_unsignedTransaction=%%B"
  goto :tryOpenWorld2
)
:tryOpenWorld2
echo.└──── Get unsignedTransaction successful
echo ==========
echo Step 3: Get Signature
rem Create Action File
call certutil -decodehex _unsignedTransaction.txt action >nul
echo.└── Using the previously saved password ...
"%_cd%\planet\planet" key sign --passphrase %_PASSWORD% --store-path %_cd%\user\utc %_KeyID% action> _signature.txt 2>nul
set "_signature="
rem Get value exceeding 1024 characters
for %%A in (_signature.txt) do for /f "usebackq delims=" %%B in ("%%A") do (
  set "_signature=%%B"
  goto :tryOpenWorld3
)
:tryOpenWorld3
if [%_signature%] == [] (echo.└──── Error 1: The password is not right ... & echo.─── wait 10 minutes and try again, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto:eof)
echo.└──── Get Signature successful
echo ==========
echo Step 4: Get signTransaction
echo.
echo.[1] Continue open World %_world%, automatic after 10s
echo.[2] Back to menu and turn off Auto
choice /c 12 /n /t 10 /d 1 /m "Enter number from the keyboard: "
if %errorlevel%==1 (goto :tryOpenWorld4)
if %errorlevel%==2 (set /a _canAutoOnOff=0 & goto:eof)
:tryOpenWorld4
echo {"query":"query{transaction{signTransaction(unsignedTransaction:\"%_unsignedTransaction%\",signature:\"%_signature%\")}}"}> input.json 2>nulrem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json  2>nul
echo.└── Find signTransaction ...
jq -r "..|.signTransaction?|select(.)" output.json> _signTransaction.txt 2>nul
echo.└──── Get signTransaction successful
echo ==========
echo Step 5: Get stageTransaction
echo.
rem Get value exceeding 1024 characters
for %%A in (_signTransaction.txt) do for /f "usebackq delims=" %%B in ("%%A") do (
  set "_signTransaction=%%B"
  goto :tryOpenWorld5
)
:tryOpenWorld5
echo {"query":"mutation{stageTransaction(payload:\"%_signTransaction%\")}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json  2>nul
echo.└── Find stageTransaction ...
jq -r "..|.stageTransaction?|select(.)" output.json> _stageTransaction.txt 2>nul
echo.└──── Get stageTransaction successful
set /a _countKtraAuto=0
set /a _countKtraStaging=0
:ktraAutoOpenWorld
set /a _countKtraAuto+=1
set /a _countKtraStaging+=1
color 0B
cls
set _temp=       %_9cscanBlock%
echo.╔═══════════════╗   ╔═══════════════╗   ╔═══════════════╗
if %_canAuto%==5 echo ║ID %_vi:~0,7%***	║   ║Block: %_temp:~-7% ║   ║[40;92mCan Auto? [X]	[40;96m║
if not %_canAuto%==5 echo ║ID %_vi:~0,7%***	║   ║Block: %_temp:~-7% ║   ║[40;97mCan Auto? [ ]	[40;96m║
echo.╚═══════════════╝   ╚═══════════════╝   ╚═══════════════╝
echo ==========
echo Step 6: Check auto open world %_world% character: %_name%
echo.─── Check %_countKtraStaging% time(s)
if %_countKtraStaging% gtr 50 (color 8F & echo.─── Status: Auto open world failure & echo.─── the cause is node broken & echo.─── use node 1 and try again ... & %_cd%\data\flashError.exe & set /a _node=1 & timeout /t 20 /nobreak & echo.└──── Updating ... & goto:eof)
set /p _stageTransaction=<_stageTransaction.txt
echo {"query":"query{transaction{transactionResult(txId:\"%_stageTransaction%\"){txStatus}}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json 2>nul
echo.└── Find txStatus ...
jq -r "..|.txStatus?|select(.)" output.json> _txStatus.txt 2>nul
set /p _txStatus=<_txStatus.txt
if "%_txStatus%" == "STAGING" (color 0B & echo.─── Status: Auto open World is taking place & echo.─── check again after 15s ... & set /a _countKtraAuto=0 & timeout /t 15 /nobreak>nul & goto :ktraAutoOpenWorld)
if "%_txStatus%" == "FAILURE" (color 4F & echo.─── Status: Auto open World failure & echo.─── wait 10 minutes and try again auto open World, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto:eof)
if "%_txStatus%" == "INVALID" (if %_countKtraAuto% lss 4 (color 8F & echo.─── Status: Auto open World temporary failure & echo.─── check again %_countKtraAuto% time(s) after 15s ... & timeout /t 15 /nobreak>nul & goto :ktraAutoOpenWorld))
if "%_txStatus%" == "INVALID" (if %_countKtraAuto% geq 4 (color 8F & echo.─── Status: Auto open World failure & echo.─── wait 10 minutes and try again auto open World, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto:eof))
if "%_txStatus%" == "SUCCESS" (color 2F & echo.─── Status: Auto open World successful & echo.─── return menu ... & timeout /t 20 /nobreak & echo.└──── Updating ... & goto:eof)
if %_countKtraAuto% lss 4 (color 4F & echo.─── Error 2.1: Unknown error & echo.─── check again %_countKtraAuto% time(s) after 15s ... & timeout /t 15 /nobreak>nul & goto :ktraAutoOpenWorld)
if %_countKtraAuto% geq 4 (color 4F & echo.─── Error 2.2: Unknown error & echo.─── wait 10 minutes and try again auto open World, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto:eof)
goto:eof
:tryAutoUseAPpotion
rem Create data saving folders
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\autoRepeat"
if exist %_folder% (rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\autoRepeat)
md %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\autoRepeat
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\autoRepeat
copy "%_cd%\batch\jq.exe" "jq.exe"> nul
echo.└── Start auto use AP potion character %_name% ...
rem Check the balance
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_address%\"){inventory{items(inventoryItemId:500000){id,itemType,count}}}}}"} > input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql > output.json 2>nul
rem Filter the results of data
jq -r ".data.stateQuery.avatar.inventory.items|(if ([.[].count]|add) == null then 0 else ([.[].count]|add) end)" output.json > _countAPPotion.txt 2>nul
set /p _countAPPotion=<_countAPPotion.txt
set /a _countAPPotion=%_countAPPotion% 2>nul
echo.==========
echo Character	:	%_charCount%
echo Name		:	%_name%
echo Stage		:	%_stage%
if %_countAPPotion% leq 0 (echo Have		:	%_countAPPotion% AP Potion
color 4F & echo.└── Character does not have AP potion & echo.─── wait 10 minutes and try again, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto:eof
) else (echo Have		:	[40;32m%_countAPPotion%[40;96m AP Potion)
:tryAutoUseAPpotion1
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\autoRepeat
rem Check whether the previous transactions are successful or not
echo ==========
echo Step 0: Check previous use AP Potion transactions
curl https://api.9cscan.com/accounts/%_vi%/transactions?action=charge_action_point3^&limit=6 --ssl-no-revoke 2>nul|jq -r ".transactions|.[].id"> _idCheckStatus.txt 2>nul
set "_idCheckStatus="
for /f "tokens=*" %%a in (_idCheckStatus.txt) do (curl https://api.9cscan.com/transactions/%%a/status --ssl-no-revoke)
echo.
curl https://api.9cscan.com/accounts/%_vi%/transactions?action=charge_action_point3^&limit=6 --ssl-no-revoke 2>nul | jq -r ".transactions|.[].status" | findstr -i success>nul
if %errorlevel% equ 1 (color 4F & echo.└── Error 1: Not found SUCCESS transactions & echo.─── wait 10 minutes and try again, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto:eof)
echo.└──── Complete step 0
rem Send your information to my server
echo ==========
echo Step 1: Get unsignedTransaction
echo {"vi":"%_vi%","publicKey":"%_publickey%","char":"%_address%","stt":%_charCount%,"premiumTX":"%_premiumTX%"}> input.json 2>nul
curl -X POST -H "accept: application/json" -H "Content-Type: application/json" --data "@input.json" https://api.tanvpn.tk/useAPpotion --ssl-no-revoke --location> output.json 2>nul
findstr /i Micro output.json> nul
if %errorlevel% equ 0 (echo.└── Error 0.1: Server timeout & echo.─── wait 10 seconds after trying again, ... & %_cd%\data\flashError.exe & timeout /t 10 /nobreak & echo.└──── Updating ... & goto:eof)
findstr /i kqua output.json> nul
if %errorlevel% equ 1 (color 4F & echo.└── Error 0: Unknown error & echo.─── wait 10 minutes and try again, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto:eof)
jq -r ".checkqua" output.json> _checkqua.txt 2>nul & set /p _checkqua=<_checkqua.txt
jq -r ".kqua" output.json> _kqua.txt 2>nul
rem Get value exceeding 1024 characters
for %%A in (_kqua.txt) do for /f "usebackq delims=" %%B in ("%%A") do (
  set "_kqua=%%B"
  goto :tryAutoUseAPpotion2
)
:tryAutoUseAPpotion2
if %_checkqua% == 0 (echo.└── %_kqua% ... & echo.─── wait 10 minutes and try again, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto:eof)
echo.└──── Get unsignedTransaction successful
echo ==========
echo Step 2: Get Signature
rem Create Action File
call certutil -decodehex _kqua.txt action >nul
echo.└── Using the previously saved password ...
"%_cd%\planet\planet" key sign --passphrase %_PASSWORD% --store-path %_cd%\user\utc %_KeyID% action> _signature.txt 2>nul
set "_signature="
rem Get value exceeding 1024 characters
for %%A in (_signature.txt) do for /f "usebackq delims=" %%B in ("%%A") do (
  set "_signature=%%B"
  goto :tryAutoUseAPpotion3
)
:tryAutoUseAPpotion3
if [%_signature%] == [] (echo.└──── Error 1: The password is not right ... & echo.─── wait 10 minutes and try again, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto:eof)
echo.└──── Get Signature successful
echo ==========
echo Step 3: Get signTransaction
echo.
echo.[1] Continue to use 1 AP potion, automatic after 10s
echo.[2] Back to menu and turn off Auto
choice /c 12 /n /t 10 /d 1 /m "Enter number from the keyboard: "
if %errorlevel%==1 (goto :tryAutoUseAPpotion4)
if %errorlevel%==2 (set /a _canAutoOnOff=0 & goto:eof)
:tryAutoUseAPpotion4
echo {"query":"query{transaction{signTransaction(unsignedTransaction:\"%_kqua%\",signature:\"%_signature%\")}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json  2>nul
echo.└── Find signTransaction ...
jq -r "..|.signTransaction?|select(.)" output.json> _signTransaction.txt 2>nul
echo.└──── Get signTransaction successful
echo ==========
echo Step 4: Get stageTransaction
echo.
rem Get value exceeding 1024 characters
for %%A in (_signTransaction.txt) do for /f "usebackq delims=" %%B in ("%%A") do (
  set "_signTransaction=%%B"
  goto :tryAutoUseAPpotion5
)
:tryAutoUseAPpotion5
echo {"query":"mutation{stageTransaction(payload:\"%_signTransaction%\")}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json  2>nul
echo.└── Find stageTransaction ...
jq -r "..|.stageTransaction?|select(.)" output.json> _stageTransaction.txt 2>nul
echo.└──── Get stageTransaction successful
set /a _countKtraAuto=0
set /a _countKtraStaging=0
:ktraAutoUseAPpotion
set /a _countKtraAuto+=1
set /a _countKtraStaging+=1
color 0B
cls
set _temp=       %_9cscanBlock%
echo.╔═══════════════╗   ╔═══════════════╗   ╔═══════════════╗
if %_canAuto%==5 echo ║ID %_vi:~0,7%***	║   ║Block: %_temp:~-7% ║   ║[40;92mCan Auto? [X]	[40;96m║
if not %_canAuto%==5 echo ║ID %_vi:~0,7%***	║   ║Block: %_temp:~-7% ║   ║[40;97mCan Auto? [ ]	[40;96m║
echo.╚═══════════════╝   ╚═══════════════╝   ╚═══════════════╝
echo ==========
echo Step 5: Check auto use 1 AP potion character: %_name%
echo.─── Check %_countKtraStaging% time(s)
if %_countKtraStaging% gtr 50 (color 8F & echo.─── Status: Auto use AP potion failure & echo.─── the cause is node broken & echo.─── use node 1 and try again ... & %_cd%\data\flashError.exe & set /a _node=1 & timeout /t 20 /nobreak & echo.└──── Updating ... & goto:eof)
set /p _stageTransaction=<_stageTransaction.txt
echo {"query":"query{transaction{transactionResult(txId:\"%_stageTransaction%\"){txStatus}}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json 2>nul
echo.└── Find txStatus ...
jq -r "..|.txStatus?|select(.)" output.json> _txStatus.txt 2>nul
set /p _txStatus=<_txStatus.txt
if "%_txStatus%" == "STAGING" (color 0B & echo.─── Status: Auto use AP potion is taking place & echo.─── check again after 15s ... & set /a _countKtraAuto=0 & timeout /t 15 /nobreak>nul & goto :ktraAutoUseAPpotion)
if "%_txStatus%" == "FAILURE" (color 4F & echo.─── Status: Auto use AP potion failure & echo.─── wait 10 minutes and try again auto use AP potion, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto:eof)
if "%_txStatus%" == "INVALID" (if %_countKtraAuto% lss 4 (color 8F & echo.─── Status: Auto use AP potion temporary failure & echo.─── check again %_countKtraAuto% time(s) after 15s ... & timeout /t 15 /nobreak>nul & goto :ktraAutoUseAPpotion))
if "%_txStatus%" == "INVALID" (if %_countKtraAuto% geq 4 (color 8F & echo.─── Status: Auto use AP potion failure & echo.─── wait 10 minutes and try again auto use AP potion, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto:eof))
if "%_txStatus%" == "SUCCESS" (color 2F & echo.─── Status: Auto use AP potion successful & echo.─── return menu ... & timeout /t 20 /nobreak & echo.└──── Updating ... & goto:eof)
if %_countKtraAuto% lss 4 (color 4F & echo.─── Error 2.1: Unknown error & echo.─── check again %_countKtraAuto% time(s) after 15s ... & timeout /t 15 /nobreak>nul & goto :ktraAutoUseAPpotion)
if %_countKtraAuto% geq 4 (color 4F & echo.─── Error 2.2: Unknown error & echo.─── wait 10 minutes and try again auto use AP potion, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Updating ... & goto:eof)
goto:eof