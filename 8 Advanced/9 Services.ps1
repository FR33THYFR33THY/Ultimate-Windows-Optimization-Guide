    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
    {Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit}
    $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " (Administrator)"
    $Host.UI.RawUI.BackgroundColor = "Black"
	$Host.PrivateData.ProgressBackgroundColor = "Black"
    $Host.PrivateData.ProgressForegroundColor = "White"
    Clear-Host

#trusted installer exploit by zoicware
function Run-Trusted([String]$command) {

    Stop-Service -Name TrustedInstaller -Force -ErrorAction SilentlyContinue
    #get bin path to revert later
    $service = Get-WmiObject -Class Win32_Service -Filter "Name='TrustedInstaller'"
    $DefaultBinPath = $service.PathName
    #convert command to base64 to avoid errors with spaces
    $bytes = [System.Text.Encoding]::Unicode.GetBytes($command)
    $base64Command = [Convert]::ToBase64String($bytes)
    #change bin to command
    sc.exe config TrustedInstaller binPath= "cmd.exe /c powershell.exe -encodedcommand $base64Command" | Out-Null
    #run the command
    sc.exe start TrustedInstaller | Out-Null
    #set bin back to default
    sc.exe config TrustedInstaller binpath= "`"$DefaultBinPath`"" | Out-Null
    Stop-Service -Name TrustedInstaller -Force -ErrorAction SilentlyContinue

}

try {
$safeBoot = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SafeBoot\Option" -ErrorAction Stop
} catch {
# check if the volume shadow copy service (vss) is set to manual
$service = Get-Service -Name VSS
if ($service.StartType -eq "Manual") {
Write-Host "Create a restore point . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
# open system protection
Start-Process "C:\Windows\System32\control.exe" -ArgumentList "sysdm.cpl ,4"
Write-Host ""
Pause
Clear-Host
Write-Host "Restarting To Safe Mode: Press any key to restart . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
# Toggle safe boot
cmd /c "bcdedit /set {current} safeboot minimal >nul 2>&1"
# Restart
shutdown -r -t 00
exit
} else {
Clear-Host
Write-Host "Restarting To Safe Mode: Press any key to restart . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
# Toggle safe boot
cmd /c "bcdedit /set {current} safeboot minimal >nul 2>&1"
# Restart
shutdown -r -t 00
exit
}
}

    Clear-Host
    Write-Host "1. Services: Off"
    Write-Host "2. Services: Default"
    while ($true) {
    $choice = Read-Host " "
    if ($choice -match '^[1-2]$') {
    switch ($choice) {
    1 {

Clear-Host
Write-Host "This script does not support Wi-Fi & Bluetooth." -ForegroundColor Red
Write-Host "If your PC depends on Wi-Fi or Bluetooth, please close this window!" -ForegroundColor Red
Write-Host ""
Write-Host "This script will intentionally run minimal services." -ForegroundColor Red
Write-Host "Certain programs, settings and options may encounter issues or fail to run." -ForegroundColor Red
Write-Host "If you experience any problems, please switch back to (Services: Default)." -ForegroundColor Red
Write-Host ""
Write-Host "If Windows fails to boot or log in after applying this script," -ForegroundColor Red
Write-Host "please access your restore point from the advanced setup recovery menu." -ForegroundColor Red
Write-Host ""
Pause
Clear-Host
Write-Host "Services: Off . . ."
# create reg file
$MultilineComment = @"
Windows Registry Editor Version 5.00

; W10 & W11 SERVICES OFF
; graphic driver & defender services left out.
; sppsvc set to auto for windows activation. (can disable).
; seclogon left out, as it will always enable itself. (can disable).
; appxsvc & TextInputManagementService left out, needed for w11. (w10 can disable).
; SENS & gpsvc left out, needed for multiple account logins. (single account can disable).
; Schedule left out, needed for MSI Afterburner to apply GPU overclocks on startup. (can disable).
; TermService, KeyIso, NgcCtnrSvc & NgcSvc left out, needed for microsoft account login. (local account can disable).
; camsvc & netprofm left out, needed for mic to work. (can disable. camsvc & netprofm both need to be manual on w11. w10 can run camsvc independently)

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\AarSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\AJRouter]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\ALG]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\AppIDSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Appinfo]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\AppMgmt]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\AppReadiness]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\AppVClient]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\AppXSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\AssignedAccessManagerSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\AudioEndpointBuilder]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Audiosrv]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\autotimesvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\AxInstSV]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\BcastDVRUserService]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\BDESVC]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\BFE]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\BITS]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\BluetoothUserService]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Browser]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\BrokerInfrastructure]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\BTAGService]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\BthAvctpSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\bthserv]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\camsvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\CaptureService]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\cbdhsvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\CDPSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\CDPUserSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\CertPropSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\ClipSVC]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\CloudBackupRestoreSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\cloudidsvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\COMSysApp]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\ConsentUxUserSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\CoreMessagingRegistrar]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\CredentialEnrollmentManagerUserSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\CryptSvc]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\CscService]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\DcomLaunch]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\dcsvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\defragsvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\DeviceAssociationBrokerSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\DeviceAssociationService]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\DeviceInstall]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\DevicePickerUserSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\DevicesFlowUserSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\DevQueryBroker]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Dhcp]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\diagnosticshub.standardcollector.service]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\diagsvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\DiagTrack]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\DialogBlockingService]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\DispBrokerDesktopSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\DisplayEnhancementService]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\DmEnrollmentSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\dmwappushservice]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Dnscache]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\DoSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\dot3svc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\DPS]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\DsmSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\DsSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\DusmSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\EapHost]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\edgeupdatem]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\edgeupdate]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\EFS]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\embeddedmode]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\EntAppSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\EventLog]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\EventSystem]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Fax]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\fdPHost]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\FDResPub]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\fhsvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\FontCache]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\FontCache3.0.0.0]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\FrameServerMonitor]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\FrameServer]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\GameInputSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\gpsvc]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\GraphicsPerfSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\hidserv]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\HvHost]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\icssvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\IKEEXT]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\InstallService]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\InventorySvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\iphlpsvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\IpxlatCfgSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\KeyIso]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\KtmRm]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\LanmanServer]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\LanmanWorkstation]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\lfsvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\LicenseManager]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\lltdsvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\lmhosts]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\logi_lamparray_service]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\LSM]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\LxpSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\MapsBroker]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\McpManagementService]
"Start"=dword:00000004

; [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\MDCoreSvc]
; "Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\MessagingService]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\MicrosoftEdgeElevationService]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\MixedRealityOpenXRSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\mpssvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\MSDTC]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\MSiSCSI]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\msiserver]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\MsKeyboardFilter]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\NaturalAuthentication]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\NcaSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\NcbService]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\NcdAutoSetup]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Netlogon]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Netman]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\netprofm]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\NetSetupSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\NetTcpPortSharing]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\NgcCtnrSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\NgcSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\NlaSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\NPSMSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\nsi]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\OneSyncSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\p2pimsvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\p2psvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\P9RdrService]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\PcaSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\PeerDistSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\PenService]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\perceptionsimulation]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\PerfHost]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\PhoneSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\PimIndexMaintenanceSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\pla]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\PlugPlay]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\PNRPAutoReg]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\PNRPsvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\PolicyAgent]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Power]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\PrintNotify]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\PrintWorkflowUserSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\ProfSvc]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\PushToInstall]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\QWAVE]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\RasAuto]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\RasMan]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\RemoteAccess]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\RemoteRegistry]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\RetailDemo]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\RmSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\RpcEptMapper]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\RpcLocator]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\RpcSs]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SamSs]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SCardSvr]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\ScDeviceEnum]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Schedule]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SCPolicySvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SDRSVC]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\seclogon]
"Start"=dword:00000003

; [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SecurityHealthService]
; "Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SEMgrSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SensorDataService]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SensorService]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SensrSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SENS]
"Start"=dword:00000002

; [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Sense]
; "Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SessionEnv]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SgrmBroker]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SharedAccess]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SharedRealitySvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\ShellHWDetection]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\shpamsvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\smphost]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SmsRouter]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SNMPTrap]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\spectrum]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Spooler]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\sppsvc]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SSDPSRV]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\ssh-agent]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SstpSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\StateRepository]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\stisvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\StiSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\StorSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\svsvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\swprv]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SysMain]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SystemEventsBroker]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\TabletInputService]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\TapiSrv]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\TermService]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\TextInputManagementService]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Themes]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\TieringEngineService]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\TimeBrokerSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\TokenBroker]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\TrkWks]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\TroubleshootingSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\TrustedInstaller]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\tzautoupdate]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\UdkUserSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\UevAgentService]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\uhssvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\UmRdpService]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\UnistoreSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\upnphost]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\UserDataSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\UserManager]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\UsoSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\VacSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\VaultSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\vds]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\vmicguestinterface]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\vmicheartbeat]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\vmickvpexchange]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\vmicrdv]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\vmicshutdown]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\vmictimesync]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\vmicvmsession]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\vmicvss]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\VSS]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\W32Time]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WaaSMedicSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WalletService]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WarpJITSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\wbengine]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WbioSrvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Wcmsvc]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\wcncsvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WdiServiceHost]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WdiSystemHost]
"Start"=dword:00000004

; [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WdNisSvc]
; "Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WebClient]
"Start"=dword:00000004

; [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\webthreatdefsvc]
; "Start"=dword:00000004

; [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\webthreatdefusersvc]
; "Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Wecsvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WEPHOSTSVC]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\wercplsupport]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WerSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WFDSConMgrSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WiaRpc]
"Start"=dword:00000004

; [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WinDefend]
; "Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WinHttpAutoProxySvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Winmgmt]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WinRM]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\wisvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WlanSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\wlidsvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\wlpasvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WManSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\wmiApSrv]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WMPNetworkSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\workfolderssvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WpcMonSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WPDBusEnum]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WpnService]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WpnUserService]
"Start"=dword:00000004

; [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\wscsvc]
; "Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WSearch]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\wuauserv]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WwanSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\XblAuthManager]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\XblGameSave]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\XboxGipSvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\XboxNetApiSvc]
"Start"=dword:00000004
"@
Set-Content -Path "$env:TEMP\ServicesOff.reg" -Value $MultilineComment -Force
# disable services RunTrusted
$ServicesOff = "Regedit.exe /S `"$env:TEMP\ServicesOff.reg`""
Run-Trusted -command $ServicesOff
Clear-Host
Write-Host "Press any key to restart . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
# toggle normal boot
cmd /c "bcdedit /deletevalue safeboot >nul 2>&1"
# restart
shutdown -r -t 00
exit

      }
    2 {

Clear-Host
Write-Host "Services: Default . . ."
# create reg file
$MultilineComment = @"
Windows Registry Editor Version 5.00

; W10 & W11 SERVICES ON
; graphic driver & defender services left out.

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\AarSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\AJRouter]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\ALG]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\AppIDSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Appinfo]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\AppMgmt]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\AppReadiness]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\AppVClient]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\AppXSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\AssignedAccessManagerSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\AudioEndpointBuilder]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Audiosrv]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\autotimesvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\AxInstSV]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\BcastDVRUserService]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\BDESVC]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\BFE]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\BITS]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\BluetoothUserService]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Browser]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\BrokerInfrastructure]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\BTAGService]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\BthAvctpSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\bthserv]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\camsvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\CaptureService]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\cbdhsvc]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\CDPSvc]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\CDPUserSvc]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\CertPropSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\ClipSVC]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\CloudBackupRestoreSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\cloudidsvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\COMSysApp]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\ConsentUxUserSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\CoreMessagingRegistrar]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\CredentialEnrollmentManagerUserSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\CryptSvc]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\CscService]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\DcomLaunch]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\dcsvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\defragsvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\DeviceAssociationBrokerSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\DeviceAssociationService]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\DeviceInstall]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\DevicePickerUserSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\DevicesFlowUserSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\DevQueryBroker]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Dhcp]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\diagnosticshub.standardcollector.service]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\diagsvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\DiagTrack]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\DialogBlockingService]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\DispBrokerDesktopSvc]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\DisplayEnhancementService]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\DmEnrollmentSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\dmwappushservice]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Dnscache]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\DoSvc]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\dot3svc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\DPS]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\DsmSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\DsSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\DusmSvc]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\EapHost]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\edgeupdatem]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\edgeupdate]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\EFS]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\embeddedmode]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\EntAppSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\EventLog]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\EventSystem]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Fax]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\fdPHost]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\FDResPub]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\fhsvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\FontCache]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\FontCache3.0.0.0]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\FrameServerMonitor]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\FrameServer]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\GameInputSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\gpsvc]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\GraphicsPerfSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\hidserv]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\HvHost]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\icssvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\IKEEXT]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\InstallService]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\InventorySvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\iphlpsvc]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\IpxlatCfgSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\KeyIso]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\KtmRm]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\LanmanServer]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\LanmanWorkstation]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\lfsvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\LicenseManager]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\lltdsvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\lmhosts]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\logi_lamparray_service]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\LSM]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\LxpSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\MapsBroker]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\McpManagementService]
"Start"=dword:00000003

