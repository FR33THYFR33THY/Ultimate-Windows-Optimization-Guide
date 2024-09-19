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

Write-Host "Installing: TM5 . . ."
# download tm5
$result = Get-FileFromWeb -URL "https://github.com/FR33THYFR33THY/files/raw/main/TM5.zip" -File "$env:TEMP\TM5.zip"
# extract files
Expand-Archive "$env:TEMP\TM5.zip" -DestinationPath "$env:TEMP\TM5" -ErrorAction SilentlyContinue
# create config for tm5
$MultilineComment = @"
Memory Test config file v0.02
Copyrights to the program belong to me.
Serj
testmem.tz.ru
serj_m@hotmail.com

[Main Section]
Config Name=ABSOLUT(01102021)
Config Author=anta777
Cores=0
Tests=16
Time (%)=1250
Cycles=3
Language=0
Test Sequence=1,4,6,15,3,2,7,15,5,2,8,15,4,2,9,15,3,2,10,15,5,2,11,15,4,2,12,15,5,14,15

[Global Memory Setup]
Channels=2
Interleave Type=1
Single DIMM width, bits=64
Operation Block, byts=64
Testing Window Size (Mb)=1536
Lock Memory Granularity (Mb)=64
Reserved Memory for Windows (Mb)=512
Capable=0x0
Debug Level=7

[Window Position]
WindowPosX=400
WindowPosY=400

[Test0]
Enable=1
Time (%)=8
Function=RefreshStable
DLL Name=bin\MT0.dll
Pattern Mode=0
Pattern Param0=0x0
Pattern Param1=0x0
Parameter=0
Test Block Size (Mb)=0

[Test1]
Enable=1
Time (%)=240
Function=SimpleTest
DLL Name=bin\MT0.dll
Pattern Mode=2
Pattern Param0=0x77777777
Pattern Param1=0x33333333
Parameter=0
Test Block Size (Mb)=4

[Test2]
Enable=1
Time (%)=8
Function=SimpleTest
DLL Name=bin\MT0.dll
Pattern Mode=1
Pattern Param0=0
Pattern Param1=0
Parameter=0
Test Block Size (Mb)=0

[Test3]
Enable=1
Time (%)=20
Function=MirrorMove128
DLL Name=bin\MT0.dll
Pattern Mode=0
Pattern Param0=0x0
Pattern Param1=0x0
Parameter=2
Test Block Size (Mb)=0

[Test4]
Enable=1
Time (%)=20
Function=MirrorMove
DLL Name=bin\MT0.dll
Pattern Mode=0
Pattern Param0=0x0
Pattern Param1=0x0
Parameter=4
Test Block Size (Mb)=0

[Test5]
Enable=1
Time (%)=20
Function=MirrorMove128
DLL Name=bin\MT0.dll
Pattern Mode=0
Pattern Param0=0x0
Pattern Param1=0x0
Parameter=1
Test Block Size (Mb)=0

[Test6]
Enable=1
Time (%)=240
Function=SimpleTest
DLL Name=bin\MT0.dll
Pattern Mode=0
Pattern Param0=0x0
Pattern Param1=0x0
Parameter=0
Test Block Size (Mb)=4

[Test7]
Enable=1
Time (%)=120
Function=SimpleTest
DLL Name=bin\MT0.dll
Pattern Mode=0
Pattern Param0=0x0
Pattern Param1=0x0
Parameter=0
Test Block Size (Mb)=8

[Test8]
Enable=1
Time (%)=60
Function=SimpleTest
DLL Name=bin\MT0.dll
Pattern Mode=0
Pattern Param0=0x0
Pattern Param1=0x0
Parameter=0
Test Block Size (Mb)=16

[Test9]
Enable=1
Time (%)=30
Function=SimpleTest
DLL Name=bin\MT0.dll
Pattern Mode=0
Pattern Param0=0x0
Pattern Param1=0x0
Parameter=0
Test Block Size (Mb)=32

[Test10]
Enable=1
Time (%)=16
Function=SimpleTest
DLL Name=bin\MT0.dll
Pattern Mode=0
Pattern Param0=0x0
Pattern Param1=0x0
Parameter=0
Test Block Size (Mb)=64

[Test11]
Enable=1
Time (%)=8
Function=SimpleTest
DLL Name=bin\MT0.dll
Pattern Mode=0
Pattern Param0=0x0
Pattern Param1=0x0
Parameter=0
Test Block Size (Mb)=128

[Test12]
Enable=1
Time (%)=8
Function=SimpleTest
DLL Name=bin\MT0.dll
Pattern Mode=0
Pattern Param0=0x0
Pattern Param1=0x0
Parameter=0
Test Block Size (Mb)=256

[Test13]
Enable=1
Time (%)=8
Function=SimpleTest
DLL Name=bin\MT0.dll
Pattern Mode=0
Pattern Param0=0x0
Pattern Param1=0x0
Parameter=0
Test Block Size (Mb)=512

[Test14]
Enable=1
Time (%)=8
Function=SimpleTest
DLL Name=bin\MT0.dll
Pattern Mode=0
Pattern Param0=0x0
Pattern Param1=0x0
Parameter=0
Test Block Size (Mb)=0

[Test15]
Enable=1
Time (%)=8
Function=SimpleTest
DLL Name=bin\MT0.dll
Pattern Mode=0
Pattern Param0=0x0
Pattern Param1=0x0
Parameter=256
Test Block Size (Mb)=0
"@
Set-Content -Path "$env:TEMP\TM5\bin\MT.cfg" -Value $MultilineComment -Force
# set config to read only
Set-ItemProperty -Path "$env:TEMP\TM5\bin\MT.cfg" -Name IsReadOnly -Value $true
# start tm5
Start-Process "$env:TEMP\TM5\TM5.exe"
Clear-Host
Write-Host "Run a basic RAM stress test to check for errors."
Write-Host "Check temps and WHEA errors in Hw Info during this test."
Write-Host "TM5 will run three cycles."
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
