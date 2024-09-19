    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
    {Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit}
    $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " (Administrator)"
    $Host.UI.RawUI.BackgroundColor = "Black"
	$Host.PrivateData.ProgressBackgroundColor = "Black"
    $Host.PrivateData.ProgressForegroundColor = "White"
    Clear-Host

Write-Host "Disable: Internet . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
# open device manager
Start-Process devmgmt.msc
Clear-Host
Write-Host "Press any key to continue . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Clear-Host
# copy key to clipboard
Set-Clipboard -Value "VK7JG-NPHTM-C97JM-9MPGT-3V66T"
Write-Host "Enter: VK7JG-NPHTM-C97JM-9MPGT-3V66T (Or Paste From Clipboard) . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
# create device manager shortcut
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$Home\Desktop\Enable Internet.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Windows\System32\devmgmt.msc"
$Shortcut.Save()
# open activation screen
Start-Process slui.exe 3
Clear-Host
Write-Host "Enter: VK7JG-NPHTM-C97JM-9MPGT-3V66T (Or Paste From Clipboard) . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
