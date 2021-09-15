@echo off
REM
REM Batch script to uninstall XL Deploy Server service
REM

setlocal ENABLEDELAYEDEXPANSION

REM Get XL Deploy server home dir
if "%xldeploy_home%"=="" (
    cd /d "%~dp0"
    cd ..
    set xldeploy_home=!CD!
)

call "%xldeploy_home%\bin\.wrapper-env.cmd"

if %errorLevel% neq 0 ( exit /b %errorLevel% )

set conf_file="%xldeploy_home%/conf/xld-wrapper-server.conf"
if "%1" == "worker" (
    set conf_file="%xldeploy_home%/conf/xld-wrapper-worker.conf"
)

call %java_exe% %wrapper_java_options% -jar %wrapper_jar% -p %conf_file%
call %java_exe% %wrapper_java_options% -jar %wrapper_jar% -r %conf_file%

endlocal
