rem @echo off
@echo off
chcp 65001
rem chcp 1251
rem Данный скрипт создаёт архивную копию данных из %IncludeList% в %baseArch% 
rem Он будет создавать инкрементные архивы, если %WholeMode%=0
rem Он скопирует файлы в разные места, если %NeedSpread%=1
rem %IncludeList% - это файл со списком файлов и/или каталогов
rem один в строке
rem 
rem Требования:
rem 7-Zip 4.57 or > (http://www.7-zip.org/)
rem pDate 1.1 or > (http://pdate.sourceforge.net/)
rem 
rem Pavel Malakhov 2007.12.12
rem ... ряд изменений:
rem 2010.01.13 Добавлен экспорт из реестра прав на шары
rem Ссылка http://sysadminwiki.ru/wiki/Резервное_копирование_в_Windows
rem
rem Использование скрипта:
rem 0) Установить 7-Zip в C:\Program Files\ (можно переопределить в переменных скрипта, если путь установки отличается от дефолтного);
rem 1) Установить pdate.exe в C:\Tools\ (можно переопределить в переменных скрипта);
rem 2) Создать директорию C:\Tools (можно переопределить в переменных скрипта);
rem 3) Создать файл include_general.txt в C:\Tools (можно переопределить в переменных скрипта);
rem 4) Записать в файл include_general.txt пути для файлов/директорий, которые необходимо архивировать
rem	Одна строка в файле = одному пути, строк может быть сколько угодно;
rem 5) Во избежание проблем скрипт запускать из-под административной УЗ
rem -======[ VARIABLES ]======-
rem Временный каталог, используется для кэша
set tmpDir=C:\Temp

if not exist %tmpDir% mkdir %tmpDir%
else set tmpDir=C:\Temp

rem Используем переменные для внешних программ	
set run_7z="C:\Program Files\7-Zip\7za.exe"
set run_pdate="C:\Tools\pdate.exe"

rem --- установить и получить "day of month" через переменную %dm% ---
%run_pdate% "\s\e\t \d\m\=e" > %tmpDir%\tmp.bat
call %tmpDir%\tmp.bat
del %tmpDir%\tmp.bat

rem --- установить и получить "day of week" через переменную %dw% ---
%run_pdate% "\s\e\t \d\w\=u" > %tmpDir%\tmp.bat
call %tmpDir%\tmp.bat
del %tmpDir%\tmp.bat

rem --- установить и получить "week number" через переменную %wn% ---
%run_pdate% "\s\e\t \w\n\=V" > %tmpDir%\tmp.bat
call %tmpDir%\tmp.bat
del %tmpDir%\tmp.bat

rem Журнал
set LogDir=C:\Tools
rem set Log=%LogDir%/bk_7z_general.log
set Log=%LogDir%\bk_7z_general.log

rem Места и названия архивов
rem Место хранения архивов
set dDir=C:\Backup
rem Архивы за прошлый месяц
set dlmDir=C:\Backup\LastMonth
rem Имя основного архива
set baseArch=%dDir%\month_general.7z
rem Список архивируемых объектов
set IncludeList=%LogDir%\include_general.txt
rem Имя для ежедневного инкрементного архива
set updArch_dw=%dDir%\day_general_%dw%.7z
rem Имя для еженедельного инкрементного архива
set updArch_wn=%dDir%\week_general_%wn%.7z
rem Архив реестра
set regShares=%dDir%\shares_%wn%.reg

rem --- (=1) Делает целую резервную копию каждый день ---
rem --- (=0) Делает полную резервную копию только один раз в месяц. Создавайте архивы обновлений (по возрастанию до месяца) каждый день ---
set WholeMode=1

rem --- Распространять архивные файлы на несколько мест (= 1) или нет (= 0 или что-то ещё) ---
set NeedSpread=1

rem --- Где размещать архивы. Целевые каталоги ---
rem 1-го числа
set dDirM=C:\Backup\
rem в понедельник
set dDir1=C:\Backup\1
rem во вторник и т.д.
set dDir2=C:\Backup\2
set dDir3=C:\Backup\3
set dDir4=C:\Backup\4
set dDir5=C:\Backup\5
set dDir6=C:\Backup\6
rem ... в воскресенье = еженедельный архив
set dDir7=C:\Backup\7

