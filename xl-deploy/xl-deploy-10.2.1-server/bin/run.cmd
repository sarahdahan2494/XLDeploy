@echo off
REM
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

REM Build XL Deploy server classpath, JVM and logging options
FOR /F "tokens=1* delims==" %%A IN ('type "%DEPLOYIT_SERVER_HOME%\conf\xld-wrapper.conf.common"') DO (
    set key=%%A
    IF "!key:~0,23!"=="wrapper.java.classpath." (
        set value=%%B
        IF "!value:~-2!" neq "/*" (
            set DEPLOYIT_SERVER_CLASSPATH=!DEPLOYIT_SERVER_CLASSPATH!;%%B
        ) ELSE (
            set DEPLOYIT_SERVER_CLASSPATH=!DEPLOYIT_SERVER_CLASSPATH!;%%B
            for /d %%i in ("%%B") do set DEPLOYIT_SERVER_CLASSPATH=!DEPLOYIT_SERVER_CLASSPATH!;!value:~0,-1!%%i
        )
    )
    IF "!key:~0,24!"=="wrapper.java.additional." (
        set DEPLOYIT_SERVER_OPTS=!DEPLOYIT_SERVER_OPTS! %%B
    )
)

set BOOTSTRAPPER="com.xebialabs.deployit.DeployitBootstrapper"
set args=%*
if "%~1"=="" (
  GOTO runXLD
)
REM This is ugly but apparently the only way to do it
if NOT "%1"=="worker" if NOT "%1"=="plugin-manager-cli" (
  GOTO runXLD
)
if "%1"=="worker" (
  set BOOTSTRAPPER="com.xebialabs.deployit.TaskExecutionEngineBootstrapper"
)
if "%1"=="plugin-manager-cli" (
  set BOOTSTRAPPER="com.xebialabs.deployit.PluginManagerCliBootstrapper"
)

REM ...since doing this inside the above IF wouldn't work b/c of how var substitution works in cmd.exe
REM This is super ugly, but sadly, SHIFT leaves %* unchanged so we can't use that.
SHIFT && SHIFT
set args=%0 %1 %2 %3 %4 %5 %6 %7 %8 %9
shift && shift && shift && shift && shift && shift && shift && shift && shift && shift
set args=%args% %0 %1 %2 %3 %4 %5 %6 %7 %8 %9
shift && shift && shift && shift && shift && shift && shift && shift && shift && shift
set args=%args% %0 %1 %2 %3 %4 %5 %6 %7 %8 %9

REM Run XL Deploy server
:runXLD
%JAVACMD% -Dfile.encoding=UTF-8 %DEPLOYIT_SERVER_OPTS% -cp "%DEPLOYIT_SERVER_CLASSPATH%" %BOOTSTRAPPER% %args%

endlocal
