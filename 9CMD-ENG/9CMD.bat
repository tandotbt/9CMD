echo  off
mode con:cols=39 lines=20
color 0B
rem Install Vietnamese
chcp 65001
cls
rem Create _cd.txt
title 9CMD - by tanbt
echo ==========
echo Create file _cd.txt
echo.Note: The folder name contains 9CMD
echo.THERE IS NO SPACES
echo.If have, not work :vv
set _cd=%~dp0
echo %_cd%>_cd.txt
rem Copy _cd.txt for all folders
copy "%_cd%\_cd.txt" "%_cd%\batch\_cd.txt">nul
copy "%_cd%\_cd.txt" "%_cd%\planet\_cd.txt">nul
copy "%_cd%\_cd.txt" "%_cd%\user\_cd.txt">nul
copy "%_cd%\_cd.txt" "%_cd%\PASSWORD\_cd.txt">nul
copy "%_cd%\_cd.txt" "%_cd%\data\_cd.txt">nul
copy "%_cd%\_cd.txt" "%_cd%\data\avatarAddress\_cd.txt">nul
copy "%_cd%\_cd.txt" "%_cd%\batch\avatarAddress\_cd.txt">nul
copy "%_cd%\_cd.txt" "%_cd%\user\avatarAddress\_cd.txt">nul
timeout 20
call %_cd%\batch\enterUTC.bat