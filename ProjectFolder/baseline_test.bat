@rem  Run Eros program with following arguments
@rem
@echo off
@set EROS_PROG=C:\Users\mey\SynologyDrive\erosmatlabinterface\bin\eros7.exe
@set COMMAND=%EROS_PROG% %*
@echo on
@rem

goto:todo

:not_todo

:todo


start /LOW %COMMAND% -dir=Results\ baseline_test.arg