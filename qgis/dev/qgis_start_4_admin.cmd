@echo off
REM QGIS starting bat
REM 	History:	First version / pos / 2024-08-29
REM				  	Add better parameter handling / pos / 2025-12-16
REM				  	add new environment variables & custom python scripts  / rekjuh / 2026-11-6
REM				  	add profiles, new parameters  / rekjuh & joonaris / 2026-10

REM Make parent of this script location our current directory,
REM converting UNC path to drive letter if needed

REM You can also execute this from command-line

REM ---------------------------------------------------------------------------
REM		Custom settings
REM ---------------------------------------------------------------------------
SET QGIS_VERSION=4.2.2.
REM ---------------------------------------------------------------------------

REM Check that we have QGIS executable
SET QGIS_EXE_PATH="C:\Program Files\QGIS 4.2.2\bin\qgis-bin.exe"

IF NOT EXIST %QGIS_EXE_PATH% (
	echo Not found QGIS executable in %QGIS_EXE_PATH%
	PAUSE
	GOTO EXIT
)

pushd %~dp0

if exist "qgis_profiles" SET QGIS_CUSTOM_CONFIG_PATH=%~dp0qgis_profiles
if exist "qgis_settings\qgis_global_settings.ini" SET QGIS_GLOBAL_SETTINGS_FILE=%~dp0qgis\parameters\qgis_global_settings.ini
if exist "custom_python.py" SET PYQGIS_STARTUP=%~dp0qgis\parameters\custom_python.py
if exist "qgis_opencl_program_folder" SET QGIS_OPENCL_PROGRAM_FOLDER=%~dp0qgis\parameters\qgis_opencl_program_folder
if exist "qgis_log_files.log" SET QGIS_LOG_FILE=%~dp0qgis\misc\qgis_log_files.log

if exist "%~dp0pgservice.conf" (
 SET PGSERVICEFILE=%~dp0pgservice.conf
 echo Using local PGSERVICEFILE: %~dp0pgservice.conf
)

SET guivar=%1

if "%guivar%" == "" (	
	echo No parameter, proceed normally
) else (
	if "%guivar%"=="nogui" (
		echo No custom UI file in use
		SET QGIS_CUSTOM_UI_FILE=
	) else (
		echo Using GUI file, if exists
	)
)

if not exist "%QGIS_CUSTOM_UI_FILE%" goto noguifile

START "QGIS (LTR) custom GUI" /B %QGIS_EXE_PATH% --customizationfile %QGIS_CUSTOM_UI_FILE%
goto exit

:noguifile
echo Start QGIS without custom UI file
START "QGIS (LTR)" /B %QGIS_EXE_PATH%

:exit
echo Exiting
REM EXIT


REM		End of command file
REM ------------------------------------------------------------------------------------
