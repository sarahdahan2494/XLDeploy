@echo off

if x%1x == xx (
    echo.
    echo At least one argument is required, which must be a positive number
    echo.
    echo startLocalWorker.cmd NUMBER -api URL -master NAME:PORT ...
    echo Usage: Starts a local worker with parameter values set based on the NUMBER.
    echo        See usage message of 'run.cmd worker' for details.
    exit /b -1
)

set /A WORKER_NUMBER=0+%1
if %WORKER_NUMBER% LEQ 0 (
    echo.
    echo First argument ["%1"] must be a positive number
    echo.
    echo startLocalWorker.cmd NUMBER -api URL -master NAME:PORT ...
    echo Usage: Starts a local worker with parameter values set based on the NUMBER.
    echo        See usage message of 'run.cmd worker' for details.
    exit /b -1
)

set WORKER_NAME=worker-%WORKER_NUMBER%
set /A WORKER_PORT=8180 + WORKER_NUMBER
set WORKER_WORKDIR=work-%WORKER_NUMBER%
set LOGFILE=deployit-worker-%WORKER_NUMBER%
set BIN_DIR=%~dp0

REM Remove script path and first argument, pass 'the rest' to args.
REM 'The rest' is limited to 30 arguments for now.
REM This is super ugly, but sadly, SHIFT leaves %* unchanged so we can't use that.
shift && shift
set args=%0 %1 %2 %3 %4 %5 %6 %7 %8 %9
shift && shift && shift && shift && shift && shift && shift && shift && shift && shift
set args=%args% %0 %1 %2 %3 %4 %5 %6 %7 %8 %9
shift && shift && shift && shift && shift && shift && shift && shift && shift && shift
set args=%args% %0 %1 %2 %3 %4 %5 %6 %7 %8 %9

@echo on
%BIN_DIR%run.cmd worker -name %WORKER_NAME% -port %WORKER_PORT% -work %WORKER_WORKDIR% %args%
