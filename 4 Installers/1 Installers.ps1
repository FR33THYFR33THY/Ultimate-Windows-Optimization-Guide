        # SCRIPT RUN AS ADMIN
        If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
        {Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
        Exit}
        $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " (Administrator)"
        $Host.UI.RawUI.BackgroundColor = "Black"
        $Host.PrivateData.ProgressBackgroundColor = "Black"
        $Host.PrivateData.ProgressForegroundColor = "White"
        Clear-Host

        # SCRIPT CHECK INTERNET
        if (!(Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet -ErrorAction SilentlyContinue)) {
        Write-Host "Internet Connection Required`n" -ForegroundColor Red
        Pause
        exit
        }

        # FUNCTION FASTER DOWNLOADS % BAR
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
        if ($response.StatusCode -eq 401 -or $response.StatusCode -eq 403 -or $response.StatusCode -eq 404) { throw "401, 403 or 404 '$URL'." }
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
        Write-Host "- Disable hardware acceleration"
        Write-Host "- Turn off running at startup"
        Write-Host "- Deactivate overlays`n"
        Write-Host "Lower GPU usage and higher framerates reduce latency"
        Write-Host "Optimize your game settings to achieve this"
        Write-Host "Further tuning can be done via config files or launch options`n"
        Write-Host " 1. Exit"
	    Write-Host " 2. Discord"
	    Write-Host " 3. Roblox"
        Write-Host " 4. 7-Zip"
        Write-Host " 5. Battle.net"
        Write-Host " 6. Brave"
        Write-Host " 7. Electronic Arts"
        Write-Host " 8. Epic Games"
        Write-Host " 9. Escape From Tarkov"
        Write-Host "10. Firefox"
        Write-Host "11. Frame View"		
        Write-Host "12. GOG launcher"
        Write-Host "13. Google Chrome"
        Write-Host "14. League Of Legends"
        Write-Host "15. Notepad ++"
        Write-Host "16. Nvidia App"
        Write-Host "17. OBS Studio"
        Write-Host "18. Onboard Memory Manager"
		Write-Host "19. Pot Player"		
        Write-Host "20. Rockstar Games"
        Write-Host "21. Spotify"
        Write-Host "22. Steam"
        Write-Host "23. Ubisoft Connect"
        Write-Host "24. Valorant`n"
	                  }
	    show-menu
        while ($true) {
        $choice = Read-Host " "
        if ($choice -match '^(2[0-4]|1[0-9]|[1-9])$') {
        switch ($choice) {
        1 {

Clear-Host

exit

          }
        2 {

Clear-Host

Write-Host "Installing: Discord..."

# set config for discord
New-Item -Path "$env:APPDATA\discord\settings.json" -ItemType File -Force | Out-Null
$DiscordSettings = @'
{
    "SKIP_HOST_UPDATE": true,
    "DEVELOPER_MODE": true,
    "enableHardwareAcceleration": false,
    "MINIMIZE_TO_TRAY": true,
    "OPEN_ON_STARTUP": false,
    "START_MINIMIZED": false,
    "IS_MAXIMIZED": true,
    "IS_MINIMIZED": false,
    "debugLogging": false
}
'@
Set-Content -Path "$env:APPDATA\discord\settings.json" -Value $DiscordSettings -Force | Out-Null

# download discord				  
Get-FileFromWeb -URL "https://discord.com/api/downloads/distributions/app/installers/latest?channel=stable&platform=win&arch=x64" -File "$env:SystemRoot\Temp\Discord.exe"

# install discord	
Start-Process "$env:SystemRoot\Temp\Discord.exe"

show-menu

          }
        3 {

Clear-Host

Write-Host "Installing: Roblox..."

# download roblox
Get-FileFromWeb -URL "https://www.roblox.com/download/client?os=win" -File "$env:SystemRoot\Temp\Roblox.exe"

# install roblox
Start-Process "$env:SystemRoot\Temp\Roblox.exe" -ArgumentList "/S"

show-menu

          }
        4 {

Clear-Host

Write-Host "Installing: 7Zip..."

# download 7zip
Get-FileFromWeb -URL "https://www.7-zip.org/a/7z2301-x64.exe" -File "$env:SystemRoot\Temp\7 Zip.exe"

# install 7zip
Start-Process -Wait "$env:SystemRoot\Temp\7 Zip.exe" -ArgumentList "/S"

# set config for 7zip
cmd /c "reg add `"HKEY_CURRENT_USER\Software\7-Zip\Options`" /v `"ContextMenu`" /t REG_DWORD /d `"259`" /f >nul 2>&1"
cmd /c "reg add `"HKEY_CURRENT_USER\Software\7-Zip\Options`" /v `"CascadedMenu`" /t REG_DWORD /d `"0`" /f >nul 2>&1"

# cleaner start menu shortcut path
Move-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\7-Zip\7-Zip File Manager.lnk" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force -ErrorAction SilentlyContinue | Out-Null
Remove-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\7-Zip" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

# create 7zip shortcut
$WshShell = New-Object -comObject WScript.Shell
$Desktop = (New-Object -ComObject Shell.Application).Namespace('shell:Desktop').Self.Path
$Shortcut = $WshShell.CreateShortcut("$Desktop\7-Zip File Manager.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Program Files\7-Zip\7zFM.exe"
$Shortcut.WorkingDirectory = "$env:SystemDrive\Program Files\7-Zip"
$Shortcut.Save()

show-menu

          }
        5 {

Clear-Host

Write-Host "Installing: Battle.net..."

# download battle.net
Get-FileFromWeb -URL "https://downloader.battle.net/download/getInstaller?os=win&installer=Battle.net-Setup.exe" -File "$env:SystemRoot\Temp\Battle.net.exe"

# install battle.net 
Start-Process "$env:SystemRoot\Temp\Battle.net.exe" -ArgumentList '--lang=enUS --installpath="C:\Program Files (x86)\Battle.net"'

show-menu

          }
        6 {

Clear-Host

Write-Host "Installing: Brave..."

# download brave
Get-FileFromWeb -URL "https://brave-browser-downloads.s3.brave.com/latest/brave_installer-x64.exe" -File "$env:SystemRoot\Temp\BraveInstaller.exe"

# install brave
Start-Process "$env:SystemRoot\Temp\BraveInstaller.exe" -ArgumentList "--system-level" -Wait

# install ublock origin
cmd /c "reg add `"HKLM\SOFTWARE\Policies\BraveSoftware\Brave\ExtensionInstallForcelist`" /v `"1`" /t REG_SZ /d `"cjpalhdlnbpafiamejdnhcphjbkeiagm;https://clients2.google.com/service/update2/crx`" /f >nul 2>&1"

# add brave policies
cmd /c "reg add `"HKLM\SOFTWARE\Policies\BraveSoftware\Brave`" /v `"HardwareAccelerationModeEnabled`" /t REG_DWORD /d `"0`" /f >nul 2>&1"
cmd /c "reg add `"HKLM\SOFTWARE\Policies\BraveSoftware\Brave`" /v `"BackgroundModeEnabled`" /t REG_DWORD /d `"0`" /f >nul 2>&1"
cmd /c "reg add `"HKLM\SOFTWARE\Policies\BraveSoftware\Brave`" /v `"HighEfficiencyModeEnabled`" /t REG_DWORD /d `"1`" /f >nul 2>&1"

# remove logon brave
$basePath = "HKLM:\Software\Microsoft\Active Setup\Installed Components"
Get-ChildItem $basePath | ForEach-Object {
$val = (Get-ItemProperty $_.PsPath)."(default)"
if ($val -like "*Brave*") {
Remove-Item $_.PsPath -Force -ErrorAction SilentlyContinue
}
}

# remove brave services
$services = Get-Service | Where-Object { $_.Name -match 'Brave' }
foreach ($service in $services) {
cmd /c "sc stop `"$($service.Name)`" >nul 2>&1"
cmd /c "sc delete `"$($service.Name)`" >nul 2>&1"
}

# remove brave scheduled tasks
Get-ScheduledTask | Where-Object { $_.TaskName -like '*Brave*' } | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue

show-menu

          }
        7 {

Clear-Host

Write-Host "Installing: Electronic Arts..."

# download electronic arts
Get-FileFromWeb -URL "https://origin-a.akamaihd.net/EA-Desktop-Client-Download/installer-releases/EAappInstaller.exe" -File "$env:SystemRoot\Temp\Electronic Arts.exe"

# install electronic arts
Start-Process "$env:SystemRoot\Temp\Electronic Arts.exe"

show-menu

          }
        8 {

Clear-Host

Write-Host "Installing: Epic Games..."

# download epic games
Get-FileFromWeb -URL "https://launcher-public-service-prod06.ol.epicgames.com/launcher/api/installer/download/EpicGamesLauncherInstaller.msi" -File "$env:SystemRoot\Temp\Epic Games.msi"

# install epic games
Start-Process -Wait "$env:SystemRoot\Temp\Epic Games.msi" -ArgumentList "/quiet"

Clear-Host
Write-Host "Close: Epic Games After Update" -ForegroundColor Red

# open epic games to update and install epic online services
Start-Process -Wait "$env:SystemDrive\Program Files\Epic Games\Launcher\Portal\Binaries\Win64\EpicGamesLauncher.exe"

Clear-Host
Write-Host "Uninstall: Epic Online Services..."

# uninstall epic online services
$FindEpicOnlineServices = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
$EpicOnlineServices = Get-ItemProperty $FindEpicOnlineServices -ErrorAction SilentlyContinue |
Where-Object { $_.DisplayName -like "*Epic Online Services*" }
if ($EpicOnlineServices) {
$guid = $EpicOnlineServices.PSChildName
Start-Process "msiexec.exe" -ArgumentList "/x $guid /qn" -Wait -NoNewWindow
}

# remove logon epic games
cmd /c "reg delete `"HKCU\Software\Microsoft\Windows\CurrentVersion\Run`" /v `"EpicGamesLauncher`" /f >nul 2>&1"

show-menu

          }
        9 {

Clear-Host

Write-Host "Installing: Escape From Tarkov..."

# download escape from tarkov
Get-FileFromWeb -URL "https://prod.escapefromtarkov.com/launcher/download" -File "$env:SystemRoot\Temp\Escape From Tarkov.exe"

# install escape from tarkov
Start-Process -Wait "$env:SystemRoot\Temp\Escape From Tarkov.exe" -ArgumentList "/VERYSILENT /NORESTART"

# create escape from tarkov shortcut
$WshShell = New-Object -comObject WScript.Shell
$Desktop = (New-Object -ComObject Shell.Application).Namespace('shell:Desktop').Self.Path
$Shortcut = $WshShell.CreateShortcut("$Desktop\Battlestate Games Launcher.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Battlestate Games\BsgLauncher\BsgLauncher.exe"
$Shortcut.WorkingDirectory = "$env:SystemDrive\Battlestate Games\BsgLauncher"
$Shortcut.Save()

# cleaner start menu shortcut path
Move-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Battlestate Games\Battlestate Games Launcher.lnk" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force -ErrorAction SilentlyContinue | Out-Null
Remove-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Battlestate Games" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

show-menu

          }
       10 {

Clear-Host

Write-Host "Installing: Firefox..."

# download firefox
Get-FileFromWeb -URL "https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=en-US" -File "$env:SystemRoot\Temp\Firefox.exe"

# install firefox
Start-Process -Wait "$env:SystemRoot\Temp\Firefox.exe" -ArgumentList "/S"

# uninstall mozilla maintenance service
Start-Process -FilePath "C:\Program Files (x86)\Mozilla Maintenance Service\uninstall.exe" -ArgumentList "/S" -WindowStyle Hidden -Wait

# remove firefox scheduled tasks
Get-ScheduledTask | Where-Object {$_.Taskname -match 'Firefox'} | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue

# install ublock origin
$uBlockDir = "C:\Program Files\Mozilla Firefox\distribution\extensions"
If (!(Test-Path $ublockDir)) { New-Item -ItemType Directory -Path $ublockDir -Force | Out-Null }
Get-FileFromWeb -URL "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi" -File "$uBlockDir\uBlock0@raymondhill.net.xpi"

# disable firefox updates
cmd /c "reg add `"HKLM\SOFTWARE\Policies\Mozilla\Firefox`" /v `"AppAutoUpdate`" /t REG_DWORD /d `"0`" /f >nul 2>&1"

# start and close firefox hidden to create profiles folder
Start-Process -FilePath "$env:SystemDrive\Program Files\Mozilla Firefox\firefox.exe" -ArgumentList "--headless"
Start-Sleep -Seconds 5
Stop-Process -Name "firefox" -Force -ErrorAction SilentlyContinue

# disable firefox hardware acceleration
$JsFile = @'
user_pref("layers.acceleration.disabled", true);
user_pref("gfx.direct2d.disabled", true);
'@
$FireFoxProfile = Get-ChildItem "$env:APPDATA\Mozilla\Firefox\Profiles" -Directory | Where-Object { $_.Name -match '\.default-release$' } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($FireFoxProfile) {
[System.IO.File]::WriteAllText("$($FireFoxProfile.FullName)\user.js", $JsFile, [System.Text.UTF8Encoding]::new($false))
}

show-menu

          }
       11 {

Clear-Host

Write-Host "Installing: Frame View..."

# download frame view
Get-FileFromWeb -URL "https://images.nvidia.com/content/geforce/technologies/frameview/FrameView_1.7/FrameViewSetup.exe" -File "$env:SystemRoot\Temp\FrameView.exe"

# install frame view 
Start-Process -Wait "$env:SystemRoot\Temp\FrameView.exe" -ArgumentList "/s"

# cleaner start menu shortcut path
Move-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\NVIDIA FrameView\FrameView.lnk" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force -ErrorAction SilentlyContinue | Out-Null
Remove-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\NVIDIA FrameView" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

show-menu

          }
       12 {

Clear-Host

Write-Host "Installing: GOG launcher..."

# download gog launcher
Get-FileFromWeb -URL "https://webinstallers.gog-statics.com/download/GOG_Galaxy_2.0.exe" -File "$env:SystemRoot\Temp\GOG launcher.exe"

# install gog launcher
Start-Process "$env:SystemRoot\Temp\GOG launcher.exe"

show-menu

          }
       13 {

Clear-Host

Write-Host "Installing: Google Chrome..."

# download google chrome
Get-FileFromWeb -URL "https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi" -File "$env:SystemRoot\Temp\Chrome.msi"

# install google chrome
Start-Process -Wait "$env:SystemRoot\Temp\Chrome.msi" -ArgumentList "/quiet"

# install ublock origin lite
cmd /c "reg add `"HKLM\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist`" /v `"1`" /t REG_SZ /d `"ddkjiahejlhfcafbddmgiahcphecmpfh;https://clients2.google.com/service/update2/crx`" /f >nul 2>&1"

# add chrome policies
cmd /c "reg add `"HKLM\SOFTWARE\Policies\Google\Chrome`" /v `"HardwareAccelerationModeEnabled`" /t REG_DWORD /d `"0`" /f >nul 2>&1"
cmd /c "reg add `"HKLM\SOFTWARE\Policies\Google\Chrome`" /v `"BackgroundModeEnabled`" /t REG_DWORD /d `"0`" /f >nul 2>&1"
cmd /c "reg add `"HKLM\SOFTWARE\Policies\Google\Chrome`" /v `"HighEfficiencyModeEnabled`" /t REG_DWORD /d `"1`" /f >nul 2>&1"

# remove logon chrome
$basePath = "HKLM:\Software\Microsoft\Active Setup\Installed Components"
Get-ChildItem $basePath | ForEach-Object {
$val = (Get-ItemProperty $_.PsPath)."(default)"
if ($val -like "*Chrome*") {
Remove-Item $_.PsPath -Force -ErrorAction SilentlyContinue
}
}

# remove chrome services
$services = Get-Service | Where-Object { $_.Name -match 'Google' }
foreach ($service in $services) {
cmd /c "sc stop `"$($service.Name)`" >nul 2>&1"
cmd /c "sc delete `"$($service.Name)`" >nul 2>&1"
}

# remove chrome scheduled tasks
Get-ScheduledTask | Where-Object { $_.TaskName -like '*Google*' } | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue

show-menu

          }
       14 {

Clear-Host

Write-Host "Installing: League Of Legends..."

# download league of legends
Get-FileFromWeb -URL "https://lol.secure.dyn.riotcdn.net/channels/public/x/installer/current/live.na.exe" -File "$env:SystemRoot\Temp\League Of Legends.exe"

# install league of legends
Start-Process "$env:SystemRoot\Temp\League Of Legends.exe" -ArgumentList "--skip-to-install"

show-menu

          }
       15 {

Clear-Host

Write-Host "Installing: Notepad ++..."

# download notepad ++
Get-FileFromWeb -URL "https://github.com/FR33THYFR33THY/files/raw/main/Notepad%20++.exe" -File "$env:SystemRoot\Temp\Notepad ++.exe"

# install notepad ++
Start-Process -Wait "$env:SystemRoot\Temp\Notepad ++.exe" -ArgumentList "/S"

# create config for notepad ++
$NotePadConfig = @'
<?xml version="1.0" encoding="UTF-8" ?>
<NotepadPlus>
    <ProjectPanels>
        <ProjectPanel id="0" workSpaceFile="" />
        <ProjectPanel id="1" workSpaceFile="" />
        <ProjectPanel id="2" workSpaceFile="" />
    </ProjectPanels>
    <ColumnEditor choice="number">
        <text content="" />
        <number initial="-1" increase="-1" repeat="-1" formatChoice="dec" leadingChoice="none" />
    </ColumnEditor>
    <GUIConfigs>
        <GUIConfig name="ToolBar" visible="yes" fluentColor="0" fluentCustomColor="16229943" fluentMono="no">small</GUIConfig>
        <GUIConfig name="StatusBar">show</GUIConfig>
        <GUIConfig name="TabBar" dragAndDrop="yes" drawTopBar="yes" drawInactiveTab="yes" reduce="yes" closeButton="yes" pinButton="yes" showOnlyPinnedButton="no" buttonsOninactiveTabs="no" doubleClick2Close="no" vertical="no" multiLine="no" hide="no" quitOnEmpty="no" iconSetNumber="0" tabCompactLabelLen="0" />
        <GUIConfig name="ScintillaViewsSplitter">vertical</GUIConfig>
        <GUIConfig name="UserDefineDlg" position="undocked">hide</GUIConfig>
        <GUIConfig name="TabSetting" replaceBySpace="no" size="4" backspaceUnindent="no" />
        <GUIConfig name="AppPosition" x="0" y="0" width="1024" height="700" isMaximized="no" />
        <GUIConfig name="FindWindowPosition" left="0" top="0" right="0" bottom="0" isLessModeOn="no" />
        <GUIConfig name="FinderConfig" wrappedLines="no" purgeBeforeEverySearch="no" showOnlyOneEntryPerFoundLine="yes" />
        <GUIConfig name="noUpdate" intervalDays="15" nextUpdateDate="20260401" autoUpdateMode="0">yes</GUIConfig>
        <GUIConfig name="Auto-detection">yes</GUIConfig>
        <GUIConfig name="CheckHistoryFiles">no</GUIConfig>
        <GUIConfig name="TrayIcon">0</GUIConfig>
        <GUIConfig name="MaintainIndent">1</GUIConfig>
        <GUIConfig name="TagsMatchHighLight" TagAttrHighLight="yes" HighLightNonHtmlZone="no">yes</GUIConfig>
        <GUIConfig name="RememberLastSession">no</GUIConfig>
        <GUIConfig name="KeepSessionAbsentFileEntries">no</GUIConfig>
        <GUIConfig name="DetectEncoding">yes</GUIConfig>
        <GUIConfig name="SaveAllConfirm">yes</GUIConfig>
        <GUIConfig name="NewDocDefaultSettings" format="0" encoding="4" lang="0" codepage="-1" openAnsiAsUTF8="yes" addNewDocumentOnStartup="no" useContentAsTabName="no" />
        <GUIConfig name="langsExcluded" gr0="0" gr1="0" gr2="0" gr3="0" gr4="0" gr5="0" gr6="0" gr7="0" gr8="0" gr9="0" gr10="0" gr11="0" gr12="0" langMenuCompact="yes" />
        <GUIConfig name="Print" lineNumber="yes" printOption="3" headerLeft="" headerMiddle="" headerRight="" footerLeft="" footerMiddle="" footerRight="" headerFontName="" headerFontStyle="0" headerFontSize="0" footerFontName="" footerFontStyle="0" footerFontSize="0" margeLeft="0" margeRight="0" margeTop="0" margeBottom="0" />
        <GUIConfig name="Backup" action="0" useCustumDir="no" dir="" isSnapshotMode="no" snapshotBackupTiming="7000" />
        <GUIConfig name="TaskList">yes</GUIConfig>
        <GUIConfig name="MRU">yes</GUIConfig>
        <GUIConfig name="URL">0</GUIConfig>
        <GUIConfig name="uriCustomizedSchemes">svn:// cvs:// git:// imap:// irc:// irc6:// ircs:// ldap:// ldaps:// news: telnet:// gopher:// ssh:// sftp:// smb:// skype: snmp:// spotify: steam:// sms: slack:// chrome:// bitcoin:</GUIConfig>
        <GUIConfig name="globalOverride" fg="no" bg="no" font="no" fontSize="no" bold="no" italic="no" underline="no" />
        <GUIConfig name="auto-completion" autoCAction="3" triggerFromNbChar="1" autoCIgnoreNumbers="yes" insertSelectedItemUseENTER="yes" insertSelectedItemUseTAB="yes" autoCBrief="no" funcParams="yes" />
        <GUIConfig name="auto-insert" parentheses="no" brackets="no" curlyBrackets="no" quotes="no" doubleQuotes="no" htmlXmlTag="no" />
        <GUIConfig name="sessionExt"></GUIConfig>
        <GUIConfig name="workspaceExt"></GUIConfig>
        <GUIConfig name="MenuBar">show</GUIConfig>
        <GUIConfig name="Caret" width="1" blinkRate="600" />
        <GUIConfig name="openSaveDir" value="0" defaultDirPath="" lastUsedDirPath="" />
        <GUIConfig name="titleBar" short="no" />
        <GUIConfig name="insertDateTime" customizedFormat="yyyy-MM-dd HH:mm:ss" reverseDefaultOrder="no" />
        <GUIConfig name="wordCharList" useDefault="yes" charsAdded="" />
        <GUIConfig name="delimiterSelection" leftmostDelimiter="40" rightmostDelimiter="41" delimiterSelectionOnEntireDocument="no" />
        <GUIConfig name="largeFileRestriction" fileSizeMB="200" isEnabled="yes" allowAutoCompletion="no" allowBraceMatch="no" allowSmartHilite="no" allowClickableLink="no" deactivateWordWrap="yes" suppress2GBWarning="no" />
        <GUIConfig name="multiInst" setting="0" clipboardHistory="no" documentList="no" characterPanel="no" folderAsWorkspace="no" projectPanels="no" documentMap="no" fuctionList="no" pluginPanels="no" />
        <GUIConfig name="MISC" fileSwitcherWithoutExtColumn="no" fileSwitcherExtWidth="50" fileSwitcherWithoutPathColumn="yes" fileSwitcherPathWidth="50" fileSwitcherNoGroups="no" backSlashIsEscapeCharacterForSql="yes" writeTechnologyEngine="1" isFolderDroppedOpenFiles="no" docPeekOnTab="no" docPeekOnMap="no" sortFunctionList="no" saveDlgExtFilterToAllTypes="no" muteSounds="yes" enableFoldCmdToggable="no" hideMenuRightShortcuts="no" />
        <GUIConfig name="Searching" monospacedFontFindDlg="no" fillFindFieldWithSelected="yes" fillFindFieldSelectCaret="yes" findDlgAlwaysVisible="no" confirmReplaceInAllOpenDocs="yes" replaceStopsWithoutFindingNext="no" inSelectionAutocheckThreshold="1024" fillFindWhatThreshold="1024" fillDirFieldFromActiveDoc="no" />
        <GUIConfig name="searchEngine" searchEngineChoice="2" searchEngineCustom="" />
        <GUIConfig name="MarkAll" matchCase="no" wholeWordOnly="yes" />
        <GUIConfig name="SmartHighLight" matchCase="no" wholeWordOnly="yes" useFindSettings="no" onAnotherView="no">yes</GUIConfig>
        <GUIConfig name="DarkMode" enable="yes" colorTone="0" customColorTop="2105376" customColorMenuHotTrack="4539717" customColorActive="3684408" customColorMain="2105376" customColorError="176" customColorText="14737632" customColorDarkText="12632256" customColorDisabledText="8421504" customColorLinkText="65535" customColorEdge="6579300" customColorHotEdge="10197915" customColorDisabledEdge="4737096" enableWindowsMode="no" darkThemeName="DarkModeDefault.xml" darkToolBarIconSet="0" darkTbFluentColor="0" darkTbFluentCustomColor="16229943" darkTbFluentMono="no" darkTabIconSet="2" darkTabUseTheme="no" lightThemeName="" lightToolBarIconSet="4" lightTbFluentColor="0" lightTbFluentCustomColor="12873472" lightTbFluentMono="no" lightTabIconSet="0" lightTabUseTheme="yes" />
        <GUIConfig name="ScintillaPrimaryView" lineNumberMargin="show" lineNumberDynamicWidth="yes" bookMarkMargin="show" indentGuideLine="show" folderMarkStyle="box" isChangeHistoryEnabled="1" lineWrapMethod="aligned" currentLineIndicator="1" currentLineFrameWidth="1" virtualSpace="no" scrollBeyondLastLine="yes" rightClickKeepsSelection="no" selectedTextForegroundSingleColor="no" disableAdvancedScrolling="no" wrapSymbolShow="hide" Wrap="no" borderEdge="yes" isEdgeBgMode="no" edgeMultiColumnPos="" zoom="0" zoom2="0" whiteSpaceShow="hide" eolShow="hide" eolMode="1" npcShow="hide" npcMode="1" npcCustomColor="no" npcIncludeCcUniEOL="no" npcNoInputC0="yes" ccShow="yes" borderWidth="2" smoothFont="no" paddingLeft="0" paddingRight="0" distractionFreeDivPart="4" lineCopyCutWithoutSelection="yes" multiSelection="yes" columnSel2MultiEdit="yes" />
        <GUIConfig name="DockingManager" leftWidth="200" rightWidth="200" topHeight="200" bottomHeight="200">
            <ActiveTabs cont="0" activeTab="-1" />
            <ActiveTabs cont="1" activeTab="-1" />
            <ActiveTabs cont="2" activeTab="-1" />
            <ActiveTabs cont="3" activeTab="-1" />
        </GUIConfig>
    </GUIConfigs>
    <FindHistory nbMaxFindHistoryPath="10" nbMaxFindHistoryFilter="10" nbMaxFindHistoryFind="10" nbMaxFindHistoryReplace="10" matchWord="no" matchCase="no" wrap="yes" directionDown="yes" fifRecuisive="yes" fifInHiddenFolder="no" fifProjectPanel1="no" fifProjectPanel2="no" fifProjectPanel3="no" fifFilterFollowsDoc="no" searchMode="0" transparencyMode="1" transparency="150" dotMatchesNewline="no" isSearch2ButtonsMode="no" regexBackward4PowerUser="no" bookmarkLine="no" purge="no" />
    <History nbMaxFile="0" inSubMenu="no" customLength="-1" />
</NotepadPlus>

'@
Set-Content -Path "$env:AppData\Notepad++\config.xml" -Value $NotePadConfig -Force

# create notepad ++ shortcut
$WshShell = New-Object -comObject WScript.Shell
$Desktop = (New-Object -ComObject Shell.Application).Namespace('shell:Desktop').Self.Path
$Shortcut = $WshShell.CreateShortcut("$Desktop\Notepad++.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Program Files\Notepad++\notepad++.exe"
$Shortcut.WorkingDirectory = "$env:SystemDrive\Program Files\Notepad++"
$Shortcut.Save()

show-menu

          }
       16 {

Clear-Host

Write-Host "Installing: Nvidia App..."

# download nvidia app
Get-FileFromWeb -URL "https://us.download.nvidia.com/nvapp/client/11.0.6.383/NVIDIA_app_v11.0.6.383.exe" -File "$env:SystemRoot\Temp\NvidiaApp.exe"

# install nvidia app
Start-Process -Wait "$env:SystemRoot\Temp\NvidiaApp.exe" -ArgumentList "/s"

# cleaner start menu shortcut path
Move-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\NVIDIA Corporation\NVIDIA App.lnk" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force -ErrorAction SilentlyContinue | Out-Null
Remove-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\NVIDIA Corporation" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

show-menu

          }
       17 {

Clear-Host

Write-Host "Installing: OBS Studio..."

# download obs studio                      
Get-FileFromWeb -URL "https://cdn-fastly.obsproject.com/downloads/OBS-Studio-32.1.0-Windows-x64-Installer.exe" -File "$env:SystemRoot\Temp\OBS Studio.exe"

# install obs studio
Start-Process -Wait "$env:SystemRoot\Temp\OBS Studio.exe" -ArgumentList "/S"

show-menu

          }
       18 {

Clear-Host

Write-Host "Installing: Onboard Memory Manager..."

# download onboard memory manager
Get-FileFromWeb -URL "https://download01.logi.com/web/ftp/pub/techsupport/gaming/OnboardMemoryManager_2.6.1749.exe" -File "$env:SystemDrive\Program Files (x86)\Onboard Memory Manager\Onboard Memory Manager.exe"

# create desktop shortcut
$WshShell = New-Object -comObject WScript.Shell
$Desktop = (New-Object -ComObject Shell.Application).Namespace('shell:Desktop').Self.Path
$Shortcut = $WshShell.CreateShortcut("$Desktop\Onboard Memory Manager.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Program Files (x86)\Onboard Memory Manager\Onboard Memory Manager.exe"
$Shortcut.WorkingDirectory = "$env:SystemDrive\Program Files (x86)\Onboard Memory Manager"
$Shortcut.Save()

# create start menu shortcut
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Onboard Memory Manager.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Program Files (x86)\Onboard Memory Manager\Onboard Memory Manager.exe"
$Shortcut.WorkingDirectory = "$env:SystemDrive\Program Files (x86)\Onboard Memory Manager"
$Shortcut.Save()

show-menu

          }
       19 {

Clear-Host

Write-Host "Installing: Pot Player..."

# download pot player         
Get-FileFromWeb -URL "https://t1.daumcdn.net/potplayer/PotPlayer/Version/Latest/PotPlayerSetup64.exe" -File "$env:SystemRoot\Temp\Pot Player.exe"

# install pot player 
Start-Process -Wait "$env:SystemRoot\Temp\Pot Player.exe" -ArgumentList "/S /allusers"

# cleaner start menu shortcut path
Move-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\PotPlayer\PotPlayer 64 bit.lnk" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force -ErrorAction SilentlyContinue | Out-Null
Remove-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\PotPlayer" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

show-menu

          }
       20 {

Clear-Host

Write-Host "Installing: Rockstar Games..."

# download rockstar games
Get-FileFromWeb -URL "https://gamedownloads.rockstargames.com/public/installer/Rockstar-Games-Launcher.exe" -File "$env:SystemRoot\Temp\Rockstar Games.exe"

# install rockstar games
Start-Process -Wait "$env:SystemRoot\Temp\Rockstar Games.exe" -ArgumentList "/s /f"

# cleaner start menu shortcut path
Move-Item -Path "$env:AppData\Microsoft\Windows\Start Menu\Programs\Rockstar Games\Rockstar Games Launcher.lnk" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force -ErrorAction SilentlyContinue | Out-Null
Remove-Item "$env:AppData\Microsoft\Windows\Start Menu\Programs\Rockstar Games" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

show-menu

          }
       21 {

Clear-Host

Write-Host "Installing: Spotify..."

# set config for spotify
New-Item -Path "$env:APPDATA\Spotify\prefs" -ItemType File -Force | Out-Null
$SpotifySettingsPrefs = @'
app.autostart-configured=true
app.autostart-mode="off"
ui.hardware_acceleration=false
'@
Set-Content -Path "$env:APPDATA\Spotify\prefs" -Value $SpotifySettingsPrefs -Force | Out-Null

# download spotify
Get-FileFromWeb -URL "https://download.scdn.co/SpotifySetup.exe" -File "$env:TEMP\Spotify.exe"

# install spotify
Start-Process "explorer.exe" -ArgumentList "$env:TEMP\Spotify.exe"

show-menu

          }
       22 {

Clear-Host

Write-Host "Installing: Steam..."

# download steam
Get-FileFromWeb -URL "https://cdn.cloudflare.steamstatic.com/client/installer/SteamSetup.exe" -File "$env:SystemRoot\Temp\Steam.exe"

# install steam
Start-Process -Wait "$env:SystemRoot\Temp\Steam.exe" -ArgumentList "/S"

# cleaner start menu shortcut path
Move-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Steam\Steam.lnk" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force -ErrorAction SilentlyContinue | Out-Null
Remove-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Steam" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

# remove logon steam
cmd /c "reg delete `"HKCU\Software\Microsoft\Windows\CurrentVersion\Run`" /v `"Steam`" /f >nul 2>&1"

show-menu

          }
       23 {

Clear-Host

Write-Host "Installing: Ubisoft Connect..."

# download ubisoft connect
Get-FileFromWeb -URL "https://static3.cdn.ubi.com/orbit/launcher_installer/UbisoftConnectInstaller.exe" -File "$env:SystemRoot\Temp\Ubisoft Connect.exe"

# install ubisoft connect
Start-Process -Wait "$env:SystemRoot\Temp\Ubisoft Connect.exe" -ArgumentList "/S"

# cleaner start menu shortcut path
Move-Item -Path "$env:AppData\Microsoft\Windows\Start Menu\Programs\Ubisoft\Ubisoft Connect\Ubisoft Connect.lnk" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Force -ErrorAction SilentlyContinue | Out-Null
Remove-Item "$env:AppData\Microsoft\Windows\Start Menu\Programs\Ubisoft" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null

show-menu

          }
       24 {

Clear-Host

Write-Host "Installing: Valorant..."

# download valorant
Get-FileFromWeb -URL "https://valorant.secure.dyn.riotcdn.net/channels/public/x/installer/current/live.live.ap.exe" -File "$env:SystemRoot\Temp\Valorant.exe"

# install valorant 
Start-Process "$env:SystemRoot\Temp\Valorant.exe" -ArgumentList "--skip-to-install"

show-menu

          }
        } } else { Write-Host "Invalid input. Please select a valid option (1-24)." } }