rem -======[ COMMANDS ]======-
if not exist %baseArch% goto BaseArchive
if %WholeMode%==1 goto BaseArchive
if %dm% GTR 1 goto UpdateArchive

:BaseArchive
rem --- Очистищает %dlmDir% и перемещает данные предыдущего месяца в этот каталог ---
if not exist %dlmDir%\nul mkdir %dlmDir%
del /Q %dlmDir%\*
move /Y %dDir%\* %dlmDir%
move /Y %LogDir%\*.log %dlmDir%

%run_pdate% "====== Y B =======" > %Log%
%run_pdate% "z, A --- \B\a\c\k\u\p \s\h\a\r\e \r\i\g\h\t\s " >> %Log%
REG EXPORT HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Shares %regShares%
%run_pdate% "z, A --- \S\t\a\r\t \t\o \c\r\e\a\t\e \n\e\w \a\r\c\h\i\v\e" >> %Log%

rem --- Создаст архив ---
%run_7z% a %baseArch% -w%tmpDir% -i@%IncludeList% -ssw -slp -scsWIN -mmt=on -mx3 -ms=off >> %Log%
%run_pdate% "z, A -^- \n\e\w \a\r\c\h\i\v\e \c\r\e\a\t\e\d" >> %Log%
set SpreadArch=%baseArch%
if %NeedSpread%==1 goto Spread
goto End

:UpdateArchive
echo ******* ******* *******  >> %Log%
%run_pdate% "z, A --- \S\t\a\r\t \t\o \u\p\d\a\t\e \a\r\c\h\i\v\e" >> %Log%
if %dw%==7 (set updArch=%updArch_wn%) else set updArch=%updArch_dw%

rem --- Проверка наличия файлов ---
if exist %updArch% del /Q %updArch%

rem --- Создание инкрементного архива ---
%run_7z% u %baseArch% -u- -up0q0r2x0y2z0w0!%updArch% -w%tmpDir% -i@%IncludeList% -ssw -slp -scsWIN -mmt=on -mx5 -ms=off >> %Log%
%run_pdate% "z, A -^- \u\p\d\a\t\e \f\i\n\n\i\s\h\e\d" >> %Log%
set SpreadArch=%updArch%

if %NeedSpread%==1 goto Spread
goto End

:Spread
rem --- Распространение созданного архива в резервные места ---
if %dm%==1 set SpreadDir=%dDirM%
if %dw%==1 set SpreadDir=%dDir1%
if %dw%==2 set SpreadDir=%dDir2%
if %dw%==3 set SpreadDir=%dDir3%
if %dw%==4 set SpreadDir=%dDir4%
if %dw%==5 set SpreadDir=%dDir5%
if %dw%==6 set SpreadDir=%dDir6%
if %dw%==7 set SpreadDir=%dDir7%

%run_pdate% "z, A ---  \S\p\r\e\a\d \s\t\a\r\t\e\d" >> %Log%
rem - не работает на Win 2003 - если не существует %Spread Dir%\ nul mkdir %SpreadDir%
mkdir %SpreadDir%
echo spread to: %SpreadDir%, file to copy:%SpreadArch% >> %Log%
copy /Y %SpreadArch% %SpreadDir%  >> %Log%
%run_pdate% "z, A -^- \C\o\p\y \l\o\g \s\t\a\r\t\e\d" >> %Log%
copy /Y %Log% %SpreadDir%  >> %Log%

:End
%run_pdate% "z, A -^- \D\o\n\e" >> %Log%

rem -=======[ COMMENTS ]=======-
rem Some keys for 7z command:
rem -ssw (Compress files open for writing)
rem -slp (Set Large Pages mode) increases the speed of compression of large data
rem -scs (Set charset for list files) {UTF-8 | WIN | DOS}
rem -ms=100f100m (set solid mode with 100 files & 10 MB limits per one solid block.)
rem -mmt=on  (Sets multithread mode. If you have a multiprocessor or multicore system, you can get a increase with this switch.)
rem -mx=5  (x=[0 | 1 | 5 | 7 | 9 ] Sets level of compression)
rem
rem 7z a archive.7z c:\*path\to\file.ext 
rem stores full path except volume letter, but it is slow to start because it has to scan the hard disk for matches