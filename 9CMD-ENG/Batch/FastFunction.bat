rem Install %_cd% original
set /p _cd=<_cd.txt
cd %_cd%
rem Set Title windows
title Fast Function
call :background
call %_cd%\batch\miniChonNode.bat
:batdau
call :background
echo.
echo.[1] Fast auto Refill AP, Sweep và Repeat
echo.[2] Fast auto Craft và Upgrade
echo.
echo.==========
echo.[3] Back to the menu
choice /c 123 /n /m "Enter the number from the keyboard: "
if %errorlevel% equ 1 (start %_cd%\batch\avatarAddress\trackerFast.bat & goto :batdau)
if %errorlevel% equ 2 (start %_cd%\batch\avatarAddress\autoCraftFast.bat & goto :batdau)
if %errorlevel% equ 3 (call %_cd%\batch\Menu.bat)
goto :batdau
:Background
cls
cd %_cd%
call %_cd%\Batch\TitleFastFunction.bat
exit /b