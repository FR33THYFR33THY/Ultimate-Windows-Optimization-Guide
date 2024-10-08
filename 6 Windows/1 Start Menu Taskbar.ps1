    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
    {Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit}
    $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " (Administrator)"
    $Host.UI.RawUI.BackgroundColor = "Black"
	$Host.PrivateData.ProgressBackgroundColor = "Black"
    $Host.PrivateData.ProgressForegroundColor = "White"
    Clear-Host

    function Get-FileFromWeb {
    param ([Parameter(Mandatory)][string]$URL, [Parameter(Mandatory)][string]$File)
    function Show-Progress {
    param ([Parameter(Mandatory)][Single]$TotalValue, [Parameter(Mandatory)][Single]$CurrentValue, [Parameter(Mandatory)][string]$ProgressText, [Parameter()][int]$BarSize = 10, [Parameter()][switch]$Complete)
    $percent = $CurrentValue / $TotalValue
    $percentComplete = $percent * 100
    if ($psISE) { Write-Progress "$ProgressText" -id 0 -percentComplete $percentComplete }
    else { Write-Host -NoNewLine "`r$ProgressText $(''.PadRight($BarSize * $percent, [char]9608).PadRight($BarSize, [char]9617)) $($percentComplete.ToString('##0.00').PadLeft(6)) % " }
    }
    try {
    $request = [System.Net.HttpWebRequest]::Create($URL)
    $response = $request.GetResponse()
    if ($response.StatusCode -eq 401 -or $response.StatusCode -eq 403 -or $response.StatusCode -eq 404) { throw "Remote file either doesn't exist, is unauthorized, or is forbidden for '$URL'." }
    if ($File -match '^\.\\') { $File = Join-Path (Get-Location -PSProvider 'FileSystem') ($File -Split '^\.')[1] }
    if ($File -and !(Split-Path $File)) { $File = Join-Path (Get-Location -PSProvider 'FileSystem') $File }
    if ($File) { $fileDirectory = $([System.IO.Path]::GetDirectoryName($File)); if (!(Test-Path($fileDirectory))) { [System.IO.Directory]::CreateDirectory($fileDirectory) | Out-Null } }
    [long]$fullSize = $response.ContentLength
    [byte[]]$buffer = new-object byte[] 1048576
    [long]$total = [long]$count = 0
    $reader = $response.GetResponseStream()
    $writer = new-object System.IO.FileStream $File, 'Create'
    do {
    $count = $reader.Read($buffer, 0, $buffer.Length)
    $writer.Write($buffer, 0, $count)
    $total += $count
    if ($fullSize -gt 0) { Show-Progress -TotalValue $fullSize -CurrentValue $total -ProgressText " $($File.Name)" }
    } while ($count -gt 0)
    }
    finally {
    $reader.Close()
    $writer.Close()
    }
    }

    Write-Host "1. Start Menu Taskbar: Clean (Recommended)"
    Write-Host "2. Start Menu Taskbar: Default"
    while ($true) {
    $choice = Read-Host " "
    if ($choice -match '^[1-2]$') {
    switch ($choice) {
    1 {

Clear-Host
Write-Host "Start Menu Taskbar: Clean . . ."
# CLEAN TASKBAR
# unpin all taskbar icons
cmd /c "reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband /f >nul 2>&1"
Remove-Item -Recurse -Force "$env:USERPROFILE\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch" -ErrorAction SilentlyContinue | Out-Null
New-Item -Path "$env:USERPROFILE\AppData\Roaming\Microsoft\Internet Explorer" -Name "Quick Launch" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
New-Item -Path "$env:USERPROFILE\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch" -Name "User Pinned" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
New-Item -Path "$env:USERPROFILE\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned" -Name "TaskBar" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
New-Item -Path "$env:USERPROFILE\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned" -Name "ImplicitAppShortcuts" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
# pin file explorer to taskbar
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:AppData\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\File Explorer.lnk")
$Shortcut.TargetPath = "explorer"
$Shortcut.Save()
# create reg file
$MultilineComment = @"
Windows Registry Editor Version 5.00

; pin file explorer to taskbar
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband]
"Favorites"=hex:00,aa,01,00,00,3a,00,1f,80,c8,27,34,1f,10,5c,10,42,aa,03,2e,e4,\
  52,87,d6,68,26,00,01,00,26,00,ef,be,10,00,00,00,f4,7e,76,fa,de,9d,da,01,40,\
  61,5d,09,df,9d,da,01,19,b8,5f,09,df,9d,da,01,14,00,56,00,31,00,00,00,00,00,\
  a4,58,a9,26,10,00,54,61,73,6b,42,61,72,00,40,00,09,00,04,00,ef,be,a4,58,a9,\
  26,a4,58,a9,26,2e,00,00,00,de,9c,01,00,00,00,02,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,0c,f4,85,00,54,00,61,00,73,00,6b,00,42,00,61,00,72,00,00,\
  00,16,00,18,01,32,00,8a,04,00,00,a4,58,b6,26,20,00,46,49,4c,45,45,58,7e,31,\
  2e,4c,4e,4b,00,00,54,00,09,00,04,00,ef,be,a4,58,b6,26,a4,58,b6,26,2e,00,00,\
  00,b7,a8,01,00,00,00,04,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,c0,5a,\
  1e,01,46,00,69,00,6c,00,65,00,20,00,45,00,78,00,70,00,6c,00,6f,00,72,00,65,\
  00,72,00,2e,00,6c,00,6e,00,6b,00,00,00,1c,00,22,00,00,00,1e,00,ef,be,02,00,\
  55,00,73,00,65,00,72,00,50,00,69,00,6e,00,6e,00,65,00,64,00,00,00,1c,00,12,\
  00,00,00,2b,00,ef,be,19,b8,5f,09,df,9d,da,01,1c,00,74,00,00,00,1d,00,ef,be,\
  02,00,7b,00,46,00,33,00,38,00,42,00,46,00,34,00,30,00,34,00,2d,00,31,00,44,\
  00,34,00,33,00,2d,00,34,00,32,00,46,00,32,00,2d,00,39,00,33,00,30,00,35,00,\
  2d,00,36,00,37,00,44,00,45,00,30,00,42,00,32,00,38,00,46,00,43,00,32,00,33,\
  00,7d,00,5c,00,65,00,78,00,70,00,6c,00,6f,00,72,00,65,00,72,00,2e,00,65,00,\
  78,00,65,00,00,00,1c,00,00,00,ff

; remove windows widgets from taskbar
[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Dsh]
"AllowNewsAndInterests"=dword:00000000

; left taskbar alignment
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"TaskbarAl"=dword:00000000

; remove search from taskbar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search]
"SearchboxTaskbarMode"=dword:00000000

; remove task view from taskbar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"ShowTaskViewButton"=dword:00000000

; remove chat from taskbar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"TaskbarMn"=dword:00000000

; remove copilot from taskbar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"ShowCopilotButton"=dword:00000000

; remove news and interests
[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Windows Feeds]
"EnableFeeds"=dword:00000000

; remove meet now
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer]
"HideSCAMeetNow"=dword:00000001

; remove security taskbar icon
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run]
"SecurityHealth"=hex:07,00,00,00,05,db,8a,69,8a,49,d9,01

; show all taskbar icons w10 only
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer]
"EnableAutoTray"=dword:00000000
"@
Set-Content -Path "$env:TEMP\Taskbar Clean.reg" -Value $MultilineComment -Force
# import reg file
Set-Location -Path "$env:TEMP"
Regedit.exe /S "Taskbar Clean.reg"
# CLEAN START MENU W11
$progresspreference = 'silentlycontinue'
Remove-Item -Recurse -Force "$env:USERPROFILE\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState\start2.bin" -ErrorAction SilentlyContinue
#start2.bin cert
#leaves only file explorer and settings pinned (edge too if its installed)
$certContent = "-----BEGIN CERTIFICATE-----
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
TSz1QZdkum5Y3uC7wc7paXh1rm11nwluCC7jiA==
-----END CERTIFICATE-----
"
New-Item "$env:TEMP\start2.txt" -Value $certContent -Force | Out-Null
certutil.exe -decode "$env:TEMP\start2.txt" "$env:TEMP\start2.bin" >$null
Copy-Item "$env:TEMP\start2.bin" -Destination "$env:USERPROFILE\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState" -Force | Out-Null
# CLEAN START MENU W10
# delete startmenulayout.xml
Remove-Item -Recurse -Force "$env:SystemDrive\Windows\StartMenuLayout.xml" -ErrorAction SilentlyContinue | Out-Null
# create startmenulayout.xml
$MultilineComment = @"
<LayoutModificationTemplate xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout" Version="1" xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout" xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification">
    <LayoutOptions StartTileGroupCellWidth="6" />
    <DefaultLayoutOverride>
        <StartLayoutCollection>
            <defaultlayout:StartLayout GroupCellWidth="6" />
        </StartLayoutCollection>
    </DefaultLayoutOverride>
