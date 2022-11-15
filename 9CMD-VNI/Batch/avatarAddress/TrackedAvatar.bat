rem Cài %_cd% gốc
set /p _cd=<_cd.txt
cd %_cd%
rem Đặt title cửa sổ windows
title Theo dõi Avatar
rem Sử dụng dữ liệu trước đó hay tạo mới
call :background
call %_cd%\batch\miniChonNode.bat
call :background
set /a _ktra=0
echo [1]Tạo mới
echo [2]Sử dụng dữ liệu cũ
echo [3]Quay lại Menu
echo ==========
echo.
choice /c 123 /n /m "[1] Tạo mới, [2]Lịch sử hoặc [3]Main Menu: "
if %errorlevel% equ 1 (echo ""> %_cd%\user\avatarAddress\oldData.txt & goto :nhapvi)
if %errorlevel% equ 2 (goto :KtraLichSu)
if %errorlevel% equ 3 (call %_cd%\batch\Menu.bat && exit /b)
:KtraLichSu
rem Ktra đã có file oldData.txt trước đó chưa
setlocal
Set _file="%_cd%\user\avatarAddress\oldData.txt"
if not exist %_file% (echo ""> %_cd%\user\avatarAddress\oldData.txt)
goto :LichSu
endlocal
:nhapvi
call :background
rem Nhận biến
set /p _node=<%_cd%\data\_node.txt
rem Xóa khoảng trắng
set _node=%_node: =%
echo ==========
echo Nhập ví
echo.
rem Hiển thị ví đang có file UTC
cd %_cd%\planet
planet key --path %_cd%\user\utc> _allKey.txt
more _allKey.txt
copy _allKey.txt %_cd%\user\avatarAddress\utc.txt>nul
del _allKey.txt
echo.==========
echo.
echo.Gõ "allUTC" để nhập nhanh toàn bộ ví trong thư mục UTC
echo.Gõ "waybackhome" để quay lại
set /p _vi="Nhập ví: "
if "%_vi%" == "allUTC" (call %_cd%\batch\avatarAddress\UTCtoAddress.bat & set "_vi=" & goto :LichSu)
if "%_vi%" == "waybackhome" (set "_vi=" & goto :KtraLichSu)
goto :KtraVi
:KtraVi
cd %_cd%\batch
rem Kiểm tra số dư
echo {"query":"query{stateQuery{agent(address:\"%_vi%\"){crystal}}goldBalance(address: \"%_vi%\" )}"} > input.json
rem Gửi code đến http://9c-main-rpc-%_node%.nine-chronicles.com/graphql
curl --header "Content-Type: application/json" --data "@input.json" --show-error http://9c-main-rpc-%_node%.nine-chronicles.com/graphql > output.json
rem Lọc kết quả lấy dữ liệu
jq "..|.crystal?|select(.)|tonumber" output.json > %_cd%/user/avatarAddress/_crystal.txt
jq "..|.goldBalance?|select(.)|tonumber" output.json > %_cd%/user/avatarAddress/_ncg.txt
rem Xóa file nháp input và output
cd %_cd%\batch
del *.json
cd %_cd%
rem Kiểm tra
call :background 
echo ==========
echo Kiểm tra ví
set /p _ncg=<%_cd%/user/avatarAddress/_ncg.txt
set /p _crystal=<%_cd%/user/avatarAddress/_crystal.txt
del /q %_cd%\user\avatarAddress\_ncg.txt
del /q %_cd%\user\avatarAddress\_crystal.txt
cd %_cd%\batch
if not [%_ncg%] == [] (echo %_vi% >> %_cd%\user\avatarAddress\oldData.txt & goto :LichSu) else (echo Lỗi 1: Ví A chưa đúng cú pháp 'phân biệt cả chữ hoa chữ thường', thử lại... && color 4F && timeout 10 && goto :nhapvi)
:LichSu
echo ___> %_cd%\user\avatarAddress\_temp.json
echo.[*] Đang xử lý...
cd %_cd%\user\avatarAddress
set _i=0
for /f "tokens=*" %%a in (oldData.txt) do (call :processline %%a)
rem Hiển thị nhiều hơn
if %_i% gtr 15 (mode con:cols=100 lines=40 & cls & type %_cd%\Data\avatarAddress\_TitleTrackedAvatar.txt)
call :background
echo.==========
echo.Ví đã nhập trước đây: 
more %_cd%\user\avatarAddress\_temp.json
echo.==========
echo.[1] Reset bộ nhớ
echo.[2] Nhập thêm ví
echo.[3] Chạy
choice /c 123 /n /m "Nhập từ bàn phím: "
if %errorlevel%==1 (echo ""> %_cd%\user\avatarAddress\oldData.txt & echo ___> %_cd%\user\avatarAddress\_temp.json & goto :LichSu)
if %errorlevel%==2 (call :background & echo ___> %_cd%\user\avatarAddress\_temp.json & goto :nhapvi)
if %errorlevel%==3 (goto :KtraChay)
:KtraChay
if %_i%==1 (echo Lỗi 1: Chưa có ví, thử lại... && color 4F && timeout 3 & goto :nhapvi) else (call %_cd%\batch\avatarAddress\AddressToJson.bat & copy %_cd%\user\avatarAddress\oldData.json %_cd%\batch\avatarAddress\oldData.json & goto :TheoDoiAvatar)
goto :eof
:processline
if %_i%==0 (echo. & set /a _i+=1) else (echo Ví %_i%	:	%*>> %_cd%\user\avatarAddress\_temp.json & set /a _i+=1)
goto :eof
:eof
:TheoDoiAvatar
set /a _j=1
call :background
echo.[*] Đang xử lý...
del /q %_cd%\batch\avatarAddress\_temp.json
:hienThongTin
cd %_cd%\batch\avatarAddress
jq -r ".[%_j%]|.vi?|select(.)" oldData.json> _vi.json
set /p _vi=<_vi.json
jq -r ".[%_j%]|.ncg?|select(.)" oldData.json> _ncg.json
set /p _ncg=<_ncg.json
rem Xóa phần thập phân
set /a _ncg=%_ncg%
set _ncg=               %_ncg%
jq -r ".[%_j%]|.crystal?|select(.)" oldData.json> _crystal.json
set /p _crystal=<_crystal.json
rem Xóa phần thập phân
set /a _crystal=%_crystal%
set _crystal=               %_crystal%
echo.[%_j%]Ví		 : %_vi:~0,7%***		%_ncg:~-15%		%_crystal:~-15%>> _temp.json
set /a _j+=1
if not %_i%==%_j% (goto :hienThongTin)
cd %_cd%\batch\avatarAddress
del /q _vi.json & del /q _ncg.json & del /q _crystal.json
:done
call :background
if %_i% gtr 15 (mode con:cols=100 lines=40 & cls & type %_cd%\Data\avatarAddress\_TitleTrackedAvatar.txt)
echo.[*]Sử dụng node	: %_node%			           NCG                 CRYSTAL
cd %_cd%\batch\avatarAddress
more _temp.json
echo.==========
set /a _j+=-1
echo.[1..%_j%] Tracked Avatar +
echo.[100] Gửi NCG/Crystal
echo.[200] Quay lại Menu
set /a _j=%_i%
echo.
set /p _pick="Nhập [0] để làm mới dữ liệu, hoặc nhập [số]: "
rem Kiểm tra _pick có là số hay không
cd %_cd%
if [%_pick%] == [] (echo Lỗi 1: Chưa nhập gì, thử lại... && color 4F && timeout 3 && goto :done)
set "var="&for /f "delims=0123456789" %%i in ("%_pick%") do set var=%%i
if defined var (echo Lỗi 2: Sai cú pháp, thử lại... && color 4F && timeout 3 & set "_pick=" & goto :done)
if "%_pick%"=="0" (del /q %_cd%\batch\avatarAddress\_temp.json & call %_cd%\batch\avatarAddress\AddressToJson.bat & copy %_cd%\user\avatarAddress\oldData.json %_cd%\batch\avatarAddress\oldData.json & set "_pick=" & goto :TheoDoiAvatar)
if %_pick%==100 (del /q %_cd%\batch\avatarAddress\_temp.json & set "_pick=" & call %_cd%\batch\SendCurrency.bat)
if %_pick%==200 (del /q %_cd%\batch\avatarAddress\_temp.json & set "_pick=" & call %_cd%\batch\Menu.bat)
if %_pick% geq %_j% (echo Lỗi 3: Giá trị vượt quá [%_j%], thử lại... && color 4F && timeout 10 & set "_pick=" & goto :done)
if %_pick% lss %_j% (start %_cd%\batch\avatarAddress\tracker.bat %_pick% & set "_pick=")
goto :done
:Background
cls
cd %_cd%
call %_cd%\Batch\avatarAddress\TitleTrackedAvatar.bat
exit /b