; [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\MDCoreSvc]
; "Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\MessagingService]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\MicrosoftEdgeElevationService]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\MixedRealityOpenXRSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\mpssvc]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\MSDTC]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\MSiSCSI]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\msiserver]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\MsKeyboardFilter]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\NaturalAuthentication]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\NcaSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\NcbService]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\NcdAutoSetup]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Netlogon]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Netman]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\netprofm]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\NetSetupSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\NetTcpPortSharing]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\NgcCtnrSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\NgcSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\NlaSvc]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\NPSMSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\nsi]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\OneSyncSvc]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\p2pimsvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\p2psvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\P9RdrService]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\PcaSvc]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\PeerDistSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\PenService]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\perceptionsimulation]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\PerfHost]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\PhoneSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\PimIndexMaintenanceSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\pla]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\PlugPlay]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\PNRPAutoReg]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\PNRPsvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\PolicyAgent]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Power]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\PrintNotify]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\PrintWorkflowUserSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\ProfSvc]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\PushToInstall]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\QWAVE]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\RasAuto]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\RasMan]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\RemoteAccess]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\RemoteRegistry]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\RetailDemo]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\RmSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\RpcEptMapper]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\RpcLocator]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\RpcSs]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SamSs]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SCardSvr]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\ScDeviceEnum]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Schedule]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SCPolicySvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SDRSVC]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\seclogon]
"Start"=dword:00000003

