echo off
mode con:cols=60 lines=25
color 0B
rem Cài tiếng Việt Nam
chcp 65001
cls
set _stt=%1
set _vi=**********************
set _9cscanBlock=*******
set _canAuto=0
set /a _HanSuDung=0
set /a _chuyendoi=0
set /a _premiumTXOK=0 & set /a _passwordOK=0 & set /a _publickeyOK=0 & set /a _keyidOK=0 & set /a _canAutoOnOff=0 & set /a _utcFileOK=0 & set /a _autoRefillAP=0 & set /a _autoSweepOnOffAll=0
:BatDau
rem setlocal ENABLEDELAYEDEXPANSION
rem Cài %_cd% gốc
set /p _cd=<_cd.txt
set _stt=%_stt%
call :background
rem Kiểm tra đã có thư mục ví chưa
set _folder="%_cd%\User\trackedAvatar"
if not exist %_folder% (md %_cd%\User\trackedAvatar)
set _folderVi=vi%_stt%
set _folder="%_cd%\User\trackedAvatar\%_folderVi%"
if exist %_folder% (goto :yesFolder) else (echo.└── Đang xử lý ... & goto :noFolder)
:yesFolder
rem Lấy ví đang được lưu
set /p _vi=<%_cd%\user\trackedAvatar\%_folderVi%\_vi.txt
call :background
echo.Đã tồn tại thư mục vi%_stt% trong bộ nhớ
echo.[1] Vẫn dùng dữ liệu cũ
echo.[2] Xóa dữ liệu ví cũ và tạo mới
echo.[3] Thoát
choice /c 123 /n /m "Nhập từ bàn phím: "
echo.└── Đang xử lý ...
if %errorlevel%==3 (echo.└──── Thoát sau 5s ... & timeout 5 & exit)
if %errorlevel%==1 (goto :duLieuViCu)
if %errorlevel%==2 (rd /s /q %_cd%\User\trackedAvatar\%_folderVi%) 
:noFolder
rem Tạo thư mục để lưu dữ liệu ví
cd %_cd%\User\trackedAvatar\
md %_folderVi%
rem Lưu lại địa chỉ ví
cd %_cd%\batch\avatarAddress
jq -r ".[%_stt%]|.vi" oldData.json> %_cd%\user\trackedAvatar\%_folderVi%\_vi.txt 2>nul & set /p _vi=<%_cd%\user\trackedAvatar\%_folderVi%\_vi.txt
:duLieuViCu
rem Tạo file cần thiết
copy "%_cd%\_cd.txt" "%_cd%\user\trackedAvatar\%_folderVi%\_cd.txt">nul
rem Lấy block hiện tại
echo.└──── Lấy block hiện tại ...
cd %_cd%\user\trackedAvatar\%_folderVi%
curl https://api.9cscan.com/transactions?limit=0 --ssl-no-revoke> _9cscanBlock.json 2>nul & set /p _9cscanBlock=<_9cscanBlock.json
del /q _9cscanBlock.json & set /a _9cscanBlock=%_9cscanBlock:~-11,-4%
rem Nhận dữ liệu nhân vật
echo.└──── Lấy thông tin tất cả nhân vật ...
cd %_cd%\batch\avatarAddress
curl https://api.9cscan.com/account?address=%_vi% --ssl-no-revoke> %_cd%\user\trackedAvatar\%_folderVi%\_allChar.json 2>nul
rem Lấy số lượng nhân vật
echo.└──── Lấy số lượng nhân vật ...
jq "length" %_cd%\user\trackedAvatar\%_folderVi%\_allChar.json> %_cd%\user\trackedAvatar\%_folderVi%\_length.txt 2>nul
set /p _length=<%_cd%\user\trackedAvatar\%_folderVi%\_length.txt
if not %_length% geq 1 (if %_length% leq 4 (echo. & echo Lỗi 1: Ví nhập sai hoặc 9cscan lỗi 404, thử lại ... & color 4F & timeout 5 & goto :BatDau))
set /a _length+=-1
rem Lấy mức stake để tìm số AP tiêu hao
echo.└──── Lấy số AP tiêu hao theo mức Stake ...
cd %_cd%\user\trackedAvatar\%_folderVi%
echo {"query":"query{stateQuery{stakeStates(addresses:\"%_vi%\"){deposit}}}"}> input.json 2>nul
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json 2>nul
echo 5 > _stakeAP.txt
rem Lọc kết quả lấy dữ liệu
findstr /i null output.json> nul
if %errorlevel% == 1 ("%_cd%\batch\jq.exe" -r ".data.stateQuery.stakeStates|.[]|.deposit|tonumber|if . > 500000 then 3 elif . > 5000 then 4 else 5 end" output.json> _stakeAP.txt 2>nul)
set /p _stakeAP=<_stakeAP.txt & set /a _stakeAP=%_stakeAP% 2>nul
rem Xóa file nháp input và output
del /q %_cd%\user\trackedAvatar\%_folderVi%\input.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\output.json 2>nul
rem Nạp dữ liệu cũ nếu có
echo.└──── Nhập lại dữ liệu cũ nếu có ...
rem Ktra file UTC có hay không
cd %_cd%\planet
set _utcfile=^|planet key --path %_cd%\user\utc 2>nul|findstr /i %_vi%>nul
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
rem Lọc từng nhân vật
set _charCount=1
:locChar
echo.└──── Nhập dữ liệu nhân vật %_charCount% ...
cd %_cd%\batch\avatarAddress
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%"
if not exist %_folder% (md %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%)
jq ".[%_charCount%]|del(.refreshBlockIndex)|del(.avatarAddress)|del(.address)|del(.goldBalance)|.[]|{address, name, level, actionPoint,timeCount: (.dailyRewardReceivedIndex+1700-%_9cscanBlock%)}" %_cd%\user\trackedAvatar\%_folderVi%\_allChar.json> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_infoChar.json 2>nul
jq "{sec: ((.timeCount*12)%%60),minute: ((((.timeCount*12)-(.timeCount*12)%%60)/60)%%60),hours: (((((.timeCount*12)-(.timeCount*12)%%60)/60)-(((.timeCount*12)-(.timeCount*12)%%60)/60%%60))/60)}" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_infoChar.json> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_infoCharAp.json 2>nul
jq -j """\(.hours):\(.minute):\(.sec)""" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_infoCharAp.json> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_infoCharAp.txt 2>nul
jq -r ".address" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_infoChar.json> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_address.txt 2>nul
jq -r ".name" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_infoChar.json> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_name.txt 2>nul
jq -r ".level" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_infoChar.json> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_level.txt 2>nul
jq -r ".actionPoint" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_infoChar.json> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_actionPoint.txt 2>nul
jq -r ".timeCount" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_infoChar.json> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_timeCount.txt 2>nul
rem Lấy stage đang tới
echo.└────── Lấy Stage đã mở ...
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%
set /p _AddressChar=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_address.txt
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_AddressChar%\"){stageMap{count}}}}"}> input.json 2>nul
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json 2>nul
rem Lọc kết quả lấy dữ liệu
"%_cd%\batch\jq.exe" -r "..|.count?|select(.)" output.json> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_stage.txt 2>nul
rem Xóa file nháp input và output
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\input.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\output.json 2>nul
rem Tạo file cần thiết
set /p _stage=<_stage.txt
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep"
if not exist %_folder% (md %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep)
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_stageSweepRandom.txt"
if not exist %_file% (echo %_stage%> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_stageSweepRandom.txt)
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_howManyTurn.txt"
if not exist %_file% (echo 0 > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_howManyTurn.txt)
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_autoSweepOnOffChar.txt"
if not exist %_file% (echo 0 > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_autoSweepOnOffChar.txt)
rem Tạo link url nơi lưu dữ liệu item từng char
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_urlJson.txt"
if exist %_file% (goto :locChar1)
echo.└────── Tạo link jsonblob.com xem vật phẩm ...
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep
curl -i -X "POST" -d "{}" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob --ssl-no-revoke 2>nul|findstr /i location>nul> _temp.txt 2>nul
set /p _temp=<_temp.txt
echo %_temp:~43,19%> _urlJson.txt 2>nul & set "_temp=" & del /q _temp.txt 2>nul
:locChar1
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\"
if exist %_folder% (goto :locChar2)
rem Tạo file index.html
echo.└────── Tạo file html xem vật phẩm ...
xcopy "%_cd%\data\CheckItem\" "%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\" >nul
set /p _urlJson=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_urlJson.txt
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem
call "%_cd%\batch\TaoInputJson.bat" _IDapiJson %_urlJson% index-raw.html> index-raw2.html 2>nul
type index-raw1.html index-raw2.html index-raw3.html> index.html 2>nul
del /q index-raw1.html index-raw2.html index-raw3.html index-raw.html
:locChar2
rem Tạo file _itemEquip.json
set _file="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_itemEquip.json"
if exist %_file% (goto :locChar3)
echo.└────── Tạo file _itemEquip.json xem vật phẩm ...
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
	echo.[1] Cập nhật lại, tự động sau 60s	[40;92m╔═══════════════╗[40;96m
	echo.[2] Cài đặt Auto			[40;92m║4.Tắt Auto tổng║[40;96m
	echo.[3] Hướng dẫn sử dụng			[40;92m╚═══════════════╝[40;96m
	) else (
		echo.[1] Cập nhật lại, tự động sau 60s	[40;97m╔═══════════════╗[40;96m
		echo.[2] Cài đặt Auto			[40;97m║4.Bật Auto tổng║[40;96m
		echo.[3] Hướng dẫn sử dụng			[40;97m╚═══════════════╝[40;96m
		)
choice /c 1234 /n /t 60 /d 1 /m "Nhập số từ bàn phím: "
if %errorlevel% equ 1 (echo.└── Đang cập nhật ... & goto :duLieuViCu)
if %errorlevel% equ 2 (goto :settingAuto)
if %errorlevel% equ 3 (goto :hdsd)
if %errorlevel% equ 4 (goto :canAutoOnOff)
goto :displayVi
:background
cd %_cd%
color 0B
title Ví [%_stt%][%_vi%]
cls
set /a _canAuto=%_premiumTXOK% + %_passwordOK% + %_publickeyOK% + %_KeyIDOK% + %_utcFileOK%
echo.╔═══════════════╗   ╔═══════════════╗   ╔═══════════════╗
if %_canAuto%==5 echo ║Ví %_vi:~0,7%***	║   ║Block: %_9cscanBlock% ║   ║[40;92mCan Auto? [X]	[40;96m║
if not %_canAuto%==5 echo ║Ví %_vi:~0,7%***	║   ║Block: %_9cscanBlock% ║   ║[40;97mCan Auto? [ ]	[40;96m║
echo.╚═══════════════╝   ╚═══════════════╝   ╚═══════════════╝
exit /b
:background2
set /a _charDisplay=%1
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%
set /p _name=<_name.txt & set /p _level=<_level.txt & set /p _stage=<_stage.txt & set /p _actionPoint=<_actionPoint.txt & set /p _infoCharAp=<_infoCharAp.txt & set /p _timeCount=<_timeCount.txt & set /p _address=<_address.txt
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%\settingSweep
rem Chọn ngẫu nhiên 1 stage
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
echo/%randline%> _stageSweep.txt
set /p _stageSweep=<_stageSweep.txt & set /p _autoSweepOnOffChar=<_autoSweepOnOffChar.txt & set /p _howManyTurn=<_howManyTurn.txt 
set /a _stageSweep=%_stageSweep% 2>nul & set /a _autoSweepOnOffChar=%_autoSweepOnOffChar% 2>nul & set /a _howManyTurn=%_howManyTurn% 2>nul
if %_stageSweep% lss 50 (echo 1 > _world.txt 2>nul)
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
rem Tự động refill AP
if %_canAutoOnOff% == 1 (if %_timeCount% lss 0 (if %_canAuto% == 5 (if %_actionPoint% == 0 (if %_autoRefillAP% == 1 (echo.└── Đang Refill AP nhân vật: %_name% ... & call :autoRefillAP)))))
rem Tự động sweep
set /a _howManyAP=%_stakeAP%*%_howManyTurn%
if %_canAutoOnOff% == 1 (if %_autoSweepOnOffChar% == 1 (if %_howManyAP% leq %_actionPoint% (echo.└── Đang Auto Sweep nhân vật: %_name% ... & call :autoSweep)))
exit /b
:background3
call :background
set /a _charDisplay=%1
rem Ktra có nhân vật hay không
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%"
if not exist %_folder% (goto :gotoSweep)
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%
set /p _name=<_name.txt & set /p _level=<_level.txt & set /p _stage=<_stage.txt & set /p _actionPoint=<_actionPoint.txt & set /p _infoCharAp=<_infoCharAp.txt & set /p _timeCount=<_timeCount.txt & set /p _address=<_address.txt
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%\settingSweep
rem Chọn ngẫu nhiên 1 stage
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
echo/%randline%> _stageSweep.txt
set /p _stageSweep=<_stageSweep.txt & set /p _autoSweepOnOffChar=<_autoSweepOnOffChar.txt & set /p _howManyTurn=<_howManyTurn.txt 
set /a _stageSweep=%_stageSweep% 2>nul & set /a _autoSweepOnOffChar=%_autoSweepOnOffChar% 2>nul & set /a _howManyTurn=%_howManyTurn% 2>nul
if %_stageSweep% lss 50 (echo 1 > _world.txt 2>nul)
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
echo.[1..5] Nhập đủ mới có thể Auto
echo.==========
echo.[6] Quay lại
echo.[7] Quay lại
echo.[8] Bật / Tắt Auto Refill AP tổng
echo.[9] Chuyển sang cài đặt [40;97mAuto Sweep[40;96m
choice /c 123456789 /n /m "Nhập số từ bàn phím: "
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
echo.[1] Nhập trang bị
echo.[2] Nhập stage muốn sweep
echo.[3] Nhập số turn trong 1 lệnh Sweep
echo.==========
echo.[4] Chuyển sang nhân vật tiếp theo
echo.[5] Bật / Tắt Auto Sweep cho [40;97m%_name%[40;96m
echo.[6] Đang hoàn thiện
echo.==========
echo.[7] Quay lại
echo.[8] Bật / Tắt Auto Sweep tổng
echo.[9] Chuyển sang cài đặt [40;97mAuto Refill AP[40;96m
choice /c 123456789 /n /m "Nhập số từ bàn phím: "
if %errorlevel% equ 1 (mode con:cols=60 lines=25 & goto :importTrangBi)
if %errorlevel% equ 2 (mode con:cols=60 lines=25 & goto :pickSweep)
if %errorlevel% equ 3 (mode con:cols=60 lines=25 & goto :howManyTurn)
if %errorlevel% equ 4 (mode con:cols=60 lines=25 & set /a _charCount+=1 &goto :gotoSweep1)
if %errorlevel% equ 5 (mode con:cols=60 lines=25 & goto :charSweepOnOff)
if %errorlevel% equ 6 (mode con:cols=60 lines=25 & goto :gotoSweep1)
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
set /a _maxTurn=%_actionPoint%/%_stakeAP%
set _maxTurn=  %_maxTurn%
echo.╔═══════════════╗   ╔═══════════════╗
echo ║AP/turn: %_stakeAP%	║   ║Max turn:	%_maxTurn:~-2%%  ║
echo.╚═══════════════╝   ╚═══════════════╝
set /a _maxTurn=%_actionPoint%/%_stakeAP%
echo.
echo.==========
rem Reset _pickHowManyTurn
set "_pickHowManyTurn="
echo.Nhập "waybackhome" để quay lại
set /p _pickHowManyTurn="Nhập số lần trong mỗi lệnh sweep: "
echo.
if "%_pickHowManyTurn%" == "waybackhome" (set "_pickHowManyTurn=" & goto :gotoSweep1)
rem Ktra có để trống hay không
if [%_pickHowManyTurn%] == [] (echo Lỗi 1: Dữ liệu nhập trống, thử lại ... & color 4F & timeout 5 & set "_pickHowManyTurn=" & goto :howManyTurn)
rem Ktra sweep có là số hay không
set "var="&for /f "delims=0123456789" %%i in ("%_pickHowManyTurn%") do set var=%%i
if defined var (echo Lỗi 2: Sai cú pháp, thử lại ... & color 4F & timeout 5 & set "_pickHowManyTurn=" & goto :howManyTurn)
rem Ktra stage có lớn hơn stage mà nhân vật đã mở hay không
if %_pickHowManyTurn% gtr %_maxTurn% (echo Lỗi 3: %_pickHowManyTurn% lớn hơn %_maxTurn% turn có thể sweep, thử lại ... & color 4F & timeout 5 & set "_pickHowManyTurn=" & goto :howManyTurn)
echo %_pickHowManyTurn% > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_howManyTurn.txt
goto :gotoSweep1
:pickSweep
call :background3 %_charCount%
echo.[40;96m==========
echo.
echo.Những stage đang lưu:
type %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_stageSweepRandom.txt
echo.==========
echo.
rem Reset _pickSweep
set "_pickSweep="
echo.Nhập "waybackhome" để quay lại
set /p _pickSweep="Nhập stage bạn muốn sweep: "
echo.
if "%_pickSweep%" == "waybackhome" (set "_pickSweep=" & goto :gotoSweep1)
rem Ktra có để trống hay không
if [%_pickSweep%] == [] (echo Lỗi 1: Dữ liệu nhập trống, thử lại ... & color 4F & timeout 5 & set "_pickSweep=" & goto :pickSweep)
rem Ktra sweep có là số hay không
set "var="&for /f "delims=0123456789" %%i in ("%_pickSweep%") do set var=%%i
if defined var (echo Lỗi 2: Sai cú pháp, thử lại ... & color 4F & timeout 5 & set "_pickSweep=" & goto :pickSweep)
rem Ktra stage có lớn hơn stage mà nhân vật đã mở hay không
if %_pickSweep% gtr %_stage% (echo Lỗi 3: Stage %_pickSweep% lớn hơn stage được phép sweep, thử lại ... & color 4F & timeout 5 & set "_pickSweep=" & goto :pickSweep)
echo %_pickSweep% >> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_stageSweepRandom.txt
call :background3 %_charCount%
echo.[40;96m==========
echo.
echo.Những stage đang lưu:
type %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_stageSweepRandom.txt
echo.==========
echo.
echo.Theo mặc định 9CMD sẽ chọn ngẫu nhiên một trong những stage
echo.đã lưu để sweep
echo.[1] Chỉ lưu stage %_pickSweep% cố định
echo.[2] Lưu thêm stage
echo.==========
echo.[3] Quay lại
choice /c 123 /n /m "Nhập số từ bàn phím: "
if %errorlevel% equ 1 (echo %_pickSweep% > %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_stageSweepRandom.txt & goto :pickSweep)
if %errorlevel% equ 2 (goto :pickSweep)
if %errorlevel% equ 3 (goto :gotoSweep1)
goto :gotoSweep1
:importTrangBi
rem Xóa dữ liệu cũ
set "_weapon=" & set "_armor=" & set "_belt=" & set "_necklace=" & set "_ring1=" & set "_ring2="
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep
"%_cd%\batch\jq.exe" -r ".weapon" _itemEquip.json> _weapon.txt & set /p _weapon=<_weapon.txt & del /q _weapon.txt
"%_cd%\batch\jq.exe" -r ".armor" _itemEquip.json> _armor.txt & set /p _armor=<_armor.txt & del /q _armor.txt
"%_cd%\batch\jq.exe" -r ".belt" _itemEquip.json> _belt.txt & set /p _belt=<_belt.txt & del /q _belt.txt
"%_cd%\batch\jq.exe" -r ".necklace" _itemEquip.json> _necklace.txt & set /p _necklace=<_necklace.txt & del /q _necklace.txt
"%_cd%\batch\jq.exe" -r ".ring1" _itemEquip.json> _ring1.txt & set /p _ring1=<_ring1.txt & del /q _ring1.txt
"%_cd%\batch\jq.exe" -r ".ring2" _itemEquip.json> _ring2.txt & set /p _ring2=<_ring2.txt & del /q _ring2.txt
call :background
echo.Trang bị cho lần sweep tới:
echo.==========
echo.[1] Weapon	:	%_weapon%
echo.[2] Armor	:	%_armor%
echo.[3] Belt	:	%_belt%
echo.[4] Necklace	:	%_necklace%
echo.[5] Ring1	:	%_ring1%
echo.[6] Ring2	:	%_ring2%
echo.==========
echo.[7] Quay lại
echo.[8] Mở trang web check đồ
echo.[9] Nhập nhanh trang bị đang được Equipped
choice /c 123456789 /n /m "Nhập số từ bàn phím: "
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
echo.└── Đang lấy dữ liệu Equipped ...
set /p _address=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_address.txt
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_address%\"){inventory{equipments{grade,id,itemSubType,elementalType,equipped,itemId,level,statsMap{aTK,hP,dEF,sPD,hIT,cRI},skills{elementalType,chance,power},stat{value,type}}}}}}"}> input.json 2>nul
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output1.json 2>nul
rem Lọc kết quả lấy dữ liệu
%_cd%\batch\jq.exe -r -f filterEQUIPPED.txt output1.json> output.json 2>nul
rem Đẩy file output.json lên https://jsonblob.com
set /p _urlJson=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_urlJson.txt
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlJson% --ssl-no-revoke >nul 2>nul
rem Lọc lấy trang bị đang Equipped
%_cd%\batch\jq.exe -r -f filterEQUIPPED2.txt output.json> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_itemEquip.json 2>nul
rem Xóa file nháp input và output
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\input.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\output1.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\output.json 2>nul
echo.└──── Lấy trang bị Equipped thành công ..
timeout 3
goto :importTrangBi
:importTrangBiWeapon
echo.└── Đang lấy dữ liệu Weapon ...
set /p _address=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_address.txt
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_address%\"){inventory{equipments{grade,id,itemSubType,elementalType,equipped,itemId,level,statsMap{aTK,hP,dEF,sPD,hIT,cRI},skills{elementalType,chance,power},stat{value,type}}}}}}"}> input.json 2>nul
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output1.json 2>nul
rem Lọc kết quả lấy dữ liệu
%_cd%\batch\jq.exe -r -f filterWEAPON.txt output1.json> output.json 2>nul
rem Đẩy file output.json lên https://jsonblob.com
set /p _urlJson=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_urlJson.txt
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlJson% --ssl-no-revoke >nul 2>nul
rem Xóa file nháp input và output
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\input.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\output1.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\output.json 2>nul
:importTrangBiWeapon1
call :background3 %_charCount%
echo.
echo.Làm mới trang web để áp dụng bộ trang bị Weapon
echo.==========
echo.
echo.[1] Nhập ID của Weapon
echo.[2] Mở trang web check đồ
echo.[3] Quay lại
choice /c 123 /n /m "Nhập số từ bàn phím: "
if %errorlevel% equ 3 (goto :importTrangBi)
if %errorlevel% equ 2 (start "" "%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\index.html" & goto :importTrangBiWeapon1)
if %errorlevel% equ 1 (
	SETLOCAL EnableDelayedExpansion
	set "_weapon="
	echo.
	set /p _weapon="Nhập ID Item của trang bị: "
	cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\
	%_cd%\batch\jq.exe "{weapon: \"!_weapon!\",armor,belt,necklace,ring1,ring2}" _itemEquip.json> _temp.json
	copy _temp.json _itemEquip.json>nul
	del /q _temp.json
	endlocal
	)
goto :importTrangBi
:importTrangBiArmor
echo.└── Đang lấy dữ liệu Armor ...
set /p _address=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_address.txt
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_address%\"){inventory{equipments{grade,id,itemSubType,elementalType,equipped,itemId,level,statsMap{aTK,hP,dEF,sPD,hIT,cRI},skills{elementalType,chance,power},stat{value,type}}}}}}"}> input.json 2>nul
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output1.json 2>nul
rem Lọc kết quả lấy dữ liệu
%_cd%\batch\jq.exe -r -f filterARMOR.txt output1.json> output.json 2>nul
rem Đẩy file output.json lên https://jsonblob.com
set /p _urlJson=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_urlJson.txt
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlJson% --ssl-no-revoke >nul 2>nul
rem Xóa file nháp input và output
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\input.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\output1.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\output.json 2>nul
:importTrangBiArmor1
call :background3 %_charCount%
echo.
echo.Làm mới trang web để áp dụng bộ trang bị Armor
echo.==========
echo.
echo.[1] Nhập ID của Armor
echo.[2] Mở trang web check đồ
echo.[3] Quay lại
choice /c 123 /n /m "Nhập số từ bàn phím: "
if %errorlevel% equ 3 (goto :importTrangBi)
if %errorlevel% equ 2 (start "" "%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\index.html" & goto :importTrangBiArmor1)
if %errorlevel% equ 1 (
	SETLOCAL EnableDelayedExpansion
	set "_armor="
	echo.
	set /p _armor="Nhập ID Item của trang bị: "
	cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\
	%_cd%\batch\jq.exe "{weapon,armor: \"!_armor!\",belt,necklace,ring1,ring2}" _itemEquip.json> _temp.json 2>nul
	copy _temp.json _itemEquip.json>nul
	del /q _temp.json
	endlocal
	)
goto :importTrangBi
:importTrangBiBelt
echo.└── Đang lấy dữ liệu Belt ...
set /p _address=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_address.txt
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_address%\"){inventory{equipments{grade,id,itemSubType,elementalType,equipped,itemId,level,statsMap{aTK,hP,dEF,sPD,hIT,cRI},skills{elementalType,chance,power},stat{value,type}}}}}}"}> input.json 2>nul
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output1.json 2>nul
rem Lọc kết quả lấy dữ liệu
%_cd%\batch\jq.exe -r -f filterBELT.txt output1.json> output.json 2>nul
rem Đẩy file output.json lên https://jsonblob.com
set /p _urlJson=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_urlJson.txt
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlJson% --ssl-no-revoke >nul 2>nul
rem Xóa file nháp input và output
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\input.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\output1.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\output.json 2>nul
:importTrangBiBelt1
call :background3 %_charCount%
echo.
echo.Làm mới trang web để áp dụng bộ trang bị Belt
echo.==========
echo.
echo.[1] Nhập ID của Belt
echo.[2] Mở trang web check đồ
echo.[3] Quay lại
choice /c 123 /n /m "Nhập số từ bàn phím: "
if %errorlevel% equ 3 (goto :importTrangBi)
if %errorlevel% equ 2 (start "" "%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\index.html" & goto :importTrangBiBelt1)
if %errorlevel% equ 1 (
	SETLOCAL EnableDelayedExpansion
	set "_belt="
	echo.
	set /p _belt="Nhập ID Item của trang bị: "
	cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\
	%_cd%\batch\jq.exe "{weapon,armor,belt: \"!_belt!\",necklace,ring1,ring2}" _itemEquip.json> _temp.json 2>nul
	copy _temp.json _itemEquip.json>nul
	del /q _temp.json
	endlocal
	)
goto :importTrangBi
:importTrangBiNecklace
echo.└── Đang lấy dữ liệu Necklace ...
set /p _address=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_address.txt
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_address%\"){inventory{equipments{grade,id,itemSubType,elementalType,equipped,itemId,level,statsMap{aTK,hP,dEF,sPD,hIT,cRI},skills{elementalType,chance,power},stat{value,type}}}}}}"}> input.json 2>nul
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output1.json 2>nul
rem Lọc kết quả lấy dữ liệu
%_cd%\batch\jq.exe -r -f filterNECKLACE.txt output1.json> output.json 2>nul
rem Đẩy file output.json lên https://jsonblob.com
set /p _urlJson=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_urlJson.txt
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlJson% --ssl-no-revoke >nul 2>nul
rem Xóa file nháp input và output
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\input.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\output1.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\output.json 2>nul
:importTrangBiNecklace1
call :background3 %_charCount%
echo.
echo.Làm mới trang web để áp dụng bộ trang bị Necklace
echo.==========
echo.
echo.[1] Nhập ID của Necklace
echo.[2] Mở trang web check đồ
echo.[3] Quay lại
choice /c 123 /n /m "Nhập số từ bàn phím: "
if %errorlevel% equ 3 (goto :importTrangBi)
if %errorlevel% equ 2 (start "" "%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\index.html" & goto :importTrangBiNecklace1)
if %errorlevel% equ 1 (
	SETLOCAL EnableDelayedExpansion
	set "_necklace="
	echo.
	set /p _necklace="Nhập ID Item của trang bị: "
	cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\
	%_cd%\batch\jq.exe "{weapon,armor,belt,necklace: \"!_necklace!\",ring1,ring2}" _itemEquip.json> _temp.json 2>nul
	copy _temp.json _itemEquip.json>nul
	del /q _temp.json
	endlocal
	)
goto :importTrangBi
:importTrangBiRing1
echo.└── Đang lấy dữ liệu Ring1 ...
set /p _address=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_address.txt
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_address%\"){inventory{equipments{grade,id,itemSubType,elementalType,equipped,itemId,level,statsMap{aTK,hP,dEF,sPD,hIT,cRI},skills{elementalType,chance,power},stat{value,type}}}}}}"}> input.json 2>nul
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output1.json 2>nul
rem Lọc kết quả lấy dữ liệu
%_cd%\batch\jq.exe -r -f filterRING.txt output1.json> output.json 2>nul
rem Đẩy file output.json lên https://jsonblob.com
set /p _urlJson=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_urlJson.txt
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlJson% --ssl-no-revoke >nul 2>nul
rem Xóa file nháp input và output
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\input.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\output1.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\output.json 2>nul
:importTrangBiRing11
call :background3 %_charCount%
echo.
echo.Làm mới trang web để áp dụng bộ trang bị Ring1
echo.==========
echo.
echo.[1] Nhập ID của Ring1
echo.[2] Mở trang web check đồ
echo.[3] Quay lại
choice /c 123 /n /m "Nhập số từ bàn phím: "
if %errorlevel% equ 3 (goto :importTrangBi)
if %errorlevel% equ 2 (start "" "%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\index.html" & goto :importTrangBiRing11)
if %errorlevel% equ 1 (goto :importTrangBiRing12)
:importTrangBiRing12
SETLOCAL EnableDelayedExpansion
set "_ring1="
echo.
set /p _ring1="Nhập ID Item của trang bị: "
if "!_ring1!" equ "%_ring2%" (
	if not "!_ring1!" equ "" (
		echo.
		echo Lỗi 1.1: Ring1 trùng ID với Ring2 ...
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
echo.└── Đang lấy dữ liệu Ring2 ...
set /p _address=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_address.txt
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_address%\"){inventory{equipments{grade,id,itemSubType,elementalType,equipped,itemId,level,statsMap{aTK,hP,dEF,sPD,hIT,cRI},skills{elementalType,chance,power},stat{value,type}}}}}}"}> input.json 2>nul
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output1.json 2>nul
rem Lọc kết quả lấy dữ liệu
%_cd%\batch\jq.exe -r -f filterRING.txt output1.json> output.json 2>nul
rem Đẩy file output.json lên https://jsonblob.com
set /p _urlJson=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\_urlJson.txt
curl -X "PUT" -d "@output.json" -H "Content-Type: application/json" -H "Accept: application/json" https://jsonblob.com/api/jsonBlob/%_urlJson% --ssl-no-revoke >nul 2>nul
rem Xóa file nháp input và output
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\input.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\output1.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\output.json 2>nul
:importTrangBiRing21
call :background3 %_charCount%
echo.
echo.Làm mới trang web để áp dụng bộ trang bị Ring2
echo.==========
echo.
echo.[1] Nhập ID của Ring2
echo.[2] Mở trang web check đồ
echo.[3] Quay lại
choice /c 123 /n /m "Nhập số từ bàn phím: "
if %errorlevel% equ 3 (goto :importTrangBi)
if %errorlevel% equ 2 (start "" "%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\settingSweep\CheckItem\index.html" & goto :importTrangBiRing21)
if %errorlevel% equ 1 (goto :importTrangBiRing22)
:importTrangBiRing22
SETLOCAL EnableDelayedExpansion
set "_ring2="
echo.
set /p _ring2="Nhập ID Item của trang bị: "
if "!_ring2!" equ "%_ring1%" (
	if not "!_ring2!" equ "" (
		echo.
		echo Lỗi 1.2: Ring2 trùng ID với Ring1 ...
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
echo.─── Cần nhập đủ thông số từ 1 - 5, bật công tắc Auto tổng
echo.─── công tắc Auto Refill AP và quay lại màn hình chính, 
echo.─── mỗi 60s sẽ tự làm mới dữ liệu nhân vật
echo.─── Khi đạt đủ điều kiện nhân vật còn [40;91m0AP[40;96m
echo.─── và [40;91mđủ thời gian[40;96m để refill, nhân vật 
echo.─── sẽ được Auto Refill AP lần lượt.
echo.
echo.[40;92mAuto Sweep?[40;96m
echo.─── Kí hiệu [[40;91ma[40;96m][[40;91mb[40;96m / [40;91mc[40;96m] trong đó:
echo.─── [[40;91ma[40;96m] [40;91m0[40;96m / [40;91m1[40;96m là tắt / bật auto sweep riêng từng char
echo.─── [[40;91mb[40;96m / [40;91mc[40;96m] là [[40;91mstage sẽ auto[40;96m / [40;91msố turn trong 1 lệnh sweep[40;96m]
echo.─── Bạn vẫn cần nhập đủ thông số từ 1 đến 5, bật công
echo.─── tắc Auto Sweep tổng, công tắc riêng cho từng char
echo.─── mà bạn muốn auto và quay lại màn hình chính.
echo.
echo.==========
echo.[40;92mPremium code là gì?[40;96m
echo.─── Là mã tx (Transaction Hash) của giao dịch gửi NCG từ bạn
echo.─── tới ví của tôi: 
echo.─── [40;91m0x6374FE5F54CdeD72Ff334d09980270c61BC95186[40;96m
echo.─── sử dụng để đăng ký [40;91mDonater tự động[40;96m
echo.─── Sau khi đăng ký thành công, nhập Premium code là
echo.─── [40;91mdonater[40;96m thay vì nhập mã tx
echo.─── cho mỗi lần sử dụng 9CMD.
echo.
echo.[40;92mSử dụng đến khi nào?[40;96m
echo.─── Tính từ block mua premium + 216000, với 12s / 1 block
echo.─── tương đương [40;91m1 ví / 30 ngày sử dụng[40;96m tool.
echo.
echo.==========
echo.Bạn muốn trở thành Donater hoặc feedback lỗi
echo.contact tôi qua ...
echo.
echo.[1] Discord tanbt#9827
echo.[2] Telegram @tandotbt
echo.[3] Discord Plantarium - #unofficial-mods
echo.[4] Youtube tanbt
echo.[5] Web gitbook HDSD
echo.
echo.==========
choice /c 123456 /n /m "Nhập [6] để quay lại: "
if %errorlevel% equ 1 (start https://discordapp.com/users/466271401796567071 & goto :hdsd)
if %errorlevel% equ 2 (start https://t.me/tandotbt & goto :hdsd)
if %errorlevel% equ 3 (start https://discord.com/channels/539405872346955788/1035354979709485106 & goto :hdsd)
if %errorlevel% equ 4 (start https://www.youtube.com/c/tanbt & goto :hdsd)
if %errorlevel% equ 5 (start https://9cmd.tanvpn.tk/ & goto :hdsd)
if %errorlevel% equ 6 (mode con:cols=60 lines=25 & goto :displayVi)
goto :displayVi
:utcFile
echo.└── Đang kiểm tra có UTC của ví %_vi:~0,7%*** hay không ..
cd %_cd%\planet
set _utcfile=^|planet key --path %_cd%\user\utc 2>nul|findstr /i %_vi%>nul
if %errorlevel% equ 0 (set /a _utcFileOK=1 & goto :settingAuto)
echo.
echo.Kéo thả file UTC hoặc thư mục chứa UTC của ví %_vi:~0,7%***
echo.Chú ý: nếu thư mục nhập có khoảng trắng sẽ không thành công!
echo.Nhập 'waybackhome' để quay lại
echo.===
set /p _nhapUTC="Kéo thả và nhấn Enter để nhập: "
set _nhapUTC=%_nhapUTC: =%
if "%_nhapUTC%" == "waybackhome" (set "_nhapUTC=" & goto :settingAuto)
echo a | copy /-y "%_nhapUTC%" "%_cd%\user\UTC\">nul
goto :utcFile
:canAutoOnOff
if %_canAutoOnOff% == 0 (set /a _canAutoOnOff=1) else (set /a _canAutoOnOff=0)
echo.└── Đang cập nhật ... & goto :duLieuViCu
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
echo.Phát hiện ID Key cũ
echo.[1] Sử dụng lại
echo.[2] Xóa dữ liệu ID Key cũ
echo.[3] Quay lại
echo.[4] Hiển thị ID Key cũ
choice /c 1234 /n /m "Nhập số từ bàn phím: "
if %errorlevel% equ 1 (set /a _KeyIDOK=1 & goto :settingAuto)
if %errorlevel% equ 2 (set /a _KeyIDOK=0 & rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\auto\KeyID & goto :KeyID)
if %errorlevel% equ 3 (goto :settingAuto)
if %errorlevel% equ 4 (echo ID Key đang lưu là: %_KeyID% & timeout 10 & goto :settingAuto)
:KeyID2
echo ==========
echo Đang lấy ID Key của ví %_vi:~0,7%*** ...
cd %_cd%\planet
planet key --path %_cd%\user\utc> %_cd%\user\trackedAvatar\%_folderVi%\auto\_allKey.json 2>nul
findstr /L /i %_vi% %_cd%\user\trackedAvatar\%_folderVi%\auto\_allKey.json > %_cd%\user\trackedAvatar\%_folderVi%\auto\_KeyID.json 2>nul
set "_KeyID="
set /p _KeyID=<%_cd%\user\trackedAvatar\%_folderVi%\auto\_KeyID.json
rem Kiểm tra ID Key
echo.└── Kiểm tra Key ID ...
if not "%_KeyID%" == "" (goto :YesUTC) else (goto :NoUTC)
:NoUTC
echo.└──── Không tìm thấy file UTC của ví %_vi:~0,7%*** trong thư mục UTC đã lưu
color 4F
set /a _KeyIDOK=0
cd %_cd%\user\trackedAvatar\%_folderVi%\auto
rem Xóa file json
del *.json
timeout 5
call :background
cd %_cd%\planet
set _utcfile=^|planet key --path %_cd%\user\utc 2>nul|findstr /i %_vi%>nul
if %errorlevel% equ 0 (set /a _utcFileOK=1 & goto :settingAuto)
echo.
echo.Kéo thả file UTC hoặc thư mục chứa UTC của ví %_vi:~0,7%***
echo.Chú ý: nếu thư mục nhập có khoảng trắng sẽ không thành công!
echo.Nhập 'waybackhome' để quay lại
echo.===
set /p _nhapUTC="Kéo thả và nhấn Enter để nhập: "
set _nhapUTC=%_nhapUTC: =%
if "%_nhapUTC%" == "waybackhome" (set "_nhapUTC=" & rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\auto\KeyID & goto :settingAuto)
echo a | copy /-y "%_nhapUTC%" "%_cd%\user\UTC\">nul
goto :KeyID2
:YesUTC
echo.└──── Lấy Key ID của ví %_vi:~0,7%*** thành công
echo %_KeyID:~0,36%> %_cd%\user\trackedAvatar\%_folderVi%\auto\KeyID\_KeyID.txt 2>nul
cd %_cd%\user\trackedAvatar\%_folderVi%\auto
rem Xóa file json
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
echo.Phát hiện Public Key cũ
echo.[1] Sử dụng lại
echo.[2] Xóa dữ liệu Public Key cũ
echo.[3] Quay lại
echo.[4] Hiển thị Public Key cũ
choice /c 1234 /n /m "Nhập số từ bàn phím: "
if %errorlevel% equ 1 (set /a _publickeyOK=1 & goto :settingAuto)
if %errorlevel% equ 2 (set /a _publickeyOK=0 & rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\auto\publickey & goto :publickey)
if %errorlevel% equ 3 (goto :settingAuto)
if %errorlevel% equ 4 (echo.========== & echo. & echo Public Key đang lưu là: %_publickey% & timeout 10 & goto :settingAuto)
:publickey2
echo ==========
echo [1]Sử dụng 9cscan
echo [2]Sử dụng Planet
echo.
choice /c 12 /n /m "Nhập từ bàn phím: "
if %errorlevel% equ 1 (goto :9cscanPublicKey)
if %errorlevel% equ 2 (goto :PlanetPublickey)
rem Nhập PK
:9cscanPublicKey
echo.
echo ==========
echo Nhập Public Key của ví %_vi:~0,7%*** bằng 9cscan ...
rem --ssl-no-revoke sửa lỗi chứng chỉ
(curl --ssl-no-revoke --header "Content-Type: application/json" https://api.9cscan.com/accounts/%_vi%/transactions?action=activate_account^&action=activate_account2)> %_cd%\user\trackedAvatar\%_folderVi%\auto\output.json 2>nul
rem Lọc kết quả lấy dữ liệu
echo.└── Tìm publicKey của ví %_vi:~0,7%*** ...
call :ReadJsonbat publicKey
copy %_cd%\user\trackedAvatar\%_folderVi%\auto\ReadJsonbat.json %_cd%\user\trackedAvatar\%_folderVi%\auto\publickey\_publickey.txt> nul
set /p _publickey=<%_cd%\user\trackedAvatar\%_folderVi%\auto\publickey\_publickey.txt
del /q %_cd%\user\trackedAvatar\%_folderVi%\auto\ReadJsonbat.json
echo.└──── Lấy Public Key của ví %_vi:~0,7%*** thành công
echo.
set /a _publickeyOK=1
timeout 5
goto :settingAuto
:PlanetPublickey
echo.
echo ==========
echo Nhập Public Key của ví %_vi:~0,7%*** bằng Planet ...
echo.
if %_keyidOK% == 0 (color 4F & echo.Nhập Key ID của ví %_vi:~0,7%*** & echo.trước khi sử dụng tính năng này! & rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\auto\publickey & timeout 10 & goto :settingAuto)
if "%_passwordOK%" == "0" (goto :tryagainWithPass) else (goto :tryagainNoPass)
:tryagainWithPass
call :background
set _password=1
set /p _KeyID=<%_cd%\user\trackedAvatar\%_folderVi%\auto\KeyID\_KeyID.txt
set _KeyID=%_KeyID: =%
echo Tùy chọn: nhập "waybackhome" để quay lại
echo Nhập mật khẩu thủ công: 
echo Lưu ý: Tắt unikey trước khi nhập
set /P "=_" < NUL > "Enter password"
findstr /A:1E /V "^$" "Enter password" NUL > CON
del "Enter password"
set /P "_password="
call :background
echo ==========
echo Nhập Public Key của ví %_vi:~0,7%*** bằng Planet ...
rem Quay lại
if %_password% == waybackhome (set /a _publickeyOK=0 & rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\auto\publickey & goto :settingAuto)
if %_password% == checkcheck (start https://youtu.be/SRf8pTXPz9I?t=26s)
rem Tìm Public Key
cd %_cd%\planet
set _PublicKey=^|planet key export --passphrase %_PASSWORD% --public-key --path %_cd%\user\utc %_KeyID%
echo %_PublicKey%> %_cd%\user\trackedAvatar\%_folderVi%\auto\_KTraPPK.txt 2>nul
set "_PASSWORD="
goto :KTraPPK2
:tryagainNoPass
call :background
rem Cài _KeyID
set /p _KeyID=<%_cd%\user\trackedAvatar\%_folderVi%\auto\KeyID\_KeyID.txt
set _KeyID=%_KeyID: =%
set /p _password=<%_cd%\user\trackedAvatar\%_folderVi%\auto\password\_password.txt
echo └── Đang sử dụng mật khẩu đã lưu trước đó ...
cd %_cd%\planet
set _PublicKey=^|planet key export --passphrase %_PASSWORD% --public-key --path %_cd%\user\utc %_KeyID%
echo %_PublicKey% > %_cd%\user\trackedAvatar\%_folderVi%\auto\_KTraPPK.txt 2>nul
set "_PASSWORD="
call :background
echo ==========
echo Nhập Public Key của ví %_vi:~0,7%*** bằng Planet ...
goto :KTraPPK1
rem Kiểm tra xem có là Publick key hay không
:KTraPPK1
set "_KTraPPK="
set /p _KTraPPK=<%_cd%\user\trackedAvatar\%_folderVi%\auto\_KTraPPK.txt
del /q %_cd%\user\trackedAvatar\%_folderVi%\auto\_KTraPPK.txt
if [%_KTraPPK%] == [] (echo Lỗi 1: Mật khẩu đã lưu chưa đúng, thử lại ... & color 4F & set /a _passwordOK=0 & rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\auto\password & timeout 10 & goto :tryagainWithPass) else (goto :YesPPK)
:KTraPPK2
set "_KTraPPK="
set /p _KTraPPK=<%_cd%\user\trackedAvatar\%_folderVi%\auto\_KTraPPK.txt
del /q %_cd%\user\trackedAvatar\%_folderVi%\auto\_KTraPPK.txt
if [%_KTraPPK%] == [] (echo Lỗi 2: Nhập sai mật khẩu, thử lại ... & color 4F & timeout 10 & goto :tryagainWithPass) else (goto :YesPPK)
:YesPPK
cd %_cd%
echo.└── Nhập Public Key của ví %_vi:~0,7%*** thành công
rem Lưu lại public key
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
echo.Phát hiện mật khẩu cũ
echo.[1] Sử dụng lại
echo.[2] Xóa dữ liệu mật khẩu cũ
echo.[3] Quay lại
echo.[4] Hiển thị mật khẩu cũ
echo.[5] Ktra thử mật khẩu bằng cách lấy Public Key qua Planet
choice /c 12345 /n /m "Nhập số từ bàn phím: "
if %errorlevel% equ 1 (set /a _passwordOK=1 & goto :settingAuto)
if %errorlevel% equ 2 (set /a _passwordOK=0 & rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\auto\password & goto :password)
if %errorlevel% equ 3 (goto :settingAuto)
if %errorlevel% equ 4 (echo.========== & echo. & echo Mật khẩu đang lưu là: %_password% & timeout 10 & goto :settingAuto)
if %errorlevel% equ 5 (goto :PlanetPublickey)
:password2
echo.
echo ==========
echo Lưu trữ mật khẩu cho ví %_vi:~0,7%***
echo Lưu ý: Tắt unikey trước khi nhập
rem Gõ mật khẩu ẩn
set /P "=_" < NUL > "Enter password"
findstr /A:1E /V "^$" "Enter password" NUL > CON
del "Enter password"
set /P "password="
cls
color 0B
rem Lưu mật khẩu
cd %_cd%
echo %PASSWORD%> %_cd%\user\trackedAvatar\%_folderVi%\auto\password\_PASSWORD.txt 2>nul
set /a _passwordOK=1
goto :settingAuto
:premium
rem Tạo thư mục premium để lưu dữ liệu
cd %_cd%\batch\avatarAddress
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\premium"
if not exist %_folder% (md %_cd%\user\trackedAvatar\%_folderVi%\premium)
rem Số NCG bạn cần gửi cho tôi tới ví của tôi là 0x6374FE5F54CdeD72Ff334d09980270c61BC95186
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
	echo.Nhập 'donater' nếu bạn đã nhập Premium code
	echo hoặc đăng ký Donater trước đó
	set /p _premiumTX="Premium code: "
	echo %_premiumTX%> %_cd%\user\trackedAvatar\%_folderVi%\premium\_premiumTX.txt 2>nul
	goto :premium2
	)
set /p _premiumTX=<%_cd%\user\trackedAvatar\%_folderVi%\premium\_premiumTX.txt
set _premiumTX=%_premiumTX: =%
rem Tìm id của ví gửi trong Premium code
set _senderBuy=^|curl https://api.9cscan.com/transactions/%_premiumTX% --ssl-no-revoke 2>nul|jq -r ".updatedAddresses|.[0]"> %_cd%\user\trackedAvatar\%_folderVi%\premium\_senderBuy.txt 2>nul & set /p _senderBuy=<%_cd%\user\trackedAvatar\%_folderVi%\premium\_senderBuy.txt & del /q %_cd%\user\trackedAvatar\%_folderVi%\premium\_senderBuy.txt
call :background
echo.╔═══════════════════════════════╗
echo.║Price premium: [40;33m%_pricePremium2% NCG[40;96m/30days	║
echo.╚═══════════════════════════════╝
echo.
if "%_premiumTX%" == "donater" (echo.Phát hiện Premium code là 'donater'?) else (echo.Phát hiện Premium code cũ của ví %_senderBuy:~0,7%***)
if not %_HanSuDung% lss 1700 (echo.Premium code còn [40;92m%_HanSuDung%[40;96m blocks) else (echo.Premium code còn [40;91m%_HanSuDung%[40;96m blocks)
echo.[1] Sử dụng lại
echo.[2] Xóa dữ liệu Premium code cũ
echo.[3] Copy và hiển thị Premium code cũ
echo.[4] Quay lại
choice /c 1234 /n /m "Nhập số từ bàn phím: "
if %errorlevel% equ 1 (goto :premium2)
if %errorlevel% equ 2 (set /a _premiumTXOK=0 & set "_senderBuy=***********" & rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\premium & goto :premium)
if %errorlevel% equ 3 (echo Premium code đang lưu: %_premiumTX% & echo %_premiumTX%|clip & timeout 10 & goto :premium)
if %errorlevel% equ 4 (goto :settingAuto)
:premium2
set /a _premiumTXOK=0
echo.└── Đang kiểm tra Premium code ...
echo %_premiumTX%> %_cd%\user\trackedAvatar\%_folderVi%\premium\_premiumTX.txt 2>nul
if "%_premiumTX%" == "donater" (goto :ktraDonater)
cd %_cd%\batch\avatarAddress
set _pricePremium=^|curl https://api.9cscan.com/price --ssl-no-revoke 2>nul|jq ".[]?|select(.USD)?|.USD|(1/(.price))+2"> %_cd%\user\trackedAvatar\%_folderVi%\premium\_pricePremium.txt 2>nul & set /p _pricePremium=<%_cd%\user\trackedAvatar\%_folderVi%\premium\_pricePremium.txt & del /q %_cd%\user\trackedAvatar\%_folderVi%\premium\_pricePremium.txt
set /a _pricePremium=%_pricePremium% 2>nul
set _premiumTX=%_premiumTX: =%
rem Kiểm tra cơ bản Premium code
set _typeBuy=^|curl https://api.9cscan.com/transactions/%_premiumTX% --ssl-no-revoke 2>nul|findstr transfer_asset|findstr NCG|findstr /i 0x6374fe5f54cded72ff334d09980270c61bc95186|findstr /i SUCCESS>nul
if %errorlevel%==1 (echo. & echo Lỗi 1: Không phải Premium code, thử lại ... & color 4F & timeout 5 & goto :premium)
cd %_cd%\batch\avatarAddress
rem Kiểm tra nâng cao Premium code
set _senderBuy=^|curl https://api.9cscan.com/transactions/%_premiumTX% --ssl-no-revoke 2>nul|jq -r ".updatedAddresses|.[0]"> %_cd%\user\trackedAvatar\%_folderVi%\premium\_senderBuy.txt 2>nul & set /p _senderBuy=<%_cd%\user\trackedAvatar\%_folderVi%\premium\_senderBuy.txt & del /q %_cd%\user\trackedAvatar\%_folderVi%\premium\_senderBuy.txt
set _senderBuy=^|echo %_senderBuy%|findstr /i %_vi%>nul
if %errorlevel%==1 (echo. & echo Lỗi 2.1: Premium code của ví & echo %_senderBuy%, thử lại ... & color 4F & timeout 5 & goto :premium)
set _receiveBuy=^|curl https://api.9cscan.com/transactions/%_premiumTX% --ssl-no-revoke 2>nul|jq -r ".updatedAddresses|.[1]"> %_cd%\user\trackedAvatar\%_folderVi%\premium\_receiveBuy.txt 2>nul & set /p _receiveBuy=<%_cd%\user\trackedAvatar\%_folderVi%\premium\_receiveBuy.txt & del /q %_cd%\user\trackedAvatar\%_folderVi%\premium\_receiveBuy.txt
set _receiveBuy=^|echo %_receiveBuy%|findstr /i 0x6374fe5f54cded72ff334d09980270c61bc95186>nul
if %errorlevel%==1 (echo. & echo Lỗi 2.2: Premium code chưa gửi đúng tới ví của tôi & echo là 0x6374FE5F54CdeD72Ff334d09980270c61BC95186, thử lại ... & color 4F & timeout 5 & goto :premium)
set _statusBuy=^|curl https://api.9cscan.com/transactions/%_premiumTX% --ssl-no-revoke 2>nul|jq -r "[..]|.[6]"> %_cd%\user\trackedAvatar\%_folderVi%\premium\_statusBuy.txt 2>nul & set /p _statusBuy=<%_cd%\user\trackedAvatar\%_folderVi%\premium\_statusBuy.txt & del /q %_cd%\user\trackedAvatar\%_folderVi%\premium\_statusBuy.txt
set _statusBuy=^|echo %_statusBuy%|findstr /i SUCCESS>nul
if %errorlevel%==1 (echo. & echo Lỗi 2.3: Premium code chưa gửi thành công, thử lại ... & color 4F & timeout 5 & goto :premium)
set _blockBuy=^|curl https://api.9cscan.com/transactions/%_premiumTX% --ssl-no-revoke 2>nul|jq -r "[..]|.[8]"> %_cd%\user\trackedAvatar\%_folderVi%\premium\_blockBuy.txt 2>nul & set /p _blockBuy=<%_cd%\user\trackedAvatar\%_folderVi%\premium\_blockBuy.txt & del /q %_cd%\user\trackedAvatar\%_folderVi%\premium\_blockBuy.txt
set /a _blockBuy+=216000 2>nul
if %_blockBuy% lss %_9cscanBlock% (echo. & echo Lỗi 2.4: Premium code đã hết hạn, thử lại ... & color 4F & timeout 5 & goto :premium)
set /a _HanSuDung= %_blockBuy% - %_9cscanBlock% 2>nul
set _NCGbuy=^|curl https://api.9cscan.com/transactions/%_premiumTX% --ssl-no-revoke 2>nul|jq -r "[..]|.[14]"> %_cd%\user\trackedAvatar\%_folderVi%\premium\_NCGbuy.json 2>nul
cd %_cd%\user\trackedAvatar\%_folderVi%\premium
set /a _NCGbuyi=1
for /f "tokens=*" %%a in (_NCGbuy.json) do call :_NCGbuyi %%a
set /a _NCGbuyi=1
for /f "tokens=*" %%a in (_NCGbuy.json) do call :_NCGbuyi %%a
findstr /i NCG %_cd%\user\trackedAvatar\%_folderVi%\premium\_NCGticker.txt>nul
if %errorlevel%==1 (del /q %_cd%\user\trackedAvatar\%_folderVi%\premium\_NCGticker.txt & del /q %_cd%\user\trackedAvatar\%_folderVi%\premium\_NCGticker.txt & echo. & echo Lỗi 2.5: Premium code không phải là gửi NCG, thử lại ... & color 4F & timeout 5 & goto :premium)
if %_NCGbuy% lss %_pricePremium% (color 4F & echo. & echo Lỗi 2.6: Premium code gửi NCG nhỏ hơn [41;33m%_pricePremium% NCG[41;97m, & echo.thử lại ... & timeout 5 & goto :premium)
del /q %_cd%\user\trackedAvatar\%_folderVi%\premium\_NCGbuy.json
set /a _premiumTXOK=1
goto :settingAuto
:ktraDonater
rem Kiểm tra ví có là donater hay không
set /a _premiumTXOK=0
cd %_cd%\user\trackedAvatar\%_folderVi%
echo {"vi":"%_vi%"}> _vi.json
"%_cd%\batch\jq.exe" -r ".vi|ascii_downcase" _vi.json> _viLowcase.txt 2>nul & set /p _viLowcase=<_viLowcase.txt
del /q _vi.json & del /q _viLowcase.txt
curl --ssl-no-revoke --header "Content-Type: application/json" https://api.tanvpn.tk/donater?vi=%_viLowcase%> _KtraDonater.json 2>nul
findstr /i %_viLowcase% _KtraDonater.json>nul
if %errorlevel%==1 (echo. & echo Lỗi 1: Bạn chưa là Donater, thử lại ... & del /q _KtraDonater.json & color 4F & timeout 5 & goto :premium)
"%_cd%\batch\jq.exe" -r ".[].block" _KtraDonater.json> _HanSuDung.txt 2>nul
set /p _HanSuDung=<_HanSuDung.txt & del /q _HanSuDung.txt & del /q _KtraDonater.json
set /a _premiumTXOK=1
goto :settingAuto
:_NCGbuyi
rem Tìm ra số NCG trong Premium code
if %_NCGbuyi%==8 echo %*> _NCGticker.txt 2>nul
if %_NCGbuyi%==10 echo %*> _NCGbuy.txt 2>nul & set /p _NCGbuy=<_NCGbuy.txt & set /a _NCGbuy=%_NCGbuy:~0,-2% & del /q _NCGbuy.txt
set /a _NCGbuyi+=1
exit /b
:ReadJsonbat
"%_cd%\batch\jq" -r "..|.%1?|select(.)" %_cd%\user\trackedAvatar\%_folderVi%\auto\output.json> %_cd%\user\trackedAvatar\%_folderVi%\auto\ReadJsonbat.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\auto\output.json
exit /b
:autoRefillAP
rem Tạo thư mục lưu dữ liệu
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%\autoRefillAP"
if exist %_folder% (rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%\autoRefillAP)
md %_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%\autoRefillAP
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%\autoRefillAP
copy "%_cd%\batch\jq.exe" "jq.exe"> nul
echo off
echo ==========
echo Bước 1: Nhận unsignedTransaction
rem Gửi thông tin của bạn tới server của tôi
echo {"vi":"%_vi%","publicKey":"%_publickey%","char":"%_address%","stt":%_charDisplay%,"premiumTX":"%_premiumTX%"}> input.json 2>nul
curl -X POST -H "accept: application/json" -H "Content-Type: application/json" --data "@input.json" https://api.tanvpn.tk/refillAP --ssl-no-revoke --location> output.json 2>nul
findstr /i kqua output.json> nul
if %errorlevel% equ 1 (echo.└── Lỗi 0: Không xác định, tắt auto ... & set /a _canAutoOnOff=0 & color 4F & timeout 5 & goto :displayVi)
jq -r ".checkqua" output.json> _checkqua.txt 2>nul & set /p _checkqua=<_checkqua.txt
jq -r ".kqua" output.json> _kqua.txt 2>nul & set /p _kqua=<_kqua.txt
if %_checkqua% == 0 (echo.└── %_kqua%, tắt auto ... & set /a _canAutoOnOff=0 & color 4F & timeout 10 & goto :displayVi)
echo.└──── Nhận unsignedTransaction thành công
echo ==========
echo Bước 2: Nhận Signature
rem Tạo file action
call certutil -decodehex _kqua.txt action >nul
rem Lấy lại _IDKey
echo.└── Đang sử dụng mật khẩu đã lưu trước đó ...
set /p _KeyID=<%_cd%\user\trackedAvatar\%_folderVi%\auto\KeyID\_KeyID.txt
set _KeyID=%_KeyID: =%
set /p _password=<%_cd%\user\trackedAvatar\%_folderVi%\auto\password\_password.txt
"%_cd%\planet\planet" key sign --passphrase %_PASSWORD% --store-path %_cd%\user\utc %_KeyID% action> _signature.txt 2>nul
set "_PASSWORD="
goto :KTraSignature1
:KTraSignature1
set "_signature="
set /p _signature=<_signature.txt
if [%_signature%] == [] (echo.└──── Lỗi 1: Mật khẩu đang lưu chưa đúng, tắt auto ... & set /a _canAutoOnOff=0 & color 4F & set /a _passwordOK=0 & rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\auto\password & timeout 10 & goto :displayVi)
echo.└──── Nhận Signature thành công
echo ==========
echo Bước 3: Nhận signTransaction
echo.
echo.[1] Tiếp tục refill AP, tự động sau 10s
echo.[2] Quay lại menu và tắt auto
choice /c 12 /n /t 10 /d 1 /m "Nhập từ bàn phím: "
if %errorlevel%==1 (goto :tieptucAutoRefillAP)
if %errorlevel%==2 (set /a _canAutoOnOff=0 & goto :displayVi)
:tieptucAutoRefillAP
call %_cd%\batch\TaoInputJson.bat _unsignedTransaction %_kqua% %_cd%\batch\_codeStep3.txt> input1.json 2>nul
call %_cd%\batch\TaoInputJson.bat _signature %_signature% input1.json> input.json 2>nul
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json  2>nul
echo.└── Tìm signTransaction ...
jq -r "..|.signTransaction?|select(.)" output.json> _signTransaction.txt 2>nul
echo.└──── Nhận signTransaction thành công
echo ==========
echo Bước 4: Nhận stageTransaction
echo.
set /p _signTransaction=<_signTransaction.txt
call %_cd%\batch\TaoInputJson.bat _signTransaction %_signTransaction% %_cd%\batch\_codeStep4.txt> input.json 2>nul
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json  2>nul
echo.└── Tìm stageTransaction ...
jq -r "..|.stageTransaction?|select(.)" output.json> _stageTransaction.txt 2>nul
echo.└──── Nhận stageTransaction thành công
set /a _countKtraAuto=0
:ktraAutoRefillAP
set /a _countKtraAuto+=1
color 0B
cls
echo.╔═══════════════╗   ╔═══════════════╗   ╔═══════════════╗
if %_canAuto%==5 echo ║Ví %_vi:~0,7%***	║   ║Block: %_9cscanBlock% ║   ║[40;92mCan Auto? [X]	[40;96m║
if not %_canAuto%==5 echo ║Ví %_vi:~0,7%***	║   ║Block: %_9cscanBlock% ║   ║[40;97mCan Auto? [ ]	[40;96m║
echo.╚═══════════════╝   ╚═══════════════╝   ╚═══════════════╝
echo ==========
echo Bước 5: Kiểm tra auto Refill AP nhân vật: %_name%
set /p _stageTransaction=<_stageTransaction.txt
call %_cd%\batch\TaoInputJson.bat _stageTransaction %_stageTransaction% %_cd%\batch\_codeStep5.txt> input.json 2>nul
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json 2>nul
echo.└── Tìm txStatus ...
jq -r "..|.txStatus?|select(.)" output.json> _txStatus.txt 2>nul
set /p _txStatus=<_txStatus.txt
if "%_txStatus%" == "STAGING" (color 0B & echo.─── Status: Auto Refill AP đang diễn ra & echo.─── kiểm tra lại sau 15s ... & set /a _countKtraAuto=0 & timeout /t 15 /nobreak>nul & goto :ktraAutoRefillAP)
if "%_txStatus%" == "FAILURE" (color 4F & echo.─── Status: Auto Refill AP thất bại & echo.─── đợi 10p sau thử lại auto Refill AP, ... & timeout /t 3600 /nobreak & echo.└──── Đang cập nhật ... & goto :duLieuViCu)
if "%_txStatus%" == "INVALID" (if %_countKtraAuto% lss 4 (color 8F & echo.─── Status: Auto Refill AP tạm thời thất bại & echo.─── kiểm tra lại lần %_countKtraAuto% sau 15s ... & timeout /t 15 /nobreak>nul & goto :ktraAutoRefillAP))
if "%_txStatus%" == "INVALID" (if %_countKtraAuto% geq 4 (color 8F & echo.─── Status: Auto Refill AP thất bại & echo.─── tắt auto ... & set /a _canAutoOnOff=0 & timeout 10 & echo.└──── Đang cập nhật ... & goto :duLieuViCu))
if "%_txStatus%" == "SUCCESS" (color 2F & echo.─── Status: Auto Refill AP thành công & echo.─── quay lại menu ... & timeout 10 & echo.└──── Đang cập nhật ... & goto :duLieuViCu)
color 4F & echo.─── Lỗi 2: Lỗi không xác định & echo.─── tắt auto ... & set /a _canAutoOnOff=0 & timeout 10 & echo.└──── Đang cập nhật ... & goto :duLieuViCu
goto :duLieuViCu
:autoSweep
rem Tạo thư mục lưu dữ liệu
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%\autoSweep"
if exist %_folder% (rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%\autoSweep)
md %_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%\autoSweep
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%\autoSweep
copy "%_cd%\batch\jq.exe" "jq.exe"> nul
jq --compact-output "[.weapon,.armor,.belt,.necklace,.ring1,.ring2]" %_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%\settingSweep\_itemEquip.json> _itemIDList.json 2>nul
set /p _itemIDList=<_itemIDList.json
echo off
rem Gửi thông tin của bạn tới server của tôi
echo ==========
echo Bước 1: Nhận unsignedTransaction
echo {"vi":"%_vi%","publicKey":"%_publickey%","char":"%_address%","stt":%_charDisplay%,"premiumTX":"%_premiumTX%","world": "%_world%","stageSweep": "%_stageSweep%","howManyAP": "%_howManyAP%","itemIDList": %_itemIDList%}> input.json 2>nul
curl -X POST -H "accept: application/json" -H "Content-Type: application/json" --data "@input.json" https://api.tanvpn.tk/autoSweep --ssl-no-revoke --location> output.json 2>nul
findstr /i kqua output.json> nul
if %errorlevel% equ 1 (echo.└── Lỗi 0: Không xác định, tắt auto ... & set /a _canAutoOnOff=0 & color 4F & timeout 5 & goto :displayVi)
jq -r ".checkqua" output.json> _checkqua.txt 2>nul & set /p _checkqua=<_checkqua.txt
jq -r ".kqua" output.json> _kqua.txt 2>nul
rem Nhận giá trị vượt quá 1024 kí tự
for %%A in (_kqua.txt) do for /f "usebackq delims=" %%B in ("%%A") do (
  set "_kqua=%%B"
  goto :autoSweep1
)
:autoSweep1
if %_checkqua% == 0 (echo.└── %_kqua%, tắt auto ... & set /a _canAutoOnOff=0 & color 4F & timeout 10 & goto :displayVi)
echo.└──── Nhận unsignedTransaction thành công
echo ==========
echo Bước 2: Nhận Signature
rem Tạo file action
call certutil -decodehex _kqua.txt action >nul
rem Lấy lại _IDKeyCuaA
echo.└── Đang sử dụng mật khẩu đã lưu trước đó ...
set /p _KeyID=<%_cd%\user\trackedAvatar\%_folderVi%\auto\KeyID\_KeyID.txt
set _KeyID=%_KeyID: =%
set /p _password=<%_cd%\user\trackedAvatar\%_folderVi%\auto\password\_password.txt
"%_cd%\planet\planet" key sign --passphrase %_PASSWORD% --store-path %_cd%\user\utc %_KeyID% action> _signature.txt 2>nul
set "_PASSWORD="
goto :KTraSignature2
:KTraSignature2
set "_signature="
rem Nhận giá trị vượt quá 1024 kí tự
for %%A in (_signature.txt) do for /f "usebackq delims=" %%B in ("%%A") do (
  set "_signature=%%B"
  goto :autoSweep2
)
:autoSweep2
if [%_signature%] == [] (echo.└──── Lỗi 1: Mật khẩu đang lưu chưa đúng, tắt auto ... & set /a _canAutoOnOff=0 & color 4F & set /a _passwordOK=0 & rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\auto\password & timeout 10 & goto :displayVi)
echo.└──── Nhận Signature thành công
echo ==========
echo Bước 3: Nhận signTransaction
echo.
echo.[1] Tiếp tục sweep, tự động sau 10s
echo.[2] Quay lại menu và tắt auto
choice /c 12 /n /t 10 /d 1 /m "Nhập từ bàn phím: "
if %errorlevel%==1 (goto :tieptucAutoSweep)
if %errorlevel%==2 (set /a _canAutoOnOff=0 & goto :displayVi)
:tieptucAutoSweep
call %_cd%\batch\TaoInputJson.bat _unsignedTransaction %_kqua% %_cd%\batch\_codeStep3.txt> input1.json 2>nul
call %_cd%\batch\TaoInputJson.bat _signature %_signature% input1.json> input.json 2>nul
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json  2>nul
echo.└── Tìm signTransaction ...
jq -r "..|.signTransaction?|select(.)" output.json> _signTransaction.txt 2>nul
echo.└──── Nhận signTransaction thành công
echo ==========
echo Bước 4: Nhận stageTransaction
echo.
rem Nhận giá trị vượt quá 1024 kí tự
for %%A in (_signTransaction.txt) do for /f "usebackq delims=" %%B in ("%%A") do (
  set "_signTransaction=%%B"
  goto :autoSweep3
)
:autoSweep3
call %_cd%\batch\TaoInputJson.bat _signTransaction %_signTransaction% %_cd%\batch\_codeStep4.txt> input.json 2>nul
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json  2>nul
echo.└── Tìm stageTransaction ...
jq -r "..|.stageTransaction?|select(.)" output.json> _stageTransaction.txt 2>nul
echo.└──── Nhận stageTransaction thành công
set /a _countKtraAuto=0
:ktraAutoSweep
set /a _countKtraAuto+=1
color 0B
cls
echo.╔═══════════════╗   ╔═══════════════╗   ╔═══════════════╗
if %_canAuto%==5 echo ║Ví %_vi:~0,7%***	║   ║Block: %_9cscanBlock% ║   ║[40;92mCan Auto? [X]	[40;96m║
if not %_canAuto%==5 echo ║Ví %_vi:~0,7%***	║   ║Block: %_9cscanBlock% ║   ║[40;97mCan Auto? [ ]	[40;96m║
echo.╚═══════════════╝   ╚═══════════════╝   ╚═══════════════╝
echo ==========
echo Bước 5: Kiểm tra auto Sweep nhân vật: %_name%
set /p _stageTransaction=<_stageTransaction.txt
call %_cd%\batch\TaoInputJson.bat _stageTransaction %_stageTransaction% %_cd%\batch\_codeStep5.txt> input.json 2>nul
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json 2>nul
echo.└── Tìm txStatus ...
jq -r "..|.txStatus?|select(.)" output.json> _txStatus.txt 2>nul
set /p _txStatus=<_txStatus.txt
if "%_txStatus%" == "STAGING" (color 0B & echo.─── Status: Auto Sweep đang diễn ra & echo.─── kiểm tra lại sau 15s ... & set /a _countKtraAuto=0 & timeout /t 15 /nobreak>nul & goto :ktraAutoSweep)
if "%_txStatus%" == "FAILURE" (color 4F & echo.─── Status: Auto Sweep thất bại & echo.─── đợi 10p sau thử lại auto Sweep, ... & timeout /t 3600 /nobreak & echo.└──── Đang cập nhật ... & goto :duLieuViCu)
if "%_txStatus%" == "INVALID" (if %_countKtraAuto% lss 4 (color 8F & echo.─── Status: Auto Sweep tạm thời thất bại & echo.─── kiểm tra lại lần %_countKtraAuto% sau 15s ... & timeout /t 15 /nobreak>nul & goto :ktraAutoSweep))
if "%_txStatus%" == "INVALID" (if %_countKtraAuto% geq 4 (color 8F & echo.─── Status: Auto Sweep thất bại & echo.─── tắt auto ... & set /a _canAutoOnOff=0 & timeout 10 & echo.└──── Đang cập nhật ... & goto :duLieuViCu))
if "%_txStatus%" == "SUCCESS" (color 2F & echo.─── Status: Auto Sweep thành công & echo.─── quay lại menu ... & timeout 10 & echo.└──── Đang cập nhật ... & goto :duLieuViCu)
color 4F & echo.─── Lỗi 2: Lỗi không xác định & echo.─── tắt auto ... & set /a _canAutoOnOff=0 & timeout 10 & echo.└──── Đang cập nhật ... & goto :duLieuViCu
goto :duLieuViCu