</LayoutModificationTemplate>
"@
Set-Content -Path "C:\Windows\StartMenuLayout.xml" -Value $MultilineComment -Force -Encoding ASCII
# assign startmenulayout.xml registry
$layoutFile="C:\Windows\StartMenuLayout.xml"
$regAliases = @("HKLM", "HKCU")
foreach ($regAlias in $regAliases){
$basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
$keyPath = $basePath + "\Explorer"
IF(!(Test-Path -Path $keyPath)) {
New-Item -Path $basePath -Name "Explorer" | Out-Null
}
Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 1 | Out-Null
Set-ItemProperty -Path $keyPath -Name "StartLayoutFile" -Value $layoutFile | Out-Null
}
# restart explorer
Stop-Process -Force -Name explorer -ErrorAction SilentlyContinue | Out-Null
Timeout /T 5 | Out-Null
# disable lockedstartlayout registry
foreach ($regAlias in $regAliases){
$basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
$keyPath = $basePath + "\Explorer"
Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 0
}
# restart explorer
Stop-Process -Force -Name explorer -ErrorAction SilentlyContinue | Out-Null
# delete startmenulayout.xml
Remove-Item -Recurse -Force "$env:SystemDrive\Windows\StartMenuLayout.xml" -ErrorAction SilentlyContinue | Out-Null
Clear-Host
Write-Host "Restart to apply . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
exit

      }
    2 {

Clear-Host
Write-Host "Start Menu Taskbar: Default . . ."
# TASKBAR
# unpin all taskbar icons
cmd /c "reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband /f >nul 2>&1"
Remove-Item -Recurse -Force "$env:USERPROFILE\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch" -ErrorAction SilentlyContinue | Out-Null
New-Item -Path "$env:USERPROFILE\AppData\Roaming\Microsoft\Internet Explorer" -Name "Quick Launch" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
New-Item -Path "$env:USERPROFILE\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch" -Name "User Pinned" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
New-Item -Path "$env:USERPROFILE\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned" -Name "TaskBar" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
New-Item -Path "$env:USERPROFILE\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned" -Name "ImplicitAppShortcuts" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
# pin file explorer to taskbar
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:AppData\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\File Explorer.lnk")
$Shortcut.TargetPath = "explorer"
$Shortcut.Save()
# pin microsoft edge to taskbar
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:AppData\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Microsoft Edge.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"     
$Shortcut.Save()
# pin microsoft edge to taskbar
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:AppData\Microsoft\Internet Explorer\Quick Launch\Microsoft Edge.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"     
$Shortcut.Save()
# pin show desktop to taskbar
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:AppData\Microsoft\Internet Explorer\Quick Launch\Show desktop.lnk")
$Shortcut.TargetPath = "shell:::{3080F90D-D7AD-11D9-BD98-0000947B0257}"
$Shortcut.Save()
# pin switch between windows to taskbar
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:AppData\Microsoft\Internet Explorer\Quick Launch\Switch between windows.lnk")
$Shortcut.TargetPath = "shell:::{3080F90E-D7AD-11D9-BD98-0000947B0257}"
$Shortcut.Save()
# create reg file
$MultilineComment = @"
Windows Registry Editor Version 5.00

; pin all to taskbar
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband]
"FavoritesResolve"=hex:e4,02,00,00,4c,00,00,00,01,14,02,00,00,00,00,00,c0,00,\
  00,00,00,00,00,46,83,00,80,00,20,00,00,00,de,32,c4,63,b1,9a,da,01,de,32,c4,\
  63,b1,9a,da,01,fb,8c,e0,3b,b0,9a,da,01,86,09,00,00,00,00,00,00,01,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,52,01,3a,00,1f,80,c8,27,34,1f,10,5c,10,\
  42,aa,03,2e,e4,52,87,d6,68,26,00,01,00,26,00,ef,be,12,00,00,00,ee,08,2d,3c,\
  b1,9a,da,01,de,32,c4,63,b1,9a,da,01,de,32,c4,63,b1,9a,da,01,14,00,56,00,31,\
  00,00,00,00,00,9e,58,2c,1e,10,00,54,61,73,6b,42,61,72,00,40,00,09,00,04,00,\
  ef,be,9e,58,2c,1e,9e,58,2c,1e,2e,00,00,00,69,a1,01,00,00,00,01,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,22,47,53,00,54,00,61,00,73,00,6b,00,42,00,\
  61,00,72,00,00,00,16,00,c0,00,32,00,86,09,00,00,9e,58,24,1d,20,00,4d,49,43,\
  52,4f,53,7e,31,2e,4c,4e,4b,00,00,56,00,09,00,04,00,ef,be,9e,58,2c,1e,9e,58,\
  2c,1e,2e,00,00,00,6a,a1,01,00,00,00,01,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,05,55,93,00,4d,00,69,00,63,00,72,00,6f,00,73,00,6f,00,66,00,74,00,\
  20,00,45,00,64,00,67,00,65,00,2e,00,6c,00,6e,00,6b,00,00,00,1c,00,22,00,00,\
  00,1e,00,ef,be,02,00,55,00,73,00,65,00,72,00,50,00,69,00,6e,00,6e,00,65,00,\
  64,00,00,00,1c,00,12,00,00,00,2b,00,ef,be,de,32,c4,63,b1,9a,da,01,1c,00,1a,\
  00,00,00,1d,00,ef,be,02,00,4d,00,53,00,45,00,64,00,67,00,65,00,00,00,1c,00,\
  00,00,9b,00,00,00,1c,00,00,00,01,00,00,00,1c,00,00,00,2d,00,00,00,00,00,00,\
  00,9a,00,00,00,11,00,00,00,03,00,00,00,8f,cb,5d,8e,10,00,00,00,00,43,3a,5c,\
  55,73,65,72,73,5c,57,31,30,5c,41,70,70,44,61,74,61,5c,52,6f,61,6d,69,6e,67,\
  5c,4d,69,63,72,6f,73,6f,66,74,5c,49,6e,74,65,72,6e,65,74,20,45,78,70,6c,6f,\
  72,65,72,5c,51,75,69,63,6b,20,4c,61,75,6e,63,68,5c,55,73,65,72,20,50,69,6e,\
  6e,65,64,5c,54,61,73,6b,42,61,72,5c,4d,69,63,72,6f,73,6f,66,74,20,45,64,67,\
  65,2e,6c,6e,6b,00,00,60,00,00,00,03,00,00,a0,58,00,00,00,00,00,00,00,64,65,\
  73,6b,74,6f,70,2d,37,37,6c,67,32,36,38,00,cc,3c,4d,6a,1d,a8,23,4f,9f,c3,41,\
  f4,f3,a3,3b,46,2c,b0,10,91,a3,06,ef,11,a5,fd,00,0c,29,af,c6,c9,cc,3c,4d,6a,\
  1d,a8,23,4f,9f,c3,41,f4,f3,a3,3b,46,2c,b0,10,91,a3,06,ef,11,a5,fd,00,0c,29,\
  af,c6,c9,45,00,00,00,09,00,00,a0,39,00,00,00,31,53,50,53,b1,16,6d,44,ad,8d,\
  70,48,a7,48,40,2e,a4,3d,78,8c,1d,00,00,00,68,00,00,00,00,48,00,00,00,ea,11,\
  e5,4d,bc,6c,6b,41,a1,aa,68,3a,11,f5,c0,0c,00,00,00,00,00,00,00,00,00,00,00,\
  00,31,03,00,00,4c,00,00,00,01,14,02,00,00,00,00,00,c0,00,00,00,00,00,00,46,\
  83,00,80,00,20,00,00,00,21,a7,c6,63,b1,9a,da,01,aa,f6,c8,63,b1,9a,da,01,a8,\
  b6,c6,da,dd,ac,d5,01,97,01,00,00,00,00,00,00,01,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,a0,01,3a,00,1f,80,c8,27,34,1f,10,5c,10,42,aa,03,2e,e4,52,\
  87,d6,68,26,00,01,00,26,00,ef,be,12,00,00,00,ee,08,2d,3c,b1,9a,da,01,de,32,\
  c4,63,b1,9a,da,01,aa,f6,c8,63,b1,9a,da,01,14,00,56,00,31,00,00,00,00,00,9e,\
  58,2c,1e,11,00,54,61,73,6b,42,61,72,00,40,00,09,00,04,00,ef,be,9e,58,2c,1e,\
  9e,58,2c,1e,2e,00,00,00,69,a1,01,00,00,00,01,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,56,83,4e,00,54,00,61,00,73,00,6b,00,42,00,61,00,72,00,00,00,\
  16,00,0e,01,32,00,97,01,00,00,87,4f,07,49,20,00,46,49,4c,45,45,58,7e,31,2e,\
  4c,4e,4b,00,00,7c,00,09,00,04,00,ef,be,9e,58,2c,1e,9e,58,2c,1e,2e,00,00,00,\
  6b,a1,01,00,00,00,01,00,00,00,00,00,00,00,00,00,52,00,00,00,00,00,58,9c,44,\
  00,46,00,69,00,6c,00,65,00,20,00,45,00,78,00,70,00,6c,00,6f,00,72,00,65,00,\
  72,00,2e,00,6c,00,6e,00,6b,00,00,00,40,00,73,00,68,00,65,00,6c,00,6c,00,33,\
  00,32,00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,32,00,32,00,30,00,36,00,37,00,\
  00,00,1c,00,22,00,00,00,1e,00,ef,be,02,00,55,00,73,00,65,00,72,00,50,00,69,\
  00,6e,00,6e,00,65,00,64,00,00,00,1c,00,12,00,00,00,2b,00,ef,be,aa,f6,c8,63,\
  b1,9a,da,01,1c,00,42,00,00,00,1d,00,ef,be,02,00,4d,00,69,00,63,00,72,00,6f,\
  00,73,00,6f,00,66,00,74,00,2e,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,\
  2e,00,45,00,78,00,70,00,6c,00,6f,00,72,00,65,00,72,00,00,00,1c,00,00,00,9a,\
  00,00,00,1c,00,00,00,01,00,00,00,1c,00,00,00,2d,00,00,00,00,00,00,00,99,00,\
  00,00,11,00,00,00,03,00,00,00,8f,cb,5d,8e,10,00,00,00,00,43,3a,5c,55,73,65,\
  72,73,5c,57,31,30,5c,41,70,70,44,61,74,61,5c,52,6f,61,6d,69,6e,67,5c,4d,69,\
  63,72,6f,73,6f,66,74,5c,49,6e,74,65,72,6e,65,74,20,45,78,70,6c,6f,72,65,72,\
  5c,51,75,69,63,6b,20,4c,61,75,6e,63,68,5c,55,73,65,72,20,50,69,6e,6e,65,64,\
  5c,54,61,73,6b,42,61,72,5c,46,69,6c,65,20,45,78,70,6c,6f,72,65,72,2e,6c,6e,\
  6b,00,00,60,00,00,00,03,00,00,a0,58,00,00,00,00,00,00,00,64,65,73,6b,74,6f,\
  70,2d,37,37,6c,67,32,36,38,00,cc,3c,4d,6a,1d,a8,23,4f,9f,c3,41,f4,f3,a3,3b,\
  46,32,b0,10,91,a3,06,ef,11,a5,fd,00,0c,29,af,c6,c9,cc,3c,4d,6a,1d,a8,23,4f,\
  9f,c3,41,f4,f3,a3,3b,46,32,b0,10,91,a3,06,ef,11,a5,fd,00,0c,29,af,c6,c9,45,\
  00,00,00,09,00,00,a0,39,00,00,00,31,53,50,53,b1,16,6d,44,ad,8d,70,48,a7,48,\
  40,2e,a4,3d,78,8c,1d,00,00,00,68,00,00,00,00,48,00,00,00,ea,11,e5,4d,bc,6c,\
  6b,41,a1,aa,68,3a,11,f5,c0,0c,00,00,00,00,00,00,00,00,00,00,00,00,99,06,00,\
  00,4c,00,00,00,01,14,02,00,00,00,00,00,c0,00,00,00,00,00,00,46,81,00,80,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,01,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,47,06,14,00,1f,80,9b,d4,34,42,45,02,f3,4d,b7,80,38,93,94,34,56,e1,31,\
  06,00,00,99,05,41,50,50,53,87,05,08,00,03,00,00,00,00,00,00,00,4e,02,00,00,\
  31,53,50,53,55,28,4c,9f,79,9f,39,4b,a8,d0,e1,d4,2d,e1,d5,f3,5d,00,00,00,11,\
  00,00,00,00,1f,00,00,00,25,00,00,00,4d,00,69,00,63,00,72,00,6f,00,73,00,6f,\
  00,66,00,74,00,2e,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,53,00,74,00,\
  6f,00,72,00,65,00,5f,00,38,00,77,00,65,00,6b,00,79,00,62,00,33,00,64,00,38,\
  00,62,00,62,00,77,00,65,00,00,00,00,00,11,00,00,00,0e,00,00,00,00,13,00,00,\
  00,01,00,00,00,85,00,00,00,15,00,00,00,00,1f,00,00,00,39,00,00,00,4d,00,69,\
  00,63,00,72,00,6f,00,73,00,6f,00,66,00,74,00,2e,00,57,00,69,00,6e,00,64,00,\
  6f,00,77,00,73,00,53,00,74,00,6f,00,72,00,65,00,5f,00,31,00,31,00,39,00,31,\
  00,30,00,2e,00,31,00,30,00,30,00,32,00,2e,00,35,00,2e,00,30,00,5f,00,78,00,\
  36,00,34,00,5f,00,5f,00,38,00,77,00,65,00,6b,00,79,00,62,00,33,00,64,00,38,\
  00,62,00,62,00,77,00,65,00,00,00,00,00,65,00,00,00,05,00,00,00,00,1f,00,00,\
  00,29,00,00,00,4d,00,69,00,63,00,72,00,6f,00,73,00,6f,00,66,00,74,00,2e,00,\
  57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,53,00,74,00,6f,00,72,00,65,00,5f,\
  00,38,00,77,00,65,00,6b,00,79,00,62,00,33,00,64,00,38,00,62,00,62,00,77,00,\
  65,00,21,00,41,00,70,00,70,00,00,00,00,00,bd,00,00,00,0f,00,00,00,00,1f,00,\
  00,00,56,00,00,00,43,00,3a,00,5c,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,\
  00,20,00,46,00,69,00,6c,00,65,00,73,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,\
  77,00,73,00,41,00,70,00,70,00,73,00,5c,00,4d,00,69,00,63,00,72,00,6f,00,73,\
  00,6f,00,66,00,74,00,2e,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,53,00,\
  74,00,6f,00,72,00,65,00,5f,00,31,00,31,00,39,00,31,00,30,00,2e,00,31,00,30,\
  00,30,00,32,00,2e,00,35,00,2e,00,30,00,5f,00,78,00,36,00,34,00,5f,00,5f,00,\
  38,00,77,00,65,00,6b,00,79,00,62,00,33,00,64,00,38,00,62,00,62,00,77,00,65,\
  00,00,00,1d,00,00,00,20,00,00,00,00,48,00,00,00,05,c5,72,a5,af,32,5c,4e,a5,\
  56,c4,94,0b,8a,77,a1,00,00,00,00,8a,02,00,00,31,53,50,53,4d,0b,d4,86,69,90,\
  3c,44,81,9a,2a,54,09,0d,cc,ec,55,00,00,00,0c,00,00,00,00,1f,00,00,00,21,00,\
  00,00,41,00,73,00,73,00,65,00,74,00,73,00,5c,00,41,00,70,00,70,00,54,00,69,\
  00,6c,00,65,00,73,00,5c,00,53,00,74,00,6f,00,72,00,65,00,4d,00,65,00,64,00,\
  54,00,69,00,6c,00,65,00,2e,00,70,00,6e,00,67,00,00,00,00,00,55,00,00,00,02,\
  00,00,00,00,1f,00,00,00,21,00,00,00,41,00,73,00,73,00,65,00,74,00,73,00,5c,\
  00,41,00,70,00,70,00,54,00,69,00,6c,00,65,00,73,00,5c,00,53,00,74,00,6f,00,\
  72,00,65,00,41,00,70,00,70,00,4c,00,69,00,73,00,74,00,2e,00,70,00,6e,00,67,\
  00,00,00,00,00,59,00,00,00,0f,00,00,00,00,1f,00,00,00,23,00,00,00,41,00,73,\
  00,73,00,65,00,74,00,73,00,5c,00,41,00,70,00,70,00,54,00,69,00,6c,00,65,00,\
  73,00,5c,00,53,00,74,00,6f,00,72,00,65,00,42,00,61,00,64,00,67,00,65,00,4c,\
  00,6f,00,67,00,6f,00,2e,00,70,00,6e,00,67,00,00,00,00,00,55,00,00,00,0d,00,\
  00,00,00,1f,00,00,00,22,00,00,00,41,00,73,00,73,00,65,00,74,00,73,00,5c,00,\
  41,00,70,00,70,00,54,00,69,00,6c,00,65,00,73,00,5c,00,53,00,74,00,6f,00,72,\
  00,65,00,57,00,69,00,64,00,65,00,54,00,69,00,6c,00,65,00,2e,00,70,00,6e,00,\
  67,00,00,00,11,00,00,00,04,00,00,00,00,13,00,00,00,00,78,d7,ff,59,00,00,00,\
  13,00,00,00,00,1f,00,00,00,23,00,00,00,41,00,73,00,73,00,65,00,74,00,73,00,\
  5c,00,41,00,70,00,70,00,54,00,69,00,6c,00,65,00,73,00,5c,00,53,00,74,00,6f,\
  00,72,00,65,00,4c,00,61,00,72,00,67,00,65,00,54,00,69,00,6c,00,65,00,2e,00,\
  70,00,6e,00,67,00,00,00,00,00,11,00,00,00,05,00,00,00,00,13,00,00,00,ff,ff,\
  ff,ff,11,00,00,00,0e,00,00,00,00,13,00,00,00,a5,04,00,00,31,00,00,00,0b,00,\
  00,00,00,1f,00,00,00,10,00,00,00,4d,00,69,00,63,00,72,00,6f,00,73,00,6f,00,\
  66,00,74,00,20,00,53,00,74,00,6f,00,72,00,65,00,00,00,59,00,00,00,14,00,00,\
  00,00,1f,00,00,00,23,00,00,00,41,00,73,00,73,00,65,00,74,00,73,00,5c,00,41,\
  00,70,00,70,00,54,00,69,00,6c,00,65,00,73,00,5c,00,53,00,74,00,6f,00,72,00,\
  65,00,53,00,6d,00,61,00,6c,00,6c,00,54,00,69,00,6c,00,65,00,2e,00,70,00,6e,\
  00,67,00,00,00,00,00,00,00,00,00,31,00,00,00,31,53,50,53,b1,16,6d,44,ad,8d,\
  70,48,a7,48,40,2e,a4,3d,78,8c,15,00,00,00,64,00,00,00,00,15,00,00,00,14,01,\
  00,00,00,00,00,00,00,00,00,00,4d,00,00,00,31,53,50,53,30,f1,25,b7,ef,47,1a,\
  10,a5,f1,02,60,8c,9e,eb,ac,31,00,00,00,0a,00,00,00,00,1f,00,00,00,10,00,00,\
  00,4d,00,69,00,63,00,72,00,6f,00,73,00,6f,00,66,00,74,00,20,00,53,00,74,00,\
  6f,00,72,00,65,00,00,00,00,00,00,00,2d,00,00,00,31,53,50,53,b3,77,ed,0d,14,\
  c6,6c,45,ae,5b,28,5b,38,d7,b0,1b,11,00,00,00,07,00,00,00,00,13,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,22,00,00,00,1e,00,ef,be,02,00,55,00,\
  73,00,65,00,72,00,50,00,69,00,6e,00,6e,00,65,00,64,00,00,00,9f,05,12,00,00,\
  00,2b,00,ef,be,c8,58,cb,63,b1,9a,da,01,9f,05,5e,00,00,00,1d,00,ef,be,02,00,\
  4d,00,69,00,63,00,72,00,6f,00,73,00,6f,00,66,00,74,00,2e,00,57,00,69,00,6e,\
  00,64,00,6f,00,77,00,73,00,53,00,74,00,6f,00,72,00,65,00,5f,00,38,00,77,00,\
  65,00,6b,00,79,00,62,00,33,00,64,00,38,00,62,00,62,00,77,00,65,00,21,00,41,\
  00,70,00,70,00,00,00,9f,05,00,00,00,00,00,00,01,07,00,00,4c,00,00,00,01,14,\
  02,00,00,00,00,00,c0,00,00,00,00,00,00,46,81,00,80,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,01,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,af,06,14,00,1f,\
  80,9b,d4,34,42,45,02,f3,4d,b7,80,38,93,94,34,56,e1,99,06,00,00,b5,05,41,50,\
  50,53,a3,05,08,00,03,00,00,00,00,00,00,00,f6,02,00,00,31,53,50,53,55,28,4c,\
  9f,79,9f,39,4b,a8,d0,e1,d4,2d,e1,d5,f3,75,00,00,00,11,00,00,00,00,1f,00,00,\
  00,32,00,00,00,6d,00,69,00,63,00,72,00,6f,00,73,00,6f,00,66,00,74,00,2e,00,\
  77,00,69,00,6e,00,64,00,6f,00,77,00,73,00,63,00,6f,00,6d,00,6d,00,75,00,6e,\
  00,69,00,63,00,61,00,74,00,69,00,6f,00,6e,00,73,00,61,00,70,00,70,00,73,00,\
  5f,00,38,00,77,00,65,00,6b,00,79,00,62,00,33,00,64,00,38,00,62,00,62,00,77,\
  00,65,00,00,00,11,00,00,00,0e,00,00,00,00,13,00,00,00,01,00,00,00,a9,00,00,\
  00,15,00,00,00,00,1f,00,00,00,4b,00,00,00,6d,00,69,00,63,00,72,00,6f,00,73,\
  00,6f,00,66,00,74,00,2e,00,77,00,69,00,6e,00,64,00,6f,00,77,00,73,00,63,00,\
  6f,00,6d,00,6d,00,75,00,6e,00,69,00,63,00,61,00,74,00,69,00,6f,00,6e,00,73,\
  00,61,00,70,00,70,00,73,00,5f,00,31,00,36,00,30,00,30,00,35,00,2e,00,31,00,\
  31,00,36,00,32,00,39,00,2e,00,32,00,30,00,33,00,31,00,36,00,2e,00,30,00,5f,\
  00,78,00,36,00,34,00,5f,00,5f,00,38,00,77,00,65,00,6b,00,79,00,62,00,33,00,\
  64,00,38,00,62,00,62,00,77,00,65,00,00,00,00,00,ad,00,00,00,05,00,00,00,00,\
  1f,00,00,00,4d,00,00,00,6d,00,69,00,63,00,72,00,6f,00,73,00,6f,00,66,00,74,\
  00,2e,00,77,00,69,00,6e,00,64,00,6f,00,77,00,73,00,63,00,6f,00,6d,00,6d,00,\
  75,00,6e,00,69,00,63,00,61,00,74,00,69,00,6f,00,6e,00,73,00,61,00,70,00,70,\
  00,73,00,5f,00,38,00,77,00,65,00,6b,00,79,00,62,00,33,00,64,00,38,00,62,00,\
  62,00,77,00,65,00,21,00,6d,00,69,00,63,00,72,00,6f,00,73,00,6f,00,66,00,74,\
  00,2e,00,77,00,69,00,6e,00,64,00,6f,00,77,00,73,00,6c,00,69,00,76,00,65,00,\
  2e,00,6d,00,61,00,69,00,6c,00,00,00,00,00,e1,00,00,00,0f,00,00,00,00,1f,00,\
  00,00,68,00,00,00,43,00,3a,00,5c,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,\
  00,20,00,46,00,69,00,6c,00,65,00,73,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,\
  77,00,73,00,41,00,70,00,70,00,73,00,5c,00,6d,00,69,00,63,00,72,00,6f,00,73,\
  00,6f,00,66,00,74,00,2e,00,77,00,69,00,6e,00,64,00,6f,00,77,00,73,00,63,00,\
  6f,00,6d,00,6d,00,75,00,6e,00,69,00,63,00,61,00,74,00,69,00,6f,00,6e,00,73,\
  00,61,00,70,00,70,00,73,00,5f,00,31,00,36,00,30,00,30,00,35,00,2e,00,31,00,\
  31,00,36,00,32,00,39,00,2e,00,32,00,30,00,33,00,31,00,36,00,2e,00,30,00,5f,\
  00,78,00,36,00,34,00,5f,00,5f,00,38,00,77,00,65,00,6b,00,79,00,62,00,33,00,\
  64,00,38,00,62,00,62,00,77,00,65,00,00,00,1d,00,00,00,20,00,00,00,00,48,00,\
  00,00,a0,07,88,66,ed,fc,34,49,88,1d,9d,b7,35,48,d3,3c,00,00,00,00,12,02,00,\
  00,31,53,50,53,4d,0b,d4,86,69,90,3c,44,81,9a,2a,54,09,0d,cc,ec,49,00,00,00,\
  0c,00,00,00,00,1f,00,00,00,1c,00,00,00,69,00,6d,00,61,00,67,00,65,00,73,00,\
  5c,00,48,00,78,00,4d,00,61,00,69,00,6c,00,4d,00,65,00,64,00,69,00,75,00,6d,\
  00,54,00,69,00,6c,00,65,00,2e,00,70,00,6e,00,67,00,00,00,45,00,00,00,02,00,\
  00,00,00,1f,00,00,00,19,00,00,00,69,00,6d,00,61,00,67,00,65,00,73,00,5c,00,\
  48,00,78,00,4d,00,61,00,69,00,6c,00,41,00,70,00,70,00,4c,00,69,00,73,00,74,\
  00,2e,00,70,00,6e,00,67,00,00,00,00,00,41,00,00,00,0f,00,00,00,00,1f,00,00,\
  00,17,00,00,00,69,00,6d,00,61,00,67,00,65,00,73,00,5c,00,48,00,78,00,4d,00,\
  61,00,69,00,6c,00,42,00,61,00,64,00,67,00,65,00,2e,00,70,00,6e,00,67,00,00,\
  00,00,00,45,00,00,00,0d,00,00,00,00,1f,00,00,00,1a,00,00,00,69,00,6d,00,61,\
  00,67,00,65,00,73,00,5c,00,48,00,78,00,4d,00,61,00,69,00,6c,00,57,00,69,00,\
  64,00,65,00,54,00,69,00,6c,00,65,00,2e,00,70,00,6e,00,67,00,00,00,11,00,00,\
  00,04,00,00,00,00,13,00,00,00,00,78,d7,ff,49,00,00,00,13,00,00,00,00,1f,00,\
  00,00,1b,00,00,00,69,00,6d,00,61,00,67,00,65,00,73,00,5c,00,48,00,78,00,4d,\
  00,61,00,69,00,6c,00,4c,00,61,00,72,00,67,00,65,00,54,00,69,00,6c,00,65,00,\
  2e,00,70,00,6e,00,67,00,00,00,00,00,11,00,00,00,05,00,00,00,00,13,00,00,00,\
  ff,ff,ff,ff,11,00,00,00,0e,00,00,00,00,13,00,00,00,ad,04,00,00,1d,00,00,00,\
  0b,00,00,00,00,1f,00,00,00,05,00,00,00,4d,00,61,00,69,00,6c,00,00,00,00,00,\
  49,00,00,00,14,00,00,00,00,1f,00,00,00,1b,00,00,00,69,00,6d,00,61,00,67,00,\
  65,00,73,00,5c,00,48,00,78,00,4d,00,61,00,69,00,6c,00,53,00,6d,00,61,00,6c,\
  00,6c,00,54,00,69,00,6c,00,65,00,2e,00,70,00,6e,00,67,00,00,00,00,00,00,00,\
  00,00,31,00,00,00,31,53,50,53,b1,16,6d,44,ad,8d,70,48,a7,48,40,2e,a4,3d,78,\
  8c,15,00,00,00,64,00,00,00,00,15,00,00,00,10,01,00,00,00,00,00,00,00,00,00,\
  00,39,00,00,00,31,53,50,53,30,f1,25,b7,ef,47,1a,10,a5,f1,02,60,8c,9e,eb,ac,\
  1d,00,00,00,0a,00,00,00,00,1f,00,00,00,05,00,00,00,4d,00,61,00,69,00,6c,00,\
  00,00,00,00,00,00,00,00,2d,00,00,00,31,53,50,53,b3,77,ed,0d,14,c6,6c,45,ae,\
  5b,28,5b,38,d7,b0,1b,11,00,00,00,07,00,00,00,00,13,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,26,00,00,00,1e,00,ef,be,02,00,53,00,79,00,73,00,\
  74,00,65,00,6d,00,50,00,69,00,6e,00,6e,00,65,00,64,00,00,00,bb,05,12,00,00,\
  00,2b,00,ef,be,48,aa,ba,63,b1,9a,da,01,bb,05,a6,00,00,00,1d,00,ef,be,02,00,\
  6d,00,69,00,63,00,72,00,6f,00,73,00,6f,00,66,00,74,00,2e,00,77,00,69,00,6e,\
  00,64,00,6f,00,77,00,73,00,63,00,6f,00,6d,00,6d,00,75,00,6e,00,69,00,63,00,\
  61,00,74,00,69,00,6f,00,6e,00,73,00,61,00,70,00,70,00,73,00,5f,00,38,00,77,\
  00,65,00,6b,00,79,00,62,00,33,00,64,00,38,00,62,00,62,00,77,00,65,00,21,00,\
  6d,00,69,00,63,00,72,00,6f,00,73,00,6f,00,66,00,74,00,2e,00,77,00,69,00,6e,\
  00,64,00,6f,00,77,00,73,00,6c,00,69,00,76,00,65,00,2e,00,6d,00,61,00,69,00,\
  6c,00,00,00,bb,05,00,00,00,00,00,00
