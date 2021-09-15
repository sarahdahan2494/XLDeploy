@echo off
REM
REM Batch script to start the DB Anonymizer
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
)
set ANONYMIZER_EXTRA_OPTS=-DentityExpansionLimit=0 -DtotalEntitySizeLimit=0 -Djdk.xml.totalEntitySizeLimit=0

set BOOTSTRAPPER="com.xebialabs.database.anonymizer.AnonymizerBootstrapper"
set args=%*

%JAVACMD% -Dfile.encoding=UTF-8 %ANONYMIZER_OPTS% %ANONYMIZER_EXTRA_OPTS% -cp "%DEPLOYIT_SERVER_CLASSPATH%" %BOOTSTRAPPER% %args%

endlocal
