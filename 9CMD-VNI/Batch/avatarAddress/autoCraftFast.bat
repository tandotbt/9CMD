echo off
mode con:cols=60 lines=25
color 0B
rem Cài tiếng Việt Nam
chcp 65001
cls
rem Cài %_cd% gốc
set /p _cd=<_cd.txt
set _vi=**********************
set _9cscanBlock=*******
set _canAuto=0
set /p _node=<%_cd%\data\_node.txt
set _node=%_node: =%
set /a _premiumTXOK=0 & set /a _passwordOK=0 & set /a _publickeyOK=0 & set /a _keyidOK=0 & set /a _utcFileOK=0 & set /a _canAutoOnOff=0
title Auto Craft Loop  [* to *] [*][*][***]
set /a _countAutoCraftLoop=0
:autoCraftLoop1
set /p "_countViStart=Bắt đầu từ ví:"
set _folderVi=%_cd%\user\trackedAvatar\vi%_countViStart%
if not exist %_folderVi% (echo Không có dữ liệu ví %_countViStart%, thử lại ... & timeout 10 & goto :autoCraftLoop1)
set /p "_countViEnd=Tới ví:"
set _folderVi=%_cd%\user\trackedAvatar\vi%_countViEnd%
if not exist %_folderVi% (echo Không có dữ liệu ví %_countViEnd%, thử lại ... & timeout 10 & goto :autoCraftLoop1)
:autoCraftLoop2
set /a _countVi=%_countViStart%
set /a _countVi-=1
:autoCraftLoop3
set /a _countVi+=1
set /a _countChar=0
if %_countVi% gtr %_countViEnd% (goto :autoCraftLoop2)
set _folderVi=vi%_countVi%
set _folder="%_cd%\User\trackedAvatar\%_folderVi%"
if not exist %_folder% (goto :autoCraftLoop3)
:autoCraftLoop4
set /a _countAutoCraftLoop=0
set /a _countChar+=1
set _folder="%_cd%\User\trackedAvatar\%_folderVi%\char%_countChar%"
if not exist %_folder% (goto :autoCraftLoop3)
:menuAutoCraftRefreshData
if %_countAutoCraftLoop% gtr 0 (goto :autoCraftLoop4)
rem Lấy ví đang được lưu
set /p _vi=<%_cd%\user\trackedAvatar\%_folderVi%\_vi.txt
set /p _char=<%_cd%\user\trackedAvatar\vi%_countVi%\char%_countChar%\_address.txt
set /p _name=<%_cd%\user\trackedAvatar\vi%_countVi%\char%_countChar%\_name.txt
title Auto Craft Loop [%_countViStart% to %_countViEnd%] [%_countVi%][%_countChar%][%_name%]

