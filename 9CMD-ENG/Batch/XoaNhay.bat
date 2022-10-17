echo ==========
echo Delete quotes "" in the string
rem Install %_cd% original
set /p _cd=<_cd.txt
cd %_cd%
set /p xoa_nhay=<%_cd%\user\_Input.txt
rem Remove quotes
set xoa_nhay=###%xoa_nhay%###
set xoa_nhay=%xoa_nhay:"###=%
set xoa_nhay=%xoa_nhay:###"=%
set xoa_nhay=%xoa_nhay:###=%
echo %xoa_nhay% > %_cd%\user\_Output.txt