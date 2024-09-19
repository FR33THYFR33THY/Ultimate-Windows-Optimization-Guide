    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
    {Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit}
    $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " (Administrator)"
    $Host.UI.RawUI.BackgroundColor = "Black"
	$Host.PrivateData.ProgressBackgroundColor = "Black"
    $Host.PrivateData.ProgressForegroundColor = "White"
    Clear-Host

    Write-Host "No mouse acceleration on 150% scaling with EPP on"
    Write-Host "If using 150% scaling while gaming turn raw input off"	
    Write-Host ""
    Write-Host "1. 100%"
    Write-Host "2. 150%"
    while ($true) {
    $choice = Read-Host " "
    if ($choice -match '^[1-2]$') {
    switch ($choice) {
    1 {

Clear-Host
# create reg file
$MultilineComment = @"
Windows Registry Editor Version 5.00

; 6-11 pointer speed
[HKEY_CURRENT_USER\Control Panel\Mouse]
"MouseSensitivity"="10"

; enhance pointer precision disable
[HKEY_CURRENT_USER\Control Panel\Mouse]
"MouseSpeed"="0"
"MouseThreshold1"="0"
"MouseThreshold2"="0"

; mouse curve default
[HKEY_CURRENT_USER\Control Panel\Mouse]
"SmoothMouseXCurve"=hex:\
    00,00,00,00,00,00,00,00,\
	c0,cc,0c,00,00,00,00,00,\
	80,99,19,00,00,00,00,00,\
	40,66,26,00,00,00,00,00,\
	00,33,33,00,00,00,00,00
"SmoothMouseYCurve"=hex:\
    00,00,00,00,00,00,00,00,\
	00,00,38,00,00,00,00,00,\
	00,00,70,00,00,00,00,00,\
	00,00,a8,00,00,00,00,00,\
	00,00,e0,00,00,00,00,00

; dpi scaling 100%
[HKEY_CURRENT_USER\Control Panel\Desktop]
"Win8DpiScaling"=dword:00000001
"LogPixels"=dword:00000060

; fix scaling for apps disable
[HKEY_CURRENT_USER\Control Panel\Desktop]
"EnablePerProcessSystemDPI"=dword:00000000
"@
Set-Content -Path "$env:TEMP\100%.reg" -Value $MultilineComment -Force
# import reg file
Regedit.exe /S "$env:TEMP\100%.reg"
Timeout /T 5 | Out-Null
# logout
logoff
exit

      }
    2 {

Clear-Host
# create reg file
$MultilineComment = @"
Windows Registry Editor Version 5.00

; 6-11 pointer speed
[HKEY_CURRENT_USER\Control Panel\Mouse]
"MouseSensitivity"="10"

; enhance pointer precision enable
[HKEY_CURRENT_USER\Control Panel\Mouse]
"MouseSpeed"="1"
"MouseThreshold1"="6"
"MouseThreshold2"="10"

; mouse curve 150% scaling
[HKEY_CURRENT_USER\Control Panel\Mouse]
"SmoothMouseXCurve"=hex:\
	00,00,00,00,00,00,00,00,\
	30,33,13,00,00,00,00,00,\
	60,66,26,00,00,00,00,00,\
	90,99,39,00,00,00,00,00,\
	C0,CC,4C,00,00,00,00,00
"SmoothMouseYCurve"=hex:\
	00,00,00,00,00,00,00,00,\
	00,00,38,00,00,00,00,00,\
	00,00,70,00,00,00,00,00,\
	00,00,A8,00,00,00,00,00,\
	00,00,E0,00,00,00,00,00

; dpi scaling 150%
[HKEY_CURRENT_USER\Control Panel\Desktop]
"Win8DpiScaling"=dword:00000001
"LogPixels"=dword:00000090

; fix scaling for apps enable
[HKEY_CURRENT_USER\Control Panel\Desktop]
"EnablePerProcessSystemDPI"=dword:00000001
"@
Set-Content -Path "$env:TEMP\150%.reg" -Value $MultilineComment -Force
# import reg file
Regedit.exe /S "$env:TEMP\150%.reg"
Timeout /T 5 | Out-Null
# logout
logoff
exit

      }
    } } else { Write-Host "Invalid input. Please select a valid option (1-2)." } }