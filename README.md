# MacBootableUSB
How to create a bootable mac USB from Windows.

### Prerequisites:

1. Paragon Partition Manager Free Edition, [download here](https://www.paragon-software.com/home/pm-express/).
2. 7zip, [download here](http://www.7-zip.org/download.html). Please install it in the default directory as I am using that path in the script below.
3. macBoot.bat script, available from this GitHub repository.

All the software above is available for free. 

### Preparing the USB drive
1. Convert the USB drive to GPT. Open Run prompt – Win+R. Type diskpart, press Enter. Execute the command below highlighted with bold text.  

  DISKPART> **list disk**  

  Disk ###  Status         Size     Free     Dyn  Gpt  
  --------  -------------  -------  -------  ---  ---  
  Disk 0    Online          233 GB  1024 KB        *  
  Disk 1    Online           29 GB      0 B        *  
  Disk 2    No Media           0 B      0 B  

  Now select the disk number that represents your flash drive. You should be able to recognize it by its size.  

  DISKPART> **sel disk X**  
  Disk X is now the selected disk.  
  DISKPART> **clean**  
  DiskPart succeeded in cleaning the disk.  
  DISKPART> **convert gpt**  
  DiskPart successfully converted the selected disk to GPT format.  
  DISKPART> **create partition primary**  
  DiskPart succeeded in creating the specified partition.  
  DISKPART> **sel part 1**  
  Partition 1 is now the selected partition.  
  DISKPART> **format fs=ntfs quick**  
  100 percent completed  
  DiskPart successfully formatted the volume.  
  DISKPART> **exit**  
  Leaving DiskPart...  

2.	Use the bat file to create a bootable mac usb drive.   
  Command format: **macBoot.bat pathToDMG driveLetter**  
  Usage example: **macBoot.bat “OS_X_El_Capitan_10.11.6_MAS.dmg” G:**  
  In this case, the macBoot.bat file and OSX dmg file are in the same folder.  
  Make sure that you have at least 2 times the size of the image as free space.  

3. Run Paragon Partition Manager and convert the USB drive from NTFS to HFS+. The wizard is pretty straightforward. The faster the write speed of the USB drive the faster it will finish converting.
4.	Now the USB drive is ready to boot

### Explanation
There are a few difficulties to create a bootable usb stick in windows:

1. Windows doesn’t support natively HFS Plus filesystem  
2. The .dmg image format also is not supported natively  
3. Apple, as always, doesn’t follow standards

The USB drive will be recognized as bootable by the MAC bootloader if it contains the following file structure:  
.IABootFiles  
.IABootFiles\boot.efi  
.IABootFiles\com.apple.Boot.plist  
.IABootFiles\prelinkedkernel  
Library  
Library\Preferences  
Library\Preferences\SystemConfiguration  
Library\Preferences\SystemConfiguration\com.apple.Boot.plist  
System  
System\Library  
System\Library\CoreServices  
System\Library\CoreServices\boot.efi   
Install OS X El Capitan.app  

This is all that is needed to boot the USB drive. The UEFI firmware doesn’t require any MBR tinkering to boot a usb drive, because there is no MBR. It only needs a correct file structure. Below you can find the full DMG path for boot.efi, prelinkedkernel and the explanation for com.apple.Boot.plist


**boot.efi**  - Install OS X El Capitan.app\Contents\SharedSupport\InstallESD.dmg\ InstallMacOSX.pkg\InstallESD.dmg\5.hfs\OS X Install ESD\BaseSystem.dmg\OS X Base System\System\Library\CoreServices\boot.efi

**prelinkedkernel** - Install OS X El Capitan.app\Contents\SharedSupport\InstallESD.dmg\InstallMacOSX.pkg\InstallESD.dmg\5.hfs\OS X Install ESD\BaseSystem.dmg\OS X Base System\System\Library\PrelinkedKernels\prelinkedkernel

**com.apple.Boot.plist** – is an XML file that must be generated. Here is the format:  
```
<?xml version="1.0" encoding="UTF-8"?>  
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">  
<plist version="1.0">  
<dict>  
	<key>Kernel Cache</key>  
	<string>/.IABootFiles/prelinkedkernel</string>  
	<key>Kernel Flags</key>  
	<string>container-dmg=file:///Install%20macOS%20Sierra.app/Contents/SharedSupport/InstallESD.dmg root-dmg=file:///BaseSystem.dmg</string>  
</dict>  
</plist>  
```

The container-dmg must be changed according to the version of OSX that needs to be installed. And it also must be HTTP encoded so that the spaces are transformed into %20 strings.



