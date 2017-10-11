@ECHO on
chcp 1251

if NOT "%1"=="" goto no_param

:no_param

Set wrk_dir=%cd%
Set syg_dir=%wrk_dir%\Cygwin\bin
set project_dir="c:\Project\workspace\vtb24_local"

Set /p commit=Enter period commit (yesterday/2 day ago/all/...):
Set /p server=Enter Server (VTB24_DEV):
Set /p user=Enter User (IBS):
Set /p pass=Enter Pass (IBS):
Set /p errm=Enter Jira query:
Set /p mode=Enter Mode (1):

rem 1- только методы со схемы
rem 2- разница между комитами

rem if %server%=="" (set server="VTB24_DEV")
rem  if %user%=="" (set user="IBS")
rem  if %pass%=="" (set pass="IBS")
rem  if %mode%=="" (set pass="IBS")


mkdir ibsobj



if %mode%=="1"  goto mode1
if %mode%=="2"  goto mode2

:mode1

rem get yesterday commit 
cd %project_dir%

if %commit%=="all"  goto all_commit
git log --oneline --graph --name-only --after="%commit%" > %wrk_dir%\tmp_commit.txt
git log --oneline --graph --name-only --after="%commit%" | %syg_dir%\grep -oP "[^\/]+$" | %syg_dir%\sed '/.mp/d'| %syg_dir%\sed '/.mc/d' | %syg_dir%\gawk 'match($0, /.plp/) {print "METH " $0}; match($0, /.tbp/) {print "TYPE " $0}' >%wrk_dir%\commit_info.txt

:all_commit

git log --oneline --graph --name-only > %wrk_dir%\tmp_commi.txt
git log --oneline --graph --name-only | %syg_dir%\grep -oP "[^\/]+$" | %syg_dir%\sed '/.mp/d'| %syg_dir%\sed '/.mc/d' | %syg_dir%\gawk 'match($0, /.plp/) {print "METH " $0}; match($0, /.tbp/) {print "TYPE " $0}' >%wrk_dir%\commit_info.txt
cd %wrk_dir%

echo on
REM generate pck file 
	echo VER2 > ibsobj\ibsobj_%errm%.pck
	echo REM Список элементов >> ibsobj\ibsobj_%errm%.pck
	echo REM %user%@%server% >> ibsobj\ibsobj_%errm%.pck
	echo.>> ibsobj\ibsobj_%errm%.pck
	echo REM ERR %errm%>> ibsobj\ibsobj_%errm%.pck
	echo.>> ibsobj\ibsobj_%errm%.pck
	%syg_dir%\cat %wrk_dir%\commit_info.txt| %syg_dir%\sed 's/.plp//g' | %syg_dir%\sed 's/.tbp//g' >> ibsobj\ibsobj_%errm%.pck
	rem echo METH MAIN_DOCUM VTB24_CONF_DOC>> ibsobj\ibsobj.pck_%errm%>> ibsobj\ibsobj_%errm%.pck

REM generate config file for picker

	echo ^<?xml version="1.0" encoding="Windows-1251"?^> 					> .\daily.xml
	echo.																	>> .\daily.xml
	echo ^<configuration													>> .\daily.xml
	echo    version="1"														>> .\daily.xml
	echo    server="%server%"												>> .\daily.xml		
	echo    user="%user%"													>> .\daily.xml	
	echo    owner="%pass%"													>> .\daily.xml
	echo    pfx-file=" "													>> .\daily.xml
	echo    show-monitor="false"											>> .\daily.xml	
	echo ^>																	>> .\daily.xml	
	echo    ^<download														>> .\daily.xml	
	echo        id="Создание хранилища %errm%"								>> .\daily.xml
	echo        pck-file="%wrk_dir%\ibsobj\ibsobj_%errm%.pck"				>> .\daily.xml
	echo        storage-file="%wrk_dir%\ibsobj\ibsobj_%errm%.mdb"			>> .\daily.xml
	echo        dependent-mode="include"									>> .\daily.xml
	echo        enabled="true"												>> .\daily.xml
	echo    /^>																>> .\daily.xml
	echo ^</configuration^> 												>> .\daily.xml

	
rem	sqlplus -s %user%/%pass%@%server% @get_meth.sql >> ibsobj\ibsobj.pck
	@echo on

 	C:\ARM\Pick93_145.exe /cf daily.xml /p %pass% /lf ibsobj\log_%errm%.log
	
	cd %wrk_dir%
	pause

goto :eof

:mode2
echo "Режим работы с git. Данный режим работы еще не реализован!"
