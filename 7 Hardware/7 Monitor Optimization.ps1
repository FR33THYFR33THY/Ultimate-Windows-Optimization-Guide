    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
    {Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit}
    $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " (Administrator)"
    $Host.UI.RawUI.BackgroundColor = "Black"
	$Host.PrivateData.ProgressBackgroundColor = "Black"
    $Host.PrivateData.ProgressForegroundColor = "White"
    Clear-Host

# open test ufo
Start-Process "https://www.testufo.com/framerates#count=6&background=none&pps=1920"
Write-Host "Monitor optimizations:"
Write-Host "-Enable overclock mode"
Write-Host "-Run highest refresh rate"
Write-Host "-Disable adaptive brightness and variable backlight"
Write-Host "-Turn off variable refresh rate, adaptive sync and g-sync"
Write-Host "-Adjust color, brightness and sharpening to your preference"
Write-Host "-Max overdrive without causing overshoot or reducing motion clarity"
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