rem Tạo thư mục lưu dữ liệu
set _folder="%_cd%\User\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft"
if not exist %_folder% (md %_cd%\User\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft)
cd %_cd%\User\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
rem Lấy block hiện tại
echo.└──── Lấy block hiện tại ...
curl https://api.9cscan.com/transactions?limit=0 --ssl-no-revoke> _9cscanBlock.json 2>nul & set /p _9cscanBlock=<_9cscanBlock.json
del /q _9cscanBlock.json & set /a _9cscanBlock=%_9cscanBlock:~-11,-4%
rem Nạp dữ liệu cũ nếu có
echo.───── Nhập dữ liệu nhân vật %_countChar% ...
rem Ktra file UTC có hay không
set _utcfile=^|%_cd%\planet\planet key --path %_cd%\user\utc 2>nul|findstr /i %_vi%>nul
if %errorlevel% equ 0 (set /a _utcFileOK=1)
set _file="%_cd%\user\trackedAvatar\%_folderVi%\premium\_premiumTX.txt"
if exist %_file% (set /p _premiumTX=<%_cd%\user\trackedAvatar\%_folderVi%\premium\_premiumTX.txt & set /a _premiumTXOK=1)
rem Thử lấy mật khẩu
set _file="%_cd%\user\trackedAvatar\%_folderVi%\auto\password\_password.txt"
if exist %_file% (set /p _password=<%_cd%\user\trackedAvatar\%_folderVi%\auto\password\_password.txt & set /a _passwordOK=1)
rem Thử lấy public key
set _file="%_cd%\user\trackedAvatar\%_folderVi%\auto\publickey\_publickey.txt"
if exist %_file% (set /p _publickey=<%_cd%\user\trackedAvatar\%_folderVi%\auto\publickey\_publickey.txt & set /a _publickeyOK=1)
rem Thử lấy Key ID
set _file="%_cd%\user\trackedAvatar\%_folderVi%\auto\KeyID\_KeyID.txt"
if exist %_file% (set /p _KeyID=<%_cd%\user\trackedAvatar\%_folderVi%\auto\KeyID\_KeyID.txt & set /a _keyidOK=1)

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
echo.───── Lấy Stage đã mở và số dư crystal ...
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_char%\"){actionPoint,dailyRewardReceivedIndex,level,stageMap{count}}agent(address:\"%_vi%\"){crystal}}}"}> input.json 2>nul
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json 2>nul
rem Lọc kết quả lấy dữ liệu
%_cd%\batch\jq.exe -r "..|.count?|select(.)" output.json > _stage.txt 2>nul
%_cd%\batch\jq.exe -r "..|.crystal?|select(.)|tonumber" output.json > _crystal.txt 2>nul
echo.───── Lấy AP và thời gian refill AP ...
"%_cd%\batch\jq.exe" -r ".data.stateQuery.avatar.actionPoint" output.json > _actionPoint.txt 2>nul
"%_cd%\batch\jq.exe" -r ".data.stateQuery.avatar|.dailyRewardReceivedIndex+1700-%_9cscanBlock%" output.json > _timeCount.txt 2>nul
"%_cd%\batch\jq.exe" -r ".data.stateQuery.avatar|.dailyRewardReceivedIndex+1700-%_9cscanBlock%|{sec: ((.*12)%%60),minute: ((((.*12)-(.*12)%%60)/60)%%60),hours: (((((.*12)-(.*12)%%60)/60)-(((.*12)-(.*12)%%60)/60%%60))/60)}" output.json > _infoCharAp.json 2>nul
"%_cd%\batch\jq.exe" -j """\(.hours):\(.minute):\(.sec)""" _infoCharAp.json> _infoCharAp.txt 2>nul
"%_cd%\batch\jq.exe" -r ".data.stateQuery.avatar.level" output.json> _level.txt 2>nul
set /p _infoCharAp=<_infoCharAp.txt
set /p _level=<_level.txt
set /p _actionPoint=<_actionPoint.txt
set /p _timeCount=<_timeCount.txt
rem Xóa file nháp input và output
del /q input.json 2>nul
del /q output.json 2>nul
set /p _stage=<_stage.txt
set /p _crystal=<_crystal.txt
set /a _crystal=%_crystal% 2>nul
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\CheckItem\"
if exist %_folder% (goto :menuAutoCraftRefreshData1)
rem Tạo file index.html
echo.───── Tạo file html xem vật phẩm ...
xcopy "%_cd%\data\CheckItem2\" "%_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\CheckItem\" >nul
set /p _urlJson=<%_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingSweep\_urlJson.txt
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\CheckItem
echo $.getJSON("https://jsonblob.com/api/jsonBlob/%_urlJson%",> index-raw2.html 2>nul
type index-raw1.html index-raw2.html index-raw3.html> index.html 2>nul
del /q index-raw1.html index-raw2.html index-raw3.html index-raw.html
:menuAutoCraftRefreshData1
cd %_cd%\User\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
rem Tạo file _infoSlot.json
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json"
if exist %_file% (goto :menuAutoCraftRefreshData2)
echo.───── Tạo file _infoSlot.json ...
echo {"block9cscan": %_9cscanBlock%,"slot1_id":"10110000","slot1_type":"Basic","slot1_block":0,"slot1_item":"","slot2_id":"10110000","slot2_type":"Basic","slot2_block":0,"slot2_item":"","slot3_id":"10110000","slot3_type":"Basic","slot3_block":0,"slot3_item":"","slot4_id":"10110000","slot4_type":"Basic","slot4_block":0,"slot4_item":""}> _infoSlot.json
:menuAutoCraftRefreshData2
rem Tạo file _infoSuperCraft.json
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSuperCraft.json"
if exist %_file% (goto :menuAutoCraftRefreshData31)
echo.───── Tạo file _infoSuperCraft.json ...
echo {}> _infoSuperCraft.json
:menuAutoCraftRefreshData31
cd %_cd%\User\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
rem Tìm file _urlDataOnline.txt
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_urlDataOnline.txt"
if exist %_file% (goto :menuAutoCraftRefreshData3)
echo.───── Tạo link jsonblob.com ...
%_cd%\batch\jq.exe -s -c "." _infoSuperCraft.json> _temp1.txt
set /p _temp1=<_temp1.txt
%_cd%\batch\jq.exe -c "{block9cscan: %_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item, SuperCraft:%_temp1%}" _infoSlot.json> output.json
curl -i -X "POST" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob --ssl-no-revoke 2>nul|findstr /i location>nul> _temp.txt 2>nul
set /p _temp=<_temp.txt
echo %_temp:~43,19%> _urlDataOnline.txt 2>nul & set "_temp=" & del /q _temp.txt 2>nul
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
set /p _urlDataOnline=<_urlDataOnline.txt
echo.───── Lưu online thông tin Slot và Super Craft ...
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
echo.───── Nhập online thông tin Slot và Super Craft ...
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
echo.───── Tạo _infoUpgrade.json ...
echo.{"type":"Weapon","grade":1,"ele1":0,"ele2":0,"levelUp":0}> _infoUpgrade.json
:menuAutoCraftRefreshData6
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_SuperCraftBasicOrPremium.txt"
if not exist %_file% (echo 0 > %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_SuperCraftBasicOrPremium.txt)
set /p _SuperCraftBasicOrPremium=<_SuperCraftBasicOrPremium.txt
set /a _SuperCraftBasicOrPremium=%_SuperCraftBasicOrPremium% 2>nul
:displayMenuAutoCraft
echo.───── Hoàn thành!
timeout 2 >nul
call :background
set /a _slot=1
set _temp1=                    %_name%
set _temp2=                    %_level%
set _temp3=                    %_stage%
set _temp4=               %_actionPoint%
set _temp5=               %_infoCharAp%
set _temp6=               %_crystal%
echo.╔═ Nhân vật %_countChar% ══════════════════════════════════════════╗
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
%_cd%\batch\jq.exe -r "\"Auto Upgrade: \(.type) - \(.grade) búa - \(.levelUp) lên \(.levelUp+1) - \(if .ele1 == 1 then \"Fire\" elif .ele1 == 2 then \"Water\" elif .ele1 == 3 then \"Land\" elif .ele1 == 4 then \"Wind\" else \"Normal\" end) đến \(if .ele2 == 1 then \"Fire\" elif .ele2 == 2 then \"Water\" elif .ele2 == 3 then \"Land\" elif .ele2 == 4 then \"Wind\" else \"Normal\" end)\"" %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoUpgrade.json
set /a _slot=1
:displayMenuAutoCraft2
set /a _countTryAutoCraft=0
set /a _8temp=0
if %_canAutoOnOff% == 1 (if %_canAuto%==5 (call :tryAuto))
if %_8temp% lss 0 (call :autoStart & goto :menuAutoCraftRefreshData)
set /a _slot+=1
if %_slot% lss 5 (goto :displayMenuAutoCraft2)
set /a _countAutoCraftLoop+=1
if %_canAutoOnOff% == 1 (
	echo.[40;96m[1] Cập nhật lại, tự động sau 60s	[40;92m╔═══════════════╗[40;96m
	echo.[2] Cài đặt Auto			[40;92m║4.Tắt Auto tổng║[40;96m
	echo.[3] Hướng dẫn sử dụng			[40;92m╚═══════════════╝[40;96m
	) else (
		echo.[40;96m[1] Cập nhật lại, tự động sau 60s	[40;97m╔═══════════════╗[40;96m
		echo.[2] Cài đặt Auto			[40;97m║4.Bật Auto tổng║[40;96m
		echo.[3] Hướng dẫn sử dụng			[40;97m╚═══════════════╝[40;96m
		)
choice /c 1234 /n /t 60 /d 1 /m "Nhập số từ bàn phím: "
if %errorlevel% equ 1 (echo.└── Đang cập nhật ... & goto :menuAutoCraftRefreshData)
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
echo.[*]Tên		: %_7temp%
echo.[1]ID craft	: [40;97m%_1temp%[40;96m
echo.[2]Chế tạo kiểu	: [40;97m%_2temp%[40;96m
echo.[3]Blocks	: [40;97m%_8temp%[40;96m
echo.[*]ItemID	: %_4temp%
echo.[4]Super Craft	: [40;97m%_5temp% / %_6temp% hammer[40;96m
echo.
echo.==========
echo.[5] Chuyển sang Auto Upgrade
echo.[6] Chuyển tới slot tiếp theo
echo.==========
echo.[7] Quay lại
echo.[8] Mở trang web thông tin ID trang bị
echo.[9] Chuyển sang Setting data online
choice /c 123456789 /n /m "Nhập số từ bàn phím: "
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
set /p _urlDataOnline=<_urlDataOnline.txt
echo.───── Lưu online thông tin Slot và Super Craft ...
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
if %errorlevel% equ 8 (echo.└─── Đang xử lý ...)
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
%_cd%\batch\jq.exe -s -r  ".[]|\"Loại \(.type) \(.grade) búa từ level \(.levelUp) lên \(.levelUp+1)\n\ttừ thuộc tính \(if .ele1 == 1 then \"Fire\" elif .ele1 == 2 then \"Water\" elif .ele1 == 3 then \"Land\" elif .ele1 == 4 then \"Wind\" else \"Normal\" end) đến \(if .ele2 == 1 then \"Fire\" elif .ele2 == 2 then \"Water\" elif .ele2 == 3 then \"Land\" elif .ele2 == 4 then \"Wind\" else \"Normal\" end)\"" _infoUpgrade.json> _temp.txt
type _temp.txt
del /q _tempInfoUpgrade.json _temp.txt
echo.
echo.[1]Blocks	: [40;97m%_8temp%[40;96m
echo.[2]ItemID	: %_4temp%
echo.[3]Chỉnh sửa Upgrade
echo.==========
echo.
echo.[5]Chuyển sang Craft
echo.[6]Chuyển sang Slot tiếp theo
echo.==========
echo.[7]Quay lại
echo.[9]Chuyển sang [40;97mSetting data online[40;96m
choice /c 123456789 /n /m "Nhập số từ bàn phím: "
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
set /p _urlDataOnline=<_urlDataOnline.txt
echo.───── Lưu online thông tin Slot và Super Craft ...
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
echo.Chọn loại vật phẩm nâng cấp
echo.[1] Weapon
echo.[2] Armor
echo.[3] Belt
echo.[4] Ring
choice /c 1234 /n /m "Nhập số từ bàn phím: "
if %errorlevel% == 1 (set _temp1=Weapon)
if %errorlevel% == 2 (set _temp1=Armor)
if %errorlevel% == 3 (set _temp1=Belt)
if %errorlevel% == 4 (set _temp1=Ring)
echo.
choice /c 12345 /m "Chọn loại búa nâng cấp: "
set _temp2=%errorlevel%
echo.
echo.[1] Từ level 0 lên level 1
echo.[2] Từ level 1 lên level 2
echo.[3] Từ level 2 lên level 3
choice /c 123 /m "Chọn level nâng cấp: "
set /a _temp3=%errorlevel%-1
echo.
echo.[1] Normal
echo.[2] Fire
echo.[3] Water
echo.[4] Land
echo.[5] Wind
choice /c 12345 /m "Chọn thuộc tính nâng cấp từ: "
set /a _temp4=%errorlevel%-1
echo.
echo.[1] Normal
echo.[2] Fire
echo.[3] Water
echo.[4] Land
echo.[5] Wind
choice /c 12345 /m "Chọn thuộc tính nâng cấp tới: "
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
echo.Mã lưu data online đang có: %_urlDataOnline%
echo.Dữ liệu local của slot và SuperCraft
echo.được tự động tải lên
echo.https://jsonblob.com/%_urlDataOnline%
) else (echo.Không tìm thấy mã lưu data online)

echo.
echo.[1]Tạo mới 1 mã lưu data online
echo.[2]Nhập mã cũ
echo.[3]Lưu / Nhập dữ liệu online
echo.==========
echo.[7]Quay lại
echo.[9]Chuyển sang Setting slot
choice /c 123456789 /n /m "Nhập số từ bàn phím: "
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
echo.[40;97mDữ liệu ở local[40;96m
echo.%_temp1%
echo.
echo.[40;97mDữ liệu online[40;96m
curl https://jsonblob.com/api/jsonBlob/%_urlDataOnline% --ssl-no-revoke 2>nul|%_cd%\batch\jq.exe -c "."> _temp2.txt 2>nul
set /p _temp2=<_temp2.txt
echo.%_temp2%
echo.[1] Nhập dữ liệu từ online vào local
echo.[2] Lưu dữ liệu từ local lên online
echo.[3] Quay lại
choice /c 123 /n /m "Nhập số từ bàn phím: "
if %errorlevel% == 1 (
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
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
echo.─── Lưu online thông tin Slot và Super Craft ...
%_cd%\batch\jq.exe -s -c "." _infoSuperCraft.json> _temp1.txt
set /p _temp1=<_temp1.txt
%_cd%\batch\jq.exe -c "{block9cscan: %_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item, SuperCraft:%_temp1%}" _infoSlot.json> output.json
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlDataOnline% --ssl-no-revoke >nul 2>nul
del /q output.json
echo %_9cscanBlock% > _9cscanBlockSave.txt
goto :settingDataOnline
:settingDataOnlineChoice2
set /p "_temp=Mã lưu data online: "
curl https://jsonblob.com/api/jsonBlob/%_temp% --ssl-no-revoke 2>nul|findstr /i SuperCraft>nul
if %errorlevel% == 1 (color 4F & echo.Mã lưu data không chính xác & timeout 10 & goto :settingDataOnline)
echo.%_temp%> _urlDataOnline.txt
echo.Đã lưu lại mã!
timeout 2>nul
goto :settingDataOnline
:settingDataOnlineChoice1
echo.
echo.Mã mới sẽ lưu đè nên mã cũ
echo.[1]Tiếp tục
echo.[2]Quay lại
choice /c 12 /n /m "Nhập số từ bàn phím: "
if %errorlevel% == 2 (goto :settingDataOnline)
echo.└─── Tạo link jsonblob.com ...
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
%_cd%\batch\jq.exe -s -c "." _infoSuperCraft.json> _temp1.txt
set /p _temp1=<_temp1.txt
%_cd%\batch\jq.exe -c "{block9cscan: %_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item, SuperCraft:%_temp1%}" _infoSlot.json> output.json
curl -i -X "POST" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob --ssl-no-revoke 2>nul|findstr /i location>nul> _temp.txt 2>nul
set /p _temp=<_temp.txt
echo %_temp:~43,19%> _urlDataOnline.txt 2>nul & set "_temp=" & del /q _temp.txt 2>nul
set /p _urlDataOnline=<_urlDataOnline.txt
echo %_9cscanBlock% > _9cscanBlockSave.txt
echo.──── Hoàn thành tạo link jsonblob.com ...
timeout 2>nul
goto :settingDataOnline
:pickCraftItemID
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
echo.Tên			: %_7temp%
echo.ItemID	: %_4temp%
set /p "_temp=Nhập item ID: "
if %_slot% == 1 (%_cd%\batch\jq.exe "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item: \"%_temp%\",slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" _infoSlot.json> _tempInfoSlot.json)
if %_slot% == 2 (%_cd%\batch\jq.exe "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item: \"%_temp%\",slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" _infoSlot.json> _tempInfoSlot.json)
if %_slot% == 3 (%_cd%\batch\jq.exe "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item: \"%_temp%\",slot4_id,slot4_type,slot4_block,slot4_item}" _infoSlot.json> _tempInfoSlot.json)
if %_slot% == 4 (%_cd%\batch\jq.exe "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item: \"%_temp%\"}" _infoSlot.json> _tempInfoSlot.json)
copy _tempInfoSlot.json _infoSlot.json>nul
del /q _tempInfoSlot.json
set /p _urlDataOnline=<_urlDataOnline.txt
echo.─── Lưu online thông tin Slot và Super Craft ...
%_cd%\batch\jq.exe -s -c "." _infoSuperCraft.json> _temp1.txt
set /p _temp1=<_temp1.txt
%_cd%\batch\jq.exe -c "{block9cscan: %_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item, SuperCraft:%_temp1%}" _infoSlot.json> output.json
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlDataOnline% --ssl-no-revoke >nul 2>nul
del /q output.json
echo %_9cscanBlock% > _9cscanBlockSave.txt
goto :settingAuto1
:pickCraftHammer
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
echo.Tên			: %_7temp%
echo.Super Craft		: %_5temp% / %_6temp% hammer
set /p "_temp=Số búa đang có: "
rem Kiểm tra có là số hay không
set "var="&for /f "delims=0123456789" %%i in ("%_temp%") do set var=%%i
if defined var (echo Lỗi 1: Chưa là kiểu dữ liệu số, thử lại ... & goto :pickCraftHammer)
echo if (keys^|.[] == "h%_1temp%") then (select(keys^|.[] == "h%_1temp%")^|{h%_1temp%: %_temp%}) else (select(keys^|.[] != "h%_1temp%")) end> _filter.txt
%_cd%\batch\jq.exe -f _filter.txt _infoSuperCraft.json> _tempInfoSuperCraft.json
copy _tempInfoSuperCraft.json _infoSuperCraft.json>nul
del /q _tempInfoSuperCraft.jsom _filter.txt
set /p _urlDataOnline=<_urlDataOnline.txt
echo.─── Lưu online thông tin Slot và Super Craft ...
%_cd%\batch\jq.exe -s -c "." _infoSuperCraft.json> _temp1.txt
set /p _temp1=<_temp1.txt
%_cd%\batch\jq.exe -c "{block9cscan: %_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item, SuperCraft:%_temp1%}" _infoSlot.json> output.json
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlDataOnline% --ssl-no-revoke >nul 2>nul
del /q output.json
echo %_9cscanBlock% > _9cscanBlockSave.txt
goto :settingAuto1
:pickCraftBlock
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
echo.Block hiện tại	: %_9cscanBlock%
set /p "_temp1=Cộng thêm block: "
rem Kiểm tra có là số hay không
set "var="&for /f "delims=0123456789" %%i in ("%_temp1%") do set var=%%i
if defined var (echo Lỗi 1: Chưa là kiểu dữ liệu số, thử lại ... & goto :pickCraftBlock)
set /a _temp=%_temp1%+%_9cscanBlock%
if %_slot% == 1 (%_cd%\batch\jq.exe "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block: %_temp%,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" _infoSlot.json> _tempInfoSlot.json)
if %_slot% == 2 (%_cd%\batch\jq.exe "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block: %_temp%,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" _infoSlot.json> _tempInfoSlot.json)
if %_slot% == 3 (%_cd%\batch\jq.exe "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block: %_temp%,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" _infoSlot.json> _tempInfoSlot.json)
if %_slot% == 4 (%_cd%\batch\jq.exe "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block: %_temp%,slot4_item}" _infoSlot.json> _tempInfoSlot.json)
copy _tempInfoSlot.json _infoSlot.json>nul
del /q _tempInfoSlot.json
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
set /p _urlDataOnline=<_urlDataOnline.txt
echo.─── Lưu online thông tin Slot và Super Craft ...
%_cd%\batch\jq.exe -s -c "." _infoSuperCraft.json> _temp1.txt
set /p _temp1=<_temp1.txt
%_cd%\batch\jq.exe -c "{block9cscan: %_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item, SuperCraft:%_temp1%}" _infoSlot.json> output.json
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlDataOnline% --ssl-no-revoke >nul 2>nul
del /q output.json
echo %_9cscanBlock% > _9cscanBlockSave.txt
goto :settingAuto1
:pickCraftType
echo.Chỉ hỗ trợ kiểu Basic cho craft thông thường
echo.
echo.Chọn kiểu chế tạo khi Super Craft
echo.[1] Basic
echo.[2] Premium
echo.==========
echo.[3] Quay lại
choice /c 123 /n /m "Nhập số từ bàn phím: "
if %errorlevel% == 1 (echo 0 > %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_SuperCraftBasicOrPremium.txt)
if %errorlevel% == 2 (echo 1 > %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_SuperCraftBasicOrPremium.txt)
if %errorlevel% == 3 (goto :settingAuto1)
goto :settingAuto1
:pickCraftID
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
set /p "_temp=ID vật phẩm auto Craft: "
%_cd%\batch\jq.exe "(if (([.[]|select(.equipment_id == %_temp%)]) != []) then true else false end)" %_cd%\Data\ModulPlus\Basic.txt | findstr /i true >nul
if %errorlevel%==1 (color 4F & echo.└── Lỗi 1: Không phải là ID trang bị & timeout 10 & goto :settingAuto1)
%_cd%\batch\jq.exe ".[]|select(.equipment_id == %_temp%)|(if (.unlock_stage <= %_stage%) then true else false end)" %_cd%\Data\ModulPlus\Basic.txt | findstr /i true >nul
if %errorlevel%==1 (color 4F & echo.└── Lỗi 2: Không thể craft trang bị %_temp% & timeout 10 & goto :settingAuto1)
if %_slot% == 1 (%_cd%\batch\jq.exe "{block9cscan:%_9cscanBlock%,slot1_id: \"%_temp%\",slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" _infoSlot.json> _tempInfoSlot.json)
if %_slot% == 2 (%_cd%\batch\jq.exe "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id: \"%_temp%\",slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" _infoSlot.json> _tempInfoSlot.json)
if %_slot% == 3 (%_cd%\batch\jq.exe "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id: \"%_temp%\",slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" _infoSlot.json> _tempInfoSlot.json)
if %_slot% == 4 (%_cd%\batch\jq.exe "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id: \"%_temp%\",slot4_type,slot4_block,slot4_item}" _infoSlot.json> _tempInfoSlot.json)
copy _tempInfoSlot.json _infoSlot.json>nul
del /q _tempInfoSlot.json
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
set /p _urlDataOnline=<_urlDataOnline.txt
echo.─── Lưu online thông tin Slot và Super Craft ...
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
choice /c 123456 /n /m "Nhập [6] để quay lại: "
if %errorlevel% equ 1 (start https://discordapp.com/users/466271401796567071 & goto :hdsd)
if %errorlevel% equ 2 (start https://t.me/tandotbt & goto :hdsd)
if %errorlevel% equ 3 (start https://discord.com/channels/539405872346955788/1035354979709485106 & goto :hdsd)
if %errorlevel% equ 4 (start https://www.youtube.com/c/tanbt & goto :hdsd)
if %errorlevel% equ 5 (start https://9cmd.tanvpn.tk/ & goto :hdsd)
if %errorlevel% equ 6 (goto :displayMenuAutoCraft)
goto :displayMenuAutoCraft
:canAutoOnOff
if %_canAutoOnOff% == 0 (set /a _canAutoOnOff=1) else (set /a _canAutoOnOff=0)
echo.└── Đang cập nhật ...
goto :menuAutoCraftRefreshData
:background
color 0B
mode con:cols=60 lines=25
rem Lấy block hiện tại
echo.└──── Lấy block hiện tại ...
curl https://api.9cscan.com/transactions?limit=0 --ssl-no-revoke> _9cscanBlock.json 2>nul & set /p _9cscanBlock=<_9cscanBlock.json
del /q _9cscanBlock.json & set /a _9cscanBlock=%_9cscanBlock:~-11,-4%
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
if %_countTryAutoCraft% gtr 2 (color 8F & echo.─── Đã thử Craft / Upgrade 2 lần & echo.─── cộng 50 blocks cho slot %_slot%, ... & %_cd%\data\flashError.exe & set /a _tempAddBlock=50 & goto :autoCraftEditSlotFAILURE_2)
rem Kiểm tra số lượng búa
if %_5temp% geq %_6temp% (set _tempSuperCraft=true) else (set _tempSuperCraft=false)
if "%_tempSuperCraft%" == "true" (echo.└── Đang auto Super Craft slot %_slot% ...) else (echo.└── Đang auto Craft slot %_slot% ...)
rem Tạo thư mục lưu dữ liệu
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\autoCraft"
if exist %_folder% (rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\autoCraft)
md %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\autoCraft
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\autoCraft
copy "%_cd%\batch\jq.exe" "jq.exe"> nul
if "%_tempSuperCraft%" == "false" (goto :checkMaterialCraft)
echo.└──── Kiểm tra điều kiện crystal Super Craft
jq -r ".[]|select(.equipment_id == %_1temp%)|.crystal_cost" %_cd%\Data\ModulPlus\Basic.txt> %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\crystal_cost.txt
set /p _crystal_cost=<%_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\crystal_cost.txt
set /a _crystal_cost=%_crystal_cost% 2>nul
echo.───── Ví đang có %_crystal% CRYSTAL
echo.───── Cần %_crystal_cost% CRYSTAL để Super Craft %_7temp%
if %_crystal% lss %_crystal_cost% (goto :tryAutoCraftSuper1)
echo.───── Hoàn thành kiểm tra điều kiện crystal Super Craft
goto :tryAutoCraft1
:tryAutoCraftSuper1
set /a _temp=%_crystal_cost%-%_crystal% 2>nul
echo.───── Thiếu [40;91m%_temp% CRYSTAL[40;96m
echo.
echo.[1] Craft thông thường
echo.[2] Quay lại và tắt auto
choice /c 12 /n /t 20 /d 1 /m "Tự động chọn [1] sau 20s: "
if %errorlevel% == 1 (set _tempSuperCraft=false & goto :tryAutoCraft1)
if %errorlevel% == 2 (set /a _canAutoOnOff=0 & goto:eof)
:checkMaterialCraft
echo.└──── Kiểm tra nguyên liệu cần để craft ...
jq -r "[.[]|select(.equipment_id == %_1temp%)|if (.mat_1_id != \"\") then {mat: .mat_1_id,count: .mat_1_count} else empty end,if (.mat_2_id != \"\") then {mat: .mat_2_id,count: .mat_2_count} else empty end,if (.mat_3_id != \"\") then {mat: .mat_3_id,count: .mat_3_count} else empty end,if (.mat_4_id != \"\") then {mat: .mat_4_id,count: .mat_4_count} else empty end]" %_cd%\Data\ModulPlus\Basic.txt> allMaterial.json
jq "length" allMaterial.json > _lengthMaterial.txt
set /p _lengthMaterial=<_lengthMaterial.txt
set /a _lengthMaterial=%_lengthMaterial% 2>nul
echo.───── Cần %_lengthMaterial% loại nguyên liệu để craft %_7temp%
set /a _tempCount=0
:checkMaterialCraftLoop
set /a _temp=%_tempCount%+1
if %_tempCount% geq %_lengthMaterial% (goto :tryAutoCraft1)
echo.└────── Kiểm tra số lượng nguyên liệu %_temp%
jq -r ".[%_tempCount%].mat" allMaterial.json > _temp1.txt
jq -r ".[%_tempCount%].count" allMaterial.json > _temp2.txt
set /p _temp1=<_temp1.txt
set /p _temp2=<_temp2.txt/
set /a _temp2=%_temp2% 2>nul
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_char%\"){inventory{items(inventoryItemId:%_temp1%){count}}}}}"}> input.json 2>nul
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json  2>nul
jq -r ".data.stateQuery.avatar.inventory.items|if . == [] then 0 else .[].count end" output.json > _temp3.txt
set /p _temp3=<_temp3.txt
set /a _temp3=%_temp3% 2>nul
echo.─────── Đang có	: %_temp3%
echo.─────── Cần	: %_temp2%
if %_temp3% lss %_temp2% (echo.─────── Không đủ nguyên liệu & echo.─── chuyển sang auto Upgrade, ... & goto :tryAutoUpgrade)
set /a _tempCount+=1
goto :checkMaterialCraftLoop
:tryAutoCraft1
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\autoCraft
rem Kiểm tra những giao dịch trước có thành công hay không
echo ==========
echo Bước 0: Kiểm tra những lệnh craft trước
curl https://api.9cscan.com/accounts/%_vi%/transactions?action=combination_equipment14^&limit=6 --ssl-no-revoke 2>nul|jq -r ".transactions|.[].id"> _idCheckStatus.txt 2>nul
set "_idCheckStatus="
for /f "tokens=*" %%a in (_idCheckStatus.txt) do (curl https://api.9cscan.com/transactions/%%a/status --ssl-no-revoke)
echo.
curl https://api.9cscan.com/accounts/%_vi%/transactions?action=combination_equipment14^&limit=6 --ssl-no-revoke 2>nul | jq -r ".transactions|.[].status" | findstr -i success>nul
if %errorlevel% equ 1 (color 4F & echo.└── Lỗi 1: Không tìm thấy giao dịch SUCCESS & echo.─── đợi 10p sau thử lại, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Đang cập nhật ... & goto:eof)
echo.└──── Hoàn thành bước 0
rem Gửi thông tin của bạn tới server của tôi
echo ==========
echo Bước 1: Nhận unsignedTransaction
if "%_2temp%" equ "Premium" (set _tempBasicOrPre=1) else (set _tempBasicOrPre=0)
set /a _temp5=%_slot%-1
if "%_tempSuperCraft%" == "false" (goto :skipSuperCraftBasicOrPremium)
set /a _temp1=%_SuperCraftBasicOrPremium%+1
echo.Kiểu chế tạo Super Craft %_7temp%
echo.[1] Basic
echo.[2] Premium
echo.
echo.Tự động chọn [%_temp1%] sau 10s
choice /c 12 /n /t 10 /d %_temp1% /m "Nhập số từ bàn phím: "
if %errorlevel% == 1 (set _tempBasicOrPre=0)
if %errorlevel% == 2 (set _tempBasicOrPre=1) else (set _tempBasicOrPre=0)
:skipSuperCraftBasicOrPremium
echo {"vi":"%_vi%","publicKey":"%_publickey%","char":"%_char%","stt":%_countChar%,"premiumTX":"%_premiumTX%","itemIDCraft":%_1temp%,"typeCraft":%_tempBasicOrPre%,"slotCraft":%_temp5%,"superCraft":%_tempSuperCraft%}> input.json 2>nul
curl -X POST -H "accept: application/json" -H "Content-Type: application/json" --data "@input.json" https://api.tanvpn.tk/CraftEquipment --ssl-no-revoke --location> output.json 2>nul
findstr /i Micro output.json> nul
if %errorlevel% equ 0 (echo.└── Lỗi 0.1: Quá thời gian chờ & echo.─── đợi 10s sau thử lại, ... & %_cd%\data\flashError.exe & timeout /t 10 /nobreak & echo.└──── Đang cập nhật ... & goto:eof)
findstr /i kqua output.json> nul
if %errorlevel% equ 1 (color 4F & echo.└── Lỗi 0: Không xác định & echo.─── đợi 10p sau thử lại, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Đang cập nhật ... & goto:eof)
jq -r ".checkqua" output.json> _checkqua.txt 2>nul & set /p _checkqua=<_checkqua.txt
jq -r ".kqua" output.json> _kqua.txt 2>nul
rem Nhận giá trị vượt quá 1024 kí tự
for %%A in (_kqua.txt) do for /f "usebackq delims=" %%B in ("%%A") do (
  set "_kqua=%%B"
  goto :tryAutoCraft2
)
:tryAutoCraft2
if %_checkqua% == 0 (echo.└── %_kqua% ... & echo.─── đợi 10p sau thử lại, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Đang cập nhật ... & goto:eof)
jq -r ".option1" output.json> _optionBlock1.txt
jq -r ".option2" output.json> _optionBlock2.txt
jq -r ".option3" output.json> _optionBlock3.txt
jq -r ".option4" output.json> _optionBlock4.txt
set /p _optionBlock1=<_optionBlock1.txt
set /p _optionBlock2=<_optionBlock2.txt
set /p _optionBlock3=<_optionBlock3.txt
set /p _optionBlock4=<_optionBlock4.txt
echo.└──── Nhận unsignedTransaction thành công
echo ==========
echo Bước 2: Nhận Signature
rem Tạo file action
call certutil -decodehex _kqua.txt action >nul
echo.└── Đang sử dụng mật khẩu đã lưu trước đó ...
"%_cd%\planet\planet" key sign --passphrase %_PASSWORD% --store-path %_cd%\user\utc %_KeyID% action> _signature.txt 2>nul
set "_signature="
rem Nhận giá trị vượt quá 1024 kí tự
for %%A in (_signature.txt) do for /f "usebackq delims=" %%B in ("%%A") do (
  set "_signature=%%B"
  goto :tryAutoCraft3
)
:tryAutoCraft3
if [%_signature%] == [] (color 4F & echo.└──── Lỗi 1: Mật khẩu đang lưu chưa đúng ... & %_cd%\data\flashError.exe & echo.───── đợi 10p sau thử lại, ... & timeout /t 3600 /nobreak & echo.└──── Đang cập nhật ... & goto:eof)
echo.└──── Nhận Signature thành công
echo ==========
echo Bước 3: Nhận signTransaction
echo.
if "%_tempSuperCraft%" == "true" (echo.[1] Tiếp tục Super craft %_7temp%, tự động sau 10s) else (echo.[1] Tiếp tục craft %_7temp%, tự động sau 10s)
echo.[2] Quay lại menu và tắt auto
choice /c 12 /n /t 10 /d 1 /m "Nhập từ bàn phím: "
if %errorlevel%==1 (goto :tryAutoCraft4)
if %errorlevel%==2 (set /a _canAutoOnOff=0 & goto:eof)
:tryAutoCraft4
echo.└── Xuất danh sách vật phẩm trước craft
rem Lưu danh sách item trước và sau
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_char%\"){inventory{equipments{grade,id,itemSubType,elementalType,equipped,itemId,level,statsMap{aTK,hP,dEF,sPD,hIT,cRI},skills{elementalType,chance,power},stat{value,type}}}}}}"}> input.json 2>nul
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json  2>nul
jq "[.data.stateQuery.avatar.inventory.equipments|.[]]" output.json > before.json
rem Tìm signTransaction
echo {"query":"query{transaction{signTransaction(unsignedTransaction:\"%_kqua%\",signature:\"%_signature%\")}}"}> input.json 2>nul
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json  2>nul
echo.─── Tìm signTransaction ...
jq -r "..|.signTransaction?|select(.)" output.json> _signTransaction.txt 2>nul
echo.└──── Nhận signTransaction thành công
echo ==========
echo Bước 4: Nhận stageTransaction
echo.
rem Nhận giá trị vượt quá 1024 kí tự
for %%A in (_signTransaction.txt) do for /f "usebackq delims=" %%B in ("%%A") do (
  set "_signTransaction=%%B"
  goto :tryAutoCraft5
)
:tryAutoCraft5
echo {"query":"mutation{stageTransaction(payload:\"%_signTransaction%\")}"}> input.json 2>nul
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json  2>nul
echo.└── Tìm stageTransaction ...
jq -r "..|.stageTransaction?|select(.)" output.json> _stageTransaction.txt 2>nul
echo.└──── Nhận stageTransaction thành công
set /a _countKtraAuto=0
set /a _countKtraStaging=0
:ktraAutoCraft
set /a _countKtraAuto+=1
set /a _countKtraStaging+=1
color 0B
cls
set _temp=       %_9cscanBlock%
echo.╔═══════════════╗   ╔═══════════════╗   ╔═══════════════╗
if %_canAuto%==5 echo ║Ví %_vi:~0,7%***	║   ║Block: %_temp:~-7% ║   ║[40;92mCan Auto? [X]	[40;96m║
if not %_canAuto%==5 echo ║Ví %_vi:~0,7%***	║   ║Block: %_temp:~-7% ║   ║[40;97mCan Auto? [ ]	[40;96m║
echo.╚═══════════════╝   ╚═══════════════╝   ╚═══════════════╝
echo ==========
if "%_tempSuperCraft%" == "true" (echo Bước 5: Kiểm tra auto Super craft %_7temp%) else (echo Bước 5: Kiểm tra auto craft %_7temp%)
echo nhân vật: %_name%
echo.slot: %_slot%
echo.─── Kiểm tra lần %_countKtraStaging%
if %_countKtraStaging% gtr 50 (color 8F & echo.─── Status: Auto craft thất bại & echo.─── nguyên nhân do node đã chọn hỏng & echo.─── sử dụng node số 1 và thử lại ... & %_cd%\data\flashError.exe & set /a _node=1 & timeout /t 20 /nobreak & echo.└──── Đang cập nhật ... & goto:eof)
set /p _stageTransaction=<_stageTransaction.txt
echo {"query":"query{transaction{transactionResult(txId:\"%_stageTransaction%\"){txStatus}}}"}> input.json 2>nul
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json 2>nul
echo.└── Tìm txStatus ...
jq -r "..|.txStatus?|select(.)" output.json> _txStatus.txt 2>nul
set /p _txStatus=<_txStatus.txt
if "%_txStatus%" == "STAGING" (color 0B & echo.─── Status: Auto craft đang diễn ra & echo.─── kiểm tra lại sau 15s ... & set /a _countKtraAuto=0 & timeout /t 15 /nobreak>nul & goto :ktraAutoCraft)
if "%_txStatus%" == "FAILURE" (color 4F & echo.─── Status: Auto craft thất bại & echo.─── cộng 50 blocks cho slot %_slot%, ... & %_cd%\data\flashError.exe & set /a _tempAddBlock=50 & goto :autoCraftEditSlotFAILURE)
if "%_txStatus%" == "INVALID" (if %_countKtraAuto% lss 4 (color 8F & echo.─── Status: Auto craft tạm thời thất bại & echo.─── kiểm tra lại lần %_countKtraAuto% sau 15s ... & timeout /t 15 /nobreak>nul & goto :ktraAutoCraft))
if "%_txStatus%" == "INVALID" (if %_countKtraAuto% geq 4 (color 8F & echo.─── Status: Auto craft thất bại & echo.─── cộng 50 blocks cho slot %_slot%, ... & %_cd%\data\flashError.exe & set /a _tempAddBlock=50 & goto :autoCraftEditSlotFAILURE))
if "%_txStatus%" == "SUCCESS" (color 2F & echo.─── Status: Auto craft thành công & goto :autoCraftEditSlotSUCCESS)
if %_countKtraAuto% lss 4 (color 4F & echo.─── Lỗi 2.1: Lỗi không xác định & echo.─── kiểm tra lại lần %_countKtraAuto% sau 15s ... & timeout /t 15 /nobreak>nul & goto :ktraAutoCraft)
if %_countKtraAuto% geq 4 (color 4F & echo.─── Lỗi 2.2: Lỗi không xác định & echo.─── đợi 10p sau thử lại auto craft, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Đang cập nhật ... & goto:eof)
:autoCraftEditSlotSUCCESS
if "%_tempSuperCraft%" equ "false" (goto :autoCraftEditSlotSUCCESS_2)
set /a _tempAddBlock=20
echo.└──── Đang reset búa Supper Craft cho %_7temp%
echo if (keys^|.[] == "h%_1temp%") then (select(keys^|.[] == "h%_1temp%")^|{h%_1temp%: 0}) else (select(keys^|.[] != "h%_1temp%")) end> _filter.txt
jq -f _filter.txt %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSuperCraft.json> _tempInfoSuperCraft.json
copy _tempInfoSuperCraft.json %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSuperCraft.json >nul
echo.───── Hoàn thành reset búa Supper Craft cho %_7temp%
goto :autoCraftEditSlotFAILURE_2
:autoCraftEditSlotSUCCESS_2
echo.└──── Đang lưu lại blocks thông tin slot %_slot% ...
echo.───── Xuất danh sách vật phẩm sau craft
rem Lưu danh sách item trước và sau
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_char%\"){inventory{equipments{grade,id,itemSubType,elementalType,equipped,itemId,level,statsMap{aTK,hP,dEF,sPD,hIT,cRI},skills{elementalType,chance,power},stat{value,type}}}}}}"}> input.json 2>nul
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
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
rem Lấy block hiện tại
echo.───── Lấy block hiện tại ...
curl https://api.9cscan.com/transactions?limit=0 --ssl-no-revoke> _9cscanBlock.json 2>nul & set /p _9cscanBlock=<_9cscanBlock.json
del /q _9cscanBlock.json & set /a _9cscanBlock=%_9cscanBlock:~-11,-4%
set /a _tempBlockEnd=%_9cscanBlock%+%_optionBlock1%+%_hasOption2%*%_optionBlock2%+%_hasSkill%*%_optionBlock3%
if %_slot% == 1 (jq "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block: %_tempBlockEnd%,slot1_item: \"%_itemIdCraft%\",slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json> _tempInfoSlot.json)
if %_slot% == 2 (jq "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block: %_tempBlockEnd%,slot2_item: \"%_itemIdCraft%\",slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json> _tempInfoSlot.json)
if %_slot% == 3 (jq "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block: %_tempBlockEnd%,slot3_item: \"%_itemIdCraft%\",slot4_id,slot4_type,slot4_block,slot4_item}" %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json> _tempInfoSlot.json)
if %_slot% == 4 (jq "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block: %_tempBlockEnd%,slot4_item: \"%_itemIdCraft%\"}" %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json> _tempInfoSlot.json)
copy _tempInfoSlot.json %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json >nul
echo.───── Hoàn thành lưu lại blocks thông tin slot %_slot%
set _temp1=%_temp1: =%
echo.└──── Đang +1 búa Supper Craft cho %_7temp%
echo if (keys^|.[] == "h%_1temp%") then (select(keys^|.[] == "h%_1temp%")^|{h%_1temp%: (.h%_1temp%+1)}) else (select(keys^|.[] != "h%_1temp%")) end> _filter.txt
jq -f _filter.txt %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSuperCraft.json> _tempInfoSuperCraft.json
copy _tempInfoSuperCraft.json %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSuperCraft.json >nul
echo.───── Hoàn thành +1 búa Supper Craft cho %_7temp%
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
set /p _urlDataOnline=<_urlDataOnline.txt
echo.───── Lưu online thông tin Slot và Super Craft ...
%_cd%\batch\jq.exe -s -c "." _infoSuperCraft.json> _temp1.txt
set /p _temp1=<_temp1.txt
%_cd%\batch\jq.exe -c "{block9cscan: %_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item, SuperCraft:%_temp1%}" _infoSlot.json> output.json
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlDataOnline% --ssl-no-revoke >nul 2>nul
del /q output.json
echo %_9cscanBlock% > _9cscanBlockSave.txt
timeout /t 20 /nobreak & echo.└──── Đang cập nhật ... & goto:eof
goto:eof
:autoCraftEditSlotFAILURE
if "%_tempSuperCraft%" equ "false" (goto :autoCraftEditSlotFAILURE_2)
echo.└──── Đang -1 búa Supper Craft cho %_7temp%
echo if (keys^|.[] == "h%_1temp%") then (select(keys^|.[] == "h%_1temp%")^|{h%_1temp%: (.h%_1temp%-1)}) else (select(keys^|.[] != "h%_1temp%")) end> _filter.txt
jq -f _filter.txt %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSuperCraft.json> _tempInfoSuperCraft.json
copy _tempInfoSuperCraft.json %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSuperCraft.json >nul
echo.───── Hoàn thành -1 búa Supper Craft cho %_7temp%
:autoCraftEditSlotFAILURE_2
echo.└──── Đang +%_tempAddBlock% blocks cho slot %_slot% ...
rem Lấy block hiện tại
echo.└──── Lấy block hiện tại ...
curl https://api.9cscan.com/transactions?limit=0 --ssl-no-revoke> _9cscanBlock.json 2>nul & set /p _9cscanBlock=<_9cscanBlock.json
del /q _9cscanBlock.json & set /a _9cscanBlock=%_9cscanBlock:~-11,-4%
set /a _tempBlockEnd=%_9cscanBlock%+%_tempAddBlock%
if %_slot% == 1 (jq "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block: %_tempBlockEnd%,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json> _tempInfoSlot.json)
if %_slot% == 2 (jq "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block: %_tempBlockEnd%,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json> _tempInfoSlot.json)
if %_slot% == 3 (jq "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block: %_tempBlockEnd%,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json> _tempInfoSlot.json)
if %_slot% == 4 (jq "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block: %_tempBlockEnd%,slot4_item}" %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json> _tempInfoSlot.json)
copy _tempInfoSlot.json %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json >nul
echo.└────── Hoàn thành lưu lại blocks thông tin slot %_slot% ...
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
set /p _urlDataOnline=<_urlDataOnline.txt
echo.───── Lưu online thông tin Slot và Super Craft ...
%_cd%\batch\jq.exe -s -c "." _infoSuperCraft.json> _temp1.txt
set /p _temp1=<_temp1.txt
%_cd%\batch\jq.exe -c "{block9cscan: %_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item, SuperCraft:%_temp1%}" _infoSlot.json> output.json
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlDataOnline% --ssl-no-revoke >nul 2>nul
del /q output.json
echo %_9cscanBlock% > _9cscanBlockSave.txt
timeout /t 20 /nobreak & echo.└──── Đang cập nhật ... & goto:eof
goto:eof

:tryAutoUpgrade
set /a _countTryAutoCraft+=1
if %_countTryAutoCraft% gtr 2 (color 8F & echo.─── Đã thử Craft / Upgrade 2 lần & echo.─── cộng 50 blocks cho slot %_slot%, ... & %_cd%\data\flashError.exe & set /a _tempAddBlock=50 & goto :autoCraftEditSlotFAILURE_2)
echo.└── Đang auto Upgrade slot %_slot% ...
rem Tạo thư mục lưu dữ liệu
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\autoUpgrade"
if exist %_folder% (rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\autoUpgrade)
md %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\autoUpgrade
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\autoUpgrade
copy "%_cd%\batch\jq.exe" "jq.exe"> nul
jq -r "\"─── \(.type) \(.grade) búa từ level \(.levelUp) lên \(.levelUp+1)\n─── với thuộc tính từ \(if .ele1 == 1 then \"Fire\" elif .ele1 == 2 then \"Water\" elif .ele1 == 3 then \"Land\" elif .ele1 == 4 then \"Wind\" else \"Normal\" end) đến \(if .ele2 == 1 then \"Fire\" elif .ele2 == 2 then \"Water\" elif .ele2 == 3 then \"Land\" elif .ele2 == 4 then \"Wind\" else \"Normal\" end)\"" %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoUpgrade.json
echo.─── Chọn 2 trang bị có CP cao nhất và thấp nhất ...
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_char%\"){inventory{equipments{grade,id,itemSubType,elementalType,equipped,itemId,level,statsMap{aTK,hP,dEF,sPD,hIT,cRI},skills{elementalType,chance,power},stat{value,type}}}}}}"}> input.json 2>nul
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json 2>nul
echo ^".data.stateQuery.avatar.inventory.equipments^|.[]^|select(.itemSubType == ^\^"^\(.type^|ascii_upcase)^\^")^|select(.grade == ^\(.grade))^|select(.level == ^\(.levelUp))^|select(((if .elementalType == ^\^"WIND^\^" then 4 elif .elementalType == ^\^"LAND^\^" then 3 elif .elementalType == ^\^"WATER^\^" then 2 elif .elementalType == ^\^"FIRE^\^" then 1 else 0 end) ^>= ^\(.ele1))and(if .elementalType == ^\^"WIND^\^" then 4 elif .elementalType == ^\^"LAND^\^" then 3 elif .elementalType == ^\^"WATER^\^" then 2 elif .elementalType == ^\^"FIRE^\^" then 1 else 0 end) ^<= ^\(.ele2))^|{itemId,stat: (.stat.value),CP: (if .skills != [] then (.statsMap^|(.hP*0.7+.aTK*10.5+.dEF*10.5+.sPD*3+.hIT*2.3)*1.15^|round) else (.statsMap^|.hP*0.7+.aTK*10.5+.dEF*10.5+.sPD*3+.hIT*2.3^|round) end)}^"> _filter1.txt 2>nul
jq -r -f _filter1.txt %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoUpgrade.json> _filter2.txt 2>nul
jq -c -f _filter2.txt output.json> output2.json 2>nul
jq -c "(if (.slot1_block > %_9cscanBlock%) then {itemId: .slot1_item} else empty end),(if (.slot2_block > %_9cscanBlock%) then {itemId: .slot2_item} else empty end),(if (.slot3_block > %_9cscanBlock%) then {itemId: .slot3_item} else empty end),(if (.slot4_block > %_9cscanBlock%) then {itemId: .slot4_item} else empty end)"  %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json> output3.json 2>nul
type output2.json output3.json> output4.json 2>nul
jq -s "[group_by(.itemId)|.[]|select(length == 1)|.[]|select(length > 1)]" output4.json> output5.json 2>nul
jq "if (length > 2) then true else false end" output5.json 2>nul | findstr /i true >nul
if %errorlevel% == 1 (echo.─── Không đủ trang bị để nâng cấp & echo.─── chuyển sang auto Craft, ... & goto :tryAutoCraft)
jq -r "max_by(.CP).itemId|select(.)" output5.json> _itemA.txt
jq -r "min_by(.CP).itemId|select(.)" output5.json> _itemB.txt
set /p _itemA=<_itemA.txt
set /p _itemB=<_itemB.txt
echo.─── Trang bị được nâng cấp:
echo.───── %_itemA%
echo.─── Trang bị làm nguyên liệu nâng cấp:
echo.───── %_itemB%
:tryAutoUpgrade1
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\autoUpgrade
rem Kiểm tra những giao dịch trước có thành công hay không
echo ==========
echo Bước 0: Kiểm tra những lệnh Upgrade trước
curl https://api.9cscan.com/accounts/%_vi%/transactions?action=item_enhancement11^&limit=6 --ssl-no-revoke 2>nul|jq -r ".transactions|.[].id"> _idCheckStatus.txt 2>nul
set "_idCheckStatus="
for /f "tokens=*" %%a in (_idCheckStatus.txt) do (curl https://api.9cscan.com/transactions/%%a/status --ssl-no-revoke)
echo.
curl https://api.9cscan.com/accounts/%_vi%/transactions?action=item_enhancement11^&limit=6 --ssl-no-revoke 2>nul | jq -r ".transactions|.[].status" | findstr -i success>nul
if %errorlevel% equ 1 (color 4F & echo.└── Lỗi 1: Không tìm thấy giao dịch SUCCESS & echo.─── đợi 10p sau thử lại, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Đang cập nhật ... & goto:eof)
echo.└──── Hoàn thành bước 0
rem Gửi thông tin của bạn tới server của tôi
echo ==========
echo Bước 1: Nhận unsignedTransaction
set /a _temp5=%_slot%-1
echo {"vi":"%_vi%","publicKey":"%_publickey%","char":"%_char%","stt":%_countChar%,"premiumTX":"%_premiumTX%","slotUpgrade":%_temp5%,"itemA":"%_itemA%","itemB":"%_itemB%"}> input.json 2>nul
curl -X POST -H "accept: application/json" -H "Content-Type: application/json" --data "@input.json" https://api.tanvpn.tk/UpgradeEquipment --ssl-no-revoke --location> output.json 2>nul
findstr /i Micro output.json> nul
if %errorlevel% equ 0 (echo.└── Lỗi 0.1: Quá thời gian chờ & echo.─── đợi 10s sau thử lại, ... & %_cd%\data\flashError.exe & timeout /t 10 /nobreak & echo.└──── Đang cập nhật ... & goto:eof)
findstr /i kqua output.json> nul
if %errorlevel% equ 1 (color 4F & echo.└── Lỗi 0: Không xác định & echo.─── đợi 10p sau thử lại, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Đang cập nhật ... & goto:eof)
jq -r ".checkqua" output.json> _checkqua.txt 2>nul & set /p _checkqua=<_checkqua.txt
jq -r ".kqua" output.json> _kqua.txt 2>nul
rem Nhận giá trị vượt quá 1024 kí tự
for %%A in (_kqua.txt) do for /f "usebackq delims=" %%B in ("%%A") do (
  set "_kqua=%%B"
  goto :tryAutoUpgrade2
)
:tryAutoUpgrade2
if %_checkqua% == 0 (echo.└── %_kqua% ... & echo.─── đợi 10p sau thử lại, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Đang cập nhật ... & goto:eof)
echo.└──── Nhận unsignedTransaction thành công
echo ==========
echo Bước 2: Nhận Signature
rem Tạo file action
call certutil -decodehex _kqua.txt action >nul
echo.└── Đang sử dụng mật khẩu đã lưu trước đó ...
"%_cd%\planet\planet" key sign --passphrase %_PASSWORD% --store-path %_cd%\user\utc %_KeyID% action> _signature.txt 2>nul
set "_signature="
rem Nhận giá trị vượt quá 1024 kí tự
for %%A in (_signature.txt) do for /f "usebackq delims=" %%B in ("%%A") do (
  set "_signature=%%B"
  goto :tryAutoUpgrade3
)
:tryAutoUpgrade3
if [%_signature%] == [] (color 4F & echo.└──── Lỗi 1: Mật khẩu đang lưu chưa đúng ... & echo.───── đợi 10p sau thử lại, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Đang cập nhật ... & goto:eof)
echo.└──── Nhận Signature thành công
echo ==========
echo Bước 3: Nhận signTransaction
jq -r "\"─── \(.type) \(.grade) búa từ level \(.levelUp) lên \(.levelUp+1)\n─── với thuộc tính từ \(if .ele1 == 1 then \"Fire\" elif .ele1 == 2 then \"Water\" elif .ele1 == 3 then \"Land\" elif .ele1 == 4 then \"Wind\" else \"Normal\" end) đến \(if .ele2 == 1 then \"Fire\" elif .ele2 == 2 then \"Water\" elif .ele2 == 3 then \"Land\" elif .ele2 == 4 then \"Wind\" else \"Normal\" end)\"" %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoUpgrade.json
echo.
echo.[1] Tiếp tục upgrade, tự động sau 10s
echo.[2] Quay lại menu và tắt auto
choice /c 12 /n /t 10 /d 1 /m "Nhập từ bàn phím: "
if %errorlevel%==1 (goto :tryAutoUpgrade4)
if %errorlevel%==2 (set /a _canAutoOnOff=0 & goto:eof)
:tryAutoUpgrade4
rem Tìm signTransaction
echo {"query":"query{transaction{signTransaction(unsignedTransaction:\"%_kqua%\",signature:\"%_signature%\")}}"}> input.json 2>nul
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json  2>nul
echo.─── Tìm signTransaction ...
jq -r "..|.signTransaction?|select(.)" output.json> _signTransaction.txt 2>nul
echo.└──── Nhận signTransaction thành công
echo ==========
echo Bước 4: Nhận stageTransaction
echo.
rem Nhận giá trị vượt quá 1024 kí tự
for %%A in (_signTransaction.txt) do for /f "usebackq delims=" %%B in ("%%A") do (
  set "_signTransaction=%%B"
  goto :tryAutoUpgrade5
)
:tryAutoUpgrade5
echo {"query":"mutation{stageTransaction(payload:\"%_signTransaction%\")}"}> input.json 2>nul
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json  2>nul
echo.└── Tìm stageTransaction ...
jq -r "..|.stageTransaction?|select(.)" output.json> _stageTransaction.txt 2>nul
echo.└──── Nhận stageTransaction thành công
set /a _countKtraAuto=0
set /a _countKtraStaging=0
:ktraAutoUpgrade
set /a _countKtraAuto+=1
set /a _countKtraStaging+=1
color 0B
cls
set _temp=       %_9cscanBlock%
echo.╔═══════════════╗   ╔═══════════════╗   ╔═══════════════╗
if %_canAuto%==5 echo ║Ví %_vi:~0,7%***	║   ║Block: %_temp:~-7% ║   ║[40;92mCan Auto? [X]	[40;96m║
if not %_canAuto%==5 echo ║Ví %_vi:~0,7%***	║   ║Block: %_temp:~-7% ║   ║[40;97mCan Auto? [ ]	[40;96m║
echo.╚═══════════════╝   ╚═══════════════╝   ╚═══════════════╝
echo ==========
echo Bước 5: Kiểm tra auto upgrade
echo nhân vật: %_name%
echo.slot: %_slot%
jq -r "\"─── \(.type) \(.grade) búa từ level \(.levelUp) lên \(.levelUp+1)\n─── với thuộc tính từ \(if .ele1 == 1 then \"Fire\" elif .ele1 == 2 then \"Water\" elif .ele1 == 3 then \"Land\" elif .ele1 == 4 then \"Wind\" else \"Normal\" end) đến \(if .ele2 == 1 then \"Fire\" elif .ele2 == 2 then \"Water\" elif .ele2 == 3 then \"Land\" elif .ele2 == 4 then \"Wind\" else \"Normal\" end)\"" %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoUpgrade.json
echo.─── Kiểm tra lần %_countKtraStaging%
if %_countKtraStaging% gtr 50 (color 8F & echo.─── Status: Auto upgrade thất bại & echo.─── nguyên nhân do node đã chọn hỏng & echo.─── sử dụng node số 1 và thử lại ... & %_cd%\data\flashError.exe & set /a _node=1 & timeout /t 20 /nobreak & echo.└──── Đang cập nhật ... & goto:eof)
set /p _stageTransaction=<_stageTransaction.txt
echo {"query":"query{transaction{transactionResult(txId:\"%_stageTransaction%\"){txStatus}}}"}> input.json 2>nul
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json 2>nul
echo.└── Tìm txStatus ...
jq -r "..|.txStatus?|select(.)" output.json> _txStatus.txt 2>nul
set /p _txStatus=<_txStatus.txt
if "%_txStatus%" == "STAGING" (color 0B & echo.─── Status: Auto upgrade đang diễn ra & echo.─── kiểm tra lại sau 15s ... & set /a _countKtraAuto=0 & timeout /t 15 /nobreak>nul & goto :ktraAutoUpgrade)
if "%_txStatus%" == "FAILURE" (color 4F & echo.─── Status: Auto upgrade thất bại & echo.─── cộng 50 blocks cho slot %_slot%, ... & %_cd%\data\flashError.exe & set /a _tempAddBlock=50 & goto :autoCraftEditSlotFAILURE_2)
if "%_txStatus%" == "INVALID" (if %_countKtraAuto% lss 4 (color 8F & echo.─── Status: Auto upgrade tạm thời thất bại & echo.─── kiểm tra lại lần %_countKtraAuto% sau 15s ... & timeout /t 15 /nobreak>nul & goto :ktraAutoUpgrade))
if "%_txStatus%" == "INVALID" (if %_countKtraAuto% geq 4 (color 8F & echo.─── Status: Auto upgrade thất bại & echo.─── cộng 50 blocks cho slot %_slot%, ... & %_cd%\data\flashError.exe & set /a _tempAddBlock=50 & goto :autoCraftEditSlotFAILURE_2))
if "%_txStatus%" == "SUCCESS" (color 2F & echo.─── Status: Auto upgrade thành công & goto :autoUpgradeEditSlotSUCCESS)
if %_countKtraAuto% lss 4 (color 4F & echo.─── Lỗi 2.1: Lỗi không xác định & echo.─── kiểm tra lại lần %_countKtraAuto% sau 15s ... & timeout /t 15 /nobreak>nul & goto :ktraAutoUpgrade)
if %_countKtraAuto% geq 4 (color 4F & echo.─── Lỗi 2.2: Lỗi không xác định & echo.─── đợi 10p sau thử lại auto upgrade, ... & %_cd%\data\flashError.exe & timeout /t 3600 /nobreak & echo.└──── Đang cập nhật ... & goto:eof)
goto:eof
:autoUpgradeEditSlotSUCCESS
echo.└──── Đang lưu lại blocks thông tin slot %_slot% ...
echo.───── Số block lưu = khi upgrade great
echo ^".[]^|select(.item_sub_type == \^"\(.type)\^")^|select(.grade == \(.grade))^|select(.level == \(.levelUp+1))^|.great_success_required_block_index^"> _filter1.txt 2>nul
jq -r -f _filter1.txt %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoUpgrade.json> _filter2.txt 2>nul
jq -r -f _filter2.txt %_cd%\Data\ModulPlus\Upgrade.txt> _temp.txt
set /p _temp=<_temp.txt
set /a _temp=%_temp% 2>nul
rem Lấy block hiện tại
echo.───── Lấy block hiện tại ...
curl https://api.9cscan.com/transactions?limit=0 --ssl-no-revoke> _9cscanBlock.json 2>nul & set /p _9cscanBlock=<_9cscanBlock.json
del /q _9cscanBlock.json & set /a _9cscanBlock=%_9cscanBlock:~-11,-4%
set /a _tempBlockEnd=%_9cscanBlock%+%_temp%
if %_slot% == 1 (jq "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block: %_tempBlockEnd%,slot1_item: \"%_itemA%\",slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json> _tempInfoSlot.json)
if %_slot% == 2 (jq "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block: %_tempBlockEnd%,slot2_item: \"%_itemA%\",slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item}" %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json> _tempInfoSlot.json)
if %_slot% == 3 (jq "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block: %_tempBlockEnd%,slot3_item: \"%_itemA%\",slot4_id,slot4_type,slot4_block,slot4_item}" %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json> _tempInfoSlot.json)
if %_slot% == 4 (jq "{block9cscan:%_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block: %_tempBlockEnd%,slot4_item: \"%_itemA%\"}" %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json> _tempInfoSlot.json)
copy _tempInfoSlot.json %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft\_infoSlot.json >nul
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_countChar%\settingCraft
set /p _urlDataOnline=<_urlDataOnline.txt
echo.───── Lưu online thông tin Slot và Super Craft ...
%_cd%\batch\jq.exe -s -c "." _infoSuperCraft.json> _temp1.txt
set /p _temp1=<_temp1.txt
%_cd%\batch\jq.exe -c "{block9cscan: %_9cscanBlock%,slot1_id,slot1_type,slot1_block,slot1_item,slot2_id,slot2_type,slot2_block,slot2_item,slot3_id,slot3_type,slot3_block,slot3_item,slot4_id,slot4_type,slot4_block,slot4_item, SuperCraft:%_temp1%}" _infoSlot.json> output.json
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlDataOnline% --ssl-no-revoke >nul 2>nul
del /q output.json
echo %_9cscanBlock% > _9cscanBlockSave.txt
timeout /t 20 /nobreak & echo.└──── Đang cập nhật ... & goto:eof
goto:eof