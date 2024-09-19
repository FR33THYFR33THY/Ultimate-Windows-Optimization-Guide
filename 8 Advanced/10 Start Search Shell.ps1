    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
    {Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit}
    $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " (Administrator)"
    $Host.UI.RawUI.BackgroundColor = "Black"
	$Host.PrivateData.ProgressBackgroundColor = "Black"
    $Host.PrivateData.ProgressForegroundColor = "White"
    Clear-Host

    Write-Host "1. Start Search Shell: Off"
    Write-Host "2. Start Search Shell: Default"
    while ($true) {
    $choice = Read-Host " "
    if ($choice -match '^[1-2]$') {
    switch ($choice) {
    1 {

Clear-Host
Write-Host "This script does not support Wi-Fi & Bluetooth." -ForegroundColor Red
Write-Host "If your PC depends on Wi-Fi or Bluetooth, please close this window!" -ForegroundColor Red
Write-Host ""
Write-Host "This script will intentionally disable start, search, shell and mobsync." -ForegroundColor Red
Write-Host "Start, search, shell and taskbar menus along with their flyouts will not function." -ForegroundColor Red
Write-Host "Certain programs, settings and options may encounter issues or fail to run." -ForegroundColor Red
Write-Host "If you experience any problems, please switch back to (Start Search Shell: Default)." -ForegroundColor Red
Write-Host ""
Write-Host "If Windows fails to boot or log in after applying this script," -ForegroundColor Red
Write-Host "please access your restore point from the advanced setup recovery menu." -ForegroundColor Red
Write-Host ""
Pause
Clear-Host
# check if the volume shadow copy service (vss) is set to manual
$service = Get-Service -Name VSS
if ($service.StartType -eq "Manual") {
Write-Host "Create a restore point . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
# open system protection
Start-Process "C:\Windows\System32\control.exe" -ArgumentList "sysdm.cpl ,4"
Write-Host ""
Pause
}
Clear-Host
Write-Host "Start Search Shell: Off. Please wait . . ."
# takeownership of folders
cmd /c "takeown.exe /f C:\Windows\SystemApps\MicrosoftWindows.Client.CBS_cw5n1h2txyewy >nul 2>&1"
cmd /c "icacls.exe C:\Windows\SystemApps\MicrosoftWindows.Client.CBS_cw5n1h2txyewy /grant *S-1-3-4:F /t /q >nul 2>&1"
cmd /c "takeown.exe /f C:\Windows\SystemApps\Microsoft.Windows.Search_cw5n1h2txyewy >nul 2>&1"
cmd /c "icacls.exe C:\Windows\SystemApps\Microsoft.Windows.Search_cw5n1h2txyewy /grant *S-1-3-4:F /t /q >nul 2>&1"
cmd /c "takeown.exe /f C:\Windows\SystemApps\ShellExperienceHost_cw5n1h2txyewy >nul 2>&1"
cmd /c "icacls.exe C:\Windows\SystemApps\ShellExperienceHost_cw5n1h2txyewy /grant *S-1-3-4:F /t /q >nul 2>&1"
cmd /c "takeown.exe /f C:\Windows\SystemApps\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy >nul 2>&1"
cmd /c "icacls.exe C:\Windows\SystemApps\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy /grant *S-1-3-4:F /t /q >nul 2>&1"
cmd /c "takeown.exe /f C:\Windows\System32\mobsync.exe >nul 2>&1"
cmd /c "icacls.exe C:\Windows\System32\mobsync.exe /grant *S-1-3-4:F /t /q >nul 2>&1"
# stop tasks
cmd /c "taskkill /F /IM AccountsServiceProduct.exe >nul 2>&1"
cmd /c "taskkill /F /IM DesktopSpotlightProduct.exe >nul 2>&1"
cmd /c "taskkill /F /IM DesktopStickerEditorWin32Exe.exe >nul 2>&1"
cmd /c "taskkill /F /IM FESearchHost.exe >nul 2>&1"
cmd /c "taskkill /F /IM IrisServiceProduct.exe >nul 2>&1"
cmd /c "taskkill /F /IM LogonWebHostProduct.exe >nul 2>&1"
cmd /c "taskkill /F /IM MiniSearchHost.exe >nul 2>&1"
cmd /c "taskkill /F /IM RulesEngineProduct.exe >nul 2>&1"
cmd /c "taskkill /F /IM ScreenClippingHost.exe >nul 2>&1"
cmd /c "taskkill /F /IM SearchApp.exe >nul 2>&1"
cmd /c "taskkill /F /IM SearchHost.exe >nul 2>&1"
cmd /c "taskkill /F /IM ShellExperienceHost.exe >nul 2>&1"
cmd /c "taskkill /F /IM StartMenuExperienceHost.exe >nul 2>&1"
cmd /c "taskkill /F /IM TextInputHost.exe >nul 2>&1"
cmd /c "taskkill /F /IM WebExperienceHostApp.exe >nul 2>&1"
cmd /c "taskkill /F /IM WindowsBackupClient.exe >nul 2>&1"
cmd /c "taskkill /F /IM backgroundTaskHost.exe >nul 2>&1"
cmd /c "taskkill /F /IM explorer.exe >nul 2>&1"
cmd /c "taskkill /F /IM mobsync.exe >nul 2>&1"
cmd /c "taskkill /F /IM smartscreen.exe >nul 2>&1"
# move folders
cmd /c "move /y C:\Windows\SystemApps\MicrosoftWindows.Client.CBS_cw5n1h2txyewy C:\Windows >nul 2>&1"
cmd /c "move /y C:\Windows\SystemApps\Microsoft.Windows.Search_cw5n1h2txyewy C:\Windows >nul 2>&1"
cmd /c "move /y C:\Windows\SystemApps\ShellExperienceHost_cw5n1h2txyewy C:\Windows >nul 2>&1"
cmd /c "move /y C:\Windows\SystemApps\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy C:\Windows >nul 2>&1"
cmd /c "move /y C:\Windows\System32\mobsync.exe C:\Windows >nul 2>&1"
# disable uwp search completely w11 regedit
cmd /c "reg add `"HKLM\SOFTWARE\Microsoft\PolicyManager\default\Search\DisableSearch`" /v `"value`" /t REG_DWORD /d `"1`" /f >nul 2>&1"
cmd /c "reg add `"HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search`" /v `"DisableSearch`" /t REG_DWORD /d `"1`" /f >nul 2>&1"
# disable uwp search box taskbar w10 regedit
cmd /c "reg add `"HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search`" /v `"SearchboxTaskbarMode`" /t REG_DWORD /d `"0`" /f >nul 2>&1"
# disable legacy search service regedit
cmd /c "reg add `"HKLM\SYSTEM\ControlSet001\Services\WSearch`" /v `"Start`" /t REG_DWORD /d `"4`" /f >nul 2>&1"
# start explorer
cmd /c "start explorer.exe >nul 2>&1"
# pause so search service will stop
Start-Sleep 15
# stop legacy search service
cmd /c "sc stop WSearch >nul 2>&1"
exit

      }
    2 {

Clear-Host
Write-Host "Start Search Shell: Default. Please wait . . ."
# takeownership of folders
cmd /c "takeown.exe /f C:\Windows\MicrosoftWindows.Client.CBS_cw5n1h2txyewy >nul 2>&1"
cmd /c "icacls.exe C:\Windows\MicrosoftWindows.Client.CBS_cw5n1h2txyewy /grant *S-1-3-4:F /t /q >nul 2>&1"
cmd /c "takeown.exe /f C:\Windows\Microsoft.Windows.Search_cw5n1h2txyewy >nul 2>&1"
cmd /c "icacls.exe C:\Windows\Microsoft.Windows.Search_cw5n1h2txyewy /grant *S-1-3-4:F /t /q >nul 2>&1"
cmd /c "takeown.exe /f C:\Windows\ShellExperienceHost_cw5n1h2txyewy >nul 2>&1"
cmd /c "icacls.exe C:\Windows\ShellExperienceHost_cw5n1h2txyewy /grant *S-1-3-4:F /t /q >nul 2>&1"
cmd /c "takeown.exe /f C:\Windows\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy >nul 2>&1"
cmd /c "icacls.exe C:\Windows\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy /grant *S-1-3-4:F /t /q >nul 2>&1"
cmd /c "takeown.exe /f C:\Windows\mobsync.exe >nul 2>&1"
cmd /c "icacls.exe C:\Windows\mobsync.exe /grant *S-1-3-4:F /t /q >nul 2>&1"
# move folders
cmd /c "move /y C:\Windows\MicrosoftWindows.Client.CBS_cw5n1h2txyewy C:\Windows\SystemApps >nul 2>&1"
cmd /c "move /y C:\Windows\Microsoft.Windows.Search_cw5n1h2txyewy C:\Windows\SystemApps >nul 2>&1"
cmd /c "move /y C:\Windows\ShellExperienceHost_cw5n1h2txyewy C:\Windows\SystemApps >nul 2>&1"
cmd /c "move /y C:\Windows\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy C:\Windows\SystemApps >nul 2>&1"
cmd /c "move /y C:\Windows\mobsync.exe C:\Windows\System32 >nul 2>&1"
# enable uwp search completely w11 regedit
cmd /c "reg add `"HKLM\SOFTWARE\Microsoft\PolicyManager\default\Search\DisableSearch`" /v `"value`" /t REG_DWORD /d `"0`" /f >nul 2>&1"
cmd /c "reg delete `"HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search`" /f >nul 2>&1"
# enable uwp search box taskbar w10 regedit
cmd /c "reg delete `"HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search`" /v `"SearchboxTaskbarMode`" /f >nul 2>&1"
# enable legacy search service regedit
cmd /c "reg add `"HKLM\SYSTEM\ControlSet001\Services\WSearch`" /v `"Start`" /t REG_DWORD /d `"2`" /f >nul 2>&1"
# stop explorer
cmd /c "taskkill /F /IM explorer.exe >nul 2>&1"
# start explorer
cmd /c "start explorer.exe >nul 2>&1"
# pause so search service will start
Start-Sleep 15
# start legacy search service
cmd /c "sc stop WSearch >nul 2>&1"
exit

      }
    } } else { Write-Host "Invalid input. Please select a valid option (1-2)." } }
