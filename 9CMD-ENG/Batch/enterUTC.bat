mode con:cols=80 lines=20
cls
rem Install %_cd% origin
set /p _cd=<_cd.txt
title Import UTC file(s)
:showUTC
call :Background
echo ==========
echo File UTC existent
echo.
rem Check the UTC folder have file or not
Set _folderUTC="%_cd%\user\UTC"
For /F %%A in ('dir /b /a %_folderUTC%') Do (
    goto :oldUTC
)
Echo Not found file UTC
goto :newUTC
:oldUTC
rem Showing UTC files available
for /f "tokens=*" %%G in ('dir /b %_cd%\user\UTC\*.* ^| find "UTC"') do (echo [-] %%G>> %_cd%\_temp.txt)
type %_cd%\_temp.txt
del /q %_cd%\_temp.txt
:newUTC
echo.
echo.Drag the UTC file or folder containing UTC and press Enter to enter the UTC file
echo.Note: If the import folder has a white space, it will not succeed!
echo.===
echo.Type 'open' to open the location save data
echo.Type 'ok' to continue
set /p _nhapUTC="Type 'deleteAll' to delete file UTC entered: "
set _nhapUTC=%_nhapUTC: =%
if "%_nhapUTC%" == "open" (start %_cd%\user\UTC & goto :showUTC)
if "%_nhapUTC%" == "deleteAll" (cd %_cd%\user\UTC & set "_nhapUTC=" & del /q UTC* & del /q %_cd%\_temp.txt & goto :showUTC)
if "%_nhapUTC%" == "ok" (set "_nhapUTC=" & call %_cd%\batch\menu.bat)
rem Copy UTC and transfer into memory
echo a | copy /-y "%_nhapUTC%" "%_cd%\user\UTC\">nul
goto :showUTC
:Background
cls
cd %_cd%
type %_cd%\data\_Title9CMD.txt
exit /b