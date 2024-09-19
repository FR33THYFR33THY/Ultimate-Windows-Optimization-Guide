    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
    {Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit}
    $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " (Administrator)"
    $Host.UI.RawUI.BackgroundColor = "Black"
	$Host.PrivateData.ProgressBackgroundColor = "Black"
    $Host.PrivateData.ProgressForegroundColor = "White"
    Clear-Host

# create start menu shortcuts 1 in start menu
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Start Menu Shortcuts 1.lnk")
$Shortcut.TargetPath = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs"
$Shortcut.Save()
# create start menu shortcuts 2 in start menu
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Start Menu Shortcuts 2.lnk")
$Shortcut.TargetPath = "$env:AppData\Microsoft\Windows\Start Menu\Programs"
$Shortcut.Save()
# create startup programs 1 in start menu
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup Programs 1.lnk")
$Shortcut.TargetPath = "$env:AppData\Microsoft\Windows\Start Menu\Programs\Startup"
$Shortcut.Save()
# create startup programs 2 in start menu
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup Programs 2.lnk")
$Shortcut.TargetPath = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp"
$Shortcut.Save()
# open start menu shortcuts 1 location
Start-Process "$env:ProgramData\Microsoft\Windows\Start Menu\Programs"
# open start menu shortcuts 2 location
Start-Process "$env:AppData\Microsoft\Windows\Start Menu\Programs"
