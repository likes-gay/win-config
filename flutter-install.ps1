$version = '3.24.2'

function Add-Path($Path) {
    $Path = [System.Environment]::GetEnvironmentVariable("PATH","USER") + [IO.Path]::PathSeparator + $Path
    [Environment]::SetEnvironmentVariable( "Path", $Path, "User" )
}

Write-Host "Installing Flutter SDK $version"
Write-Host "====================="

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$zipPath = "$env:TEMP\flutter_windows_$version-stable.zip"

Write-Host "Downloading Flutter SDK..."
(New-Object Net.WebClient).DownloadFile("https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_$version-stable.zip", $zipPath)

Write-Host "Unpacking Flutter SDK..."
Expand-Archive -Path $zipPath -DestinationPath "$env:SystemDrive\Users\$Env:UserName\" | Out-Null

Add-Path "$env:SystemDrive\Users\$Env:UserName\flutter\bin"

Write-Host "Flutter SDK installed"