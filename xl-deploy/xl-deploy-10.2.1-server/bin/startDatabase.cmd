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

set START_DATABASE=1

REM Default port
set DERBY_PORT=1527

if exist "%DEPLOYIT_SERVER_HOME%/centralConfiguration/deploy-repository.yaml" (
    echo "File deploy-repository.yaml has been found to fetch the port."
	set START_DATABASE=0
	find /c "jdbc:derby://localhost" %DEPLOYIT_SERVER_HOME%\centralConfiguration\deploy-repository.yaml >nul && (
		set START_DATABASE=1
		for /F "tokens=5 delims=:/" %%F in ('type "%DEPLOYIT_SERVER_HOME%\centralConfiguration\deploy-repository.yaml"') do (
			set DERBY_PORT=%%F
		)
	)
	echo "Port %DERBY_PORT% has been fetched from %DEPLOYIT_SERVER_HOME%/centralConfiguration/deploy-repository.yaml."
	set DERBY_PORT=!DERBY_PORT!
) else (
    echo "File %DEPLOYIT_SERVER_HOME%/centralConfiguration/deploy-repository.yaml has not been found."
)

if %START_DATABASE% EQU 1 (
    set CLASSPATH="%DEPLOYIT_SERVER_HOME%\derbyns\derby.jar;%DEPLOYIT_SERVER_HOME%\derbyns\derbynet.jar"
	echo "XLD will attempt to start a Derby Network Server on port %DERBY_PORT%"
	%JAVACMD% -Djava.security.manager=java.lang.SecurityManager -Djava.security.policy=conf/xl-deploy.policy -cp !CLASSPATH! org.apache.derby.drda.NetworkServerControl start -p %DERBY_PORT% -h 0.0.0.0
) else (
     echo "Could not start Derby Network server as Derby was not configured in centralConfiguration\deploy-repository.yaml."
)


