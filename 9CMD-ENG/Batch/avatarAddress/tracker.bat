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
set /a _premiumTXOK=0 & set /a _passwordOK=0 & set /a _publickeyOK=0 & set /a _keyidOK=0 & set /a _canAutoOnOff=0 & set /a _utcFileOK=0
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
if exist %_folder% (goto :yesFolder) else (echo.└── Đang xử lý... & goto :noFolder)
:yesFolder
rem Lấy ví đang được lưu
set /p _vi=<%_cd%\user\trackedAvatar\%_folderVi%\_vi.txt
call :background
echo.Đã tồn tại thư mục vi%_stt% trong bộ nhớ
echo.[1] Vẫn dùng dữ liệu cũ
echo.[2] Xóa dữ liệu ví cũ và tạo mới
echo.[3] Thoát
choice /c 123 /n /m "Nhập từ bàn phím: "
echo.└── Đang xử lý...
if %errorlevel%==3 (echo.└──── Thoát sau 5s... & timeout 5 & exit)
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
cd %_cd%\batch\avatarAddress
curl https://api.9cscan.com/transactions?limit=0 --ssl-no-revoke> _9cscanBlock.json 2>nul & set /p _9cscanBlock=<_9cscanBlock.json
del /q _9cscanBlock.json & set /a _9cscanBlock=%_9cscanBlock:~-11,-4%
rem Nhận dữ liệu nhân vật
cd %_cd%\batch\avatarAddress
curl https://api.9cscan.com/account?address=%_vi% --ssl-no-revoke> %_cd%\user\trackedAvatar\%_folderVi%\_allChar.json 2>nul
jq "length" %_cd%\user\trackedAvatar\%_folderVi%\_allChar.json> %_cd%\user\trackedAvatar\%_folderVi%\_length.txt 2>nul
set /p _length=<%_cd%\user\trackedAvatar\%_folderVi%\_length.txt
if not %_length% geq 1 (if %_length% leq 4 (echo. & echo Lỗi 1: Ví nhập sai hoặc 9cscan lỗi 404, thử lại... & color 4F & timeout 5 & goto :BatDau))
set /a _length+=-1
rem Lọc từng nhân vật
set _charCount=1
:locChar
cd %_cd%\batch\avatarAddress
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%"
if exist %_folder% (rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%)
md %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%
jq ".[%_charCount%]|del(.refreshBlockIndex)|del(.avatarAddress)|del(.address)|del(.goldBalance)|.[]|{address, name, level, actionPoint,timeCount: (.dailyRewardReceivedIndex+1700-%_9cscanBlock%)}" %_cd%\user\trackedAvatar\%_folderVi%\_allChar.json> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_infoChar.json 2>nul
jq "{sec: ((.timeCount*12)%%60),minute: ((((.timeCount*12)-(.timeCount*12)%%60)/60)%%60),hours: (((((.timeCount*12)-(.timeCount*12)%%60)/60)-(((.timeCount*12)-(.timeCount*12)%%60)/60%%60))/60)}" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_infoChar.json> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_infoCharAp.json 2>nul
jq -j """\(.hours):\(.minute):\(.sec)""" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_infoCharAp.json> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_infoCharAp.txt 2>nul
jq -r ".address" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_infoChar.json> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_address.txt 2>nul
jq -r ".name" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_infoChar.json> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_name.txt 2>nul
jq -r ".level" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_infoChar.json> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_level.txt 2>nul
jq -r ".actionPoint" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_infoChar.json> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_actionPoint.txt 2>nul
jq -r ".timeCount" %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_infoChar.json> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_timeCount.txt 2>nul
rem Lấy stage đang tới
cd %_cd%\batch
set /p _AddressChar=<%_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_address.txt
rem Kiểm tra số dư
echo {"query":"query{stateQuery{avatar(avatarAddress:\"%_AddressChar%\"){stageMap{count}}}}"}> input.json 2>nul
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json 2>nul
rem Lọc kết quả lấy dữ liệu
jq -r "..|.count?|select(.)" output.json> %_cd%\user\trackedAvatar\%_folderVi%\char%_charCount%\_stage.txt 2>nul
rem Xóa file nháp input và output
cd %_cd%\batch
del *.json
if not "%_charCount%"=="%_length%" (set /a _charCount+=1 & goto :locChar)
:displayVi
call :background
set _charCount=1
:displayChar
call :background2 %_charCount%
if not "%_charCount%"=="%_length%" (set /a _charCount+=1 & goto :displayChar)
echo.[40;96m
echo.==========
echo.[1] Cập nhật lại, tự động sau 60s
echo.[2] Cài Auto
echo.[3] Đang hoàn thiện...
choice /c 123 /n /t 60 /d 1 /m "Nhập số từ bàn phím: "
if %errorlevel% equ 1 (echo.└── Đang làm mới dữ liệu nhân vật... & goto :duLieuViCu)
if %errorlevel% equ 2 (goto :settingAuto)
if %errorlevel% equ 3 (goto :displayVi)
goto :displayVi



:background
cd %_cd%
mode con:cols=60 lines=25
color 0B
title Ví [%_stt%][%_vi%]
cls
set /a _canAuto=%_premiumTXOK% + %_passwordOK% + %_publickeyOK% + %_KeyIDOK% + %_utcFileOK% + %_canAutoOnOff%
echo.╔═══════════════╗   ╔═══════════════╗   ╔═══════════════╗
if %_canAuto%==6 echo ║Ví %_vi:~0,7%***	║   ║Block: %_9cscanBlock% ║   ║[40;92mCan Auto? [X]	[40;96m║
if not %_canAuto%==6 echo ║Ví %_vi:~0,7%***	║   ║Block: %_9cscanBlock% ║   ║[40;97mCan Auto? [ ]	[40;96m║
echo.╚═══════════════╝   ╚═══════════════╝   ╚═══════════════╝
exit /b
:background2
set /a _charDisplay=%1
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%
set /p _name=<_name.txt & set /p _level=<_level.txt & set /p _stage=<_stage.txt & set /p _actionPoint=<_actionPoint.txt & set /p _infoCharAp=<_infoCharAp.txt & set /p _timeCount=<_timeCount.txt & set /p _address=<_address.txt
echo 0 > _world.txt 2>nul
set /a _stage=%_stage%
if %_stage% lss 50 (echo 1 > _world.txt 2>nul)
if %_stage% leq 100 (if %_stage% geq 51 (echo 2 > _world.txt 2>nul))
if %_stage% leq 150 (if %_stage% geq 101 (echo 3 > _world.txt 2>nul))
if %_stage% leq 200 (if %_stage% geq 151 (echo 4 > _world.txt 2>nul))
if %_stage% leq 250 (if %_stage% geq 201 (echo 5 > _world.txt 2>nul))
if %_stage% leq 300 (if %_stage% geq 251 (echo 6 > _world.txt 2>nul))
if %_stage% leq 350 (if %_stage% geq 301 (echo 7 > _world.txt 2>nul))
set _name=                    %_name%
set _level=                    %_level%
set _stage=               %_stage%
set _actionPoint=               %_actionPoint%
set _infoCharAp=                    %_infoCharAp%
if %_timeCount% lss 0 (
	echo.[40;32m╔═══════════════════════════════════════════════════════╗
	echo.║Name	:%_name:~-20%	AP	:%_actionPoint:~-15%║
	echo.║Level	:%_level:~-20%	Stage	:%_stage:~-15%║
	echo.║Refill	:%_infoCharAp:~-20%	[X]			║
	echo.╚═══════════════════════════════════════════════════════╝
	) else (
		echo.[40;96m╔═══════════════════════════════════════════════════════╗
		echo.║Name	:%_name:~-20%	AP	:%_actionPoint:~-15%║
		echo.║Level	:%_level:~-20%	Stage	:%_stage:~-15%║
		echo.║Refill	:%_infoCharAp:~-20%	[ ]			║
		echo.╚═══════════════════════════════════════════════════════╝
		)
set /p _name=<_name.txt & set /p _level=<_level.txt & set /p _stage=<_stage.txt & set /p _actionPoint=<_actionPoint.txt & set /p _infoCharAp=<_infoCharAp.txt & set /p _timeCount=<_timeCount.txt & set /p _address=<_address.txt
if %_timeCount% lss 0 (if %_canAuto% == 6 (if %_actionPoint% == 0 (echo.└── Đang refill AP nhân vật: %_name%... & call :autoRefillAP)))
exit /b
:settingAuto
call :background
echo.==========
echo.╔═══════════════╗   ╔═══════════════╗   ╔═══════════════╗
echo ║1.Premium?[%_premiumTXOK%]	║   ║2.Password?[%_passwordOK%] ║   ║3.PublicKey?[%_publickeyOK%]║
echo.╚═══════════════╝   ╚═══════════════╝   ╚═══════════════╝
echo.╔═══════════════╗   ╔═══════════════╗   ╔═══════════════╗
echo ║4.KeyID?[%_KeyIDOK%]	║   ║5.File UTC?[%_utcFileOK%] ║   ║6.Bật/Tắt?[%_canAutoOnOff%]  ║
echo.╚═══════════════╝   ╚═══════════════╝   ╚═══════════════╝
echo.==========
echo.[1..6] Nhập đủ mới có thể Auto
echo.[7] Hướng dẫn sử dụng
echo.[8] Quay lại
echo.[9] Nhập lại dữ liệu cũ [1, 2, 3, 4] nhanh nếu có
echo.
choice /c 123456789 /n /m "Nhập số từ bàn phím: "
if %errorlevel% equ 1 (goto :premium)
if %errorlevel% equ 2 (goto :password)
if %errorlevel% equ 3 (goto :publickey)
if %errorlevel% equ 4 (goto :KeyID)
if %errorlevel% equ 5 (goto :utcFile)
if %errorlevel% equ 6 (goto :canAutoOnOff)
if %errorlevel% equ 7 (goto :hdsd)
if %errorlevel% equ 8 (goto :displayVi)
if %errorlevel% equ 9 (goto :inputAllOldData)
goto :settingAuto
:inputAllOldData
echo.└── Đang thử nhập lại...
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\premium"
if exist %_folder% (set /p _premiumTX=<%_cd%\user\trackedAvatar\%_folderVi%\premium\_premiumTX.txt & set /a _premiumTXOK=1)
rem Thử lấy mật khẩu
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\auto\password"
if exist %_folder% (set /p _password=<%_cd%\user\trackedAvatar\%_folderVi%\auto\password\_password.txt & set /a _passwordOK=1)
rem Thử lấy publci key
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\auto\publickey"
if exist %_folder% (set /p _publickey=<%_cd%\user\trackedAvatar\%_folderVi%\auto\publickey\_publickey.txt & set /a _publickeyOK=1)
rem Thử lấy Key ID
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\auto\KeyID"
if exist %_folder% (set /p _KeyID=<%_cd%\user\trackedAvatar\%_folderVi%\auto\KeyID\_KeyID.txt & set /a _keyidOK=1)
echo.└──── Hoàn tất...
timeout 1 >nul
goto :settingAuto
:hdsd
call :background
echo.==========
echo.[40;92mCode premium là gì?[40;96m
echo.─── Là mã tx (Transaction Hash) của giao dịch gửi NCG, sử
echo.─── dụng để tự động đăng ký Donater - sắp có
echo.[40;92mSử dụng đến khi nào?[40;96m
echo.─── Tính từ block mua premium + 216000, với 12s/1block tương
echo.─── đương 30 ngày
echo.
echo.==========
echo.Bạn muốn trở thành Donater hoặc feedback lỗi
echo.contact tôi qua...
echo.
echo.[1] Discord tanbt#9827
echo.[2] Telegram @tandotbt
echo.[3] Discord Plantarium - #unofficial-mods
echo.[4] Youtube tanbt
echo.
choice /c 12345 /n /m "Nhập [5] để quay lại: "
if %errorlevel% equ 1 (start https://discordapp.com/users/466271401796567071 & goto :LienHeToi)
if %errorlevel% equ 2 (start https://t.me/tandotbt & goto :LienHeToi)
if %errorlevel% equ 3 (start https://discord.com/channels/539405872346955788/1035354979709485106 & goto :LienHeToi)
if %errorlevel% equ 4 (start https://www.youtube.com/c/tanbt & goto :LienHeToi)
if %errorlevel% equ 5 (goto :settingAuto)
goto :settingAuto
:utcFile
echo.└── Đang kiểm tra có UTC của ví %_vi:~0,7%*** hay không...
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
goto :settingAuto
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
if %errorlevel% equ 4 (echo %_KeyID% & timeout 10 & goto :settingAuto)
:KeyID2
echo ==========
echo Đang lấy ID Key của ví %_vi:~0,7%***
cd %_cd%\planet
planet key --path %_cd%\user\utc> %_cd%\user\trackedAvatar\%_folderVi%\auto\_allKey.json 2>nul
findstr /L /i %_vi% %_cd%\user\trackedAvatar\%_folderVi%\auto\_allKey.json > %_cd%\user\trackedAvatar\%_folderVi%\auto\_KeyID.json 2>nul
set "_KeyID="
set /p _KeyID=<%_cd%\user\trackedAvatar\%_folderVi%\auto\_KeyID.json
rem Kiểm tra ID Key
echo.└── Kiểm tra Key ID
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
echo Nhập Public Key của ví %_vi:~0,7%*** bằng 9cscan
rem --ssl-no-revoke sửa lỗi
curl --ssl-no-revoke --header "Content-Type: application/json" https://api.9cscan.com/accounts/%_vi%/transactions?action=activate_account 2>nul|findstr /i signed> %_cd%\user\trackedAvatar\%_folderVi%\auto\output.json 2>nul
if %errorlevel% == 0 (goto :9cscanPublicKey2)
:9cscanPublicKey1
curl --ssl-no-revoke --header "Content-Type: application/json" https://api.9cscan.com/accounts/%_vi%/transactions?action=activate_account2 2>nul|findstr /i signed> %_cd%\user\trackedAvatar\%_folderVi%\auto\output.json 2>nul
:9cscanPublicKey2
rem Lọc kết quả lấy dữ liệu
echo.└── Tìm publicKey của ví %_vi:~0,7%***
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
echo Nhập Public Key của ví %_vi:~0,7%*** bằng Planet
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
echo Nhập Public Key của ví %_vi:~0,7%*** bằng Planet
rem Quay lại 9cscanPublickey
if %_password% == waybackhome (set /a _publickeyOK=0 & rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\auto\publickey & goto :settingAuto)
if %_password% == checkcheck (start https://youtu.be/SRf8pTXPz9I?t=26s)
rem Lấy Public Key của A
cd %_cd%\planet
set _PublicKey=^|planet key export --passphrase %_PASSWORD% --public-key --path %_cd%\user\utc %_KeyID%
echo %_PublicKey%> %_cd%\user\trackedAvatar\%_folderVi%\auto\_KTraPPK.txt 2>nul
set "_PASSWORD="
goto :KTraPPK2
:tryagainNoPass
call :background
rem Lấy lại _KeyID
set /p _KeyID=<%_cd%\user\trackedAvatar\%_folderVi%\auto\KeyID\_KeyID.txt
set _KeyID=%_KeyID: =%
set /p _password=<%_cd%\user\trackedAvatar\%_folderVi%\auto\password\_password.txt
echo Sử dụng mật khẩu đã lưu
cd %_cd%\planet
set _PublicKey=^|planet key export --passphrase %_PASSWORD% --public-key --path %_cd%\user\utc %_KeyID%
echo %_PublicKey% > %_cd%\user\trackedAvatar\%_folderVi%\auto\_KTraPPK.txt 2>nul
set "_PASSWORD="
call :background
echo ==========
echo Nhập Public Key của ví %_vi:~0,7%*** bằng Planet
goto :KTraPPK1
rem Kiểm tra xem có là Publick key hay không
:KTraPPK1
set "_KTraPPK="
set /p _KTraPPK=<%_cd%\user\trackedAvatar\%_folderVi%\auto\_KTraPPK.txt
del /q %_cd%\user\trackedAvatar\%_folderVi%\auto\_KTraPPK.txt
if [%_KTraPPK%] == [] (echo Lỗi 1: Mật khẩu cài trong file PASSWORD chưa đúng, thử lại... && color 4F & set /a _passwordOK=0 & rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\auto\password & timeout 10 && goto :tryagainWithPass) else (goto :YesPPK)
:KTraPPK2
set "_KTraPPK="
set /p _KTraPPK=<%_cd%\user\trackedAvatar\%_folderVi%\auto\_KTraPPK.txt
del /q %_cd%\user\trackedAvatar\%_folderVi%\auto\_KTraPPK.txt
if [%_KTraPPK%] == [] (echo Lỗi 2: Nhập sai mật khẩu, thử lại... & color 4F & timeout 10 & goto :tryagainWithPass) else (goto :YesPPK)
:YesPPK
cd %_cd%
echo.└── Nhập Public Key của ví %_vi:~0,7%*** thành công
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
rem Gửi mật khẩu vào file _PASSWORD.txt
cd %_cd%
echo %PASSWORD%> %_cd%\user\trackedAvatar\%_folderVi%\auto\password\_PASSWORD.txt 2>nul
set /a _passwordOK=1
goto :settingAuto
:premium
cd %_cd%\batch\avatarAddress
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\premium"
if not exist %_folder% (md %_cd%\user\trackedAvatar\%_folderVi%\premium)
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
	echo.Nhập 'donater' nếu bạn là nhà tẩm hao :v
	set /p _premiumTX="Code premium: "
	echo %_premiumTX%> %_cd%\user\trackedAvatar\%_folderVi%\premium\_premiumTX.txt 2>nul
	goto :premium2
	)
set /p _premiumTX=<%_cd%\user\trackedAvatar\%_folderVi%\premium\_premiumTX.txt
set _premiumTX=%_premiumTX: =%
set _senderBuy=^|curl https://api.9cscan.com/transactions/%_premiumTX% --ssl-no-revoke 2>nul|jq -r ".updatedAddresses|.[0]"> %_cd%\user\trackedAvatar\%_folderVi%\premium\_senderBuy.txt 2>nul & set /p _senderBuy=<%_cd%\user\trackedAvatar\%_folderVi%\premium\_senderBuy.txt & del /q %_cd%\user\trackedAvatar\%_folderVi%\premium\_senderBuy.txt
call :background
rem tạo block hiện giá
echo.╔═══════════════════════════════╗
echo.║Price premium: [40;33m%_pricePremium2% NCG[40;96m/30days	║
echo.╚═══════════════════════════════╝
echo.
if "%_premiumTX%" == "donater" (echo.Phát hiện code premium là 'donater'?) else (echo.Phát hiện code premium cũ của ví %_senderBuy:~0,7%***)
if not %_HanSuDung% lss 1700 (echo.Code premium còn [40;92m%_HanSuDung%[40;96m blocks) else (echo.Code premium còn [40;91m%_HanSuDung%[40;96m blocks)
echo.[1] Sử dụng lại
echo.[2] Xóa dữ liệu code premium cũ
echo.[3] Copy và hiển thị code premium cũ
echo.[4] Quay lại
choice /c 1234 /n /m "Nhập số từ bàn phím: "
if %errorlevel% equ 1 (goto :premium2)
if %errorlevel% equ 2 (set /a _premiumTXOK=0 & set "_senderBuy=***********" & rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\premium & goto :premium)
if %errorlevel% equ 3 (echo Code premium đang lưu: %_premiumTX% & echo %_premiumTX%|clip & timeout 10 & goto :premium)
if %errorlevel% equ 4 (goto :settingAuto)
:premium2
echo.└── Đang kiểm tra code premium...
echo %_premiumTX%> %_cd%\user\trackedAvatar\%_folderVi%\premium\_premiumTX.txt 2>nul
if "%_premiumTX%" == "donater" (set /a _premiumTXOK=1 & goto :settingAuto)
cd %_cd%\batch\avatarAddress
set _pricePremium=^|curl https://api.9cscan.com/price --ssl-no-revoke 2>nul|jq ".[]?|select(.USD)?|.USD|(1/(.price))+2"> %_cd%\user\trackedAvatar\%_folderVi%\premium\_pricePremium.txt 2>nul & set /p _pricePremium=<%_cd%\user\trackedAvatar\%_folderVi%\premium\_pricePremium.txt & del /q %_cd%\user\trackedAvatar\%_folderVi%\premium\_pricePremium.txt
set /a _pricePremium=%_pricePremium% 2>nul
set _premiumTX=%_premiumTX: =%
set _typeBuy=^|curl https://api.9cscan.com/transactions/%_premiumTX% --ssl-no-revoke 2>nul|findstr transfer_asset|findstr NCG|findstr /i 0x6374fe5f54cded72ff334d09980270c61bc95186|findstr /i SUCCESS>nul
if %errorlevel%==1 (echo. & echo Lỗi 1: Code premium nhập chưa đúng, thử lại... & color 4F & timeout 5 & goto :premium)
cd %_cd%\batch\avatarAddress
set _senderBuy=^|curl https://api.9cscan.com/transactions/%_premiumTX% --ssl-no-revoke 2>nul|jq -r ".updatedAddresses|.[0]"> %_cd%\user\trackedAvatar\%_folderVi%\premium\_senderBuy.txt 2>nul & set /p _senderBuy=<%_cd%\user\trackedAvatar\%_folderVi%\premium\_senderBuy.txt & del /q %_cd%\user\trackedAvatar\%_folderVi%\premium\_senderBuy.txt
set _senderBuy=^|echo %_senderBuy%|findstr /i %_vi%>nul
if %errorlevel%==1 (echo. & echo Lỗi 2.1: Code premium của ví %_senderBuy%, thử lại... & color 4F & timeout 5 & goto :premium)
set _receiveBuy=^|curl https://api.9cscan.com/transactions/%_premiumTX% --ssl-no-revoke 2>nul|jq -r ".updatedAddresses|.[1]"> %_cd%\user\trackedAvatar\%_folderVi%\premium\_receiveBuy.txt 2>nul & set /p _receiveBuy=<%_cd%\user\trackedAvatar\%_folderVi%\premium\_receiveBuy.txt & del /q %_cd%\user\trackedAvatar\%_folderVi%\premium\_receiveBuy.txt
set _receiveBuy=^|echo %_receiveBuy%|findstr /i 0x6374fe5f54cded72ff334d09980270c61bc95186>nul
if %errorlevel%==1 (echo. & echo Lỗi 2.2: Code premium chưa gửi đúng tới ví của tôi, thử lại... & color 4F & timeout 5 & goto :premium)
set _statusBuy=^|curl https://api.9cscan.com/transactions/%_premiumTX% --ssl-no-revoke 2>nul|jq -r "[..]|.[6]"> %_cd%\user\trackedAvatar\%_folderVi%\premium\_statusBuy.txt 2>nul & set /p _statusBuy=<%_cd%\user\trackedAvatar\%_folderVi%\premium\_statusBuy.txt & del /q %_cd%\user\trackedAvatar\%_folderVi%\premium\_statusBuy.txt
set _statusBuy=^|echo %_statusBuy%|findstr /i SUCCESS>nul
if %errorlevel%==1 (echo. & echo Lỗi 2.3: Code premium chưa gửi thành công, thử lại... & color 4F & timeout 5 & goto :premium)
set _blockBuy=^|curl https://api.9cscan.com/transactions/%_premiumTX% --ssl-no-revoke 2>nul|jq -r "[..]|.[8]"> %_cd%\user\trackedAvatar\%_folderVi%\premium\_blockBuy.txt 2>nul & set /p _blockBuy=<%_cd%\user\trackedAvatar\%_folderVi%\premium\_blockBuy.txt & del /q %_cd%\user\trackedAvatar\%_folderVi%\premium\_blockBuy.txt
set /a _blockBuy+=216000 2>nul
if %_blockBuy% lss %_9cscanBlock% (echo. & echo Lỗi 2.4: Code premium đã hết hạn, thử lại... & color 4F & timeout 5 & goto :premium)
set /a _HanSuDung= %_blockBuy% - %_9cscanBlock% 2>nul
set _NCGbuy=^|curl https://api.9cscan.com/transactions/%_premiumTX% --ssl-no-revoke 2>nul|jq -r "[..]|.[14]"> %_cd%\user\trackedAvatar\%_folderVi%\premium\_NCGbuy.json 2>nul
cd %_cd%\user\trackedAvatar\%_folderVi%\premium
set /a _NCGbuyi=1
for /f "tokens=*" %%a in (_NCGbuy.json) do call :_NCGbuyi %%a
set /a _NCGbuyi=1
for /f "tokens=*" %%a in (_NCGbuy.json) do call :_NCGbuyi %%a
findstr /i NCG %_cd%\user\trackedAvatar\%_folderVi%\premium\_NCGticker.txt>nul
if %errorlevel%==1 (del /q %_cd%\user\trackedAvatar\%_folderVi%\premium\_NCGticker.txt & del /q %_cd%\user\trackedAvatar\%_folderVi%\premium\_NCGticker.txt & echo. & echo Lỗi 2.5: Code premium không phải là gửi NCG, thử lại... & color 4F & timeout 5 & goto :premium)
if %_NCGbuy% lss %_pricePremium% (color 4F & echo. & echo Lỗi 2.6: Code premium gửi NCG nhỏ hơn [41;33m%_pricePremium% NCG[41;97m, & echo.thử lại... & timeout 5 & goto :displayVi)
del /q %_cd%\user\trackedAvatar\%_folderVi%\premium\_NCGbuy.json
set /a _premiumTXOK=1
goto :displayVi
:_NCGbuyi
if %_NCGbuyi%==8 echo %*> _NCGticker.txt 2>nul
if %_NCGbuyi%==10 echo %*> _NCGbuy.txt 2>nul & set /p _NCGbuy=<_NCGbuy.txt & set /a _NCGbuy=%_NCGbuy:~0,-2% & del /q _NCGbuy.txt
set /a _NCGbuyi+=1
exit /b
:ReadJsonbat
"%_cd%\batch\jq" -r "..|.%1?|select(.)" %_cd%\user\trackedAvatar\%_folderVi%\auto\output.json> %_cd%\user\trackedAvatar\%_folderVi%\auto\ReadJsonbat.json 2>nul
del /q %_cd%\user\trackedAvatar\%_folderVi%\auto\output.json
exit /b
:autoRefillAP
rem Tự động refill AP
set _folder="%_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%\autoRefillAP"
if exist %_folder% (rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%\autoRefillAP)
md %_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%\autoRefillAP
cd %_cd%\user\trackedAvatar\%_folderVi%\char%_charDisplay%\autoRefillAP
copy "%_cd%\batch\jq.exe" "jq.exe"> nul
echo off
echo ==========
echo Bước 1: Nhận unsignedTransaction
echo {"vi":"%_vi%","publicKey":"%_publickey%","char":"%_address%","stt":%_charDisplay%,"premiumTX":"%_premiumTX%"}> input.json 2>nul
curl -X POST -H "accept: application/json" -H "Content-Type: application/json" --data "@input.json" https://api.tanvpn.tk/refillAP --ssl-no-revoke --location> output.json 2>nul
findstr /i kqua output.json> nul
if %errorlevel% equ 1 (echo.└── Lỗi 0: Không xác định, tắt auto... & set /a _canAutoOnOff=0 & color 4F & timeout 5 & goto :displayVi)
jq -r ".checkqua" output.json> _checkqua.txt 2>nul & set /p _checkqua=<_checkqua.txt
jq -r ".kqua" output.json> _kqua.txt 2>nul & set /p _kqua=<_kqua.txt
if %_checkqua% == 0 (echo.└── %_kqua%, tắt auto... & set /a _canAutoOnOff=0 & color 4F & timeout 10 & goto :displayVi)
echo.└── Nhập unsignedTransaction thành công
echo ==========
echo Bước 2: Nhận signTransaction
rem Tạo file action
call certutil -decodehex _kqua.txt action >nul
:tryagainNoPassST
rem Lấy lại _IDKeyCuaA
echo.└── Sử dụng mật khẩu đã lưu từ thư mục PASSWORD
set /p _KeyID=<%_cd%\user\trackedAvatar\%_folderVi%\auto\KeyID\_KeyID.txt
set _KeyID=%_KeyID: =%
set /p _password=<%_cd%\user\trackedAvatar\%_folderVi%\auto\password\_password.txt
"%_cd%\planet\planet" key sign --passphrase %_PASSWORD% --store-path %_cd%\user\utc %_KeyID% action> _signature.txt 2>nul
set "_PASSWORD="
goto :KTraSignature1
:KTraSignature1
set "_signature="
set /p _signature=<_signature.txt
if [%_signature%] == [] (echo.└──── Lỗi 1: Mật khẩu đang lưu chưa đúng, tắt auto... & set /a _canAutoOnOff=0 & color 4F & set /a _passwordOK=0 & rd /s /q %_cd%\user\trackedAvatar\%_folderVi%\auto\password & timeout 10 & goto :displayVi)
echo.└──── Nhập Signature thành công
echo.
echo ==========
echo Bước 3: Nhận payload
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
echo.└── Tìm signTransaction...
jq -r "..|.signTransaction?|select(.)" output.json> _signTransaction.txt 2>nul
echo ==========
echo Bước 4: Nhận stageTransaction
echo.
set /p _signTransaction=<_signTransaction.txt
call %_cd%\batch\TaoInputJson.bat _signTransaction %_signTransaction% %_cd%\batch\_codeStep4.txt> input.json 2>nul
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json  2>nul
echo.└── Tìm stageTransaction...
jq -r "..|.stageTransaction?|select(.)" output.json> _stageTransaction.txt 2>nul
:ktraAutoRefillAP
color 0B
cls
echo.╔═══════════════╗   ╔═══════════════╗   ╔═══════════════╗
if %_canAuto%==6 echo ║Ví %_vi:~0,7%***	║   ║Block: %_9cscanBlock% ║   ║[40;92mCan Auto? [X]	[40;96m║
if not %_canAuto%==6 echo ║Ví %_vi:~0,7%***	║   ║Block: %_9cscanBlock% ║   ║[40;97mCan Auto? [ ]	[40;96m║
echo.╚═══════════════╝   ╚═══════════════╝   ╚═══════════════╝
echo ==========
echo Bước 5: Kiểm tra auto Refill AP
set /p _stageTransaction=<_stageTransaction.txt
call %_cd%\batch\TaoInputJson.bat _stageTransaction %_stageTransaction% %_cd%\batch\_codeStep5.txt> input.json 2>nul
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql> output.json 2>nul
echo.└── Tìm txStatus...
jq -r "..|.txStatus?|select(.)" output.json> _txStatus.txt 2>nul
set /p _txStatus=<_txStatus.txt
if %_txStatus% == STAGING (color 0B & echo.─── Status: Auto refill đang diễn ra, kiểm tra lại sau 15s... & timeout /t 15 /nobreak>nul & goto :ktraAutoRefillAP)
if %_txStatus% == FAILURE (color 4F & echo.─── Status: Auto refill thành công nhưng nhân vật chưa đến & echo.─── thời điểm refill AP, đợi 3p sau auto Refill AP lại,... & timeout /t 300 /nobreak & goto :duLieuViCu)
if %_txStatus% == INVALID (color 8F & echo.─── Status: Auto refill thất bại, tắt auto... & set /a _canAutoOnOff=0 & timeout 10 & goto :duLieuViCu)
if %_txStatus% == SUCCESS (color 2F & echo.─── Status: Auto refill thành công, quay lại menu... & timeout 10 & echo.└──── Đang làm mới dữ liệu nhân vật... & goto :duLieuViCu)
color 4F & echo.─── Lỗi 2: Lỗi không xác định, tắt auto... & set /a _canAutoOnOff=0 & timeout 10 & goto :duLieuViCu
goto :duLieuViCu
