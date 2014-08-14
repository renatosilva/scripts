@echo off

rem    MSYS2-MSYS 2014.8.14
rem    Copyright (c) 2014 Renato Silva
rem    GNU GPLv2 licensed

rem    This script allows MSYS2 being available from Windows system path (for
rem    example from within cmd.exe) while still allowing MSYS to be executed.
rem    This is done by removing MSYS2 from system path before starting the MSYS
rem    shell, thus allowing MSYS to be executed without conflicts with MSYS2.

rem    One optional parameter is accepted for specifying location of MinTTY,
rem    which is used as MSYS terminal. If missing then MinTTY is assumed to be
rem    avaiable from system path.

rem Save path to file
set script=%TEMP%\path.bat
echo set PATH=%PATH% > %script%

rem Remove MSYS2 from path string
sed -Ei "s/;[^;]+MSYS2[^;]*//gi" %script%
sed -Ei "s/^set PATH=[^;]+MSYS2[^;]*;/PATH=/i" %script%

rem Apply new path and start MSYS
call %script%
del %script%
if not [%1] == [] set location=%1\
start %location%mintty /usr/bin/bash --login -i
exit
