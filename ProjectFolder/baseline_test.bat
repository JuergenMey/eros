@rem  Run Eros program with following arguments
@rem
@echo off
@set EROS_PROG=C:\Projects\EROS\Hochrhein\bin\eros7.exe
@set COMMAND=%EROS_PROG% %*
@echo on
@rem

goto:todo

:not_todo

:todo


start /LOW %COMMAND% -dir=baseline\ baseline_test.arg