#!/bin/bash

for /f "delims=" %%a in ('wmic os get localdatetime ^|find"."') do set
"dt=%%a"

set "hh=%dt:~8,2%"
set "min=%dt:~10,2%"
set "sec=%dt:~12,2%"

set currenttime=%hh%%min%%sec%

adb logcat -c

adb logcat -v threadtime *:v> /data/ss/log/%currenttime%.log
echo.

pause