"Favorites"=hex:00,56,01,00,00,3a,00,1f,80,c8,27,34,1f,10,5c,10,42,aa,03,2e,e4,\
  52,87,d6,68,26,00,01,00,26,00,ef,be,12,00,00,00,ee,08,2d,3c,b1,9a,da,01,de,\
  32,c4,63,b1,9a,da,01,de,32,c4,63,b1,9a,da,01,14,00,56,00,31,00,00,00,00,00,\
  9e,58,2c,1e,10,00,54,61,73,6b,42,61,72,00,40,00,09,00,04,00,ef,be,9e,58,2c,\
  1e,9e,58,2c,1e,2e,00,00,00,69,a1,01,00,00,00,01,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,22,47,53,00,54,00,61,00,73,00,6b,00,42,00,61,00,72,00,00,\
  00,16,00,c4,00,32,00,86,09,00,00,9e,58,24,1d,20,00,4d,49,43,52,4f,53,7e,31,\
  2e,4c,4e,4b,00,00,56,00,09,00,04,00,ef,be,9e,58,2c,1e,9e,58,2c,1e,2e,00,00,\
  00,6a,a1,01,00,00,00,01,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,05,55,\
  93,00,4d,00,69,00,63,00,72,00,6f,00,73,00,6f,00,66,00,74,00,20,00,45,00,64,\
  00,67,00,65,00,2e,00,6c,00,6e,00,6b,00,00,00,1c,00,12,00,00,00,2b,00,ef,be,\
  de,32,c4,63,b1,9a,da,01,1c,00,1a,00,00,00,1d,00,ef,be,02,00,4d,00,53,00,45,\
  00,64,00,67,00,65,00,00,00,1c,00,26,00,00,00,1e,00,ef,be,02,00,53,00,79,00,\
  73,00,74,00,65,00,6d,00,50,00,69,00,6e,00,6e,00,65,00,64,00,00,00,1c,00,00,\
  00,00,a4,01,00,00,3a,00,1f,80,c8,27,34,1f,10,5c,10,42,aa,03,2e,e4,52,87,d6,\
  68,26,00,01,00,26,00,ef,be,12,00,00,00,ee,08,2d,3c,b1,9a,da,01,de,32,c4,63,\
  b1,9a,da,01,aa,f6,c8,63,b1,9a,da,01,14,00,56,00,31,00,00,00,00,00,9e,58,2c,\
  1e,11,00,54,61,73,6b,42,61,72,00,40,00,09,00,04,00,ef,be,9e,58,2c,1e,9e,58,\
  2c,1e,2e,00,00,00,69,a1,01,00,00,00,01,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,56,83,4e,00,54,00,61,00,73,00,6b,00,42,00,61,00,72,00,00,00,16,00,\
  12,01,32,00,97,01,00,00,87,4f,07,49,20,00,46,49,4c,45,45,58,7e,31,2e,4c,4e,\
  4b,00,00,7c,00,09,00,04,00,ef,be,9e,58,2c,1e,9e,58,2c,1e,2e,00,00,00,6b,a1,\
  01,00,00,00,01,00,00,00,00,00,00,00,00,00,52,00,00,00,00,00,58,9c,44,00,46,\
  00,69,00,6c,00,65,00,20,00,45,00,78,00,70,00,6c,00,6f,00,72,00,65,00,72,00,\
  2e,00,6c,00,6e,00,6b,00,00,00,40,00,73,00,68,00,65,00,6c,00,6c,00,33,00,32,\
  00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,32,00,32,00,30,00,36,00,37,00,00,00,\
  1c,00,12,00,00,00,2b,00,ef,be,aa,f6,c8,63,b1,9a,da,01,1c,00,42,00,00,00,1d,\
  00,ef,be,02,00,4d,00,69,00,63,00,72,00,6f,00,73,00,6f,00,66,00,74,00,2e,00,\
  57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,2e,00,45,00,78,00,70,00,6c,00,6f,\
  00,72,00,65,00,72,00,00,00,1c,00,26,00,00,00,1e,00,ef,be,02,00,53,00,79,00,\
  73,00,74,00,65,00,6d,00,50,00,69,00,6e,00,6e,00,65,00,64,00,00,00,1c,00,00,\
  00,00,4b,06,00,00,14,00,1f,80,9b,d4,34,42,45,02,f3,4d,b7,80,38,93,94,34,56,\
  e1,35,06,00,00,99,05,41,50,50,53,87,05,08,00,03,00,00,00,00,00,00,00,4e,02,\
  00,00,31,53,50,53,55,28,4c,9f,79,9f,39,4b,a8,d0,e1,d4,2d,e1,d5,f3,5d,00,00,\
  00,11,00,00,00,00,1f,00,00,00,25,00,00,00,4d,00,69,00,63,00,72,00,6f,00,73,\
  00,6f,00,66,00,74,00,2e,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,53,00,\
  74,00,6f,00,72,00,65,00,5f,00,38,00,77,00,65,00,6b,00,79,00,62,00,33,00,64,\
  00,38,00,62,00,62,00,77,00,65,00,00,00,00,00,11,00,00,00,0e,00,00,00,00,13,\
  00,00,00,01,00,00,00,85,00,00,00,15,00,00,00,00,1f,00,00,00,39,00,00,00,4d,\
  00,69,00,63,00,72,00,6f,00,73,00,6f,00,66,00,74,00,2e,00,57,00,69,00,6e,00,\
  64,00,6f,00,77,00,73,00,53,00,74,00,6f,00,72,00,65,00,5f,00,31,00,31,00,39,\
  00,31,00,30,00,2e,00,31,00,30,00,30,00,32,00,2e,00,35,00,2e,00,30,00,5f,00,\
  78,00,36,00,34,00,5f,00,5f,00,38,00,77,00,65,00,6b,00,79,00,62,00,33,00,64,\
  00,38,00,62,00,62,00,77,00,65,00,00,00,00,00,65,00,00,00,05,00,00,00,00,1f,\
  00,00,00,29,00,00,00,4d,00,69,00,63,00,72,00,6f,00,73,00,6f,00,66,00,74,00,\
  2e,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,53,00,74,00,6f,00,72,00,65,\
  00,5f,00,38,00,77,00,65,00,6b,00,79,00,62,00,33,00,64,00,38,00,62,00,62,00,\
  77,00,65,00,21,00,41,00,70,00,70,00,00,00,00,00,bd,00,00,00,0f,00,00,00,00,\
  1f,00,00,00,56,00,00,00,43,00,3a,00,5c,00,50,00,72,00,6f,00,67,00,72,00,61,\
  00,6d,00,20,00,46,00,69,00,6c,00,65,00,73,00,5c,00,57,00,69,00,6e,00,64,00,\
  6f,00,77,00,73,00,41,00,70,00,70,00,73,00,5c,00,4d,00,69,00,63,00,72,00,6f,\
  00,73,00,6f,00,66,00,74,00,2e,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,\
  53,00,74,00,6f,00,72,00,65,00,5f,00,31,00,31,00,39,00,31,00,30,00,2e,00,31,\
  00,30,00,30,00,32,00,2e,00,35,00,2e,00,30,00,5f,00,78,00,36,00,34,00,5f,00,\
  5f,00,38,00,77,00,65,00,6b,00,79,00,62,00,33,00,64,00,38,00,62,00,62,00,77,\
  00,65,00,00,00,1d,00,00,00,20,00,00,00,00,48,00,00,00,05,c5,72,a5,af,32,5c,\
  4e,a5,56,c4,94,0b,8a,77,a1,00,00,00,00,8a,02,00,00,31,53,50,53,4d,0b,d4,86,\
  69,90,3c,44,81,9a,2a,54,09,0d,cc,ec,55,00,00,00,0c,00,00,00,00,1f,00,00,00,\
  21,00,00,00,41,00,73,00,73,00,65,00,74,00,73,00,5c,00,41,00,70,00,70,00,54,\
  00,69,00,6c,00,65,00,73,00,5c,00,53,00,74,00,6f,00,72,00,65,00,4d,00,65,00,\
  64,00,54,00,69,00,6c,00,65,00,2e,00,70,00,6e,00,67,00,00,00,00,00,55,00,00,\
  00,02,00,00,00,00,1f,00,00,00,21,00,00,00,41,00,73,00,73,00,65,00,74,00,73,\
  00,5c,00,41,00,70,00,70,00,54,00,69,00,6c,00,65,00,73,00,5c,00,53,00,74,00,\
  6f,00,72,00,65,00,41,00,70,00,70,00,4c,00,69,00,73,00,74,00,2e,00,70,00,6e,\
  00,67,00,00,00,00,00,59,00,00,00,0f,00,00,00,00,1f,00,00,00,23,00,00,00,41,\
  00,73,00,73,00,65,00,74,00,73,00,5c,00,41,00,70,00,70,00,54,00,69,00,6c,00,\
  65,00,73,00,5c,00,53,00,74,00,6f,00,72,00,65,00,42,00,61,00,64,00,67,00,65,\
  00,4c,00,6f,00,67,00,6f,00,2e,00,70,00,6e,00,67,00,00,00,00,00,55,00,00,00,\
  0d,00,00,00,00,1f,00,00,00,22,00,00,00,41,00,73,00,73,00,65,00,74,00,73,00,\
  5c,00,41,00,70,00,70,00,54,00,69,00,6c,00,65,00,73,00,5c,00,53,00,74,00,6f,\
  00,72,00,65,00,57,00,69,00,64,00,65,00,54,00,69,00,6c,00,65,00,2e,00,70,00,\
  6e,00,67,00,00,00,11,00,00,00,04,00,00,00,00,13,00,00,00,00,78,d7,ff,59,00,\
  00,00,13,00,00,00,00,1f,00,00,00,23,00,00,00,41,00,73,00,73,00,65,00,74,00,\
  73,00,5c,00,41,00,70,00,70,00,54,00,69,00,6c,00,65,00,73,00,5c,00,53,00,74,\
  00,6f,00,72,00,65,00,4c,00,61,00,72,00,67,00,65,00,54,00,69,00,6c,00,65,00,\
  2e,00,70,00,6e,00,67,00,00,00,00,00,11,00,00,00,05,00,00,00,00,13,00,00,00,\
  ff,ff,ff,ff,11,00,00,00,0e,00,00,00,00,13,00,00,00,a5,04,00,00,31,00,00,00,\
  0b,00,00,00,00,1f,00,00,00,10,00,00,00,4d,00,69,00,63,00,72,00,6f,00,73,00,\
  6f,00,66,00,74,00,20,00,53,00,74,00,6f,00,72,00,65,00,00,00,59,00,00,00,14,\
  00,00,00,00,1f,00,00,00,23,00,00,00,41,00,73,00,73,00,65,00,74,00,73,00,5c,\
  00,41,00,70,00,70,00,54,00,69,00,6c,00,65,00,73,00,5c,00,53,00,74,00,6f,00,\
  72,00,65,00,53,00,6d,00,61,00,6c,00,6c,00,54,00,69,00,6c,00,65,00,2e,00,70,\
  00,6e,00,67,00,00,00,00,00,00,00,00,00,31,00,00,00,31,53,50,53,b1,16,6d,44,\
  ad,8d,70,48,a7,48,40,2e,a4,3d,78,8c,15,00,00,00,64,00,00,00,00,15,00,00,00,\
  14,01,00,00,00,00,00,00,00,00,00,00,4d,00,00,00,31,53,50,53,30,f1,25,b7,ef,\
  47,1a,10,a5,f1,02,60,8c,9e,eb,ac,31,00,00,00,0a,00,00,00,00,1f,00,00,00,10,\
  00,00,00,4d,00,69,00,63,00,72,00,6f,00,73,00,6f,00,66,00,74,00,20,00,53,00,\
  74,00,6f,00,72,00,65,00,00,00,00,00,00,00,2d,00,00,00,31,53,50,53,b3,77,ed,\
  0d,14,c6,6c,45,ae,5b,28,5b,38,d7,b0,1b,11,00,00,00,07,00,00,00,00,13,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,12,00,00,00,2b,00,ef,be,c8,58,\
  cb,63,b1,9a,da,01,9f,05,5e,00,00,00,1d,00,ef,be,02,00,4d,00,69,00,63,00,72,\
  00,6f,00,73,00,6f,00,66,00,74,00,2e,00,57,00,69,00,6e,00,64,00,6f,00,77,00,\
  73,00,53,00,74,00,6f,00,72,00,65,00,5f,00,38,00,77,00,65,00,6b,00,79,00,62,\
  00,33,00,64,00,38,00,62,00,62,00,77,00,65,00,21,00,41,00,70,00,70,00,00,00,\
  9f,05,26,00,00,00,1e,00,ef,be,02,00,53,00,79,00,73,00,74,00,65,00,6d,00,50,\
  00,69,00,6e,00,6e,00,65,00,64,00,00,00,9f,05,00,00,00,af,06,00,00,14,00,1f,\
  80,9b,d4,34,42,45,02,f3,4d,b7,80,38,93,94,34,56,e1,99,06,00,00,b5,05,41,50,\
  50,53,a3,05,08,00,03,00,00,00,00,00,00,00,f6,02,00,00,31,53,50,53,55,28,4c,\
  9f,79,9f,39,4b,a8,d0,e1,d4,2d,e1,d5,f3,75,00,00,00,11,00,00,00,00,1f,00,00,\
  00,32,00,00,00,6d,00,69,00,63,00,72,00,6f,00,73,00,6f,00,66,00,74,00,2e,00,\
  77,00,69,00,6e,00,64,00,6f,00,77,00,73,00,63,00,6f,00,6d,00,6d,00,75,00,6e,\
  00,69,00,63,00,61,00,74,00,69,00,6f,00,6e,00,73,00,61,00,70,00,70,00,73,00,\
  5f,00,38,00,77,00,65,00,6b,00,79,00,62,00,33,00,64,00,38,00,62,00,62,00,77,\
  00,65,00,00,00,11,00,00,00,0e,00,00,00,00,13,00,00,00,01,00,00,00,a9,00,00,\
  00,15,00,00,00,00,1f,00,00,00,4b,00,00,00,6d,00,69,00,63,00,72,00,6f,00,73,\
  00,6f,00,66,00,74,00,2e,00,77,00,69,00,6e,00,64,00,6f,00,77,00,73,00,63,00,\
  6f,00,6d,00,6d,00,75,00,6e,00,69,00,63,00,61,00,74,00,69,00,6f,00,6e,00,73,\
  00,61,00,70,00,70,00,73,00,5f,00,31,00,36,00,30,00,30,00,35,00,2e,00,31,00,\
  31,00,36,00,32,00,39,00,2e,00,32,00,30,00,33,00,31,00,36,00,2e,00,30,00,5f,\
  00,78,00,36,00,34,00,5f,00,5f,00,38,00,77,00,65,00,6b,00,79,00,62,00,33,00,\
  64,00,38,00,62,00,62,00,77,00,65,00,00,00,00,00,ad,00,00,00,05,00,00,00,00,\
  1f,00,00,00,4d,00,00,00,6d,00,69,00,63,00,72,00,6f,00,73,00,6f,00,66,00,74,\
  00,2e,00,77,00,69,00,6e,00,64,00,6f,00,77,00,73,00,63,00,6f,00,6d,00,6d,00,\
  75,00,6e,00,69,00,63,00,61,00,74,00,69,00,6f,00,6e,00,73,00,61,00,70,00,70,\
  00,73,00,5f,00,38,00,77,00,65,00,6b,00,79,00,62,00,33,00,64,00,38,00,62,00,\
  62,00,77,00,65,00,21,00,6d,00,69,00,63,00,72,00,6f,00,73,00,6f,00,66,00,74,\
  00,2e,00,77,00,69,00,6e,00,64,00,6f,00,77,00,73,00,6c,00,69,00,76,00,65,00,\
  2e,00,6d,00,61,00,69,00,6c,00,00,00,00,00,e1,00,00,00,0f,00,00,00,00,1f,00,\
  00,00,68,00,00,00,43,00,3a,00,5c,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,\
  00,20,00,46,00,69,00,6c,00,65,00,73,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,\
  77,00,73,00,41,00,70,00,70,00,73,00,5c,00,6d,00,69,00,63,00,72,00,6f,00,73,\
  00,6f,00,66,00,74,00,2e,00,77,00,69,00,6e,00,64,00,6f,00,77,00,73,00,63,00,\
  6f,00,6d,00,6d,00,75,00,6e,00,69,00,63,00,61,00,74,00,69,00,6f,00,6e,00,73,\
  00,61,00,70,00,70,00,73,00,5f,00,31,00,36,00,30,00,30,00,35,00,2e,00,31,00,\
  31,00,36,00,32,00,39,00,2e,00,32,00,30,00,33,00,31,00,36,00,2e,00,30,00,5f,\
  00,78,00,36,00,34,00,5f,00,5f,00,38,00,77,00,65,00,6b,00,79,00,62,00,33,00,\
  64,00,38,00,62,00,62,00,77,00,65,00,00,00,1d,00,00,00,20,00,00,00,00,48,00,\
  00,00,a0,07,88,66,ed,fc,34,49,88,1d,9d,b7,35,48,d3,3c,00,00,00,00,12,02,00,\
  00,31,53,50,53,4d,0b,d4,86,69,90,3c,44,81,9a,2a,54,09,0d,cc,ec,49,00,00,00,\
  0c,00,00,00,00,1f,00,00,00,1c,00,00,00,69,00,6d,00,61,00,67,00,65,00,73,00,\
  5c,00,48,00,78,00,4d,00,61,00,69,00,6c,00,4d,00,65,00,64,00,69,00,75,00,6d,\
  00,54,00,69,00,6c,00,65,00,2e,00,70,00,6e,00,67,00,00,00,45,00,00,00,02,00,\
  00,00,00,1f,00,00,00,19,00,00,00,69,00,6d,00,61,00,67,00,65,00,73,00,5c,00,\
  48,00,78,00,4d,00,61,00,69,00,6c,00,41,00,70,00,70,00,4c,00,69,00,73,00,74,\
  00,2e,00,70,00,6e,00,67,00,00,00,00,00,41,00,00,00,0f,00,00,00,00,1f,00,00,\
  00,17,00,00,00,69,00,6d,00,61,00,67,00,65,00,73,00,5c,00,48,00,78,00,4d,00,\
  61,00,69,00,6c,00,42,00,61,00,64,00,67,00,65,00,2e,00,70,00,6e,00,67,00,00,\
  00,00,00,45,00,00,00,0d,00,00,00,00,1f,00,00,00,1a,00,00,00,69,00,6d,00,61,\
  00,67,00,65,00,73,00,5c,00,48,00,78,00,4d,00,61,00,69,00,6c,00,57,00,69,00,\
  64,00,65,00,54,00,69,00,6c,00,65,00,2e,00,70,00,6e,00,67,00,00,00,11,00,00,\
  00,04,00,00,00,00,13,00,00,00,00,78,d7,ff,49,00,00,00,13,00,00,00,00,1f,00,\
  00,00,1b,00,00,00,69,00,6d,00,61,00,67,00,65,00,73,00,5c,00,48,00,78,00,4d,\
  00,61,00,69,00,6c,00,4c,00,61,00,72,00,67,00,65,00,54,00,69,00,6c,00,65,00,\
  2e,00,70,00,6e,00,67,00,00,00,00,00,11,00,00,00,05,00,00,00,00,13,00,00,00,\
  ff,ff,ff,ff,11,00,00,00,0e,00,00,00,00,13,00,00,00,ad,04,00,00,1d,00,00,00,\
  0b,00,00,00,00,1f,00,00,00,05,00,00,00,4d,00,61,00,69,00,6c,00,00,00,00,00,\
  49,00,00,00,14,00,00,00,00,1f,00,00,00,1b,00,00,00,69,00,6d,00,61,00,67,00,\
  65,00,73,00,5c,00,48,00,78,00,4d,00,61,00,69,00,6c,00,53,00,6d,00,61,00,6c,\
  00,6c,00,54,00,69,00,6c,00,65,00,2e,00,70,00,6e,00,67,00,00,00,00,00,00,00,\
  00,00,31,00,00,00,31,53,50,53,b1,16,6d,44,ad,8d,70,48,a7,48,40,2e,a4,3d,78,\
  8c,15,00,00,00,64,00,00,00,00,15,00,00,00,10,01,00,00,00,00,00,00,00,00,00,\
  00,39,00,00,00,31,53,50,53,30,f1,25,b7,ef,47,1a,10,a5,f1,02,60,8c,9e,eb,ac,\
  1d,00,00,00,0a,00,00,00,00,1f,00,00,00,05,00,00,00,4d,00,61,00,69,00,6c,00,\
  00,00,00,00,00,00,00,00,2d,00,00,00,31,53,50,53,b3,77,ed,0d,14,c6,6c,45,ae,\
  5b,28,5b,38,d7,b0,1b,11,00,00,00,07,00,00,00,00,13,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,12,00,00,00,2b,00,ef,be,48,aa,ba,63,b1,9a,da,01,\
  bb,05,a6,00,00,00,1d,00,ef,be,02,00,6d,00,69,00,63,00,72,00,6f,00,73,00,6f,\
  00,66,00,74,00,2e,00,77,00,69,00,6e,00,64,00,6f,00,77,00,73,00,63,00,6f,00,\
  6d,00,6d,00,75,00,6e,00,69,00,63,00,61,00,74,00,69,00,6f,00,6e,00,73,00,61,\
  00,70,00,70,00,73,00,5f,00,38,00,77,00,65,00,6b,00,79,00,62,00,33,00,64,00,\
  38,00,62,00,62,00,77,00,65,00,21,00,6d,00,69,00,63,00,72,00,6f,00,73,00,6f,\
  00,66,00,74,00,2e,00,77,00,69,00,6e,00,64,00,6f,00,77,00,73,00,6c,00,69,00,\
  76,00,65,00,2e,00,6d,00,61,00,69,00,6c,00,00,00,bb,05,26,00,00,00,1e,00,ef,\
  be,02,00,53,00,79,00,73,00,74,00,65,00,6d,00,50,00,69,00,6e,00,6e,00,65,00,\
  64,00,00,00,bb,05,00,00,ff
