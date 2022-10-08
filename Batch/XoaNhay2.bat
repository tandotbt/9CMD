rem xóa nháy với chuỗi quá dài
echo off
echo ==========
echo Xóa nháy "" trong chuỗi
rem Cài %_cd% gốc
set /p _cd=<_cd.txt
cd %_cd%
cd %_cd%\batch
copy "%_cd%\user\_Input.txt" "%_cd%\batch\_Input.txt"
rem Tách chuỗi signTransaction thành 2 phần + xóa nháy
set /p xoa_nhay=<%_cd%\batch\_Input.txt
set xoa_nhay=%xoa_nhay:~1,-558%
cd %_cd%\batch
call %_cd%\batch\TaoInputJson.bat %xoa_nhay% _A _Input.txt > xoa_nhay1.txt
set /p xoa_nhay1=<%_cd%\batch\xoa_nhay1.txt
set xoa_nhay1=%xoa_nhay1:~1,-1%
echo %xoa_nhay1%> %_cd%\batch\xoa_nhay2.txt
call %_cd%\batch\TaoInputJson.bat _A %xoa_nhay% xoa_nhay2.txt > xoa_nhay.txt
copy "%_cd%\batch\xoa_nhay.txt" "%_cd%\user\_Output.txt"
del /q %_cd%\batch\xoa_nhay.txt
del /q %_cd%\batch\xoa_nhay1.txt
exit /b