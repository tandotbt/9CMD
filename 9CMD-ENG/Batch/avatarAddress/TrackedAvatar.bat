rem Install %_cd% origin
set /p _cd=<_cd.txt
cd %_cd%
rem Set title windows
title Tracked Avatar
rem Use previous data or create new
call :background
call %_cd%\batch\miniChonNode.bat
call :background
set /a _ktra=0
echo [1]Create new
echo [2]Use old data
echo [3]Back to the menu
echo ==========
echo.
choice /c 123 /n /m "[1] Create new, [2]Old data or [3]Main Menu: "
if %errorlevel% equ 1 (echo ""> %_cd%\user\avatarAddress\oldData.txt & goto :nhapvi)
if %errorlevel% equ 2 (goto :KtraLichSu)
if %errorlevel% equ 3 (call %_cd%\batch\Menu.bat && exit /b)
:KtraLichSu
rem Check exist file oldData.txt before that yet
setlocal
Set _file="%_cd%\user\avatarAddress\oldData.txt"
if not exist %_file% (echo ""> %_cd%\user\avatarAddress\oldData.txt)
goto :LichSu
endlocal
:nhapvi
call :background
rem Receive variable
set /p _node=<%_cd%\data\_node.txt
rem Delete spaces
set _node=%_node: =%
echo ==========
echo Enter wallet
echo.
rem Showing wallet file UTC
cd %_cd%\planet
planet key --path %_cd%\user\utc> _allKey.txt
type _allKey.txt
copy _allKey.txt %_cd%\user\avatarAddress\utc.txt>nul
del _allKey.txt
echo.==========
echo.
echo.Type "allUTC" to quickly enter the entire wallet in the UTC folder
echo.Type "open" to open with Notepad
echo.Type "waybackhome" to come back
set /p _vi="Enter wallet: "
set _vi=%_vi: =%
if "%_vi%" == "open" (start %_cd%\user\avatarAddress\utc.txt & goto :nhapvi)
if "%_vi%" == "allUTC" (call %_cd%\batch\avatarAddress\UTCtoAddress.bat & set "_vi=" & goto :LichSu)
if "%_vi%" == "waybackhome" (set "_vi=" & goto :KtraLichSu)
goto :KtraVi
:KtraVi
cd %_cd%\batch
echo ==========
echo Check the wallet
rem Check the balance
echo {"query":"query{stateQuery{agent(address:\"%_vi%\"){crystal}}goldBalance(address: \"%_vi%\" )}"} > input.json
rem Send code to http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql > output.json
rem Filter the results of data
jq "..|.crystal?|select(.)|tonumber" output.json > %_cd%/user/avatarAddress/_crystal.txt
jq "..|.goldBalance?|select(.)|tonumber" output.json > %_cd%/user/avatarAddress/_ncg.txt
rem Delete the draft file input and output
cd %_cd%\batch
del *.json
cd %_cd%
rem Check 
call :background 
echo ==========
echo Check the wallet
set "_ncg= "
set _ncg=%_ncg: =%
set /p _ncg=<%_cd%/user/avatarAddress/_ncg.txt
set /p _crystal=<%_cd%/user/avatarAddress/_crystal.txt
del /q %_cd%\user\avatarAddress\_ncg.txt
del /q %_cd%\user\avatarAddress\_crystal.txt
cd %_cd%\batch
if not [%_ncg%] == [] (echo %_vi% >> %_cd%\user\avatarAddress\oldData.txt & goto :LichSu) else (echo Error 1: Wallet A wrong syntax, 'distinguishing both text upcase, lowcase', try again... && color 4F && timeout 10 && goto :nhapvi)
:LichSu
echo ___> %_cd%\user\avatarAddress\_temp.json
echo.[*] Processing...
cd %_cd%\user\avatarAddress
set _i=0
for /f "tokens=*" %%a in (oldData.txt) do (call :processline %%a)
rem Show more
if %_i% gtr 15 (mode con:cols=100 lines=40 & cls & type %_cd%\Data\avatarAddress\_TitleTrackedAvatar.txt)
call :background
echo.==========
echo.The wallet has been imported before: 
type %_cd%\user\avatarAddress\_temp.json
echo.==========
echo.[1] Reset old data
echo.[2] Enter more wallet
echo.[3] Run
echo.[4] See details
set _file="%_cd%\user\avatarAddress\oldData.json"
if exist %_file% (echo.[9] Skip to Tracked Avatar +)
choice /c 12349 /n /m "Enter from the keyboard: "
if %errorlevel%==1 (echo ""> %_cd%\user\avatarAddress\oldData.txt & echo ___> %_cd%\user\avatarAddress\_temp.json & goto :LichSu)
if %errorlevel%==2 (call :background & echo ___> %_cd%\user\avatarAddress\_temp.json & goto :nhapvi)
if %errorlevel%==3 (goto :KtraChay)
if %errorlevel%==4 (more %_cd%\user\avatarAddress\_temp.json & goto :LichSu)
if %errorlevel%==9 (copy %_cd%\user\avatarAddress\oldData.json %_cd%\batch\avatarAddress\oldData.json)
goto :TheoDoiAvatar
:KtraChay
if %_i%==1 (echo Error 1: No wallet, retry... && color 4F && timeout 3 & goto :nhapvi) else (call %_cd%\batch\avatarAddress\AddressToJson.bat & copy %_cd%\user\avatarAddress\oldData.json %_cd%\batch\avatarAddress\oldData.json & goto :TheoDoiAvatar)
goto :eof
:processline
if %_i%==0 (echo. & set /a _i+=1) else (echo Wallet %_i%	:	%*>> %_cd%\user\avatarAddress\_temp.json & set /a _i+=1)
goto :eof
:eof
:TheoDoiAvatar
set /a _j=1
call :background
echo.[*] Processing...
del /q %_cd%\batch\avatarAddress\_temp.json
set /a _sumNCG=0 & set /a _sumCRYSTAL=0
:hienThongTin
cd %_cd%\batch\avatarAddress
jq -r ".[%_j%]|.vi?|select(.)" oldData.json > _vi.json
set /p _vi=<_vi.json
jq -r ".[%_j%]|.ncg?|select(.)" oldData.json > _ncg.json
set /p _ncg=<_ncg.json
rem Delete decimal
set /a _ncg=%_ncg%
set /a _sumNCG+=%_ncg%
set _ncg=               %_ncg%
jq -r ".[%_j%]|.crystal?|select(.)" oldData.json > _crystal.json
set /p _crystal=<_crystal.json
rem Delete decimal
set /a _crystal=%_crystal%
set /a _sumCRYSTAL+=%_crystal%
set _crystal=               %_crystal%
echo.[%_j%]Ví		: %_vi%%_ncg:~-15%	%_crystal:~-15% >> _temp.json
set /a _j+=1
if not %_i%==%_j% (goto :hienThongTin)
cd %_cd%\batch\avatarAddress
del /q _vi.json & del /q _ncg.json & del /q _crystal.json
:done
call :background
if %_i% gtr 15 (mode con:cols=100 & cls & type %_cd%\Data\avatarAddress\_TitleTrackedAvatar.txt)
set _temp1=  %_node%
echo.[*]Use node	:%_temp1:~-2%                                                     NCG             CRYSTAL
cd %_cd%\batch\avatarAddress
type _temp.json
echo.==========
set _sumNCG=                                                      %_sumNCG%
set _sumCRYSTAL=                    %_sumCRYSTAL%
echo [*]Total	:%_sumNCG:~-58%%_sumCRYSTAL:~-20%
echo.==========
set /a _j+=-1
echo.[1..%_j%] Tracked Avatar plus
echo.[100] Send NCG/Crystal
echo.[200] See detailed list
echo.[300] Quickly open all the wallets
echo.[400] Back to the menu
set /a _j=%_i%
echo.
set /p _pick="Enter [0] to refresh data, or enter [number]: "
rem Check _pick is number or not
cd %_cd%
if [%_pick%] == [] (echo Error 1: Have not entered anything, retry... && color 4F && timeout 3 && goto :done)
set "var="&for /f "delims=0123456789" %%i in ("%_pick%") do set var=%%i
if defined var (echo Error 2: Wrong syntax, retry... && color 4F && timeout 3 & set "_pick=" & goto :done)
if "%_pick%"=="0" (call %_cd%\batch\avatarAddress\AddressToJson.bat & copy %_cd%\user\avatarAddress\oldData.json %_cd%\batch\avatarAddress\oldData.json & set "_pick=" & goto :TheoDoiAvatar)
if %_pick%==100 (del /q %_cd%\batch\avatarAddress\_temp.json & set "_pick=" & start %_cd%\batch\SendCurrency.bat & goto :done)
if %_pick%==200 (more %_cd%\batch\avatarAddress\_temp.json & set "_pick=" & goto :done)
if %_pick%==300 (set "_pick=" & goto :openFull)
if %_pick%==400 (del /q %_cd%\batch\avatarAddress\_temp.json & set "_pick=" & call %_cd%\batch\Menu.bat)
if %_pick% geq %_j% (echo Error 3: The value exceeds [%_j%], retry... && color 4F && timeout 10 & set "_pick=" & goto :done)
if %_pick% lss %_j% (start %_cd%\batch\avatarAddress\tracker.bat %_pick% & set "_pick=")
goto :done
:Background
cls
cd %_cd%
call %_cd%\Batch\avatarAddress\TitleTrackedAvatar.bat
exit /b
:openFull
set _countVi=0
:openFull1
set /a _countVi+=1
if %_countVi% geq %_j% (goto :done)
echo _____ Open the wallet %_countVi%
start %_cd%\batch\avatarAddress\tracker.bat %_countVi%
timeout 1 >nul
goto :openFull1