    $Host.UI.RawUI.BackgroundColor = "Black"
	$Host.PrivateData.ProgressBackgroundColor = "Black"
    $Host.PrivateData.ProgressForegroundColor = "White"
    Clear-Host
	
# open sounds
Start-Process "mmsys.cpl"

    Write-Host "Enable Loudness EQ?"
    Write-Host "1. Yes"
    Write-Host "2. No"
    while ($true) {
    $choice = Read-Host " "
    if ($choice -match '^[1-2]$') {
    switch ($choice) {
    1 {

Clear-Host
# create powershell file
$MultilineComment = @"
Param(
   [Parameter(Mandatory,HelpMessage='PlaybackDeviceName?')]
   [ValidateLength(3,50)]
   [string]&PlaybackDeviceName,
   [ValidateRange(1, 10)]
   [int]&maxDeviceCount=2,
   [ValidateRange(2, 7)]
   [int]&releaseTime=4
)
Add-Type -AssemblyName System.Windows.Forms
function exitWithErrorMsg ([String] &msg){
    [void][System.Windows.Forms.MessageBox]::Show(&msg, &PSCommandPath,
    [System.Windows.Forms.MessageBoxButtons]::OK,
    [System.Windows.Forms.MessageBoxIcon]::Error)
    Write-Error &msg
    exit 1
}
function importReg ([String] &file){
    &startprocessParams = @{
        FilePath     = "&Env:SystemRoot\REGEDIT.exe"
        ArgumentList = '/s', &file
        Verb         = 'RunAs'
        PassThru     = &true
        Wait         = &true
    }
    &proc = Start-Process @startprocessParams
    If(&? -eq &false -or &proc.ExitCode -ne 0) {
        exitWithErrorMsg "Failed to import &file"
    }
}
&ErrorActionPreference = "Stop"
&PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
&regFile = "&env:temp\SoundEnhancementsTMP.reg"
&enhancementFlagKey = "{fc52a749-4be9-4510-896e-966ba6525980},3"
&releaseTimeKey = "{9c00eeed-edce-4cd8-ae08-cb05e8ef57a0},3"
&enhancementTabKey = "{d04e05a6-594b-4fb6-a80d-01af5eed7d1d},3"
&enhancementTabValue = "{5860E1C5-F95C-4a7a-8EC8-8AEF24F379A1}"
&releaseTimeStr = &releaseTime.ToString().PadLeft(2,'0')
&fxPropertiesImport = @'
"{d04e05a6-594b-4fb6-a80d-01af5eed7d1d},1"="{62dc1a93-ae24-464c-a43e-452f824c4250}" ;PreMixEffectClsid activates effects
"{d04e05a6-594b-4fb6-a80d-01af5eed7d1d},2"="{637c490d-eee3-4c0a-973f-371958802da2}" ;PostMixEffectClsid activates effects
"{d04e05a6-594b-4fb6-a80d-01af5eed7d1d},3"="{5860E1C5-F95C-4a7a-8EC8-8AEF24F379A1}" ;UserInterfaceClsid shows it in ui
"{d04e05a6-594b-4fb6-a80d-01af5eed7d1d},5"="{62dc1a93-ae24-464c-a43e-452f824c4250}" ;StreamEffectClsid
"{d04e05a6-594b-4fb6-a80d-01af5eed7d1d},6"="{637c490d-eee3-4c0a-973f-371958802da2}" ;ModeEffectClsid
"{fc52a749-4be9-4510-896e-966ba6525980},3"=hex:0b,00,00,00,01,00,00,00,ff,ff,00,00 ;enables loudness equalisation
"{9c00eeed-edce-4cd8-ae08-cb05e8ef57a0},3"=hex:03,00,01,60,01,00,00,00,02,00,00,00 ;equalisation release time max
'@
&devices = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render\*\Properties"
if(&devices.length -eq 0) {
    exitWithErrorMsg "Failed run as Admin."
}
&renderer = @()
foreach(&device in &devices) {
    if ((&device.GetValueNames() | %{&device.GetValue(&_)}) -match &PlaybackDeviceName) {
        &renderer += Get-ItemProperty &device.PSParentPath
    }
}
if(&renderer.length -lt 1) {
    exitWithErrorMsg "Could not find &PlaybackDeviceName"
}
&activeRenderer = @(&renderer | Where-Object -Property DeviceState -eq 1)
if(&activeRenderer.length -lt 1) {
    exitWithErrorMsg "There is &(&renderer.length) devices with the name &PlaybackDeviceName, none of them are active"
}
if(&activeRenderer.length -gt &maxDeviceCount) {
    &devices
    exitWithErrorMsg "Failed, more then &maxDeviceCount active devices have the name &PlaybackDeviceName"
}
&missingLoudness = &false
"Windows Registry Editor Version 5.00" > &regFile
&activeRenderer | ForEach-Object{
    &fxKeyPath = Join-Path -Path &_.PSPath.Replace("Microsoft.PowerShell.Core\Registry::", "") -ChildPath FxProperties
    &fxProperties = Get-ItemProperty -Path Registry::&fxKeyPath -ErrorAction Ignore
    if ((&fxProperties -eq &null) -or (&fxProperties.&enhancementFlagKey -eq &null) -or 
        (&fxProperties.&enhancementFlagKey[8] -ne 255) -or (&fxProperties.&enhancementFlagKey[9] -ne 255) -or
        (&fxProperties.&releaseTimeKey -eq &null) -or (&fxProperties.&releaseTimeKey[8] -ne &releaseTime) -or
        (&fxProperties.&enhancementTabKey -eq &null) -or (&fxProperties.&enhancementTabKey -ne &enhancementTabValue)) {
        "[" + &fxKeyPath + "]" >> &regFile
        &fxPropertiesImport >> &regFile
        &missingLoudness = &true
    }
    if (&fxProperties -eq &null) {
        Write-Host -NoNewline "Failed, FxProperties is missing '&fxKeyPath' try on another playback device" -ForegroundColor Red
    }
}
if (!&missingLoudness) {
    "Failed, already enabled"
    Start-Sleep -Seconds 5
    exit 0
}
&currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not &currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    &arguments = "-File <"&(&myInvocation.MyCommand.Definition)<" -playbackDeviceName &PlaybackDeviceName -maxDeviceCount &maxDeviceCount"
    Start-Process powershell -Verb runAs -ArgumentList &arguments
    exit
}
importReg &regFile
Restart-Service audiosrv -Force
Start-Process "mmsys.cpl"
exit
"@
Set-Content -Path "$env:TEMP\EQ.ps1" -Value $MultilineComment -Force
$path = "$env:TEMP\EQ.ps1"
(Get-Content $path) -replace '&','$' | out-file $path
(Get-Content $path) -replace '<','`' | out-file $path
Clear-Host
Write-Host "Loudness EQ not working?"
Write-Host "-Roll back/uninstall audio driver"
Write-Host "-Or try a different playback device"
Write-Host ""
Write-Host "Copy playback device name . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Clear-Host
Start-Process "mmsys.cpl"
Write-Host "Press any key to continue . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Clear-Host
# stop sounds running
Stop-Process -Name rundll32 -Force -ErrorAction SilentlyContinue
# run powershell file
& "$env:TEMP\EQ.ps1"
exit

      }
    2 {

Clear-Host
exit

      }
    } } else { Write-Host "Invalid input. Please select a valid option (1-2)." } }