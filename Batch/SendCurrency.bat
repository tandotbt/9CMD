rem Cài %_cd% gốc
set /p _cd=<_cd.txt
cd %_cd%
rem Đặt title cửa sổ windows
title Gửi NCG/Crystal
rem Reset giá trị
set /a _hienInputPass=1
set /a _ktra=0
rem Sử dụng dữ liệu trước đó hay tạo mới
call :background
echo [1]Tạo mới, 1 quá trình tịnh tiến
echo [2]Sử dụng dữ liệu trước đó, có thể tùy chỉnh riêng từng chỉ số
echo [3]Quay lại Menu
echo ==========
echo.
choice /c 123 /n /m "[1]Newgame, [2]Continue hoặc [3]Main Menu: "
if %errorlevel% equ 1 (goto :ChonNode)
if %errorlevel% equ 2 (goto :miniSendCurrency)
if %errorlevel% equ 3 (call %_cd%\batch\Menu.bat && exit /b)
rem Chọn node sử dụng
:ChonNode
call :background
rem Reset giá trị _node.txt
set _node=<%_cd%\data\_null.txt
set /p _node="Sử dụng node số (Nên chọn từ 1-10): "
echo %_node% > %_cd%\data\_node.txt
goto :KTraNode1
rem Nhập ví (A)
:NhapViA
call :background
rem Nhập ví (A)
echo.[1]Sử dụng node      : %_node%
set /p _viA="Ví người gửi (A): "
echo %_viA% > %_cd%\user\_viA.txt
rem Kiểm tra số dư ví (A)
call %_cd%\batch\KTraSoDuCuaA.bat
rem Ghi giá trị của A
set /p _crystalCuaA=<%_cd%\data\_crystal.txt
set /p _ncgCuaA=<%_cd%\data\_ncg.txt
rem Xóa số sau dấu .
set /a "_ncgCuaA=%_ncgCuaA%"
set /a "_crystalCuaA=%_crystalCuaA%"
goto :KTraViA
:NhapViB
rem Nhập đầu vào B
call :background
echo.[1]Sử dụng node        : %_node%			NCG		CRYSTAL
echo.[2]Ví người gửi (A)    : %_viA:~0,7%***		%_ncgCuaA%		%_crystalCuaA%
echo ==========
set /p _viB="Ví người nhận (B): "
echo %_viB% > %_cd%\user\_viB.txt
call %_cd%\batch\KTraSoDuCuaB.bat
rem Ghi giá trị của B
set /p _crystalCuaB=<%_cd%\data\_crystalB.txt
set /p _ncgCuaB=<%_cd%\data\_ncgB.txt
goto :KTraViB
:KTraViOK
rem In ra màn hình thông tin
call :background
echo.[1]Sử dụng node        : %_node%			NCG		CRYSTAL
echo.[2]Ví người gửi (A)    : %_viA:~0,7%***		%_ncgCuaA%		%_crystalCuaA%
echo.[3]Ví người nhận (B)   : %_viB:~0,7%***		%_ncgCuaB%		%_crystalCuaB%
if "%_hienInputPass%"=="1" (goto :inputpassword) else (goto :KTraNode1)
:inputpassword
set /a _hienInputPass=0
echo ==========
choice /c 12 /n /m "Nhập mật khẩu ví (A): [1]Ok [2]Bỏ qua"
if %errorlevel% equ 2 (echo 0 > %_cd%\PASSWORD\_YorN.txt && goto :ChonLoaiTienTe)
if %errorlevel% equ 1 (call %_cd%\batch\PASSWORD.bat && goto :ChonLoaiTienTe)
rem Chọn loại tiền tệ và số lượng
:ChonLoaiTienTe
call :background
echo.[1]Sử dụng node        : %_node%			NCG		CRYSTAL
echo.[2]Ví người gửi (A)    : %_viA:~0,7%***		%_ncgCuaA%		%_crystalCuaA%
echo.[3]Ví người nhận (B)   : %_viB:~0,7%***		%_ncgCuaB%		%_crystalCuaB%
echo ==========
rem Chọn loại tiền tệ
choice /c 12 /n /m "Gửi [1]NCG hoặc [2]Crystal: "
if %errorlevel% equ 1 (set _currency=NCG)
if %errorlevel% equ 2 (set _currency=CRYSTAL)
echo %_currency% > %_cd%\data\_currency.txt
rem Số lượng muốn gửi
set /p _soLuong="Số lượng: "
echo %_soLuong% > %_cd%\data\_soLuong.txt
rem Kiểm tra giá trị số lượng
goto :KTraSoLuong
rem Bắt đầu gửi
:SoLuongOK
call :background
echo.[1]Sử dụng node        : %_node%			NCG		CRYSTAL
echo.[2]Ví người gửi (A)    : %_viA:~0,7%***		%_ncgCuaA%		%_crystalCuaA%
echo.[3]Ví người nhận (B)   : %_viB:~0,7%***		%_ncgCuaB%		%_crystalCuaB%
echo.[4]Gửi                 : %_soLuong% %_currency%
echo ==========
choice /c 12 /n /m "Nhập Public key ví (A):[1]9cscan [2]Planet"
if %errorlevel% equ 1 (goto :9cscanPublickey)
if %errorlevel% equ 2 (goto :PlanetPublickey)
rem Nhập PK
:9cscanPublicKey
call :Background
echo ==========
echo Nhập Public Key của (A) bằng 9cscan
echo.
start https://9cscan.com/address/%_viA%
echo Đang mở 9cscan... bằng trình duyệt mặc định
echo Chọn 1 giao dịch mà ví (A) [SIGNED] KHÔNG PHẢI [INVOLVED]
echo Tìm đến mục Public key và copy
echo Lưu ý: Cách này cần chính xác, vì không tự động kiểm tra lại được Public Key!
echo Tùy chọn: nhập "waybackhome" để quay lại
set /p _PublicKeyCuaA="Dán Public key của A tại đây: "
if %_PublicKeyCuaA% == waybackhome goto :SoLuongOK
echo %_PublicKeyCuaA% > %_cd%\user\_PublicKeyCuaA.txt
echo ==========
echo Lấy Public Key của ví (A) thành công
echo.
rem Đặt biến _IDKeyCuaA về 0 để lệnh lấy signaturePlanet quay lại kiểm tra
set _IDKeyCuaA=0
echo %_IDKeyCuaA% > %_cd%\user\_IDKeyCuaA.txt
timeout 3
goto :miniSendCurrency
:PlanetPublickey
call :background
echo ==========
echo Nhập Public Key của (A) bằng Planet
echo.
call %_cd%\batch\LayIDKeyCuaA.bat
echo ==========
echo Lấy Key ID của ví (A) thành công
echo.
call :background
rem Nhận biến
set /p _YorN=<%_cd%\PASSWORD\_YorN.txt
set /p _IDKeyCuaA=<%_cd%\user\_IDKeyCuaA.txt
rem Xóa khoảng trắng
set _YorN=%_YorN: =%
set _IDKeyCuaA=%_IDKeyCuaA: =%
rem Lấy Publick key bằng Planet
call %_cd%\batch\LayPublicKeyPlanet.bat
set "_password="
rem Quay lại 9cscanPublickey
set /p _password=<%_cd%\PASSWORD\_PASSWORD.txt
if %_password% == waybackhome goto :SoLuongOK
rem Xóa file _KTraPPK.txt trong Planet
del /q %_cd%\planet\_KTraPPK.txt
rem Nhận Public Key
echo ==========
echo Lấy Public Key của ví (A) thành công
echo.
timeout 3
goto :miniSendCurrency
:miniSendCurrency
rem Nhận dữ liệu
set /p _node=<%_cd%\data\_node.txt
set /p _viA=<%_cd%\user\_viA.txt
set /p _viB=<%_cd%\user\_viB.txt
set /p _ncgCuaA=<%_cd%\data\_ncg.txt
set /p _ncgCuaB=<%_cd%\data\_ncgB.txt
set /p _crystalCuaA=<%_cd%\data\_crystal.txt
set /p _crystalCuaB=<%_cd%\data\_crystalB.txt
set /p _soLuong=<%_cd%\data\_soLuong.txt
set /p _currency=<%_cd%\data\_currency.txt
set /p _memo=<%_cd%\data\_memo.txt
set /p _PublicKeyCuaA=<%_cd%\user\_PublicKeyCuaA.txt
set /p _YorN=<%_cd%\PASSWORD\_YorN.txt
rem Xóa khoảng trắng
set _node=%_node: =%
set _viA=%_viA: =%
set _viB=%_viB: =%
set _ncgCuaA=%_ncgCuaA: =%
set _ncgCuaB=%_ncgCuaB: =%
set _crystalCuaA=%_crystalCuaA: =%
set _crystalCuaB=%_crystalCuaB: =%
set _soLuong=%_soLuong: =%
set _currency=%_currency: =%
set _memo=%_memo: =%
set _PublicKeyCuaA=%_PublicKeyCuaA: =%
set _YorN=%_YorN: =%
rem Làm tròn số NCG và Crystal
set /a "_ncgCuaA=%_ncgCuaA%"
set /a "_ncgCuaB=%_ncgCuaB%"
set /a "_crystalCuaA=%_crystalCuaA%"
set /a "_crystalCuaB=%_crystalCuaB%"
rem Làm màu cho đẹp :v
call :background
if %_currency% == NCG (color 06 &&  goto :Makecolor)
if %_currency% == CRYSTAL (color 0D && goto :Makecolor)
:Makecolor
echo ==========
echo.[1]Sử dụng node        : %_node%			NCG		CRYSTAL
echo.[2]Ví người gửi (A)    : %_viA:~0,7%***		%_ncgCuaA%		%_crystalCuaA%
echo.[3]Ví người nhận (B)   : %_viB:~0,7%***		%_ncgCuaB%		%_crystalCuaB%
echo.[4]Gửi                 : %_soLuong% %_currency%
echo.[5]Public Key của (A)  : %_PublicKeyCuaA:~0,10%***
echo.[6]Lời nhắn đi kèm     : %_memo%_9CMD_TooL
if "%_YorN%"=="1" echo.[7]Lưu PASSWORD ví (A) : [X]
if "%_YorN%"=="0" echo.[7]Lưu PASSWORD ví (A) : [ ]
echo ==========
rem Reset _chinhSua
set /p _chinhSua=<%_cd%\data\_null.txt
set /p _chinhSua="Nhập [0] để gửi ngay, hoặc nhập [số] để cập nhật: "
rem Định dạng lại _chinhSua về 1 số
set _chinhSua=%_chinhSua: =%
set _chinhSua=%_chinhSua:~-1%
rem Kiểm tra _chinhSua có là số hay không
cd %_cd%
set "var="&for /f "delims=0123456789" %%i in ("%_chinhSua%") do set var=%%i
if defined var (echo Lỗi 1: Sai cú pháp, thử lại... && color 4F && timeout 3 && goto :miniSendCurrency)
if "%_chinhSua%"=="0" (goto :BatDauGui)
if "%_chinhSua%"=="1" (call %_cd%\batch\miniChonNode.bat && set "_chinhSua=" && goto :miniSendCurrency)
if "%_chinhSua%"=="2" (call %_cd%\batch\miniNhapViA.bat && set "_chinhSua=" && goto :miniSendCurrency)
if "%_chinhSua%"=="3" (call %_cd%\batch\miniNhapViB.bat && set "_chinhSua=" && goto :miniSendCurrency)
if "%_chinhSua%"=="4" (call %_cd%\batch\miniSoLuong.bat && set "_chinhSua=" && goto :miniSendCurrency)
if "%_chinhSua%"=="5" (call %_cd%\batch\miniPublicKey.bat && set "_chinhSua=" && goto :miniSendCurrency)
if "%_chinhSua%"=="6" (call %_cd%\batch\miniMemo.bat && set "_chinhSua=" && goto :miniSendCurrency)
if "%_chinhSua%"=="7" (call %_cd%\batch\PASSWORD.bat && set "_chinhSua=" && goto :miniSendCurrency)
if "%_chinhSua%" gtr "7" (echo Lỗi 2: Giá trị vượt quá [7], thử lại... && color 4F && timeout 10 && goto :miniSendCurrency)
:BatDauGui
rem Bắt đầu gửi giao dịch
call :Background
call %_cd%\batch\SendStep1.bat
:KTraGiaoDich
call :Background
color 0B
echo ==========
echo Hoàn thành, bạn có thể thoát tool
echo.
echo ==========
echo [1] Kiểm tra giao dịch tại 9cscan
echo [2] Kiểm tra giao dịch bằng GraphQL
echo [3] Quay lại Menu
choice /c 123 /n /m "Nhập từ bàn phím...: "
if %errorlevel% equ 1 (goto :KTraGiaoDich9csan)
if %errorlevel% equ 2 (goto :KTraGiaoDichGraphQL)
if %errorlevel% equ 3 (call %_cd%\batch\Menu.bat)
:KTraGiaoDichGraphQL
call %_cd%\batch\SendStep5.bat
call :background
set /p _txStatus=<%_cd%\user\_txStatus.txt
set _txStatus=%_txStatus: =%
if %_txStatus% == INVALID (echo Trạng thái: NOT FOUND && color 8F && goto :endKtraGDGraphQL)
if %_txStatus% == STAGING (echo Trạng thái: STAGING && color 0B && goto :endKtraGDGraphQL)
if %_txStatus% == SUCCESS (echo Trạng thái: SUCCESS && color 2F && goto :endKtraGDGraphQL)
if %_txStatus% == FAILURE (echo Trạng thái: FAILURE && color 4F && goto :endKtraGDGraphQL)
echo Lỗi 1: Lỗi không xác định, vào game và làm gì đó sau đó thử gửi lại... && color 4F && timeout 10 && goto :endKtraGDGraphQL
goto :miniSendCurrency
:endKtraGDGraphQL
echo.
echo ==========
echo.[1]Kiểm tra lại
echo.[2]Quay lại
choice /c 12 /n /t 3 /d 1 /m "Tự động kiểm tra lại sau 3s: "
if %errorlevel% equ 1 (goto :KTraGiaoDichGraphQL)
if %errorlevel% equ 2 (goto :KTraGiaoDich)
:KTraGiaoDich9csan
set /p _stageTransaction=<%_cd%\user\_stageTransaction.txt
rem Xóa khoảng trắng
set _stageTransaction=%_stageTransaction: =%
start https://9cscan.com/tx/%_stageTransaction%
timeout 10
goto :KTraGiaoDich
:Background
cls
cd %_cd%
call %_cd%\Batch\TitleSendCurrency.bat
exit /b
:background1
cls
call :Background
echo.
echo ==========
echo Kiểm tra node %_node%
exit /b
:EnterToTiepTuc
set /p _enter= "Enter để tiếp tục..."
:KTraViA
rem Kiểm tra ví (A)
echo ==========
echo Kiểm tra ví (A)
echo.
if not [%_ncgCuaA%] == [] (goto :NhapViB) else (echo Lỗi 1: Ví A chưa đúng cú pháp 'phân biệt cả chữ hoa chữ thường', thử lại... && color 4F && timeout 10 && goto :NhapViA)
:KtraViB
rem Kiểm tra ví (B)
echo ==========
echo Kiểm tra ví (B)
echo.
if not [%_ncgCuaB%] == [] (goto :KTraViOK) else (echo Lỗi 2: Ví B chưa đúng cú pháp 'phân biệt cả chữ hoa chữ thường', thử lại... && color 4F && timeout 10 && goto :NhapViB)
rem Kiểm tra đã nhập node hay chưa
:KTraNode1
rem Kiểm tra node
echo ==========
echo Kiểm tra node %_node%
echo.
if not [%_node%] == [] (goto :KTraNode2) else (echo Lỗi 1: Chưa nhập node, thử lại... && color 4F && timeout 3 && goto :ChonNode)
rem Kiểm tra node có là số hay không
:KTraNode2
cd %_cd%
set "var="&for /f "delims=0123456789" %%i in ("%_node%") do set var=%%i
if defined var (echo Lỗi 2: Node chưa là định dạng số, thử lại... && color 4F && timeout 3 && goto :ChonNode) else (goto :KTraNode3)
rem Kiểm tra node có hoạt động hay không
:KTraNode3
cd %_cd%
call %_cd%\batch\KTraNode.bat
set /p _KTRaNode=<%_cd%/data/_KTraNode.txt
echo %_KTRaNode% |find /v "data" && set _ktra=0
call :background1
echo %_KTRaNode% |find /v "data" || set _ktra=1
call :background1
if "%_ktra%"=="1" (goto :NhapViA) else (echo Lỗi 3: Node %_node% không hoạt động, thử lại... && color 4F && timeout 5 && goto :ChonNode)
rem Kiểm tra có đầu vào hay không
:KTraSoLuong
rem Kiểm tra số lượng
echo ==========
echo Kiểm tra số lượng
echo.
if not [%_soLuong%] == [] (goto :KTraSoLuong2) else (echo Lỗi 1: Số lượng trống, thử lại... && color 4F && timeout 3 && goto :ChonLoaiTienTe)
rem Kiểm tra có là số hay không
:KTraSoLuong2
set "var="&for /f "delims=0123456789" %%i in ("%_soLuong%") do set var=%%i
if defined var (set /a _ktra=0) else (set /a _ktra=1)
if "%_ktra%" == "1" (goto :KTraSoLuong3) else (echo Lỗi 2: Số lượng không phải dạng số, thử lại... && color 4F && timeout 3 && goto :ChonLoaiTienTe)
rem Kiểm tra có nhỏ hơn số dư hay không
:KTraSoLuong3
if %_currency% == NCG (if %_soLuong% gtr %_ncgCuaA% (set /a _ktra=0))
if %_currency% == CRYSTAL (if %_soLuong% gtr %_crystalCuaA% (set /a _ktra=0))
if "%_ktra%" == "1" (goto :SoLuongOK) else (echo Lỗi 3: Số lượng vượt quá số dư, thử lại... && color 4F && timeout 3 && goto :ChonLoaiTienTe)