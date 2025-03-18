# Functions
function Remove-TaskbarPin {
	[CmdletBinding(SupportsShouldProcess = $true)]
	param(
		[string]$appname
	)
	try {
		$shellApp = New-Object -ComObject Shell.Application
		$taskbarFolder = $shellApp.Namespace("shell:::{4234d49b-0245-4df3-b780-3893943456e1}")
		$item = $taskbarFolder.Items() | Where-Object { $_.Name -eq $appname }
		if ($item) {
			$verbs = $item.Verbs() | Where-Object { $_.Name.Replace("&", "") -match "Unpin from taskbar" }
			foreach ($verb in $verbs) {
				if ($PSCmdlet.ShouldProcess($sappname, "Unpin from taskbar")) {
					$verb.DoIt()
					Write-Output "App '$appname' unpinned from Taskbar"
				}
			}
		} else {
			Write-Warning "App '$appname' not found on Taskbar"
		}
	} catch {
		Write-Error "Error unpinning app '$appname'!"
	}
}
function Get-LatestRelease-GitHub {
	param (
		[string]$RepositoryUrl,
		[string]$ArchPattern,
		[string]$FileExtension
	)

	# Extract the owner and repo from the URL
	if ($RepositoryUrl -match "https://github.com/([^/]+)/([^/]+)") {
		$Owner = $matches[1]
		$Repo = $matches[2]
	} else {
		Write-Error "Invalid GitHub repository URL."
		return
	}

	# Build the API URL for the latest release
	$ApiUrl = "https://api.github.com/repos/$Owner/$Repo/releases/latest"

	# Make the API request
	try {
		$Response = Invoke-RestMethod -Uri $ApiUrl -Headers @{"User-Agent"="PowerShell"}
	} catch {
		Write-Error "Failed to retrieve the latest release information."
		return
	}

	# Find the asset that matches the given pattern and file extension
	$DownloadUrl = $null
	$FileName = $null
	foreach ($asset in $Response.assets) {
		$Pattern = "$ArchPattern.*\.$FileExtension$"
		if ($asset.browser_download_url -match $Pattern) {
			$DownloadUrl = $asset.browser_download_url
			$FileName = $asset.name
			break
		}
	}

	if (-not $DownloadUrl) {
		Write-Error "No matching assets found in the latest release."
		return
	}

	# Download the asset
	try {
		Invoke-WebRequest -Uri $DownloadUrl -OutFile $FileName
		return $FileName
	} catch {
		Write-Error "Failed to download the latest release."
	}
}

function Update-Env {
	[CmdletBinding(SupportsShouldProcess = $true)]
	param()

	if ($PSCmdlet.ShouldProcess("Environment Variables", "Update Path")) {
		$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
	}
}

# Code
#---------------------------------------------------------------------------------------------------------------------------------------------

if ((Split-Path -Leaf (Get-Location)) -ne "likes-gay-config") {
	mkdir -Force "likes-gay-config"
	Set-Location "likes-gay-config"
	# $PSCommandPath is the path to the script that is running
	if ($null -ne $PSCommandPath) {
		Move-Item -Force -Path $PSCommandPath -Destination "."
	}
}

# Download user config file
try {
	Invoke-WebRequest "https://raw.githubusercontent.com/likes-gay/win-config/main/configs/$Env:UserName.json" -outfile config.json
} catch {
	Write-Output "No config file detected, please create one in this folder: https://github.com/likes-gay/win-config/blob/main/configs/"
	Exit
}

# Parse config file
try {
	$configFile = Get-Content ".\config.json" -Raw | ConvertFrom-Json
} catch {
	Write-Error "Malformed config file"
	Exit
}

# Delete config file after use
Remove-Item -Path .\config.json

# Install required PS module
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force
Install-Module -Name Microsoft.PowerShell.Archive -Scope CurrentUser -Force

# Install Scoop
if (!(Get-Command "scoop" -errorAction SilentlyContinue)){
	Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
	$script = Invoke-RestMethod -Uri https://get.scoop.sh
	Invoke-Command -ScriptBlock ([Scriptblock]::Create($script))
	Update-Env
} else {
	Write-Output "Skipping scoop install"
}

scoop install git
scoop bucket add extras
scoop bucket add main

