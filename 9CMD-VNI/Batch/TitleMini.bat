mode con:cols=100 lines=20
color 0B
rem Cài tiếng Việt Nam
chcp 65001
cls
set /p _cd=<_cd.txt
cd %_cd%\Data
if %1==1 (type _TitleMiniNode.txt)
if %1==2 (type _TitleMiniEnterWallet.txt)
if %1==3 (type _TitleMiniPublicKey.txt)
if %1==4 (type _TitleMiniAmount.txt)
