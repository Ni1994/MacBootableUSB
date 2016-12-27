@echo off



set archive=%1
set usb_drive=%2

set zip="C:\Program Files\7-Zip\7z.exe"
set zip_old="C:\Program Files (x86)\7-Zip\7z.exe"
set exit="false"
set zip_exec=""


set workfolder="osx_usb_workfolder"
set installPKG_workfolder="installPKG_workfolder"
set baseSystem_workfolder="baseSystem_workfolder"
set baseImage_workfolder="baseImage_workfolder"

IF EXIST %zip% (
	echo Using 7z located at %zip%
	set zip_exec=%zip%
)

IF EXIST %zip_old% (
	echo Using 7z located at %zip_old%
	set zip_exec=%zip_old%
)


IF %zip_exec%=="" (
	ECHO 7zip is not installed
	exit /B 5
)



IF "!archive!"=="" IF "!usb_drive!"=="" (
  echo Invalid parameters!
  echo Example: macBootableUSB.bat image.dmg G:
  exit /B 5
)


rmdir /S /Q %workfolder%
mkdir %workfolder%

%zip_exec% x -t* %archive% *hfs* -r -o%workfolder%

cd %workfolder%

set cmd="dir /b *hfs*"
echo %cmd%
FOR /F "tokens=*" %%i IN (' %cmd% ') DO SET subarchive="%%i"



%zip_exec% x %subarchive% *.app -r

del %subarchive%

set cmd="dir /b"
FOR /F "tokens=*" %%i IN (' %cmd% ') DO SET extractedFolder="%%i"

set cmd="dir /b %extractedFolder%"
FOR /F "tokens=*" %%i IN (' %cmd% ') DO SET installFolder="%%i"

move %extractedFolder%\%installFolder% %installFolder%

rmdir /S /Q %extractedFolder%


set cmd="dir /S /B InstallESD.dmg"
FOR /F "tokens=*" %%i IN (' %cmd% ') DO SET installESD="%%i"

%zip_exec% x -t* %installESD% InstallESD.dmg -r -o%installPKG_workfolder%


set cmd="dir /S /B InstallESD.dmg %installPKG_workfolder%"
FOR /F "tokens=*" %%i IN (' %cmd% ') DO SET installPKG="%%i"

%zip_exec% x -t* %installPKG% *hfs* -o%baseSystem_workfolder%

rmdir /S /Q %installPKG_workfolder%

set cmd="dir /b *hfs* %baseSystem_workfolder%"
FOR /F "tokens=*" %%i IN (' %cmd% ') DO SET subarchive="%%i"

%zip_exec% x -t* %baseSystem_workfolder%\%subarchive% BaseSystem.dmg -r -o%baseImage_workfolder%

rmdir /S /Q %baseSystem_workfolder%

set cmd="dir /b /S BaseSystem.dmg"
FOR /F "tokens=*" %%i IN (' %cmd% ') DO SET baseSystem="%%i"


mkdir .IABootFiles.
mkdir Library\Preferences\SystemConfiguration
mkdir System\Library\CoreServices


%zip_exec% e %baseSystem% prelinkedkernel -r -o.IABootFiles
%zip_exec% e %baseSystem% boot.efi -r -x!i386 -o.IABootFiles

rmdir /S /Q %baseImage_workfolder%


setlocal EnableDelayedExpansion
set replaceWith=%%20
set installFolder=!installFolder:"=!
set osx_location=!installFolder: =%replaceWith%!



echo ^<?xml version="1.0" encoding="UTF-8"?^>^<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"^>^<plist version="1.0"^>^<dict^>	^<key^>Kernel Cache^</key^>	^<string^>/.IABootFiles/prelinkedkernel^</string^>	^<key^>Kernel Flags^</key^>	^<string^>container-dmg=file:///%osx_location%/Contents/SharedSupport/InstallESD.dmg root-dmg=file:///BaseSystem.dmg^</string^>^</dict^>^</plist^> > com.apple.Boot.plist


xcopy .IABootFiles\boot.efi System\Library\CoreServices
move com.apple.Boot.plist .IABootFiles
xcopy .IABootFiles\com.apple.Boot.plist Library\Preferences\SystemConfiguration


xcopy /Y /S * %usb_drive%

cd ..
rmdir /S /Q %workfolder%
