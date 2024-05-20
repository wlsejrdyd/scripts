@echo off

setlocal

set file=1.dns_query.txt
set dom=www.a.com www.b.com
set server=1.1.1.1 2.2.2.2

echo %date% %time% > %file%	

for %%c in (%dom%) do (
	for %%d in (%server%) do (
		echo ------------------------------------------ >> %file%
		echo "%%c" >> %file%
		nslookup -q=A %%c %%d |findstr "Address" >> %file%
	)
)

endlocal