; [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SecurityHealthService]
; "Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SEMgrSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SensorDataService]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SensorService]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SensrSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SENS]
"Start"=dword:00000002

; [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Sense]
; "Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SessionEnv]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SgrmBroker]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SharedAccess]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SharedRealitySvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\ShellHWDetection]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\shpamsvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\smphost]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SmsRouter]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SNMPTrap]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\spectrum]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Spooler]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\sppsvc]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SSDPSRV]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\ssh-agent]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SstpSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\StateRepository]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\stisvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\StiSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\StorSvc]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\svsvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\swprv]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SysMain]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SystemEventsBroker]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\TabletInputService]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\TapiSrv]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\TermService]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\TextInputManagementService]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Themes]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\TieringEngineService]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\TimeBrokerSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\TokenBroker]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\TrkWks]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\TroubleshootingSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\TrustedInstaller]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\tzautoupdate]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\UdkUserSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\UevAgentService]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\uhssvc]
"Start"=dword:00000004

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\UmRdpService]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\UnistoreSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\upnphost]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\UserDataSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\UserManager]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\UsoSvc]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\VacSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\VaultSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\vds]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\vmicguestinterface]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\vmicheartbeat]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\vmickvpexchange]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\vmicrdv]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\vmicshutdown]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\vmictimesync]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\vmicvmsession]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\vmicvss]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\VSS]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\W32Time]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WaaSMedicSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WalletService]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WarpJITSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\wbengine]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WbioSrvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Wcmsvc]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\wcncsvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WdiServiceHost]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WdiSystemHost]
"Start"=dword:00000003

