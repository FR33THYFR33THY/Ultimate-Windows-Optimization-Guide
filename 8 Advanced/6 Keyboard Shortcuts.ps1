    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
    {Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit}
    $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " (Administrator)"
    $Host.UI.RawUI.BackgroundColor = "Black"
	$Host.PrivateData.ProgressBackgroundColor = "Black"
    $Host.PrivateData.ProgressForegroundColor = "White"
    Clear-Host

    Write-Host "1. Keyboard Shortcuts: Off"
    Write-Host "2. Keyboard Shortcuts: Default"
    while ($true) {
    $choice = Read-Host " "
    if ($choice -match '^[1-2]$') {
    switch ($choice) {
    1 {

Clear-Host
Write-Host "Keyboard Shortcuts: Off" -ForegroundColor Red
Write-Host ""
Write-Host "-disable all keyboard shortcuts" -ForegroundColor Red
Write-Host "-to prevent tabbing out of a game" -ForegroundColor Red
Write-Host "-cut copy paste will function" -ForegroundColor Red
Write-Host "-esc rebound to =" -ForegroundColor Red
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Clear-Host
# disable media keys (human interface device service) regedit
reg add "HKLM\SYSTEM\ControlSet001\Services\hidserv" /v "Start" /t REG_DWORD /d "4" /f | Out-Null
# disable windows key hotkeys regedit
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoWinKeys" /t REG_DWORD /d "1" /f | Out-Null
# disable shortcut keys regedit
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "DisabledHotkeys" /t REG_DWORD /d "1" /f | Out-Null
# disable win alt esc keys regedit
# esc rebound to =
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Keyboard Layout" /v "Scancode Map" /t REG_BINARY /d "00000000000000000700000000005be000005ce000003800000038e00000010001000d0000000000" /f | Out-Null
Clear-Host
Write-Host "Restart to apply . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
exit

      }
    2 {

Clear-Host
# enable media keys (human interface device service) regedit
reg add "HKLM\SYSTEM\ControlSet001\Services\hidserv" /v "Start" /t REG_DWORD /d "3" /f | Out-Null
# enable windows key hotkeys regedit
cmd /c "reg delete `"HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer`" /v `"NoWinKeys`" /f >nul 2>&1"
# enable shortcut keys regedit
cmd /c "reg delete `"HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced`" /v `"DisabledHotkeys`" /f >nul 2>&1"
# enable win alt esc keys regedit
cmd /c "reg delete `"HKLM\SYSTEM\CurrentControlSet\Control\Keyboard Layout`" /v `"Scancode Map`" /f >nul 2>&1"
Clear-Host
Write-Host "Restart to apply . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
exit

      }
    } } else { Write-Host "Invalid input. Please select a valid option (1-2)." } }
