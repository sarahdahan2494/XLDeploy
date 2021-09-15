@echo off
REM Batch script to start the XL Deploy Server
REM

setlocal ENABLEDELAYEDEXPANSION

REM Get Java executable
if "%JAVA_HOME%"=="" (
  set JAVACMD=java
) else (
  set JAVACMD="%JAVA_HOME%\bin\java"
)

REM Get XL Deploy server home dir
if "%DEPLOYIT_SERVER_HOME%"=="" (
  cd /d "%~dp0"
  cd ..
  set DEPLOYIT_SERVER_HOME=!CD!
)

cd /d "%DEPLOYIT_SERVER_HOME%"


REM Default port
set DERBY_PORT=1527

if exist "%DEPLOYIT_SERVER_HOME%/centralConfiguration/deploy-repository.yaml" (
    find /c "jdbc:derby://localhost:" %DEPLOYIT_SERVER_HOME%\centralConfiguration\deploy-repository.yaml >nul && (
		for /F "tokens=5 delims=:/" %%F in ('find "jdbc:derby://localhost:" %DEPLOYIT_SERVER_HOME%\centralConfiguration\deploy-repository.yaml') do (
			set DERBY_PORT=%%F
		)
	)
	set DERBY_PORT=!DERBY_PORT!
)
set CLASSPATH="%DEPLOYIT_SERVER_HOME%\derbyns\derby.jar;%DEPLOYIT_SERVER_HOME%\derbyns\derbynet.jar;"

echo "XLD will attempt to shutdown a Derby Network Server on port %DERBY_PORT%"
%JAVACMD% -cp %CLASSPATH% org.apache.derby.drda.NetworkServerControl shutdown -p %DERBY_PORT%