"FavoritesChanges"=dword:00000008
"FavoritesVersion"=dword:00000003

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband\AuxilliaryPins]
"MailPin"=dword:00000001

; windows widgets from taskbar
[-HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Dsh]

; normal taskbar alignment
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"TaskbarAl"=-

; search from taskbar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search]
"SearchboxTaskbarMode"=-

; task view from taskbar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"ShowTaskViewButton"=-

; chat from taskbar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"TaskbarMn"=-

; copilot from taskbar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"ShowCopilotButton"=-

; news and interests
[-HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Windows Feeds]

; meet now
[-HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer]

; security taskbar icon
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run]
"SecurityHealth"=hex:04,00,00,00,00,00,00,00,00,00,00,00

; don't show all taskbar icons w10 only
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer]
"EnableAutoTray"=-
"@
Set-Content -Path "$env:TEMP\Taskbar Default.reg" -Value $MultilineComment -Force
# import reg file
Set-Location -Path "$env:TEMP"
Regedit.exe /S "Taskbar Default.reg"
# START MENU W11
Remove-Item -Recurse -Force "$env:USERPROFILE\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState\start2.bin" -ErrorAction SilentlyContinue
# START MENU W10
# delete startmenulayout.xml
Remove-Item -Recurse -Force "$env:SystemDrive\Windows\StartMenuLayout.xml" -ErrorAction SilentlyContinue | Out-Null
# create startmenulayout.xml
$MultilineComment = @"
<LayoutModificationTemplate xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout" Version="1" xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification">
  <LayoutOptions StartTileGroupCellWidth="6" />
  <DefaultLayoutOverride>
    <StartLayoutCollection>
      <defaultlayout:StartLayout GroupCellWidth="6">
        <start:Group Name="Productivity">
          <start:Folder Name="" Size="2x2" Column="2" Row="0">
            <start:Tile Size="2x2" Column="4" Row="2" AppUserModelID="Microsoft.Office.OneNote_8wekyb3d8bbwe!microsoft.onenoteim" />
            <start:DesktopApplicationTile Size="2x2" Column="0" Row="2" DesktopApplicationLinkPath="%APPDATA%\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk" />
            <start:Tile Size="2x2" Column="0" Row="4" AppUserModelID="Microsoft.SkypeApp_kzf8qxf38zg5c!App" />
          </start:Folder>
          <start:Tile Size="2x2" Column="0" Row="0" AppUserModelID="Microsoft.MicrosoftOfficeHub_8wekyb3d8bbwe!Microsoft.MicrosoftOfficeHub" />
          <start:DesktopApplicationTile Size="2x2" Column="0" Row="2" DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk" />
          <start:Tile Size="2x2" Column="4" Row="2" AppUserModelID="7EE7776C.LinkedInforWindows_w1wdnht996qgy!App" />
          <start:Tile Size="2x2" Column="4" Row="0" AppUserModelID="microsoft.windowscommunicationsapps_8wekyb3d8bbwe!Microsoft.WindowsLive.Mail" />
          <start:Tile Size="2x2" Column="2" Row="2" AppUserModelID="Microsoft.Windows.Photos_8wekyb3d8bbwe!App" />
        </start:Group>
        <start:Group Name="Explore">
          <start:Folder Name="Play" Size="2x2" Column="4" Row="2">
            <start:Tile Size="2x2" Column="2" Row="0" AppUserModelID="Microsoft.WindowsCalculator_8wekyb3d8bbwe!App" />
            <start:Tile Size="2x2" Column="0" Row="0" AppUserModelID="Clipchamp.Clipchamp_yxz26nhyzhsrt!App" />
          </start:Folder>
          <start:Tile Size="2x2" Column="4" Row="0" AppUserModelID="Microsoft.Todos_8wekyb3d8bbwe!App" />
          <start:Tile Size="2x2" Column="2" Row="2" AppUserModelID="Microsoft.MicrosoftSolitaireCollection_8wekyb3d8bbwe!App" />
          <start:Tile Size="2x2" Column="2" Row="0" AppUserModelID="SpotifyAB.SpotifyMusic_zpdnekdrzrea0!Spotify" />
          <start:Tile Size="2x2" Column="0" Row="2" AppUserModelID="Microsoft.ZuneVideo_8wekyb3d8bbwe!Microsoft.ZuneVideo" />
          <start:Tile Size="2x2" Column="0" Row="0" AppUserModelID="Microsoft.WindowsStore_8wekyb3d8bbwe!App" />
        </start:Group>
      </defaultlayout:StartLayout>
    </StartLayoutCollection>
  </DefaultLayoutOverride>
