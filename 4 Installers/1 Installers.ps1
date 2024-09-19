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

    function show-menu {
	Clear-Host
	Write-Host "Game launchers, programs and web browsers:"
    Write-Host "-Disable hardware acceleration"
    Write-Host "-Turn off running at startup"
    Write-Host "-Deactivate overlays"
    Write-Host ""
    Write-Host "Lower GPU usage and higher framerates reduce latency."
    Write-Host "Optimize your game settings to achieve this."
    Write-Host "Further tuning can be done via config files or launch options."
	Write-Host ""
    Write-Host " 1. Exit"
    Write-Host " 2. 7-Zip"
    Write-Host " 3. Battle.net"
	Write-Host " 4. Discord"
    Write-Host " 5. Electronic Arts"
    Write-Host " 6. Epic Games"
    Write-Host " 7. Escape From Tarkov"
    Write-Host " 8. GOG launcher"
    Write-Host " 9. Google Chrome"
    Write-Host "10. League Of Legends"
    Write-Host "11. Notepad ++"
    Write-Host "12. OBS Studio"
	Write-Host "13. Roblox"
    Write-Host "14. Rockstar Games"
    Write-Host "15. Steam"
    Write-Host "16. Ubisoft Connect"
    Write-Host "17. Valorant"
	              }
	show-menu
    while ($true) {
    $choice = Read-Host " "
    if ($choice -match '^(1[0-7]|[1-9])$') {
    switch ($choice) {
    1 {

Clear-Host
exit

      }
    2 {

Clear-Host
Write-Host "Installing: 7Zip . . ."
# download 7zip
Get-FileFromWeb -URL "https://github.com/FR33THYFR33THY/files/raw/main/7-Zip.exe" -File "$env:TEMP\7-Zip.exe"
# install 7zip
Start-Process -wait "$env:TEMP\7-Zip.exe" -ArgumentList "/S"
show-menu

      }
    3 {

Clear-Host
Write-Host "Installing: Battle.net . . ."
# download battle.net
Get-FileFromWeb -URL "https://downloader.battle.net/download/getInstaller?os=win&installer=Battle.net-Setup.exe" -File "$env:TEMP\Battle.net.exe"
# install battle.net 
Start-Process "$env:TEMP\Battle.net.exe" -ArgumentList '--lang=enUS --installpath="C:\Program Files (x86)\Battle.net"'
# create battle.net shortcut
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$Home\Desktop\Battle.net.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Program Files (x86)\Battle.net\Battle.net Launcher.exe"
$Shortcut.Save()
show-menu

      }
    4 {

Clear-Host
Write-Host "Installing: Discord . . ."
# download discord
Get-FileFromWeb -URL "https://dl.discordapp.net/distro/app/stable/win/x86/1.0.9036/DiscordSetup.exe" -File "$env:TEMP\Discord.exe"
# install discord
Start-Process -wait "$env:TEMP\Discord.exe" -ArgumentList "/s"
show-menu

      }
    5 {

Clear-Host
Write-Host "Installing: Electronic Arts . . ."
# download electronic arts
Get-FileFromWeb -URL "https://origin-a.akamaihd.net/EA-Desktop-Client-Download/installer-releases/EAappInstaller.exe" -File "$env:TEMP\Electronic Arts.exe"
# install electronic arts
Start-Process "$env:TEMP\Electronic Arts.exe"
show-menu

      }
    6 {

Clear-Host
Write-Host "Installing: Epic Games . . ."
# download epic games
Get-FileFromWeb -URL "https://epicgames-download1.akamaized.net/Builds/UnrealEngineLauncher/Installers/Win32/EpicInstaller-15.17.1.msi?launcherfilename=EpicInstaller-15.17.1.msi" -File "$env:TEMP\Epic Games.msi"
# install epic games
Start-Process -wait "$env:TEMP\Epic Games.msi" -ArgumentList "/quiet"
show-menu

      }
    7 {

Clear-Host
Write-Host "Installing: Escape From Tarkov . . ."
# download escape from tarkov
Get-FileFromWeb -URL "https://prod.escapefromtarkov.com/launcher/download" -File "$env:TEMP\Escape From Tarkov.exe" 
# install escape from tarkov
Start-Process "$env:TEMP\Escape From Tarkov.exe"
show-menu

      }
    8 {

Clear-Host
Write-Host "Installing: GOG launcher . . ."
# download gog launcher
Get-FileFromWeb -URL "https://webinstallers.gog-statics.com/download/GOG_Galaxy_2.0.exe" -File "$env:TEMP\GOG launcher.exe"
# install gog launcher
Start-Process "$env:TEMP\GOG launcher.exe"
show-menu

      }
    9 {

Clear-Host
Write-Host "Installing: Google Chrome . . ."
# download google chrome
Get-FileFromWeb -URL "https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi" -File "$env:TEMP\Chrome.msi"
# install google chrome
Start-Process -wait "$env:TEMP\Chrome.msi" -ArgumentList "/quiet"
# open ublock origin in web browser
Start-Process "C:\Program Files\Google\Chrome\Application\chrome.exe" "https://chromewebstore.google.com/detail/ublock-origin/cjpalhdlnbpafiamejdnhcphjbkeiagm"
show-menu

      }
   10 {

Clear-Host
Write-Host "Installing: League Of Legends . . ."
# download league of legends
Get-FileFromWeb -URL "https://lol.secure.dyn.riotcdn.net/channels/public/x/installer/current/live.na.exe" -File "$env:TEMP\League Of Legends.exe"
# install league of legends
Start-Process "$env:TEMP\League Of Legends.exe"
show-menu

      }
   11 {

Clear-Host
Write-Host "Installing: Notepad ++ . . ."
# download notepad ++
Get-FileFromWeb -URL "https://github.com/FR33THYFR33THY/files/raw/main/Notepad%20++.exe" -File "$env:TEMP\Notepad ++.exe"
# install notepad ++
Start-Process -wait "$env:TEMP\Notepad ++.exe" -ArgumentList "/S"
show-menu

      }
   12 {

Clear-Host
Write-Host "Installing: OBS Studio . . ."
# download obs studio
Get-FileFromWeb -URL "https://github.com/obsproject/obs-studio/releases/download/30.2.3/OBS-Studio-30.2.3-Windows-Installer.exe" -File "$env:TEMP\OBS Studio.exe"
# install obs studio
Start-Process -wait "$env:TEMP\OBS Studio.exe" -ArgumentList "/S"
show-menu

      }
   13 {

Clear-Host
Write-Host "Installing: Roblox . . ."
# download roblox
Get-FileFromWeb -URL "https://www.roblox.com/download/client?os=win" -File "$env:TEMP\Roblox.exe"
# install roblox
Start-Process "$env:TEMP\Roblox.exe"
show-menu

      }
   14 {

Clear-Host
Write-Host "Installing: Rockstar Games . . ."
# download rockstar games
Get-FileFromWeb -URL "https://gamedownloads.rockstargames.com/public/installer/Rockstar-Games-Launcher.exe" -File "$env:TEMP\Rockstar Games.exe"
# install rockstar games
Start-Process "$env:TEMP\Rockstar Games.exe"
show-menu

      }
   15 {

Clear-Host
Write-Host "Installing: Steam . . ."
# download steam
Get-FileFromWeb -URL "https://cdn.cloudflare.steamstatic.com/client/installer/SteamSetup.exe" -File "$env:TEMP\Steam.exe"
# install steam
Start-Process -wait "$env:TEMP\Steam.exe" -ArgumentList "/S"
show-menu

      }
   16 {

Clear-Host
Write-Host "Installing: Ubisoft Connect . . ."
# download ubisoft connect
Get-FileFromWeb -URL "https://static3.cdn.ubi.com/orbit/launcher_installer/UbisoftConnectInstaller.exe" -File "$env:TEMP\Ubisoft Connect.exe"
# install ubisoft connect
Start-Process -wait "$env:TEMP\Ubisoft Connect.exe" -ArgumentList "/S"
show-menu

      }
   17 {

Clear-Host
Write-Host "Installing: Valorant . . ."
# download valorant
Get-FileFromWeb -URL "https://valorant.secure.dyn.riotcdn.net/channels/public/x/installer/current/live.live.ap.exe" -File "$env:TEMP\Valorant.exe"
# install valorant 
Start-Process "$env:TEMP\Valorant.exe"
show-menu

      }
    } } else { Write-Host "Invalid input. Please select a valid option (1-17)." } }
