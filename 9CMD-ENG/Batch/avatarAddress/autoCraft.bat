echo off
mode con:cols=60 lines=25
color 0B
rem Install Vietnamese
chcp 65001
cls
rem Set %_cd% origin
set /p _cd=<_cd.txt
set /a _countVi=%1
set /a _countChar=%2
set _folderVi=vi%_countVi%
rem Get the wallet being saved
set _vi=**********************
set /p _vi=<%_cd%\user\trackedAvatar\%_folderVi%\_vi.txt
set /p _node=<%_cd%\data\_node.txt
set _node=%_node: =%
:menuAutoCraft
set _9cscanBlock=*******
set _canAuto=0
set /a _premiumTXOK=0 & set /a _passwordOK=0 & set /a _publickeyOK=0 & set /a _keyidOK=0 & set /a _utcFileOK=0
set /a _canAutoOnOff=0
call :background
:menuAutoCraftRefreshData
title Auto Craft [%_countVi%] [%_countChar%]
rem Create data saving folders
set _folder="%_cd%\User\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft"
if not exist %_folder% (md %_cd%\User\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft)
cd %_cd%\User\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
rem Get the current block
echo.└──── Get the current block ...
curl https://api.tanvpn.tk/blockNow --ssl-no-revoke --location > _9cscanBlock.txt 2>nul & set /p _9cscanBlock=<_9cscanBlock.txt
set /a _9cscanBlock=%_9cscanBlock%
rem Load old data if any
echo.───── Input character data %_countChar% ...
rem Check if the UTC file is available or not
set _utcfile=^|%_cd%\planet\planet key --path %_cd%\user\utc 2>nul|findstr /i %_vi%>nul
if %errorlevel% equ 0 (set /a _utcFileOK=1)
set _file="%_cd%\user\trackedAvatar\%_folderVi%\premium\_premiumTX.txt"
if exist %_file% (set /p _premiumTX=<%_cd%\user\trackedAvatar\%_folderVi%\premium\_premiumTX.txt & set /a _premiumTXOK=1)
rem Try getting password
set _file="%_cd%\user\trackedAvatar\%_folderVi%\auto\password\_password.txt"
if exist %_file% (set /p _password=<%_cd%\user\trackedAvatar\%_folderVi%\auto\password\_password.txt & set /a _passwordOK=1)
rem Try to get public key
set _file="%_cd%\user\trackedAvatar\%_folderVi%\auto\publickey\_publickey.txt"
if exist %_file% (set /p _publickey=<%_cd%\user\trackedAvatar\%_folderVi%\auto\publickey\_publickey.txt & set /a _publickeyOK=1)
rem Try to get the key ID
set _file="%_cd%\user\trackedAvatar\%_folderVi%\auto\KeyID\_KeyID.txt"
if exist %_file% (set /p _KeyID=<%_cd%\user\trackedAvatar\%_folderVi%\auto\KeyID\_KeyID.txt & set /a _keyidOK=1)
set /p _char=<%_cd%\user\trackedAvatar\vi%_countVi%\char%_countChar%\_address.txt
set /p _name=<%_cd%\user\trackedAvatar\vi%_countVi%\char%_countChar%\_name.txt
curl https://api.9cscan.com/account?address=%_vi% --ssl-no-revoke> _allChar.json 2>nul
%_cd%\batch\jq.exe ".[%_countChar%]|del(.refreshBlockIndex)|del(.avatarAddress)|del(.address)|del(.goldBalance)|.[]|{address, name, level, actionPoint,timeCount: (.dailyRewardReceivedIndex+1700-%_9cscanBlock%)}" _allChar.json> _infoChar.json 2>nul
%_cd%\batch\jq.exe "{sec: ((.timeCount*12)%%60),minute: ((((.timeCount*12)-(.timeCount*12)%%60)/60)%%60),hours: (((((.timeCount*12)-(.timeCount*12)%%60)/60)-(((.timeCount*12)-(.timeCount*12)%%60)/60%%60))/60)}" _infoChar.json> _infoCharAp.json 2>nul
%_cd%\batch\jq.exe -j """\(.hours):\(.minute):\(.sec)""" _infoCharAp.json> _infoCharAp.txt 2>nul
%_cd%\batch\jq.exe -r ".level" _infoChar.json > _level.txt 2>nul
%_cd%\batch\jq.exe -r ".actionPoint" _infoChar.json > _actionPoint.txt 2>nul
%_cd%\batch\jq.exe -r ".timeCount" _infoChar.json> _timeCount.txt 2>nul
set /p _infoCharAp=<_infoCharAp.txt
set /p _level=<_level.txt
set /p _actionPoint=<_actionPoint.txt
set /p _timeCount=<_timeCount.txt
echo.───── Get opened Stage and Crystal balance ...
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_char%\"){actionPoint,dailyRewardReceivedIndex,level,stageMap{count}}agent(address:\"%_vi%\"){crystal}}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json 2>nul
rem Filter the results of data
%_cd%\batch\jq.exe -r "..|.count?|select(.)" output.json > _stage.txt 2>nul
%_cd%\batch\jq.exe -r "..|.crystal?|select(.)|tonumber" output.json > _crystal.txt 2>nul
echo.───── Get AP and time Refill AP ...
"%_cd%\batch\jq.exe" -r ".data.stateQuery.avatar.actionPoint" output.json > _actionPoint.txt 2>nul
"%_cd%\batch\jq.exe" -r ".data.stateQuery.avatar|.dailyRewardReceivedIndex+1700-%_9cscanBlock%" output.json > _timeCount.txt 2>nul
"%_cd%\batch\jq.exe" -r ".data.stateQuery.avatar|.dailyRewardReceivedIndex+1700-%_9cscanBlock%|{sec: ((.*12)%%60),minute: ((((.*12)-(.*12)%%60)/60)%%60),hours: (((((.*12)-(.*12)%%60)/60)-(((.*12)-(.*12)%%60)/60%%60))/60)}" output.json > _infoCharAp.json 2>nul
"%_cd%\batch\jq.exe" -j """\(.hours):\(.minute):\(.sec)""" _infoCharAp.json> _infoCharAp.txt 2>nul
"%_cd%\batch\jq.exe" -r ".data.stateQuery.avatar.level" output.json> _level.txt 2>nul
set /p _infoCharAp=<_infoCharAp.txt
set /p _level=<_level.txt
set /p _actionPoint=<_actionPoint.txt
set /p _timeCount=<_timeCount.txt
rem Delete Input and Output filters
del /q input.json 2>nul
del /q output.json 2>nul
set /a _stage=0
set /p _stage=<_stage.txt
if %_stage% == 0 (echo.Error 1.1: Opened stage not found & echo.the cause is node broken & echo.use next node and try again ... & %_cd%\data\flashError.exe & call :changeNode & color 4F & timeout 5 & goto :menuAutoCraftRefreshData)
set /p _crystal=<_crystal.txt
set /a _crystal=%_crystal% 2>nul
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\CheckItem\"
if exist %_folder% (goto :menuAutoCraftRefreshData1)
rem Tạo file index.html
echo.───── Create html file to see items ...
xcopy "%_cd%\data\CheckItem2\" "%_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\CheckItem\" >nul
set /p _urlJson=<%_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingSweep\_urlJson.txt
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\CheckItem
echo $.getJSON("https://jsonblob.com/api/jsonBlob/%_urlJson%",> index-raw2.html 2>nul
type index-raw1.html index-raw2.html index-raw3.html> index.html 2>nul
del /q index-raw1.html index-raw2.html index-raw3.html index-raw.html
:menuAutoCraftRefreshData1
cd %_cd%\User\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
rem Create file _infoSlot.json
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json"
if exist %_file% (goto :menuAutoCraftRefreshData2)
echo.───── Create file _infoSlot.json ...
echo {"block9cscan": %_9cscanBlock%,"slot1_id":"10110000","slot1_type":"Basic","slot1_block":0,"slot1_item":"","slot2_id":"10110000","slot2_type":"Basic","slot2_block":0,"slot2_item":"","slot3_id":"10110000","slot3_type":"Basic","slot3_block":0,"slot3_item":"","slot4_id":"10110000","slot4_type":"Basic","slot4_block":0,"slot4_item":""}> _infoSlot.json
:menuAutoCraftRefreshData2
rem Create file _infoSuperCraft.json
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSuperCraft.json"
if exist %_file% (goto :menuAutoCraftRefreshData31)
echo.───── Create file _infoSuperCraft.json ...
echo {}> _infoSuperCraft.json
:menuAutoCraftRefreshData31
cd %_cd%\User\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
rem Find file _urlDataOnline.txt
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_urlDataOnline.txt"
if exist %_file% (goto :menuAutoCraftRefreshData3)
echo.───── Create link jsonblob.com ...
%_cd%\batch\jq.exe -s -c "." _infoSuperCraft.json> _temp1.txt
set /p _temp1=<_temp1.txt
%_cd%\batch\jq.exe -c "{block9cscan: %_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item, SuperCraft:%_temp1%}" _infoSlot.json> output.json
curl -i -X "POST" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob --ssl-no-revoke 2>nul|findstr /i location>nul> _temp.txt 2>nul
set /p _temp=<_temp.txt
echo %_temp:~43,19%> _urlDataOnline.txt 2>nul & set "_temp=" & del /q _temp.txt 2>nul
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
set /p _urlDataOnline=<_urlDataOnline.txt
echo.───── Save online Slot and Super Craft information ...
%_cd%\batch\jq.exe -s -c "." _infoSuperCraft.json> _temp1.txt
set /p _temp1=<_temp1.txt
%_cd%\batch\jq.exe -c "{block9cscan: %_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item, SuperCraft:%_temp1%}" _infoSlot.json> output.json
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlDataOnline% --ssl-no-revoke >nul 2>nul
del /q output.json
echo %_9cscanBlock% > _9cscanBlockSave.txt
:menuAutoCraftRefreshData3
cd %_cd%\User\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_9cscanBlockSave.txt"
if not exist %_file% (0 > _9cscanBlockSave.txt)
set /p _urlDataOnline=<_urlDataOnline.txt
set /p _9cscanBlockSave=<_9cscanBlockSave.txt
set /a _9cscanBlockSave=%_9cscanBlockSave% 2>nul
curl https://jsonblob.com/api/jsonBlob/%_urlDataOnline% --ssl-no-revoke> _temp1.txt 2>nul
%_cd%\batch\jq.exe "(if .block9cscan >= %_9cscanBlockSave% then true else false end)" _temp1.txt | findstr -i true>nul
if %errorlevel% == 1 (goto :menuAutoCraftRefreshData4)
echo.───── Enter online Slot and Super Craft information ...
%_cd%\batch\jq.exe "{slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" _temp1.txt> _infoSlot.json
%_cd%\batch\jq.exe -c ".SuperCraft|.[]" _temp1.txt> _infoSuperCraft.json
%_cd%\batch\jq.exe -c ".block9cscan" _temp1.txt> _9cscanBlockSave.txt
goto :menuAutoCraftRefreshData5
:menuAutoCraftRefreshData4
goto :menuAutoCraftRefreshData5
:menuAutoCraftRefreshData5
del /q _temp1.txt
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoUpgrade.json"
if exist %_file% (goto :menuAutoCraftRefreshData6)
echo.───── Create _infoUpgrade.json ...
echo.{"type":"Weapon","grade":1,"ele1":0,"ele2":0,"levelUp":0}> _infoUpgrade.json
:menuAutoCraftRefreshData6
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_SuperCraftBasicOrPremium.txt"
if not exist %_file% (echo 0 > %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_SuperCraftBasicOrPremium.txt)
set /p _SuperCraftBasicOrPremium=<_SuperCraftBasicOrPremium.txt
set /a _SuperCraftBasicOrPremium=%_SuperCraftBasicOrPremium% 2>nul
:displayMenuAutoCraft
echo.───── Complete!
timeout 2 >nul
call :background
set /a _slot=1
set _temp1=                    %_name%
set _temp2=                    %_level%
set _temp3=                    %_stage%
set _temp4=               %_actionPoint%
set _temp5=               %_infoCharAp%
set _temp6=               %_crystal%
echo.╔═ Character %_countChar% ═════════════════════════════════════════╗
echo.║Name	:%_temp1:~-20%	AP	:%_temp4:~-15%║
echo.║Level	:%_temp2:~-20%	Time	:%_temp5:~-15%║
echo.║Stage	:%_temp3:~-20%	Crystal	:%_temp6:~-15%║
echo.╚═══════════════════════════════════════════════════════╝
:displayMenuAutoCraft1
call :importSlot
set /a _slot+=1
if %_slot% lss 5 (goto :displayMenuAutoCraft1)

set _tempSlot11=                 %_slot1_id%
set _tempSlot12=       %_slot1_type%
set /a _tempSlot131=%_slot1_block%-%_9cscanBlock%
set _tempSlot13=                 %_tempSlot131%
set _tempSlot14=                 %_slot1_name%
if %_tempSlot131% lss 0 (set _tempSlot15=[40;92mSlot 1 - %_tempSlot12:~-7%[40;96m) else (set _tempSlot15=Slot 1 - %_tempSlot12:~-7%)
set _tempSlot16=                 %_hammer1% / %_slot1_max_hammer_count%

set _tempSlot21=                 %_slot2_id%
set _tempSlot22=       %_slot2_type%
set /a _tempSlot231=%_slot2_block%-%_9cscanBlock%
set _tempSlot23=                 %_tempSlot231%
set _tempSlot24=                 %_slot2_name%
if %_tempSlot231% lss 0 (set _tempSlot25=[40;92mSlot 2 - %_tempSlot22:~-7%[40;96m) else (set _tempSlot25=Slot 2 - %_tempSlot22:~-7%)
set _tempSlot26=                 %_hammer2% / %_slot2_max_hammer_count%

set _tempSlot31=                 %_slot3_id%
set _tempSlot32=       %_slot3_type%
set /a _tempSlot331=%_slot3_block%-%_9cscanBlock%
set _tempSlot33=                 %_tempSlot331%
set _tempSlot34=                 %_slot3_name%
if %_tempSlot331% lss 0 (set _tempSlot35=[40;92mSlot 3 - %_tempSlot32:~-7%[40;96m) else (set _tempSlot35=Slot 3 - %_tempSlot32:~-7%)
set _tempSlot36=                 %_hammer3% / %_slot3_max_hammer_count%

set _tempSlot41=                 %_slot4_id%
set _tempSlot42=       %_slot4_type%
set /a _tempSlot431=%_slot4_block%-%_9cscanBlock%
set _tempSlot43=                 %_tempSlot431%
set _tempSlot44=                 %_slot4_name%
if %_tempSlot431% lss 0 (set _tempSlot45=[40;92mSlot 4 - %_tempSlot42:~-7%[40;96m) else (set _tempSlot45=Slot 4 - %_tempSlot42:~-7%)
set _tempSlot46=                 %_hammer4% / %_slot4_max_hammer_count%

echo.╔═ %_tempSlot15% ══════╗	╔═ %_tempSlot25% ══════╗
echo.║Name	:%_tempSlot14:~-17%║	║Name	:%_tempSlot24:~-17%║
echo.║ID	:%_tempSlot11:~-17%║	║ID	:%_tempSlot21:~-17%║
echo.║Hammer	:%_tempSlot16:~-17%║	║Hammer	:%_tempSlot26:~-17%║
echo.║Block	:%_tempSlot13:~-17%║	║Block	:%_tempSlot23:~-17%║
echo.╚═════════════════════════╝	╚═════════════════════════╝
echo.╔═ %_tempSlot35% ══════╗	╔═ %_tempSlot45% ══════╗
echo.║Name	:%_tempSlot34:~-17%║	║Name	:%_tempSlot44:~-17%║
echo.║ID	:%_tempSlot31:~-17%║	║ID	:%_tempSlot41:~-17%║
echo.║Hammer	:%_tempSlot36:~-17%║	║Hammer	:%_tempSlot46:~-17%║
echo.║Block	:%_tempSlot33:~-17%║	║Block	:%_tempSlot43:~-17%║
echo.╚═════════════════════════╝	╚═════════════════════════╝[40;97m
%_cd%\batch\jq.exe -r "\"Auto Upgrade: \(.type) - \(.grade) grade - \(.levelUp) up \(.levelUp+1) - \(if .ele1 == 1 then \"Fire\" elif .ele1 == 2 then \"Water\" elif .ele1 == 3 then \"Land\" elif .ele1 == 4 then \"Wind\" else \"Normal\" end) to \(if .ele2 == 1 then \"Fire\" elif .ele2 == 2 then \"Water\" elif .ele2 == 3 then \"Land\" elif .ele2 == 4 then \"Wind\" else \"Normal\" end)\"" %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoUpgrade.json
set /a _slot=1
:displayMenuAutoCraft2
set /a _countTryAutoCraft=0
set /a _8temp=0
if %_canAutoOnOff% == 1 (if %_canAuto%==5 (call :tryAuto))
if %_8temp% lss 0 (call :autoStart & goto :menuAutoCraftRefreshData)
set /a _slot+=1
if %_slot% lss 5 (goto :displayMenuAutoCraft2)
if %_canAutoOnOff% == 1 (
	echo.[40;96m[1] Update, automatically after 60s	[40;92m╔═══════════════╗[40;96m
	echo.[2] Setting Auto			[40;92m║4.Turn OFF Auto║[40;96m
	echo.[3] User guide				[40;92m╚═══════════════╝[40;96m
	) else (
		echo.[40;96m[1] Update, automatically after 60s	[40;97m╔═══════════════╗[40;96m
		echo.[2] Setting Auto			[40;97m║4.Turn ON Auto ║[40;96m
		echo.[3] User guide				[40;97m╚═══════════════╝[40;96m
		)
choice /c 1234 /n /t 60 /d 1 /m "Enter the number from the keyboard: "
if %errorlevel% equ 1 (echo.└── Updating ... & goto :menuAutoCraftRefreshData)
if %errorlevel% equ 2 (goto :settingAuto)
if %errorlevel% equ 3 (goto :hdsd)
if %errorlevel% equ 4 (goto :canAutoOnOff)
goto :displayMenuAutoCraft
:settingAuto
set /a _slot=1
:settingAuto1
if %_slot% gtr 4 (goto :settingAuto)
call :importSlot
if %_slot% == 1 (set _1temp=%_slot1_id% & set _2temp=%_slot1_type% & set _3temp=%_slot1_block% & set _4temp=%_slot1_item% & set _5temp=%_hammer1% & set _6temp=%_slot1_max_hammer_count% & set _7temp=%_slot1_name%)
if %_slot% == 2 (set _1temp=%_slot2_id% & set _2temp=%_slot2_type% & set _3temp=%_slot2_block% & set _4temp=%_slot2_item% & set _5temp=%_hammer2% & set _6temp=%_slot2_max_hammer_count% & set _7temp=%_slot2_name%)
if %_slot% == 3 (set _1temp=%_slot3_id% & set _2temp=%_slot3_type% & set _3temp=%_slot3_block% & set _4temp=%_slot3_item% & set _5temp=%_hammer3% & set _6temp=%_slot3_max_hammer_count% & set _7temp=%_slot3_name%)
if %_slot% == 4 (set _1temp=%_slot4_id% & set _2temp=%_slot4_type% & set _3temp=%_slot4_block% & set _4temp=%_slot4_item% & set _5temp=%_hammer4% & set _6temp=%_slot4_max_hammer_count% & set _7temp=%_slot4_name%)
set _1temp=%_1temp: =%
set _2temp=%_2temp: =%
set /a _8temp=%_3temp%-%_9cscanBlock%
if "%_2temp%" equ "Upgrade" (goto :settingAutoUpgrade)
call :background
echo.[40;97mSetting Craft
echo.Slot %_slot%[40;96m
echo.
echo.[*]Name		: %_7temp%
echo.[1]ID craft	: [40;97m%_1temp%[40;96m
echo.[2]Craft type: [40;97m%_2temp%[40;96m
echo.[3]Blocks	: [40;97m%_8temp%[40;96m
echo.[*]ItemID	: %_4temp%
echo.[4]Super Craft	: [40;97m%_5temp% / %_6temp% hammer[40;96m
echo.
echo.==========
echo.[5] Switch to Auto Upgrade
echo.[6] Next Slot
echo.==========
echo.[7] Return
echo.[8] Open the website ID item information
echo.[9] Switch to Setting data online
choice /c 123456789 /n /m "Enter the number from the keyboard: "
if %errorlevel% equ 1 (goto :pickCraftID)
if %errorlevel% equ 2 (goto :pickCraftType)
if %errorlevel% equ 3 (goto :pickCraftBlock)
if %errorlevel% equ 4 (goto :pickCraftHammer)
if %errorlevel% equ 6 (set /a _slot+=1 & goto :settingAuto1)
if %errorlevel% equ 5 (
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
if %_slot% == 1 (%_cd%\batch\jq.exe "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type: \"Upgrade\",slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" _infoSlot.json> _tempInfoSlot.json)
if %_slot% == 2 (%_cd%\batch\jq.exe "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type: \"Upgrade\",slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" _infoSlot.json> _tempInfoSlot.json)
if %_slot% == 3 (%_cd%\batch\jq.exe "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type: \"Upgrade\",slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" _infoSlot.json> _tempInfoSlot.json)
if %_slot% == 4 (%_cd%\batch\jq.exe "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type: \"Upgrade\",slot4_block,slot4_item}" _infoSlot.json> _tempInfoSlot.json)
copy _tempInfoSlot.json _infoSlot.json>nul
del /q _tempInfoSlot.json
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
set /p _urlDataOnline=<_urlDataOnline.txt
echo.─── Save online Slot and Super Craft information ...
%_cd%\batch\jq.exe -s -c "." _infoSuperCraft.json> _temp1.txt
set /p _temp1=<_temp1.txt
%_cd%\batch\jq.exe -c "{block9cscan: %_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item, SuperCraft:%_temp1%}" _infoSlot.json> output.json
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlDataOnline% --ssl-no-revoke >nul 2>nul
del /q output.json
echo %_9cscanBlock% > _9cscanBlockSave.txt
goto :settingAutoUpgrade
)
if %errorlevel% equ 7 (goto :displayMenuAutoCraft)
if %errorlevel% equ 9 (goto :settingDataOnline)
if %errorlevel% equ 8 (echo.└─── Processing ...)
%_cd%\batch\jq.exe "[.[]|{name,equipment,elementalType,mat_1,mat_2,mat_3,mat_4,equipment_id,grade,unlock_stage,level_req,max_hammer_count,crystal_cost,mat_1_count,mat_2_count,mat_3_count,mat_4_count,slot: (if .equipment_id == %_slot1_id% then (.slot + 1) else 0 end),picked}]" %_cd%\Data\ModulPlus\Basic.txt> output1.json
%_cd%\batch\jq.exe "[.[]|{name,equipment,elementalType,mat_1,mat_2,mat_3,mat_4,equipment_id,grade,unlock_stage,level_req,max_hammer_count,crystal_cost,mat_1_count,mat_2_count,mat_3_count,mat_4_count,slot: (if .equipment_id == %_slot2_id% then (.slot + 2) else .slot end),picked}]" output1.json> output2.json
%_cd%\batch\jq.exe "[.[]|{name,equipment,elementalType,mat_1,mat_2,mat_3,mat_4,equipment_id,grade,unlock_stage,level_req,max_hammer_count,crystal_cost,mat_1_count,mat_2_count,mat_3_count,mat_4_count,slot: (if .equipment_id == %_slot3_id% then (.slot + 3) else .slot end),picked}]" output2.json> output3.json
%_cd%\batch\jq.exe "[.[]|{name,equipment,elementalType,mat_1,mat_2,mat_3,mat_4,equipment_id,grade,unlock_stage,level_req,max_hammer_count,crystal_cost,mat_1_count,mat_2_count,mat_3_count,mat_4_count,slot: (if .equipment_id == %_slot4_id% then (.slot + 4) else .slot end),picked}]" output3.json> output.json
set /p _urlJson=<%_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingSweep\_urlJson.txt
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlJson% --ssl-no-revoke >nul 2>nul
del /q output.json output1.json output2.json output3.json
start %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\CheckItem\index.html
goto :settingAuto1
:settingAutoUpgrade
call :background
echo.[40;97mSetting Upgrade All Slot
echo.Slot %_slot%[40;96m
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
%_cd%\batch\jq.exe -s -c -r "[.[]|{type,grade,ele1 :(if .ele1 > .ele2 then .ele2 else .ele1 end),ele2: (if .ele2 < .ele1 then .ele1 else .ele2 end),levelUp}]|.[]" _infoUpgrade.json> _tempInfoUpgrade.json
copy _tempInfoUpgrade.json _infoUpgrade.json >nul
%_cd%\batch\jq.exe -s -r  ".[]|\"Type \(.type) \(.grade) grade from level \(.levelUp) up \(.levelUp+1)\n\tgrom element \(if .ele1 == 1 then \"Fire\" elif .ele1 == 2 then \"Water\" elif .ele1 == 3 then \"Land\" elif .ele1 == 4 then \"Wind\" else \"Normal\" end) to \(if .ele2 == 1 then \"Fire\" elif .ele2 == 2 then \"Water\" elif .ele2 == 3 then \"Land\" elif .ele2 == 4 then \"Wind\" else \"Normal\" end)\"" _infoUpgrade.json> _temp.txt
type _temp.txt
del /q _tempInfoUpgrade.json _temp.txt
echo.
echo.[1]Blocks	: [40;97m%_8temp%[40;96m
echo.[2]ItemID	: %_4temp%
echo.[3]Edit Upgrade
echo.==========
echo.
echo.[5]Switch to Craft
echo.[6]Next Slot
echo.==========
echo.[7]Return
echo.[9]Switch to Setting data online
choice /c 123456789 /n /m "Enter the number from the keyboard: "
if %errorlevel% equ 1 (goto :pickCraftBlock)
if %errorlevel% equ 2 (goto :pickCraftItemID)
if %errorlevel% equ 3 (goto :editInfoUpgarde)
if %errorlevel% equ 5 (
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
if %_slot% == 1 (%_cd%\batch\jq.exe "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type: \"Basic\",slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" _infoSlot.json> _tempInfoSlot.json)
if %_slot% == 2 (%_cd%\batch\jq.exe "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type: \"Basic\",slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" _infoSlot.json> _tempInfoSlot.json)
if %_slot% == 3 (%_cd%\batch\jq.exe "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type: \"Basic\",slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" _infoSlot.json> _tempInfoSlot.json)
if %_slot% == 4 (%_cd%\batch\jq.exe "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type: \"Basic\",slot4_block,slot4_item}" _infoSlot.json> _tempInfoSlot.json)
copy _tempInfoSlot.json _infoSlot.json>nul
del /q _tempInfoSlot.json
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
set /p _urlDataOnline=<_urlDataOnline.txt
echo.─── Save online Slot and Super Craft information ...
%_cd%\batch\jq.exe -s -c "." _infoSuperCraft.json> _temp1.txt
set /p _temp1=<_temp1.txt
%_cd%\batch\jq.exe -c "{block9cscan: %_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item, SuperCraft:%_temp1%}" _infoSlot.json> output.json
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlDataOnline% --ssl-no-revoke >nul 2>nul
del /q output.json
echo %_9cscanBlock% > _9cscanBlockSave.txt
goto :settingAuto1
)
if %errorlevel% equ 6 (set /a _slot+=1 & goto :settingAuto1)

if %errorlevel% equ 7 (goto :displayMenuAutoCraft)
if %errorlevel% equ 9 (goto :settingDataOnline)
goto :settingAuto
:editInfoUpgarde
echo.Choose an upgrade item
echo.[1] Weapon
echo.[2] Armor
echo.[3] Belt
echo.[4] Ring
choice /c 1234 /n /m "Enter the number from the keyboard: "
if %errorlevel% == 1 (set _temp1=Weapon)
if %errorlevel% == 2 (set _temp1=Armor)
if %errorlevel% == 3 (set _temp1=Belt)
if %errorlevel% == 4 (set _temp1=Ring)
echo.
choice /c 12345 /m "Choose an upgrade grade: "
set _temp2=%errorlevel%
echo.
echo.[1] From level 0 to level 1
echo.[2] From level 1 to level 2
echo.[3] From level 2 to level 3
choice /c 123 /m "Select upgrade level: "
set /a _temp3=%errorlevel%-1
echo.
echo.[1] Normal
echo.[2] Fire
echo.[3] Water
echo.[4] Land
echo.[5] Wind
choice /c 12345 /m "Select element upgrade begin: "
set /a _temp4=%errorlevel%-1
echo.
echo.[1] Normal
echo.[2] Fire
echo.[3] Water
echo.[4] Land
echo.[5] Wind
choice /c 12345 /m "Select element upgrade end: "
set /a _temp5=%errorlevel%-1
echo.{"type":"%_temp1%","grade":%_temp2%,"ele1":%_temp4%,"ele2":%_temp5%,"levelUp":%_temp3%}> _infoUpgrade.json
goto :settingAutoUpgrade
:settingDataOnline
call :background
set "_temp="
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft

set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_urlDataOnline.txt"
if exist %_file% (set /p _urlDataOnline=<_urlDataOnline.txt)
if exist %_file% (
set /p _urlDataOnline=<_urlDataOnline.txt
echo.[40;97mSetting data online[40;96m
echo.
echo.Data online code is available: %_urlDataOnline%
echo.Local data of Slot and Super Craft
echo.automatically uploaded
echo.https://jsonblob.com/%_urlDataOnline%
) else (echo.Data online code is not found)

echo.
echo.[1]Create 1 new data online code
echo.[2]Enter the old code
echo.[3]Save / Enter data online
echo.==========
echo.[7]Return
echo.[9]Switch to Setting slot
choice /c 123456789 /n /m "Enter the number from the keyboard: "
if %errorlevel% equ 1 (goto :settingDataOnlineChoice1)
if %errorlevel% equ 2 (goto :settingDataOnlineChoice2)
if %errorlevel% equ 3 (goto :settingDataOnlineChoice3)
if %errorlevel% equ 7 (goto :displayMenuAutoCraft)
if %errorlevel% equ 9 (goto :settingAuto1)
goto :settingAuto1
:settingDataOnlineChoice3
%_cd%\batch\jq.exe -s -c "." _infoSuperCraft.json> _temp1.txt
set /p _temp1=<_temp1.txt
%_cd%\batch\jq.exe -c "{block9cscan: %_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item, SuperCraft:%_temp1%}" _infoSlot.json> output.json
set /p _temp1=<output.json
del /q _temp1.txt output.json
set /p _urlDataOnline=<_urlDataOnline.txt
echo.[40;97mLocal data[40;96m
echo.%_temp1%
echo.
echo.[40;97mOnline data[40;96m
curl https://jsonblob.com/api/jsonBlob/%_urlDataOnline% --ssl-no-revoke 2>nul|%_cd%\batch\jq.exe -c "."> _temp2.txt 2>nul
set /p _temp2=<_temp2.txt
echo.%_temp2%
echo.[1] Enter data from online to local
echo.[2] Save data from local to online
echo.[3] Return
choice /c 123 /n /m "Enter the number from the keyboard: "
if %errorlevel% == 1 (
%_cd%\batch\jq.exe "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" _temp2.txt> _infoSlot.json
%_cd%\batch\jq.exe -c ".SuperCraft|.[]" _temp2.txt> _infoSuperCraft.json
echo %_9cscanBlock% > _9cscanBlockSave.txt
del /q _temp2.txt
goto :settingDataOnline
)
if %errorlevel% == 3 (goto :settingDataOnline)
if %errorlevel% == 2 (echo.)
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
set /p _urlDataOnline=<_urlDataOnline.txt
echo.──── Save online Slot and Super Craft information ...
%_cd%\batch\jq.exe -s -c "." _infoSuperCraft.json> _temp1.txt
set /p _temp1=<_temp1.txt
%_cd%\batch\jq.exe -c "{block9cscan: %_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item, SuperCraft:%_temp1%}" _infoSlot.json> output.json
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlDataOnline% --ssl-no-revoke >nul 2>nul
del /q output.json
echo %_9cscanBlock% > _9cscanBlockSave.txt
goto :settingDataOnline
:settingDataOnlineChoice2
set /p "_temp=Old data online code: "
curl https://jsonblob.com/api/jsonBlob/%_temp% --ssl-no-revoke 2>nul|findstr /i SuperCraft>nul
if %errorlevel% == 1 (color 4F & echo.The data online code is incorrect & timeout 10 & goto :settingDataOnline)
echo.%_temp%> _urlDataOnline.txt
echo.Has saved the code!
timeout 2>nul
goto :settingDataOnline
:settingDataOnlineChoice1
echo.
echo.The new code will overwrite the old code
echo.[1]Continue
echo.[2]Return
choice /c 12 /n /m "Enter the number from the keyboard: "
if %errorlevel% == 2 (goto :settingDataOnline)
echo.└─── Create link jsonblob.com ...
%_cd%\batch\jq.exe -s -c "." _infoSuperCraft.json> _temp1.txt
set /p _temp1=<_temp1.txt
%_cd%\batch\jq.exe -c "{block9cscan: %_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item, SuperCraft:%_temp1%}" _infoSlot.json> output.json
curl -i -X "POST" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob --ssl-no-revoke 2>nul|findstr /i location>nul> _temp.txt 2>nul
set /p _temp=<_temp.txt
echo %_temp:~43,19%> _urlDataOnline.txt 2>nul & set "_temp=" & del /q _temp.txt 2>nul
set /p _urlDataOnline=<_urlDataOnline.txt
echo %_9cscanBlock% > _9cscanBlockSave.txt
echo.──── Complete creation link jsonblob.com ...
timeout 2>nul
goto :settingDataOnline
:pickCraftItemID
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
echo.Name			: %_7temp%
echo.ItemID	: %_4temp%
set /p "_temp=Import item ID: "
if %_slot% == 1 (%_cd%\batch\jq.exe "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item: \"%_temp%\",slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" _infoSlot.json> _tempInfoSlot.json)
if %_slot% == 2 (%_cd%\batch\jq.exe "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item: \"%_temp%\",slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" _infoSlot.json> _tempInfoSlot.json)
if %_slot% == 3 (%_cd%\batch\jq.exe "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item: \"%_temp%\",slot4_id,slot4_type,slot4_block,slot4_item}" _infoSlot.json> _tempInfoSlot.json)
if %_slot% == 4 (%_cd%\batch\jq.exe "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item: \"%_temp%\"}" _infoSlot.json> _tempInfoSlot.json)
copy _tempInfoSlot.json _infoSlot.json>nul
del /q _tempInfoSlot.json
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
set /p _urlDataOnline=<_urlDataOnline.txt
echo.──── Save online Slot and Super Craft information ...
%_cd%\batch\jq.exe -s -c "." _infoSuperCraft.json> _temp1.txt
set /p _temp1=<_temp1.txt
%_cd%\batch\jq.exe -c "{block9cscan: %_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item, SuperCraft:%_temp1%}" _infoSlot.json> output.json
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlDataOnline% --ssl-no-revoke >nul 2>nul
del /q output.json
echo %_9cscanBlock% > _9cscanBlockSave.txt
goto :settingAuto1
:pickCraftHammer
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
echo.Name			: %_7temp%
echo.Super Craft		: %_5temp% / %_6temp% hammer
set /p "_temp=The hammer number is: "
rem Check is the number or not
set "var="&for /f "delims=0123456789" %%i in ("%_temp%") do set var=%%i
if defined var (echo Error 1: Not yet digital data type, try again ... & goto :pickCraftHammer)
echo if (keys^|.[] == "h%_1temp%") then (select(keys^|.[] == "h%_1temp%")^|{h%_1temp%: %_temp%}) else (select(keys^|.[] != "h%_1temp%")) end> _filter.txt
%_cd%\batch\jq.exe -f _filter.txt _infoSuperCraft.json> _tempInfoSuperCraft.json
copy _tempInfoSuperCraft.json _infoSuperCraft.json>nul
del /q _tempInfoSuperCraft.jsom _filter.txt
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
set /p _urlDataOnline=<_urlDataOnline.txt
echo.──── Save online Slot and Super Craft information ...
%_cd%\batch\jq.exe -s -c "." _infoSuperCraft.json> _temp1.txt
set /p _temp1=<_temp1.txt
%_cd%\batch\jq.exe -c "{block9cscan: %_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item, SuperCraft:%_temp1%}" _infoSlot.json> output.json
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlDataOnline% --ssl-no-revoke >nul 2>nul
del /q output.json
echo %_9cscanBlock% > _9cscanBlockSave.txt
goto :settingAuto1
:pickCraftBlock
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
echo.Current block	: %_9cscanBlock%
set /p "_temp1=Plus Block: "
rem Check is the number or not
set "var="&for /f "delims=0123456789" %%i in ("%_temp1%") do set var=%%i
if defined var (echo Error 1: Not yet digital data type, try again ... & goto :pickCraftBlock)
set /a _temp=%_temp1%+%_9cscanBlock%
if %_slot% == 1 (%_cd%\batch\jq.exe "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block: %_temp%,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" _infoSlot.json> _tempInfoSlot.json)
if %_slot% == 2 (%_cd%\batch\jq.exe "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block: %_temp%,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" _infoSlot.json> _tempInfoSlot.json)
if %_slot% == 3 (%_cd%\batch\jq.exe "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block: %_temp%,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" _infoSlot.json> _tempInfoSlot.json)
if %_slot% == 4 (%_cd%\batch\jq.exe "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block: %_temp%,slot4_item}" _infoSlot.json> _tempInfoSlot.json)
copy _tempInfoSlot.json _infoSlot.json>nul
del /q _tempInfoSlot.json
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
set /p _urlDataOnline=<_urlDataOnline.txt
echo.──── Save online Slot and Super Craft information ...
%_cd%\batch\jq.exe -s -c "." _infoSuperCraft.json> _temp1.txt
set /p _temp1=<_temp1.txt
%_cd%\batch\jq.exe -c "{block9cscan: %_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item, SuperCraft:%_temp1%}" _infoSlot.json> output.json
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlDataOnline% --ssl-no-revoke >nul 2>nul
del /q output.json
echo %_9cscanBlock% > _9cscanBlockSave.txt
goto :settingAuto1
:pickCraftType
echo.Only support basic type for regular craft
echo.
echo.Choose the type of craft when Super Craft
echo.[1] Basic
echo.[2] Premium
echo.==========
echo.[3] Return
choice /c 123 /n /m "Enter the number from the keyboard: "
if %errorlevel% == 1 (echo 0 > %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_SuperCraftBasicOrPremium.txt)
if %errorlevel% == 2 (echo 1 > %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_SuperCraftBasicOrPremium.txt)
if %errorlevel% == 3 (goto :settingAuto1)
goto :settingAuto1
:pickCraftID
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
set /p "_temp=Auto Craft ID item: "
%_cd%\batch\jq.exe "(if (([.[]|select(.equipment_id == %_temp%)]) != []) then true else false end)" %_cd%\Data\ModulPlus\Basic.txt | findstr /i true >nul
if %errorlevel%==1 (color 4F & echo.└── Error 1: Not a equipment ID & timeout 10 & goto :settingAuto1)
%_cd%\batch\jq.exe ".[]|select(.equipment_id == %_temp%)|(if (.unlock_stage <= %_stage%) then true else false end)" %_cd%\Data\ModulPlus\Basic.txt | findstr /i true >nul
if %errorlevel%==1 (color 4F & echo.└── Error 2: Cannot craft this equipped %_temp% & timeout 10 & goto :settingAuto1)
if %_slot% == 1 (%_cd%\batch\jq.exe "{block9cscan:%_9cscanBlock%,slot1_id: \"%_temp%\",slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" _infoSlot.json> _tempInfoSlot.json)
if %_slot% == 2 (%_cd%\batch\jq.exe "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id: \"%_temp%\",slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" _infoSlot.json> _tempInfoSlot.json)
if %_slot% == 3 (%_cd%\batch\jq.exe "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id: \"%_temp%\",slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" _infoSlot.json> _tempInfoSlot.json)
if %_slot% == 4 (%_cd%\batch\jq.exe "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id: \"%_temp%\",slot4_type,slot4_block,slot4_item}" _infoSlot.json> _tempInfoSlot.json)
copy _tempInfoSlot.json _infoSlot.json>nul
del /q _tempInfoSlot.json
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
set /p _urlDataOnline=<_urlDataOnline.txt
echo.──── Save online Slot and Super Craft information ...
%_cd%\batch\jq.exe -s -c "." _infoSuperCraft.json> _temp1.txt
set /p _temp1=<_temp1.txt
%_cd%\batch\jq.exe -c "{block9cscan: %_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item, SuperCraft:%_temp1%}" _infoSlot.json> output.json
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlDataOnline% --ssl-no-revoke >nul 2>nul
del /q output.json
echo %_9cscanBlock% > _9cscanBlockSave.txt
goto :settingAuto1
:hdsd
call :background
echo.[40;92mAuto Craft?[40;96m
echo.─── Link tutorial: ...
echo.
echo.[40;92mAuto Upgrade?[40;96m
echo.─── Link tutorial: ...
echo.==========
echo.
echo.Contact me!
echo.
echo.[1] Discord tanbt#9827
echo.[2] Telegram @tandotbt
echo.[3] Discord Plantarium - #unofficial-mods
echo.[4] Youtube tanbt
echo.[5] Web gitbook HDSD
echo.==========
choice /c 123456 /n /m "Enter [6] to Return: "
if %errorlevel% equ 1 (start https://discordapp.com/users/466271401796567071 & goto :hdsd)
if %errorlevel% equ 2 (start https://t.me/tandotbt & goto :hdsd)
if %errorlevel% equ 3 (start https://discord.com/channels/539405872346955788/1035354979709485106 & goto :hdsd)
if %errorlevel% equ 4 (start https://www.youtube.com/c/tanbt & goto :hdsd)
if %errorlevel% equ 5 (start https://9cmd.tanvpn.tk/ & goto :hdsd)
if %errorlevel% equ 6 (goto :displayMenuAutoCraft)
goto :displayMenuAutoCraft
:canAutoOnOff
if %_canAutoOnOff% == 0 (set /a _canAutoOnOff=1) else (set /a _canAutoOnOff=0)
echo.└── Updating ...
goto :menuAutoCraftRefreshData
:background
color 0B
mode con:cols=60 lines=25
rem Get the current block
echo.└──── Get the current block ...
curl https://api.tanvpn.tk/blockNow --ssl-no-revoke --location > _9cscanBlock.txt 2>nul & set /p _9cscanBlock=<_9cscanBlock.txt
set /a _9cscanBlock=%_9cscanBlock%
cls
set /a _canAuto=%_premiumTXOK% + %_passwordOK% + %_publickeyOK% + %_KeyIDOK% + %_utcFileOK%
set _temp=       %_9cscanBlock%
echo.╔═══════════════╗   ╔═══════════════╗   ╔═══════════════╗
if %_canAuto%==5 echo ║Ví %_vi:~0,7%***	║   ║Block: %_temp:~-7% ║   ║[40;92mCan Auto? [X]	[40;96m║
if not %_canAuto%==5 echo ║Ví %_vi:~0,7%***	║   ║Block: %_temp:~-7% ║   ║[40;97mCan Auto? [ ]	[40;96m║
echo.╚═══════════════╝   ╚═══════════════╝   ╚═══════════════╝
exit /b
:importSlot
if %_slot% == 1 (set "_slot1_id=" & set "_slot1_type=" & set "_slot1_block=" & set "_slot1_item=" & set "_slot1_name=" & set "_hammer1=" & set "_slot1_max_hammer_count=")
if %_slot% == 2 (set "_slot2_id=" & set "_slot2_type=" & set "_slot2_block=" & set "_slot2_item=" & set "_slot2_name=" & set "_hammer2=" & set "_slot2_max_hammer_count=")
if %_slot% == 3 (set "_slot3_id=" & set "_slot3_type=" & set "_slot3_block=" & set "_slot3_item=" & set "_slot3_name=" & set "_hammer3=" & set "_slot3_max_hammer_count=")
if %_slot% == 4 (set "_slot4_id=" & set "_slot4_type=" & set "_slot4_block=" & set "_slot4_item=" & set "_slot4_name=" & set "_hammer4=" & set "_slot4_max_hammer_count=")
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
%_cd%\batch\jq.exe -r ".slot%_slot%_id" _infoSlot.json > slot%_slot%_id.txt
%_cd%\batch\jq.exe -r ".slot%_slot%_type" _infoSlot.json > slot%_slot%_type.txt
%_cd%\batch\jq.exe -r ".slot%_slot%_block" _infoSlot.json > slot%_slot%_block.txt
%_cd%\batch\jq.exe -r ".slot%_slot%_item" _infoSlot.json > slot%_slot%_item.txt
set /p _slot%_slot%_id=<slot%_slot%_id.txt
set /p _slot%_slot%_type=<slot%_slot%_type.txt
set /p _slot%_slot%_block=<slot%_slot%_block.txt
set /p _slot%_slot%_item=<slot%_slot%_item.txt
if %_slot% == 1 (set _tempImport1=%_slot1_id%)
if %_slot% == 2 (set _tempImport1=%_slot2_id%)
if %_slot% == 3 (set _tempImport1=%_slot3_id%)
if %_slot% == 4 (set _tempImport1=%_slot4_id%)
%_cd%\batch\jq.exe -r ".[]|select(.equipment_id == %_tempImport1%)|.name" %_cd%\Data\ModulPlus\Basic.txt > slot%_slot%_name.txt
set /p _slot%_slot%_name=<slot%_slot%_name.txt
findstr /i h%_tempImport1% _infoSuperCraft.json>nul
if %errorlevel%==1 (echo {"h%_tempImport1%":0}>> _infoSuperCraft.json 2>nul)
%_cd%\batch\jq.exe "select(keys|.[] == \"h%_tempImport1%\")|.h%_tempImport1%" _infoSuperCraft.json> hammer%_slot%.txt
set /p _hammer%_slot%=<hammer%_slot%.txt
%_cd%\batch\jq.exe -r ".[]|select(.equipment_id == %_tempImport1%)|.max_hammer_count" %_cd%\Data\ModulPlus\Basic.txt > slot%_slot%_max_hammer_count.txt
set /p _slot%_slot%_max_hammer_count=<slot%_slot%_max_hammer_count.txt
del /q slot%_slot%_id.txt slot%_slot%_type.txt slot%_slot%_block.txt slot%_slot%_item.txt slot%_slot%_name.txt hammer%_slot%.txt slot%_slot%_max_hammer_count.txt
exit /b
:tryAuto
if %_slot% == 1 (set _1temp=%_slot1_id% & set _2temp=%_slot1_type% & set _3temp=%_slot1_block% & set _4temp=%_slot1_item% & set _5temp=%_hammer1% & set _6temp=%_slot1_max_hammer_count% & set _7temp=%_slot1_name%)
if %_slot% == 2 (set _1temp=%_slot2_id% & set _2temp=%_slot2_type% & set _3temp=%_slot2_block% & set _4temp=%_slot2_item% & set _5temp=%_hammer2% & set _6temp=%_slot2_max_hammer_count% & set _7temp=%_slot2_name%)
if %_slot% == 3 (set _1temp=%_slot3_id% & set _2temp=%_slot3_type% & set _3temp=%_slot3_block% & set _4temp=%_slot3_item% & set _5temp=%_hammer3% & set _6temp=%_slot3_max_hammer_count% & set _7temp=%_slot3_name%)
if %_slot% == 4 (set _1temp=%_slot4_id% & set _2temp=%_slot4_type% & set _3temp=%_slot4_block% & set _4temp=%_slot4_item% & set _5temp=%_hammer4% & set _6temp=%_slot4_max_hammer_count% & set _7temp=%_slot4_name%)
set _1temp=%_1temp: =%
set _2temp=%_2temp: =%
set /a _8temp=%_3temp%-%_9cscanBlock%
goto:eof
:autoStart
echo.[40;96m
if "%_2temp%" equ "Upgrade" (goto :tryAutoUpgrade)
:tryAutoCraft
set /a _countTryAutoCraft+=1
if %_countTryAutoCraft% gtr 2 (color 8F & echo.─── Tried Craft / Upgrade 2 times & echo.─── plus 50 blocks for slot %_slot%, ... & %_cd%\data\flashError.exe & set /a _tempAddBlock=50 & goto :autoCraftEditSlotFAILURE_2)
rem Check the number of hammer
if %_5temp% geq %_6temp% (set _tempSuperCraft=true) else (set _tempSuperCraft=false)
if "%_tempSuperCraft%" == "true" (echo.└── Auto Super Craft slot %_slot% ...) else (echo.└── Auto Craft slot %_slot% ...)
rem Create data saving folders
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\autoCraft"
if exist %_folder% (rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\autoCraft)
md %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\autoCraft
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\autoCraft
copy "%_cd%\batch\jq.exe" "jq.exe"> nul
if "%_tempSuperCraft%" == "false" (goto :checkMaterialCraft)
echo.└──── Check Crystal Super Craft conditions
jq -r ".[]|select(.equipment_id == %_1temp%)|.crystal_cost" %_cd%\Data\ModulPlus\Basic.txt> %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\crystal_cost.txt
set /p _crystal_cost=<%_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\crystal_cost.txt
set /a _crystal_cost=%_crystal_cost% 2>nul
echo.───── Balance %_crystal% CRYSTAL
echo.───── %_crystal_cost% CRYSTAL for Super Craft %_7temp%
if %_crystal% lss %_crystal_cost% (goto :tryAutoCraftSuper1)
echo.───── Complete checking Crystal Super Craft conditions
goto :tryAutoCraft1
:tryAutoCraftSuper1
set /a _temp=%_crystal_cost%-%_crystal% 2>nul
echo.───── Need [40;91m%_temp% CRYSTAL[40;96m
echo.
echo.[1] Craft normally
echo.[2] Return and turn off Auto
choice /c 12 /n /t 20 /d 1 /m "Automatically select [1] after 20s: "
if %errorlevel% == 1 (set _tempSuperCraft=false & goto :tryAutoCraft1)
if %errorlevel% == 2 (set /a _canAutoOnOff=0 & goto:eof)
:checkMaterialCraft
echo.└──── Check the material need to craft ...
jq -r "[.[]|select(.equipment_id == %_1temp%)|if (.mat_1_id != \"\") then {mat: .mat_1_id,count: .mat_1_count} else empty end,if (.mat_2_id != \"\") then {mat: .mat_2_id,count: .mat_2_count} else empty end,if (.mat_3_id != \"\") then {mat: .mat_3_id,count: .mat_3_count} else empty end,if (.mat_4_id != \"\") then {mat: .mat_4_id,count: .mat_4_count} else empty end]" %_cd%\Data\ModulPlus\Basic.txt> allMaterial.json
jq "length" allMaterial.json > _lengthMaterial.txt
set /p _lengthMaterial=<_lengthMaterial.txt
set /a _lengthMaterial=%_lengthMaterial% 2>nul
echo.───── Need %_lengthMaterial% type(s) material to craft %_7temp%
set /a _tempCount=0
:checkMaterialCraftLoop
set /a _temp=%_tempCount%+1
if %_tempCount% geq %_lengthMaterial% (goto :tryAutoCraft1)
echo.└────── Check the number of materials %_temp%
jq -r ".[%_tempCount%].mat" allMaterial.json > _temp1.txt
jq -r ".[%_tempCount%].count" allMaterial.json > _temp2.txt
set /p _temp1=<_temp1.txt
set /p _temp2=<_temp2.txt/
set /a _temp2=%_temp2% 2>nul
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_char%\"){inventory{items(inventoryItemId:%_temp1%){count}}}}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json  2>nul
jq -r ".data.stateQuery.avatar.inventory.items|if . == [] then 0 else .[].count end" output.json > _temp3.txt
set /p _temp3=<_temp3.txt
set /a _temp3=%_temp3% 2>nul
echo.─────── Having	: %_temp3%
echo.─────── Need	: %_temp2%
if %_temp3% lss %_temp2% (echo.─────── There is not enough materials & echo.─── switch to auto Upgrade, ... & goto :tryAutoUpgrade)
set /a _tempCount+=1
goto :checkMaterialCraftLoop
:tryAutoCraft1
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\autoCraft
rem Check whether the previous transactions are successful or not
echo ==========
echo Step 0: Check the previous craft transaction
curl https://api.9cscan.com/accounts/%_vi%/transactions?action=combination_equipment14^&limit=6 --ssl-no-revoke 2>nul|jq -r ".transactions|.[].id"> _idCheckStatus.txt 2>nul
set "_idCheckStatus="
for /f "tokens=*" %%a in (_idCheckStatus.txt) do (curl https://api.9cscan.com/transactions/%%a/status --ssl-no-revoke)
echo.
curl https://api.9cscan.com/accounts/%_vi%/transactions?action=combination_equipment14^&limit=6 --ssl-no-revoke 2>nul | jq -r ".transactions|.[].status" | findstr -i success>nul
if %errorlevel% equ 1 (color 4F & echo.└── Error 1: SUCCESS transactions are not found & echo.─── wait 10 minutes after try again, ... & %_cd%\data\flashError.exe & timeout /t 600 /nobreak & echo.└──── Updating ... & goto:eof)
echo.└──── Complete step 0
rem Send your information to my server
echo ==========
echo Step 1: Get unsignedTransaction
if "%_2temp%" equ "Premium" (set _tempBasicOrPre=1) else (set _tempBasicOrPre=0)
set /a _temp5=%_slot%-1
if "%_tempSuperCraft%" == "false" (goto :skipSuperCraftBasicOrPremium)
set /a _temp1=%_SuperCraftBasicOrPremium%+1
echo.Type Super Craft %_7temp%
echo.[1] Basic
echo.[2] Premium
echo.
echo.Automatically select [%_temp1%] after 10s
choice /c 12 /n /t 10 /d %_temp1% /m "Enter the number from the keyboard: "
if %errorlevel% == 1 (set _tempBasicOrPre=0)
if %errorlevel% == 2 (set _tempBasicOrPre=1) else (set _tempBasicOrPre=0)
:skipSuperCraftBasicOrPremium
echo {"vi":"%_vi%","publicKey":"%_publickey%","char":"%_char%","stt":%_countChar%,"premiumTX":"%_premiumTX%","itemIDCraft":%_1temp%,"typeCraft":%_tempBasicOrPre%,"slotCraft":%_temp5%,"superCraft":%_tempSuperCraft%}> input.json 2>nul
curl -X POST -H "accept: application/json" -H "Content-Type: application/json" --data "@input.json" https://api.tanvpn.tk/CraftEquipment --ssl-no-revoke --location> output.json 2>nul
findstr /i Micro output.json> nul
if %errorlevel% equ 0 (echo.└── Error 0.1: Server timeout & echo.─── wait 10 seconds after trying again, ... & %_cd%\data\flashError.exe & timeout /t 10 /nobreak & echo.└──── Updating ... & goto:eof)
findstr /i kqua output.json> nul
if %errorlevel% equ 1 (color 4F & echo.└── Error 0: Unknown error & echo.─── wait 10 minutes after try again, ... & %_cd%\data\flashError.exe & timeout /t 600 /nobreak & echo.└──── Updating ... & goto:eof)
jq -r ".checkqua" output.json> _checkqua.txt 2>nul & set /p _checkqua=<_checkqua.txt
jq -r ".kqua" output.json> _kqua.txt 2>nul
rem Get value exceeding 1024 characters
for %%A in (_kqua.txt) do for /f "usebackq delims=" %%B in ("%%A") do (
  set "_kqua=%%B"
  goto :tryAutoCraft2
)
:tryAutoCraft2
if %_checkqua% == 0 (echo.└── %_kqua% ... & echo.─── wait 10 minutes after try again, ... & %_cd%\data\flashError.exe & timeout /t 600 /nobreak & echo.└──── Updating ... & goto:eof)
jq -r ".option1" output.json> _optionBlock1.txt
jq -r ".option2" output.json> _optionBlock2.txt
jq -r ".option3" output.json> _optionBlock3.txt
jq -r ".option4" output.json> _optionBlock4.txt
set /p _optionBlock1=<_optionBlock1.txt
set /p _optionBlock2=<_optionBlock2.txt
set /p _optionBlock3=<_optionBlock3.txt
set /p _optionBlock4=<_optionBlock4.txt
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
  goto :tryAutoCraft3
)
:tryAutoCraft3
if [%_signature%] == [] (color 4F & echo.└──── Error 1: The password saved is not right ... & %_cd%\data\flashError.exe & echo.───── wait 10 minutes after try again, ... & timeout /t 600 /nobreak & echo.└──── Updating ... & goto:eof)
echo.└──── Get Signature successful
echo ==========
echo Step 3: Get signTransaction
echo.
if "%_tempSuperCraft%" == "true" (echo.[1] Continue Super craft %_7temp%, automatic after 10s) else (echo.[1] Continue craft %_7temp%, automatic after 10s)
echo.[2] Return menu and turn off Auto
choice /c 12 /n /t 10 /d 1 /m "Enter from the keyboard: "
if %errorlevel%==1 (goto :tryAutoCraft4)
if %errorlevel%==2 (set /a _canAutoOnOff=0 & goto:eof)
:tryAutoCraft4
echo.└── Export the list of items before craft
rem Capture the list of items before and after
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_char%\"){inventory{equipments{grade,id,itemSubType,elementalType,equipped,itemId,level,statsMap{aTK,hP,dEF,sPD,hIT,cRI},skills{elementalType,chance,power},stat{value,type}}}}}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json  2>nul
jq "[.data.stateQuery.avatar.inventory.equipments|.[]]" output.json > before.json
rem Find signTransaction
echo {"query":"query{transaction{signTransaction(unsignedTransaction:\"%_kqua%\",signature:\"%_signature%\")}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json  2>nul
echo.─── Find signTransaction ...
jq -r "..|.signTransaction?|select(.)" output.json> _signTransaction.txt 2>nul
echo.└──── Get signTransaction successful
echo ==========
echo Step 4: Get stageTransaction
echo.
rem Get value exceeding 1024 characters
for %%A in (_signTransaction.txt) do for /f "usebackq delims=" %%B in ("%%A") do (
  set "_signTransaction=%%B"
  goto :tryAutoCraft5
)
:tryAutoCraft5
echo {"query":"mutation{stageTransaction(payload:\"%_signTransaction%\")}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json  2>nul
echo.└── Find stageTransaction ...
jq -r "..|.stageTransaction?|select(.)" output.json> _stageTransaction.txt 2>nul
echo.└──── Get stageTransaction successful
set /a _countKtraAuto=0
set /a _countKtraStaging=0
:ktraAutoCraft
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
if "%_tempSuperCraft%" == "true" (echo Step 5: Check auto Super craft %_7temp%) else (echo Step 5: Check auto craft %_7temp%)
echo character: %_name%
echo.slot: %_slot%
echo.─── Check %_countKtraStaging% time(s)
if %_countKtraStaging% gtr 50 (color 8F & echo.─── Status: Auto craft failure & echo.─── the cause is node broken & echo.─── use next node and try again ... & %_cd%\data\flashError.exe & call :changeNode & timeout /t 20 /nobreak & echo.└──── Updating ... & goto:eof)
set /p _stageTransaction=<_stageTransaction.txt
echo {"query":"query{transaction{transactionResult(txId:\"%_stageTransaction%\"){txStatus}}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json 2>nul
echo.└── Find txStatus ...
jq -r "..|.txStatus?|select(.)" output.json> _txStatus.txt 2>nul
set /p _txStatus=<_txStatus.txt
if "%_txStatus%" == "STAGING" (color 0B & echo.─── Status: Auto craft happenning & echo.─── check again after 15s ... & set /a _countKtraAuto=0 & timeout /t 15 /nobreak>nul & goto :ktraAutoCraft)
if "%_txStatus%" == "FAILURE" (color 4F & echo.─── Status: Auto craft failure & echo.─── plus 50 blocks for slot %_slot%, ... & %_cd%\data\flashError.exe & set /a _tempAddBlock=50 & goto :autoCraftEditSlotFAILURE)
if "%_txStatus%" == "INVALID" (if %_countKtraAuto% lss 4 (color 8F & echo.─── Status: Auto craft temp failure & echo.─── check again %_countKtraAuto% time after 15s ... & timeout /t 15 /nobreak>nul & goto :ktraAutoCraft))
if "%_txStatus%" == "INVALID" (if %_countKtraAuto% geq 4 (color 8F & echo.─── Status: Auto craft failure & echo.─── plus 50 blocks for slot %_slot%, ... & %_cd%\data\flashError.exe & set /a _tempAddBlock=50 & goto :autoCraftEditSlotFAILURE))
if "%_txStatus%" == "SUCCESS" (color 2F & echo.─── Status: Auto craft successful & goto :autoCraftEditSlotSUCCESS)
if %_countKtraAuto% lss 4 (color 4F & echo.─── Error 2.1: Unknown error & echo.─── check again %_countKtraAuto% time(s) after 15s ... & timeout /t 15 /nobreak>nul & goto :ktraAutoCraft)
if %_countKtraAuto% geq 4 (color 4F & echo.─── Error 2.2: Unknown error & echo.─── wait 10 minutes after try again auto craft, ... & %_cd%\data\flashError.exe & timeout /t 600 /nobreak & echo.└──── Updating ... & goto:eof)
:autoCraftEditSlotSUCCESS
if "%_tempSuperCraft%" equ "false" (goto :autoCraftEditSlotSUCCESS_2)
set /a _tempAddBlock=20
echo.└──── Reset hammer Supper Craft for %_7temp%
echo if (keys^|.[] == "h%_1temp%") then (select(keys^|.[] == "h%_1temp%")^|{h%_1temp%: 0}) else (select(keys^|.[] != "h%_1temp%")) end> _filter.txt
jq -f _filter.txt %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSuperCraft.json> _tempInfoSuperCraft.json
copy _tempInfoSuperCraft.json %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSuperCraft.json >nul
echo.───── Complete reset Supper Craft hammer for %_7temp%
goto :autoCraftEditSlotFAILURE_2
:autoCraftEditSlotSUCCESS_2
echo.└──── Save Slot information blocks %_slot% ...
echo.───── Export the list of items after craft
rem Save the list of items before and after
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_char%\"){inventory{equipments{grade,id,itemSubType,elementalType,equipped,itemId,level,statsMap{aTK,hP,dEF,sPD,hIT,cRI},skills{elementalType,chance,power},stat{value,type}}}}}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json  2>nul
jq "[.data.stateQuery.avatar.inventory.equipments|.[]]" output.json > after.json
echo [> 1.txt & echo ,> 2.txt & echo ]> 3.txt
type 1.txt before.json 2.txt after.json 3.txt> output.json 2>nul
jq "flatten|group_by(.itemId)|.[]|select(length == 1)" output.json> _itemCraftDone.json
jq -r -f %_cd%\Data\ModulPlus\slotBasic.txt _itemCraftDone.json> _option.json
jq -r ".itemId" _option.json> _itemIdCraft.txt
set /p _itemIdCraft=<_itemIdCraft.txt
jq -r ".option2" _option.json> _hasOption2.txt
set /p _hasOption2=<_hasOption2.txt
jq -r ".skill" _option.json> _hasSkill.txt
set /p _hasSkill=<_hasSkill.txt
rem Get the current block
echo.───── Get the current block ...
curl https://api.tanvpn.tk/blockNow --ssl-no-revoke --location > _9cscanBlock.txt 2>nul & set /p _9cscanBlock=<_9cscanBlock.txt
set /a _9cscanBlock=%_9cscanBlock%
set /a _tempBlockEnd=%_9cscanBlock%+%_optionBlock1%+%_hasOption2%*%_optionBlock2%+%_hasSkill%*%_optionBlock3%
if %_slot% == 1 (jq "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block: %_tempBlockEnd%,slot1_item: \"%_itemIdCraft%\",slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json> _tempInfoSlot.json)
if %_slot% == 2 (jq "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block: %_tempBlockEnd%,slot2_item: \"%_itemIdCraft%\",slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json> _tempInfoSlot.json)
if %_slot% == 3 (jq "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block: %_tempBlockEnd%,slot3_item: \"%_itemIdCraft%\",slot4_id,slot4_type,slot4_block,slot4_item}" %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json> _tempInfoSlot.json)
if %_slot% == 4 (jq "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block: %_tempBlockEnd%,slot4_item: \"%_itemIdCraft%\"}" %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json> _tempInfoSlot.json)
copy _tempInfoSlot.json %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json >nul
echo.───── Complete save Slot information %_slot%
set _temp1=%_temp1: =%
echo.└──── Set +1 Supper Craft hammer for %_7temp%
echo if (keys^|.[] == "h%_1temp%") then (select(keys^|.[] == "h%_1temp%")^|{h%_1temp%: (.h%_1temp%+1)}) else (select(keys^|.[] != "h%_1temp%")) end> _filter.txt
jq -f _filter.txt %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSuperCraft.json> _tempInfoSuperCraft.json
copy _tempInfoSuperCraft.json %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSuperCraft.json >nul
echo.───── Complete +1 Supper Craft hammer for %_7temp%
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
set /p _urlDataOnline=<_urlDataOnline.txt
echo.───── Save online Slot and Super Craft information ...
%_cd%\batch\jq.exe -s -c "." _infoSuperCraft.json> _temp1.txt
set /p _temp1=<_temp1.txt
%_cd%\batch\jq.exe -c "{block9cscan: %_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item, SuperCraft:%_temp1%}" _infoSlot.json> output.json
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlDataOnline% --ssl-no-revoke >nul 2>nul
del /q output.json
echo %_9cscanBlock% > _9cscanBlockSave.txt
timeout /t 10 /nobreak & echo.└──── Updating ... & goto:eof
goto:eof
:autoCraftEditSlotFAILURE
if "%_tempSuperCraft%" equ "false" (goto :autoCraftEditSlotFAILURE_2)
echo.└──── Set -1 Supper Craft hammer for %_7temp%
echo if (keys^|.[] == "h%_1temp%") then (select(keys^|.[] == "h%_1temp%")^|{h%_1temp%: (.h%_1temp%-1)}) else (select(keys^|.[] != "h%_1temp%")) end> _filter.txt
jq -f _filter.txt %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSuperCraft.json> _tempInfoSuperCraft.json
copy _tempInfoSuperCraft.json %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSuperCraft.json >nul
echo.───── Complete -1 Supper Craft hammer for %_7temp%
:autoCraftEditSlotFAILURE_2
echo.└──── Set +%_tempAddBlock% blocks for slot %_slot% ...
rem Get the current block
echo.└──── Get the current block ...
curl https://api.tanvpn.tk/blockNow --ssl-no-revoke --location > _9cscanBlock.txt 2>nul & set /p _9cscanBlock=<_9cscanBlock.txt
set /a _9cscanBlock=%_9cscanBlock%
set /a _tempBlockEnd=%_9cscanBlock%+%_tempAddBlock%
if %_slot% == 1 (jq "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block: %_tempBlockEnd%,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json> _tempInfoSlot.json)
if %_slot% == 2 (jq "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block: %_tempBlockEnd%,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json> _tempInfoSlot.json)
if %_slot% == 3 (jq "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block: %_tempBlockEnd%,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json> _tempInfoSlot.json)
if %_slot% == 4 (jq "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block: %_tempBlockEnd%,slot4_item}" %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json> _tempInfoSlot.json)
copy _tempInfoSlot.json %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json >nul
echo.└────── Complete save Slot information %_slot% ...
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
set /p _urlDataOnline=<_urlDataOnline.txt
echo.─────── Save online Slot and Super Craft information ...
%_cd%\batch\jq.exe -s -c "." _infoSuperCraft.json> _temp1.txt
set /p _temp1=<_temp1.txt
%_cd%\batch\jq.exe -c "{block9cscan: %_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item, SuperCraft:%_temp1%}" _infoSlot.json> output.json
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlDataOnline% --ssl-no-revoke >nul 2>nul
del /q output.json
echo %_9cscanBlock% > _9cscanBlockSave.txt
timeout /t 10 /nobreak & echo.└──── Updating ... & goto:eof
goto:eof

:tryAutoUpgrade
set /a _countTryAutoCraft+=1
if %_countTryAutoCraft% gtr 2 (color 8F & echo.─── Tried Craft / Upgrade 2 times & echo.─── plus 50 blocks for slot %_slot%, ... & %_cd%\data\flashError.exe & set /a _tempAddBlock=50 & goto :autoCraftEditSlotFAILURE_2)
echo.└── Auto upgrade slot %_slot% ...
rem Create data saving folders
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\autoUpgrade"
if exist %_folder% (rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\autoUpgrade)
md %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\autoUpgrade
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\autoUpgrade
copy "%_cd%\batch\jq.exe" "jq.exe"> nul
jq -r "\"─── \(.type) \(.grade) grade from level \(.levelUp) up \(.levelUp+1)\n─── with element \(if .ele1 == 1 then \"Fire\" elif .ele1 == 2 then \"Water\" elif .ele1 == 3 then \"Land\" elif .ele1 == 4 then \"Wind\" else \"Normal\" end) to \(if .ele2 == 1 then \"Fire\" elif .ele2 == 2 then \"Water\" elif .ele2 == 3 then \"Land\" elif .ele2 == 4 then \"Wind\" else \"Normal\" end)\"" %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoUpgrade.json
echo.─── Choose 2 equipment with the highest and lowest CP ...
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_char%\"){inventory{equipments{grade,id,itemSubType,elementalType,equipped,itemId,level,statsMap{aTK,hP,dEF,sPD,hIT,cRI},skills{elementalType,chance,power},stat{value,type}}}}}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json 2>nul
echo ^".data.stateQuery.avatar.inventory.equipments^|.[]^|select(.itemSubType == ^\^"^\(.type^|ascii_upcase)^\^")^|select(.grade == ^\(.grade))^|select(.level == ^\(.levelUp))^|select(((if .elementalType == ^\^"WIND^\^" then 4 elif .elementalType == ^\^"LAND^\^" then 3 elif .elementalType == ^\^"WATER^\^" then 2 elif .elementalType == ^\^"FIRE^\^" then 1 else 0 end) ^>= ^\(.ele1))and(if .elementalType == ^\^"WIND^\^" then 4 elif .elementalType == ^\^"LAND^\^" then 3 elif .elementalType == ^\^"WATER^\^" then 2 elif .elementalType == ^\^"FIRE^\^" then 1 else 0 end) ^<= ^\(.ele2))^|{itemId,stat: (.stat.value),CP: (if .skills != [] then (.statsMap^|(.hP*0.7+.aTK*10.5+.dEF*10.5+.sPD*3+.hIT*2.3)*1.15^|round) else (.statsMap^|.hP*0.7+.aTK*10.5+.dEF*10.5+.sPD*3+.hIT*2.3^|round) end)}^"> _filter1.txt 2>nul
jq -r -f _filter1.txt %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoUpgrade.json> _filter2.txt 2>nul
jq -c -f _filter2.txt output.json> output2.json 2>nul
jq -c "(if (.slot1_block > %_9cscanBlock%) then {itemId: .slot1_item} else empty end),(if (.slot2_block > %_9cscanBlock%) then {itemId: .slot2_item} else empty end),(if (.slot3_block > %_9cscanBlock%) then {itemId: .slot3_item} else empty end),(if (.slot4_block > %_9cscanBlock%) then {itemId: .slot4_item} else empty end)"  %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json> output3.json 2>nul
type output2.json output3.json> output4.json 2>nul
jq -s "[group_by(.itemId)|.[]|select(length == 1)|.[]|select(length > 1)]" output4.json> output5.json 2>nul
jq "if (length > 2) then true else false end" output5.json 2>nul | findstr /i true >nul
if %errorlevel% == 1 (echo.─── Not enough equipment to upgrade & echo.─── switch to auto Craft, ... & goto :tryAutoCraft)
jq -r "max_by(.CP).itemId|select(.)" output5.json> _itemA.txt
jq -r "min_by(.CP).itemId|select(.)" output5.json> _itemB.txt
set /p _itemA=<_itemA.txt
set /p _itemB=<_itemB.txt
echo.─── Equipment is upgraded:
echo.───── %_itemA%
echo.─── Equipment as an upgrade material:
echo.───── %_itemB%
:tryAutoUpgrade1
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\autoUpgrade
rem Check whether the previous transactions are successful or not
echo ==========
echo Step 0: Check previous upgrade transaction
curl https://api.9cscan.com/accounts/%_vi%/transactions?action=item_enhancement11^&limit=6 --ssl-no-revoke 2>nul|jq -r ".transactions|.[].id"> _idCheckStatus.txt 2>nul
set "_idCheckStatus="
for /f "tokens=*" %%a in (_idCheckStatus.txt) do (curl https://api.9cscan.com/transactions/%%a/status --ssl-no-revoke)
echo.
curl https://api.9cscan.com/accounts/%_vi%/transactions?action=item_enhancement11^&limit=6 --ssl-no-revoke 2>nul | jq -r ".transactions|.[].status" | findstr -i success>nul
if %errorlevel% equ 1 (color 4F & echo.└── Error 1: SUCCESS transactions are not found & echo.─── wait 10 minutes after try again, ... & %_cd%\data\flashError.exe & timeout /t 600 /nobreak & goto:eof & echo.└──── Updating ... & goto:eof)
echo.└──── Complete step 0
rem Send your information to my server
echo ==========
echo Step 1: Get unsignedTransaction
set /a _temp5=%_slot%-1
echo {"vi":"%_vi%","publicKey":"%_publickey%","char":"%_char%","stt":%_countChar%,"premiumTX":"%_premiumTX%","slotUpgrade":%_temp5%,"itemA":"%_itemA%","itemB":"%_itemB%"}> input.json 2>nul
curl -X POST -H "accept: application/json" -H "Content-Type: application/json" --data "@input.json" https://api.tanvpn.tk/UpgradeEquipment --ssl-no-revoke --location> output.json 2>nul
findstr /i Micro output.json> nul
if %errorlevel% equ 0 (echo.└── Error 0.1: Server timeout & echo.─── wait 10 seconds after trying again, ... & %_cd%\data\flashError.exe & timeout /t 10 /nobreak & echo.└──── Updating ... & goto:eof)
findstr /i kqua output.json> nul
if %errorlevel% equ 1 (color 4F & echo.└── Error 0: Unknown error & echo.─── wait 10 minutes after try again, ... & %_cd%\data\flashError.exe & timeout /t 600 /nobreak & echo.└──── Updating ... & goto:eof)
jq -r ".checkqua" output.json> _checkqua.txt 2>nul & set /p _checkqua=<_checkqua.txt
jq -r ".kqua" output.json> _kqua.txt 2>nul
rem Get value exceeding 1024 characters
for %%A in (_kqua.txt) do for /f "usebackq delims=" %%B in ("%%A") do (
  set "_kqua=%%B"
  goto :tryAutoUpgrade2
)
:tryAutoUpgrade2
if %_checkqua% == 0 (echo.└── %_kqua% ... & echo.─── wait 10 minutes after try again, ... & %_cd%\data\flashError.exe & timeout /t 600 /nobreak & echo.└──── Updating ... & goto:eof)
echo.└──── Get unsignedTransaction thành công
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
  goto :tryAutoUpgrade3
)
:tryAutoUpgrade3
if [%_signature%] == [] (color 4F & echo.└──── Error 1: The password saved is not right ... & %_cd%\data\flashError.exe & echo.───── wait 10 minutes after try again, ... & timeout /t 600 /nobreak & goto:eof & echo.└──── Updating ... & goto:eof)
echo.└──── Get Signature thành công
echo ==========
echo Step 3: Get signTransaction
jq -r "\"─── \(.type) \(.grade) grade from level \(.levelUp) up \(.levelUp+1)\n─── with element \(if .ele1 == 1 then \"Fire\" elif .ele1 == 2 then \"Water\" elif .ele1 == 3 then \"Land\" elif .ele1 == 4 then \"Wind\" else \"Normal\" end) to \(if .ele2 == 1 then \"Fire\" elif .ele2 == 2 then \"Water\" elif .ele2 == 3 then \"Land\" elif .ele2 == 4 then \"Wind\" else \"Normal\" end)\"" %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoUpgrade.json
echo.
echo.[1] Continue upgrade, automatic after 10s
echo.[2] Return menu and turn off Auto
choice /c 12 /n /t 10 /d 1 /m "Enter from the keyboard: "
if %errorlevel%==1 (goto :tryAutoUpgrade4)
if %errorlevel%==2 (set /a _canAutoOnOff=0 & goto:eof)
:tryAutoUpgrade4
rem Find signTransaction
echo {"query":"query{transaction{signTransaction(unsignedTransaction:\"%_kqua%\",signature:\"%_signature%\")}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json  2>nul
echo.─── Find signTransaction ...
jq -r "..|.signTransaction?|select(.)" output.json> _signTransaction.txt 2>nul
echo.└──── Get signTransaction thành công
echo ==========
echo Step 4: Get stageTransaction
echo.
rem Get value exceeding 1024 characters
for %%A in (_signTransaction.txt) do for /f "usebackq delims=" %%B in ("%%A") do (
  set "_signTransaction=%%B"
  goto :tryAutoUpgrade5
)
:tryAutoUpgrade5
echo {"query":"mutation{stageTransaction(payload:\"%_signTransaction%\")}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json  2>nul
echo.└── Find stageTransaction ...
jq -r "..|.stageTransaction?|select(.)" output.json> _stageTransaction.txt 2>nul
echo.└──── Get stageTransaction thành công
set /a _countKtraAuto=0
set /a _countKtraStaging=0
:ktraAutoUpgrade
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
echo Step 5: Check auto upgrade
echo character: %_name%
echo.slot: %_slot%
jq -r "\"─── \(.type) \(.grade) grade from level \(.levelUp) up \(.levelUp+1)\n─── with element \(if .ele1 == 1 then \"Fire\" elif .ele1 == 2 then \"Water\" elif .ele1 == 3 then \"Land\" elif .ele1 == 4 then \"Wind\" else \"Normal\" end) to \(if .ele2 == 1 then \"Fire\" elif .ele2 == 2 then \"Water\" elif .ele2 == 3 then \"Land\" elif .ele2 == 4 then \"Wind\" else \"Normal\" end)\"" %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoUpgrade.json
echo.─── Check %_countKtraStaging% time(s)
if %_countKtraStaging% gtr 50 (color 8F & echo.─── Status: Auto upgrade failure & echo.─── the cause is node broken & echo.─── use next node and try again ... & %_cd%\data\flashError.exe & call :changeNode & timeout /t 20 /nobreak & echo.└──── Updating ... & goto:eof)
set /p _stageTransaction=<_stageTransaction.txt
echo {"query":"query{transaction{transactionResult(txId:\"%_stageTransaction%\"){txStatus}}}"}> input.json 2>nul
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json 2>nul
echo.└── Find txStatus ...
jq -r "..|.txStatus?|select(.)" output.json> _txStatus.txt 2>nul
set /p _txStatus=<_txStatus.txt
if "%_txStatus%" == "STAGING" (color 0B & echo.─── Status: Auto upgrade happenning & echo.─── check again after 15s ... & set /a _countKtraAuto=0 & timeout /t 15 /nobreak>nul & goto :ktraAutoUpgrade)
if "%_txStatus%" == "FAILURE" (color 4F & echo.─── Status: Auto upgrade failure & echo.─── plus 50 blocks for slot %_slot%, ... & %_cd%\data\flashError.exe & set /a _tempAddBlock=50 & goto :autoCraftEditSlotFAILURE_2)
if "%_txStatus%" == "INVALID" (if %_countKtraAuto% lss 4 (color 8F & echo.─── Status: Auto upgrade temp failure & echo.─── check again %_countKtraAuto% time after 15s ... & timeout /t 15 /nobreak>nul & goto :ktraAutoUpgrade))
if "%_txStatus%" == "INVALID" (if %_countKtraAuto% geq 4 (color 8F & echo.─── Status: Auto upgrade failure & echo.─── plus 50 blocks for slot %_slot%, ... & %_cd%\data\flashError.exe & set /a _tempAddBlock=50 & goto :autoCraftEditSlotFAILURE_2))
if "%_txStatus%" == "SUCCESS" (color 2F & echo.─── Status: Auto upgrade successful & goto :autoUpgradeEditSlotSUCCESS)
if %_countKtraAuto% lss 4 (color 4F & echo.─── Error 2.1: Unknown error & echo.─── check again %_countKtraAuto% time after 15s ... & timeout /t 15 /nobreak>nul & goto :ktraAutoUpgrade)
if %_countKtraAuto% geq 4 (color 4F & echo.─── Error 2.2: Unknown error & echo.─── wait 10 minutes after try again auto upgrade, ... & %_cd%\data\flashError.exe & timeout /t 600 /nobreak & echo.└──── Updating ... & goto:eof)
goto:eof
:autoUpgradeEditSlotSUCCESS
echo.└──── Save Slot information blocks %_slot% ...
echo.───── Block number save = when Upgrade Great
echo ^".[]^|select(.item_sub_type == \^"\(.type)\^")^|select(.grade == \(.grade))^|select(.level == \(.levelUp+1))^|.great_success_required_block_index^"> _filter1.txt 2>nul
jq -r -f _filter1.txt %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoUpgrade.json> _filter2.txt 2>nul
jq -r -f _filter2.txt %_cd%\Data\ModulPlus\Upgrade.txt> _temp.txt
set /p _temp=<_temp.txt
set /a _temp=%_temp% 2>nul
rem Get the current block
echo.───── Get the current block ...
curl https://api.tanvpn.tk/blockNow --ssl-no-revoke --location > _9cscanBlock.txt 2>nul & set /p _9cscanBlock=<_9cscanBlock.txt
set /a _9cscanBlock=%_9cscanBlock%
set /a _tempBlockEnd=%_9cscanBlock%+%_temp%
if %_slot% == 1 (jq "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block: %_tempBlockEnd%,slot1_item: \"%_itemA%\",slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json> _tempInfoSlot.json)
if %_slot% == 2 (jq "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block: %_tempBlockEnd%,slot2_item: \"%_itemA%\",slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json> _tempInfoSlot.json)
if %_slot% == 3 (jq "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block: %_tempBlockEnd%,slot3_item: \"%_itemA%\",slot4_id,slot4_type,slot4_block,slot4_item}" %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json> _tempInfoSlot.json)
if %_slot% == 4 (jq "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block: %_tempBlockEnd%,slot4_item: \"%_itemA%\"}" %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json> _tempInfoSlot.json)
copy _tempInfoSlot.json %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json >nul
echo.───── Complete save Slot information %_slot%
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
set /p _urlDataOnline=<_urlDataOnline.txt
echo.───── Save online Slot and Super Craft information ...
%_cd%\batch\jq.exe -s -c "." _infoSuperCraft.json> _temp1.txt
set /p _temp1=<_temp1.txt
%_cd%\batch\jq.exe -c "{block9cscan: %_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item, SuperCraft:%_temp1%}" _infoSlot.json> output.json
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlDataOnline% --ssl-no-revoke >nul 2>nul
del /q output.json
echo %_9cscanBlock% > _9cscanBlockSave.txt
timeout /t 10 /nobreak & echo.└──── Updating ... & goto:eof
goto:eof
:changeNode
set /a _node+=1
if %_node% gtr 5 (set /a _node=1)
echo Node %_node% will be used
goto:eof