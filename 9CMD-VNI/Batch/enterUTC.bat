mode con:cols=80 lines=20
cls
rem Cài %_cd% gốc
set /p _cd=<_cd.txt
title Nhập UTC file(s)
:showUTC
call :Background
echo ==========
echo File UTC đang có
echo.
rem Kiểm tra thư mục UTC có file hay rỗng
Set _folderUTC="%_cd%\user\UTC"
For /F %%A in ('dir /b /a %_folderUTC%') Do (
    goto :oldUTC
)
Echo Không tìm thấy file UTC
goto :newUTC
:oldUTC
rem Hiển thị file UTC đang có
for /f "tokens=*" %%G in ('dir /b %_cd%\user\UTC\*.* ^| find "UTC"') do (echo [-] %%G>> %_cd%\_temp.txt)
type %_cd%\_temp.txt
del /q %_cd%\_temp.txt
:newUTC
echo.
echo.Kéo thả file UTC hoặc thư mục chứa UTC và nhấn Enter để nhập file UTC
echo.Chú ý: nếu thư mục nhập có khoảng trắng sẽ không thành công!
echo.===
echo.Gõ 'open' để mở vị trí lưu
echo.Gõ 'ok' để tiếp tục
set /p _nhapUTC="Gõ 'deleteAll' để xóa file UTC đã nhập: "
set _nhapUTC=%_nhapUTC: =%
if "%_nhapUTC%" == "open" (start %_cd%\user\UTC & goto :showUTC)
if "%_nhapUTC%" == "deleteAll" (cd %_cd%\user\UTC & set "_nhapUTC=" & del /q UTC* & del /q %_cd%\_temp.txt & goto :showUTC)
if "%_nhapUTC%" == "ok" (set "_nhapUTC=" & call %_cd%\batch\menu.bat)
rem copy UTC và chuyển vào bộ nhớ
echo a | copy /-y "%_nhapUTC%" "%_cd%\user\UTC\">nul
goto :showUTC
:Background
cls
cd %_cd%
type %_cd%\data\_Title9CMD.txt
exit /b