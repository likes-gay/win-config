#functions
function UnPin-App { param(
	[string]$appname
)
try {
	((New-Object -Com Shell.Application).NameSpace("shell:::{4234d49b-0245-4df3-b780-3893943456e1}").Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace("&", "") -match "Unpin from taskbar"} | %{$_.DoIt()}
	return "App '$appname' unpinned from Taskbar"
}
catch {
	Write-Error "Error Unpinning App! (Is '$appname' correct?)"
}
}

# Override for the confirm function
$confirmOverride = false

function Confirmation{
	param ([string]$text)

	if ($confirmOverride) {
		return true
 	}

	$option = Read-Host $text "[y/n]"
	if (!(($option -eq "y") -Or ($option -eq "yes")) -And !(($option -eq "n") -Or ($option -eq "no"))) {
		return Confirmation $text
	}

    	return ($option -eq "y") -Or ($option -eq "yes")
}

# Option to accept all the options
if (Confirmation "Apply all options") {
	$confirmOverride = true
}

# Unpin unused apps from the taskbar
if (Confirmation "Unpin unused apps") {
	UnPin-App "Microsoft Edge"
	UnPin-App "Microsoft Store"
	UnPin-App "Mail"
}

# Turns on dark mode for apps and system
if (Confirmation "Turn on dark mode for apps and system") {
	$themesPersonalise = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
	Set-ItemProperty -Path $themesPersonalise -Name "AppsUseLightTheme" -Value 0 -Type Dword
	Set-ItemProperty -Path $themesPersonalise -Name "SystemUsesLightTheme" -Value 0 -Type Dword
}

$explorer = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

# Remove task view
if (Confirmation "Remove task view") {
	Set-ItemProperty -Path $explorer -Name "ShowTaskViewButton" -Value 0
}

# Turn on file extensions in File Explorer
if (Confirmation "Turn on file extensions in File Explorer") {
	Set-ItemProperty -Path $explorer -Name "HideFileExt" -Value 0
}

# Hide desktop icons
if (Confirmation "Hide desktop icons") {
	Set-ItemProperty -Path $explorer -Name "HideIcons" -Value 1
}

# Enable seconds in clock
if (Confirmation "Enable seconds on clock") {
	Set-ItemProperty -Path $explorer -Name "ShowSecondsInSystemClock" -Value 1 -Force
}

# Enable 12 hour time in clock
if (Confirmation "Enable 12 hour time in clock") {
	Set-ItemProperty -Path $explorer -Name "UseWin32TrayClockExperience" -Value 0 -Force
}

# Enable the clipboard history
if (Confirmation "Enable clipboard history") {
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Clipboard" -Name "EnableClipboardHistory" -Value 1
}

# Set print screen to open snipping tool
if (Confirmation "Rebind print screen to open snipping tool") {
	Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "PrintScreenKeyForSnippingEnabled" -Value 1 -Type Dword
}

# Set scroll lines to 7
if (Confirmation "Set scroll lines to 7") {
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

	$scrollSpeed = 7
	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WheelScrollLines" -Value $scrollSpeed
	[WinAPI]::SystemParametersInfo(0x0069, $scrollSpeed, 0, 2)
	[WinAPI]::SendMessageTimeout(0xffff, 0x1a, [IntPtr]::Zero, "Environment", 2, 5000, [IntPtr]::Zero)
}

# Setup edge redirect - https://github.com/rcmaehl/MSEdgeRedirect/wiki/Deploying-MSEdgeRedirect
if (Confirmation "Install and configure MSEdgeRedirect") {
	Invoke-WebRequest "https://github.com/rcmaehl/MSEdgeRedirect/releases/latest/download/MSEdgeRedirect.exe" -OutFile .\MSEdgeRedirect.exe
	Invoke-WebRequest "https://raw.githubusercontent.com/likes-gay/win-config/main/edge_redirect.ini" -OutFile .\edge_redirect.ini
	Start-Process "MSEdgeRedirect.exe" -ArgumentList "/silentinstall",".\edge_redirect.ini" -PassThru
	Remove-Item -Path ".\edge_redirect.ini"
	Remove-Item -Path ".\MSEdgeRedirect.exe"
}

try {
	Stop-Process -Name msedge -Force
} catch {
	Write-Output "Microsoft Edge is already shut"
}

try {
	Stop-Process -Name Teams -Force
} catch {
	Write-Output "Microsoft Teams is already shut"
}

Set-Content -Path $originalFile -Value $content

Stop-Process -processName: Explorer # Restart explorer to apply changes that require it

# Open useful tabs
Start-Process "chrome.exe" "https://www.bbc.co.uk/news"
Start-Process "chrome.exe" "https://github.com/login"
Start-Process "chrome.exe" "https://office.com"
Start-Process "chrome.exe" "https://teams.microsoft.com/v2" -Wait -PassThru

# Easter egg ;)
$images = (Invoke-WebRequest "https://raw.githubusercontent.com/likes-gay/win-config/main/photos.txt").Content.Split([Environment]::NewLine)

# Create folder to store downloaded images in to prevent clutter.
$downloadPath = $env:USERPROFILE + "\Downloads\likes-gay-images"
If (!(test-path $downloadPath)) {
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

exit