# Set default browser to Chrome
if ($configFile."Default-browser-chrome") {
	Invoke-WebRequest "https://raw.githubusercontent.com/likes-gay/win-config/main/default_browser.vbs" -OutFile .\default_browser.vbs
	Cscript.exe .\default_browser.vbs //nologo
	Remove-Item -Path ".\default_browser.vbs"

	# Setup edge redirect - https://github.com/rcmaehl/MSEdgeRedirect/wiki/Deploying-MSEdgeRedirect
	if ($configFile."Setup-edge-redirect") {
		Invoke-WebRequest "https://github.com/rcmaehl/MSEdgeRedirect/releases/latest/download/MSEdgeRedirect.exe" -OutFile .\MSEdgeRedirect.exe
		Invoke-WebRequest "https://raw.githubusercontent.com/likes-gay/win-config/main/edge_redirect.ini" -OutFile .\edge_redirect.ini

		$process = Start-Process -FilePath ".\MSEdgeRedirect.exe" -ArgumentList "/si",".\edge_redirect.ini" -PassThru
		$process.WaitForExit()

		Remove-Item -Path ".\edge_redirect.ini"
		Remove-Item -Path ".\MSEdgeRedirect.exe"
	}
}

# Unpin unused apps from the taskbar
if ($configFile."Unpin-apps") {
	Remove-TaskbarPin "Microsoft Edge"
	Remove-TaskbarPin "Microsoft Store"
	Remove-TaskbarPin "Mail"
}

# Turns on dark mode for apps and system
if ($configFile."Dark-mode") {
	$themesPersonalise = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
	Set-ItemProperty -Path $themesPersonalise -Name "AppsUseLightTheme" -Value 0 -Type Dword
	Set-ItemProperty -Path $themesPersonalise -Name "SystemUsesLightTheme" -Value 0 -Type Dword
}

$explorer = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

# Remove task view
if ($configFile."Remove-task-view") {
	Set-ItemProperty -Path $explorer -Name "ShowTaskViewButton" -Value 0
}

# Combine taskbar button settings
if ($configFile."Combine-taskbar-buttons") {
	$combineTaskbarButtonsMap = @{
		"Always"	= 0
		"When-full" = 1
		"Never"	 = 2
	}

	$combineValue = $combineTaskbarButtonsMap[$configFile."Combine-taskbar-buttons"]
	if ($null -ne $combineValue) {
		Set-ItemProperty -Path $explorer -Name "TaskbarGlomLevel" -Value $combineValue
	}
}

# Set task bar search type
if ($configFile."Task-bar-search-mode") {
	$taskBarSearchModeRegKey = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
	$searchboxTaskbarModeMap = @{
		"Hidden" = 0
		"Icon"   = 1
		"Bar"	= 2
	}

	$searchboxValue = $searchboxTaskbarModeMap[$configFile."Task-bar-search-mode"]

	if ($null -ne $searchboxValue) {
		Set-ItemProperty -Path $taskBarSearchModeRegKey -Name "SearchboxTaskbarMode" -Value $searchboxValue
	}
}

# Turn on file extensions in File Explorer
if ($configFile."File-extentions") {
	Set-ItemProperty -Path $explorer -Name "HideFileExt" -Value 0
}

# Hide desktop icons
if ($configFile."Remove-desktop-icons") {
	Set-ItemProperty -Path $explorer -Name "HideIcons" -Value 1
}

# Enable seconds in clock
if ($configFile."Seconds-in-clock") {
	Set-ItemProperty -Path $explorer -Name "ShowSecondsInSystemClock" -Value 1 -Force
}

# Enable 12 hour time in clock
if ($configFile."12-hr-clock") {
	Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name "sShortTime" -Value "h:mm tt" -Force
	Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name "sTimeFormat" -Value "h:mm:ss tt" -Force
}

# Enable the clipboard history
if ($configFile."clipboard-history") {
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Clipboard" -Name "EnableClipboardHistory" -Value 1
}

# Set print screen to open snipping tool
if ($configFile."Print-scrn-snipping-tool") {
	Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "PrintScreenKeyForSnippingEnabled" -Value 1 -Type Dword
}

# Set scroll lines to user defined
if ($configFile."Set-scroll-lines") {
	$scrollSpeed = $configFile."Set-scroll-lines"
	Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class WinAPI {
	[DllImport("user32.dll", SetLastError = true)]
	public static extern IntPtr SendMessageTimeout(IntPtr hWnd, int Msg, IntPtr wParam, string lParam, uint fuFlags, uint uTimeout, IntPtr lpdwResult);

	[DllImport("user32.dll", SetLastError = true)]
	public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, uint pvParam, uint fWinIni);
}
"@

	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WheelScrollLines" -Value $scrollSpeed
	[WinAPI]::SystemParametersInfo(0x0069, $scrollSpeed, 0, 2)
	[WinAPI]::SendMessageTimeout(0xffff, 0x1a, [IntPtr]::Zero, "Environment", 2, 5000, [IntPtr]::Zero)
}

