echo ==========
echo Export the wallet address from the folder UTC
rem Install %_cd% origin
set /p _cd=<_cd.txt
cd %_cd%
rem Receive variable
set /p _node=<%_cd%\data\_node.txt
rem Delete spaces
set _node=%_node: =%
rem Convert all UTC into Address
cd %_cd%\user\avatarAddress
set _i=1
for /f "tokens=*" %%a in (utc.txt) do (call :processline %%a)
exit /b
goto :eof
:processline
set _vi=%* & set _vi1=%_vi:~-43,-1%
echo %_vi:~-43,-1%  >> %_cd%\user\avatarAddress\oldData.txt & set /a _i+=1
goto :eof
:eof