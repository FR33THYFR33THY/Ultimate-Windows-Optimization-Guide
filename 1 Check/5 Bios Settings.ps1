    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
    {Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit}
    $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " (Administrator)"
    $Host.UI.RawUI.BackgroundColor = "Black"
	$Host.PrivateData.ProgressBackgroundColor = "Black"
    $Host.PrivateData.ProgressForegroundColor = "White"
    Clear-Host

Write-Host "INTEL CPU"
Write-Host "-ENABLE ram profile (XMP DOCP EXPO)"
Write-Host "-DISABLE c-state"
Write-Host "-ENABLE resizable bar (REBAR C.A.M)"
Write-Host ""
Write-Host "AMD CPU"
Write-Host "-ENABLE ram profile (XMP DOCP EXPO)"
Write-Host "-ENABLE precision boost overdrive (PBO)"
Write-Host "-ENABLE resizable bar (REBAR C.A.M)"
Write-Host ""
Write-Host "MAX pump and set fans to performance"
Write-Host ""
Write-Host "DISABLE any driver installer software"
Write-Host "-Asus armory crate"
Write-Host "-MSI driver utility"
Write-Host "-Gigabyte update utility"
Write-Host "-Asrock motherboard utility"
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Clear-Host

    Write-Host "Press 'Y' To Restart To BIOS"
    while ($true) {
    $choice = Read-Host " "
    if ($choice -match '^[yY]$') {
    switch ($choice) {
    y {

Clear-Host
Write-Host "Restarting To BIOS: Press any key to restart . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
# restart to bios
cmd /c C:\Windows\System32\shutdown.exe /r /fw
exit

      }
    } } else { Write-Host "Invalid input. Please select a valid option (Y)." } }