</LayoutModificationTemplate>
"@
Set-Content -Path "C:\Windows\StartMenuLayout.xml" -Value $MultilineComment -Force -Encoding ASCII
# assign startmenulayout.xml registry
$layoutFile="C:\Windows\StartMenuLayout.xml"
$regAliases = @("HKLM", "HKCU")
foreach ($regAlias in $regAliases){
$basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
$keyPath = $basePath + "\Explorer"
IF(!(Test-Path -Path $keyPath)) {
New-Item -Path $basePath -Name "Explorer" | Out-Null
}
Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 1 | Out-Null
Set-ItemProperty -Path $keyPath -Name "StartLayoutFile" -Value $layoutFile | Out-Null
}
# restart explorer
Stop-Process -Force -Name explorer -ErrorAction SilentlyContinue | Out-Null
Timeout /T 5 | Out-Null
# disable lockedstartlayout registry
foreach ($regAlias in $regAliases){
$basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
$keyPath = $basePath + "\Explorer"
Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 0
}
# restart explorer
Stop-Process -Force -Name explorer -ErrorAction SilentlyContinue | Out-Null
# delete startmenulayout.xml
Remove-Item -Recurse -Force "$env:SystemDrive\Windows\StartMenuLayout.xml" -ErrorAction SilentlyContinue | Out-Null
Clear-Host
Write-Host "Restart to apply . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
exit

      }
    } } else { Write-Host "Invalid input. Please select a valid option (1-2)." } }