; [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WdNisSvc]
; "Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WebClient]
"Start"=dword:00000003

; [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\webthreatdefsvc]
; "Start"=dword:00000003

; [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\webthreatdefusersvc]
; "Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Wecsvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WEPHOSTSVC]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\wercplsupport]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WerSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WFDSConMgrSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WiaRpc]
"Start"=dword:00000003

; [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WinDefend]
; "Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WinHttpAutoProxySvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Winmgmt]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WinRM]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\wisvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WlanSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\wlidsvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\wlpasvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WManSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\wmiApSrv]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WMPNetworkSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\workfolderssvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WpcMonSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WPDBusEnum]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WpnService]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WpnUserService]
"Start"=dword:00000002

; [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\wscsvc]
; "Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WSearch]
"Start"=dword:00000002

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\wuauserv]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WwanSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\XblAuthManager]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\XblGameSave]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\XboxGipSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\XboxNetApiSvc]
"Start"=dword:00000003
"@
Set-Content -Path "$env:TEMP\ServicesOn.reg" -Value $MultilineComment -Force
# enable services RunTrusted
$ServicesOn = "Regedit.exe /S `"$env:TEMP\ServicesOn.reg`""
Run-Trusted -command $ServicesOn
Clear-Host
Write-Host "Press any key to restart . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
# toggle normal boot
cmd /c "bcdedit /deletevalue safeboot >nul 2>&1"
# restart
shutdown -r -t 00
exit

      }
    } } else { Write-Host "Invalid input. Please select a valid option (1-2)." } }
