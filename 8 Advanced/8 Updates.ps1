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

    Write-Host "1. Updates: Off"
    Write-Host "2. Updates: Default"
    while ($true) {
    $choice = Read-Host " "
    if ($choice -match '^[1-2]$') {
    switch ($choice) {
    1 {

Clear-Host
Write-Host "Updates: Off. Please wait . . ."
# download lgpo
Get-FileFromWeb -URL "https://download.microsoft.com/download/8/5/C/85C25433-A1B0-4FFA-9429-7E023E7DA8D8/LGPO.zip" -File "$env:TEMP\LGPO.zip"
# extract files
Expand-Archive "$env:TEMP\LGPO.zip" -DestinationPath "$env:TEMP" -ErrorAction SilentlyContinue
# create disableupdates config for lgpo
$MultilineComment = @"
Computer
Software\Policies\Microsoft\Windows\WindowsUpdate
WUServer
SZ:https://fuckyoumicrosoft.com/

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate
WUStatusServer
SZ:https://fuckyoumicrosoft.com/

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate
UpdateServiceUrlAlternate
SZ:https://fuckyoumicrosoft.com/

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate
FillEmptyContentUrls
DELETE

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate
SetDisableUXWUAccess
DWORD:1

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate
DoNotConnectToWindowsUpdateInternetLocations
DWORD:1

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate
ExcludeWUDriversInQualityUpdate
DWORD:1

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate\AU
NoAutoUpdate
DWORD:1

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate\AU
AUOptions
DELETE

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate\AU
AutomaticMaintenanceEnabled
DELETE

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate\AU
ScheduledInstallDay
DELETE

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate\AU
ScheduledInstallTime
DELETE

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate\AU
ScheduledInstallEveryWeek
DELETE

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate\AU
ScheduledInstallFirstWeek
DELETE

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate\AU
ScheduledInstallSecondWeek
DELETE

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate\AU
ScheduledInstallThirdWeek
DELETE

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate\AU
ScheduledInstallFourthWeek
DELETE

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate\AU
AllowMUUpdateService
DELETE

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate\AU
UseWUServer
DWORD:1
"@
Set-Content -Path "$env:TEMP\LGPO_30\DisableUpdates.txt" -Value $MultilineComment -Force
# import config lgpo
Start-Process -wait "$env:TEMP\LGPO_30\lgpo.exe" -ArgumentList "/t $env:TEMP\LGPO_30\DisableUpdates.txt" -WindowStyle Hidden
# update policies
gpupdate /force | Out-Null
Clear-Host
Write-Host "Restart to apply . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Start-Process ms-settings:windowsupdate
exit

      }
    2 {

Clear-Host
Write-Host "Updates: Default. Please wait . . ."
# download lgpo
Get-FileFromWeb -URL "https://download.microsoft.com/download/8/5/C/85C25433-A1B0-4FFA-9429-7E023E7DA8D8/LGPO.zip" -File "$env:TEMP\LGPO.zip"
# extract files
Expand-Archive "$env:TEMP\LGPO.zip" -DestinationPath "$env:TEMP" -ErrorAction SilentlyContinue
# create enableupdates config for lgpo
$MultilineComment = @"
Computer
Software\Policies\Microsoft\Windows\WindowsUpdate
WUServer
CLEAR

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate
WUStatusServer
CLEAR

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate
UpdateServiceUrlAlternate
CLEAR

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate
FillEmptyContentUrls
CLEAR

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate
SetDisableUXWUAccess
CLEAR

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate
DoNotConnectToWindowsUpdateInternetLocations
CLEAR

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate
ExcludeWUDriversInQualityUpdate
CLEAR

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate\AU
NoAutoUpdate
CLEAR

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate\AU
AUOptions
CLEAR

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate\AU
AutomaticMaintenanceEnabled
CLEAR

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate\AU
ScheduledInstallDay
CLEAR

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate\AU
ScheduledInstallTime
CLEAR

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate\AU
ScheduledInstallEveryWeek
CLEAR

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate\AU
ScheduledInstallFirstWeek
CLEAR

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate\AU
ScheduledInstallSecondWeek
CLEAR

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate\AU
ScheduledInstallThirdWeek
CLEAR

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate\AU
ScheduledInstallFourthWeek
CLEAR

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate\AU
AllowMUUpdateService
CLEAR

Computer
Software\Policies\Microsoft\Windows\WindowsUpdate\AU
UseWUServer
CLEAR
"@
Set-Content -Path "$env:TEMP\LGPO_30\EnableUpdates.txt" -Value $MultilineComment -Force
# import config lgpo
Start-Process -wait "$env:TEMP\LGPO_30\lgpo.exe" -ArgumentList "/t $env:TEMP\LGPO_30\EnableUpdates.txt" -WindowStyle Hidden
# OVERKILL W11 BUG NOT RESETTING POLICIES
# delete group policy folders
cmd /c "RD /S /Q `"%WinDir%\System32\GroupPolicyUsers`" >nul 2>&1"
cmd /c "RD /S /Q `"%WinDir%\System32\GroupPolicy`" >nul 2>&1"
# delete policies regedit
cmd /c "reg delete `"HKLM\SOFTWARE\Microsoft\WindowsUpdate\UpdatePolicy`" /f >nul 2>&1"
# update policies
gpupdate /force | Out-Null
Clear-Host
Write-Host "Restart to apply . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Start-Process ms-settings:windowsupdate
exit

      }
    } } else { Write-Host "Invalid input. Please select a valid option (1-2)." } }