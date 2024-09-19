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

Write-Host "Installing: Prime95 . . ."
# download prime95
Get-FileFromWeb -URL "https://github.com/FR33THYFR33THY/files/raw/main/Prime%2095.zip" -File "$env:TEMP\Prime 95.zip"
# extract files
Expand-Archive "$env:TEMP\Prime 95.zip" -DestinationPath "$env:TEMP\Prime 95" -ErrorAction SilentlyContinue
# start prime95
Start-Process "$env:TEMP\Prime 95\prime95.exe"
Clear-Host
Write-Host "Run a basic CPU stress test to check for errors."
Write-Host "Check temps and WHEA errors in Hw Info during this test."
Write-Host "In Prime95, click 'Window' and select 'Merge All Workers'."
Write-Host ""
Write-Host "CPU and RAM errors should not be ignored as they can lead to:"
Write-Host "-Corrupted Windows"
Write-Host "-Corrupted files"
Write-Host "-Stutters and hitches"
Write-Host "-Poor performance"
Write-Host "-Input lag"
Write-Host "-Shutdowns"
Write-Host "-Blue screens"
Write-Host ""
Write-Host "Basic troubleshooting for errors or issues running XMP DOCP EXPO:"
Write-Host "-BIOS out of date? (update)"
Write-Host "-BIOS bugged out? (clear CMOS)"
Write-Host "-Incompatible RAM? (check QVL)"
Write-Host "-Mismatched RAM? (replace)"
Write-Host "-RAM in wrong slots? (check manual)"
Write-Host "-Unlucky CPU memory controller? (lower RAM speed)"
Write-Host "-Overclock? (turn it off/dial it down)"
Write-Host "-CPU cooler overtightened? (loosen)"
Write-Host "-CPU overheating? (repaste/retighten/RMA cooler)"
Write-Host "-RAM overheating? Typically over 55deg. (fix case flow/ram fan)"
Write-Host "-Faulty RAM stick? (RMA)"
Write-Host "-Faulty motherboard? (RMA)"
Write-Host "-Faulty CPU? (RMA)"
Write-Host "-Bent CPU pin? (RMA)"
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
