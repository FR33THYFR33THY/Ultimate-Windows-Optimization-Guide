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

    Write-Host "1. Install: Nvidia Driver (Recommended)"
    Write-Host "2. Install: NvCleanInstall"
    while ($true) {
    $choice = Read-Host " "
    if ($choice -match '^[1-2]$') {
    switch ($choice) {
    1 {

Clear-Host
# clean old files
Remove-Item -Recurse -Force "$env:TEMP\NvidiaDriver.exe" -ErrorAction SilentlyContinue | Out-Null
Remove-Item -Recurse -Force "$env:TEMP\NvidiaDriver" -ErrorAction SilentlyContinue | Out-Null
Remove-Item -Recurse -Force "$env:TEMP\7-Zip.exe" -ErrorAction SilentlyContinue | Out-Null
# find latest nvidia driver
$uri = 'https://gfwsl.geforce.com/services_toolkit/services/com/nvidia/services/AjaxDriverService.php?func=DriverManualLookup&psid=120&pfid=929&osID=57&languageCode=1033&isWHQL=1&dch=1&sort1=0&numberOfResults=1'
$response = Invoke-WebRequest -Uri $uri -Method GET -UseBasicParsing
$payload = $response.Content | ConvertFrom-Json
$version =  $payload.IDS[0].downloadInfo.Version
# check windows version & bits
$windowsVersion = if ([Environment]::OSVersion.Version -ge (new-object 'Version' 9, 1)) {"win10-win11"} else {"win8-win7"}
$windowsArchitecture = if ([Environment]::Is64BitOperatingSystem) {"64bit"} else {"32bit"}
# create download link
$url = "https://international.download.nvidia.com/Windows/$version/$version-desktop-$windowsVersion-$windowsArchitecture-international-dch-whql.exe"
Write-Output "Downloading: Nvidia Driver $version . . ."
# download nvidia driver
Get-FileFromWeb -URL $url -File "$env:TEMP\NvidiaDriver.exe"
Clear-Host
Write-Host "Installing: Nvidia Driver . . ."
# download 7zip
Get-FileFromWeb -URL "https://github.com/FR33THYFR33THY/files/raw/main/7-Zip.exe" -File "$env:TEMP\7-Zip.exe"
# install 7zip
Start-Process -wait "$env:TEMP\7-Zip.exe" /S
# extract files with 7zip
cmd /c "C:\Program Files\7-Zip\7z.exe" x "$env:TEMP\NvidiaDriver.exe" -o"$env:TEMP\NvidiaDriver" -y | Out-Null
# install nvidia driver
Start-Process "$env:TEMP\NvidiaDriver\setup.exe"
exit

      }
    2 {

Clear-Host
Write-Host "Installing: NvCleanInstall . . ."
# download nvcleaninstall
Get-FileFromWeb -URL "https://github.com/FR33THYFR33THY/files/raw/main/NV%20Clean%20Install.exe" -File "$env:TEMP\NV Clean Install.exe"
# start nvcleaninstall
Start-Process "$env:TEMP\NV Clean Install.exe"
exit

      }
    } } else { Write-Host "Invalid input. Please select a valid option (1-2)." } }