# Turn on "Live Caption" in Google Chrome
if ($configFile."Enable-live-caption-chrome") {
	$originalFile = "$env:LocalAppData\Google\Chrome\User Data\Default\Preferences"
	$content = Get-Content -Path $originalFile | ConvertFrom-Json

	$content | Add-Member -MemberType NoteProperty -Name "accessibility" -Value @{
		captions = @{
			live_caption_enabled = $true
		}
	} -Force

	$content | ConvertTo-Json -Compress | Set-Content -Path $originalFile
}

if ($configFile."Close-edge") {
	try {
		Stop-Process -Name msedge -Force
	} catch {
		Write-Output "Microsoft Edge is already shut"
	}
}

if ($configFile."Add-NuGet-source") {
	dotnet nuget add source --name nuget.org https://api.nuget.org/v3/index.json
}

# Open useful tabs
if ($configFile."Open-tabs") {
	for (
		$i = 0
		$i -lt $configFile."Open-tabs".Count
		$i++
		) {
			Start-Process $configFile."Open-tabs"[$i]
		}
}

# Lanuch VScode
if ($configFile."Launch-VScode") {
	code
}

# Set accent colour from config file
if ($configFile."Accent-colour") {
	$ColorValue = $configFile."Accent-colour".Split(" ") | ForEach-Object { "0x$_" }
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" -Name "AccentPalette" -Value ([byte[]]$ColorValue)
}

if ($configFile."Accent-colour-on-task-bar") {
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "ColorPrevalence" -Value 1
}

Stop-Process -processName: Explorer # Restart explorer to apply changes that require it

if ($configFile."Install-gh-desktop") {
	scoop install extras/github
}

if ($configFile."Install-gh-cli") {
	scoop install gh
}

# Install UV (Python PIP replacement https://github.com/astral-sh/uv)
if ($configFile."Install-UV") {
	powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
	if ($configFile."Campus-UV-PIP-Fix") {
 		New-Item -ItemType Directory -Force -Path "$Env:APPDATA\uv"
		Invoke-WebRequest "https://github.com/likes-gay/win-config/raw/refs/heads/main/uv.toml" -OutFile "$Env:APPDATA\uv\uv.toml"
  	}
}

# Install MS-Terminal
if ($configFile."Install-terminal") {
	scoop install extras/windows-terminal

	if ($configFile."Set-default-terminal") {
		$consoleStartupPath = "HKCU:\Console\%%Startup"

	if (-not (Test-Path $consoleStartupPath)) {
		New-Item -Path $consoleStartupPath -Force
	}

	New-ItemProperty -Path $consoleStartupPath -Name "DelegationConsole" -Value "{2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69}"
	New-ItemProperty -Path $consoleStartupPath -Name "DelegationTerminal" -Value "{E12CFF52-A866-4C77-9A90-F570A7AA2C6B}"
	}
}

if ($configFile."Install-JB-Toolbox") {
	scoop install extras/jetbrains-toolbox
}

if ($configFile."Install-Spotify") {
	scoop install extras/spotify
}

if ($configFile."Install-Bitwarden") {
	scoop install extras/bitwarden
}

if ($configFile."Install-Firefox") {
	scoop install extras/firefox
}

if ($configFile."Install-PowerToys") {
	scoop install extras/powertoys
}

if ($configFile."Install-Responsively") {
	scoop install responsively
}

if ($configFile."Install-pnpm") {
	scoop install main/pnpm
}



# Easter egg ;)
if ($configFile."Funny-joe-biden") {
	$images = (Invoke-WebRequest "https://raw.githubusercontent.com/likes-gay/win-config/main/photos.txt").Content.Split([Environment]::NewLine)

	# Create folder to store downloaded images in to prevent clutter.
	$downloadPath = "$env:USERPROFILE\Downloads\likes-gay-images"
	if (!(test-path $downloadPath)) {
		New-Item -ItemType Directory -Path $downloadPath
	}

	foreach ($i in $images) {
		# Get the name of the image from the URL
		# Windows will not open images in the photo viewer unless they have a file extension.
		$imageName = $i.split("/")[$i.split("/").Count - 1]

		# Download and open the image
		Invoke-WebRequest -Uri $i -OutFile $downloadPath\$imageName
		Start-Process $downloadPath\$imageName
	}
}

Exit
