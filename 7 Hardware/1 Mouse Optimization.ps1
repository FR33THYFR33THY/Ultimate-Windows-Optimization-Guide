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

Write-Host "Installing: Mouse Movement Recorder . . ."
# download mouse movement recorder
Get-FileFromWeb -URL "https://github.com/FR33THYFR33THY/files/raw/main/Mouse%20Movement%20Recorder.exe" -File "$env:TEMP\Mouse Movement Recorder.exe"
# open mouse movement recorder
Start-Process "$env:TEMP\Mouse Movement Recorder.exe"
Clear-Host
Write-Host "Mouse optimizations:"
Write-Host "-Keep dongle close to mouse"
Write-Host "-Disable angle snapping"
Write-Host "-Turn off motion sync"
Write-Host "-Set lowest debounce time"
Write-Host "-Use maximum polling rate"
Write-Host ""
Write-Host "Extreme polling may affect some PCs and game engines."
Write-Host ""
Write-Host "Set a comfortable DPI."
Write-Host "Increased DPI reduces pixel skipping and latency."
Write-Host "Suggested settings to reduce pixel skipping:"
Write-Host "-400dpi for 1080p"
Write-Host "-800dpi for 1440p"
Write-Host "-1600dpi for 4k"
Write-Host ""
Write-Host "To prevent mouse acceleration when gaming:"
Write-Host "-Enable raw input in games when possible"
Write-Host "-Set 6/11 and pointer precision off"
Write-Host "-Use 100% scaling"
Write-Host ""
Write-Host "Some game engines might override 100% scaling for 4K and higher resolutions."
Write-Host "This can occasionally occur on laptops of any resolution as well."
Write-Host "Scaling may need to manually be set 100% through Advanced Scaling Settings."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
