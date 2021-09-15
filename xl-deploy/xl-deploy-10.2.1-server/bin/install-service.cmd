@echo off
REM
REM Batch script to install XL Deploy Server as a service
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

If NOT exist "%xldeploy_home%\conf\deployit.conf" (
    echo The XL Deploy server is not initialized. Please execute the run.cmd script!
    exit /b 1
)

If NOT exist "%xldeploy_home%\conf\deployit-license.lic" (
    echo A license is required in order to be able to install the XL Deploy Server as a service.
    exit /b 1
)

set conf_file="%xldeploy_home%/conf/xld-wrapper-server.conf"
if "%1" == "worker" (
    set conf_file="%xldeploy_home%/conf/xld-wrapper-worker.conf"
    if "%2"=="" (
         REM FOR BACKWARDS COMPATIBILITY : ./install-service.cmd worker
         set /p wrapper.app.parameter.4="Please provide the connection details for the XL Deploy master (HOST:PORT): "
         set /p wrapper.app.parameter.2="Please provide the URL for the REST api: "

	)else (
	    set "api="
        set "master="
		:loop
		IF NOT "%1"=="" (
			IF "%1"=="-master" (
				SET master=%2 !master!
				SHIFT
			)
			IF "%1"=="-api" (
					SET api=%2
					SHIFT
			)
			SHIFT
			GOTO :loop
		)
		set wrapper.app.parameter.4=!master!
        set wrapper.app.parameter.2=!api!
	)
)

call %java_exe% %wrapper_java_options% -jar %wrapper_jar% -i %conf_file%
call %java_exe% %wrapper_java_options% -jar %wrapper_jar% -t %conf_file%

echo.
echo Please make sure the server is configured so that it can start without input from the user
echo (e.g. if a repository keystore password is required then it should be provided in deployit.conf).

endlocal
