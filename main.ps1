#functions
function UnPin-App { param(
	[string]$appname
)
	try {
		((New-Object -Com Shell.Application).NameSpace("shell:::{4234d49b-0245-4df3-b780-3893943456e1}").Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace("&", "") -match "Unpin from taskbar"} | %{$_.DoIt()}
		return "App '$appname' unpinned from Taskbar"
	} catch {
		Write-Error "Error Unpinning App! (Is '$appname' correct?)"
	}
}

# Download user config file
try {
	Invoke-WebRequest "https://raw.githubusercontent.com/likes-gay/win-config/main/configs/$Env:UserName.json" -outfile "config.json"
} catch {
	Write-Output "No config file detected, please create one in this folder: https://github.com/likes-gay/win-config/blob/main/configs/"
	Exit
}

# Parse config file
try {
	$configFile = Get-Content .\config.json -Raw | ConvertFrom-Json
	
} catch {
	Write-Error "Malformed config file"
	Exit
}

# Delete config file after use
Remove-Item -Path .\config.json

# Install git
if ($configFile."Install-git") {
	Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
	winget install --id Git.Git -e --source winget
}

# Unpin unused apps from the taskbar
if ($configFile."Unpin-apps") {
	UnPin-App "Microsoft Edge"
	UnPin-App "Microsoft Store"
	UnPin-App "Mail"
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

# Set task bar search type
if ($configFile.'Task-bar-search-mode') {
	$taskBarSearchModeRegKey = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
	if ($configFile.'Task-bar-search-mode' -eq "Hidden") {
		Set-ItemProperty -Path $taskBarSearchModeRegKey -Name "SearchboxTaskbarMode" -Value 0
	}
	
	if ($configFile.'Task-bar-search-mode' -eq "Icon") {
		Set-ItemProperty -Path $taskBarSearchModeRegKey -Name "SearchboxTaskbarMode" -Value 1
	}
	
	if ($configFile.'Task-bar-search-mode' -eq "Bar") {
		Set-ItemProperty -Path $taskBarSearchModeRegKey -Name "SearchboxTaskbarMode" -Value 2
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
	Set-ItemProperty -Path $explorer -Name "UseWin32TrayClockExperience" -Value 0 -Force
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

# Set default browser to Chrome
if ($configFile."Default-browser-chrome") {
	Invoke-WebRequest "https://raw.githubusercontent.com/likes-gay/win-config/main/default_browser.vbs" -OutFile .\default_browser.vbs
	Invoke-Expression "Cscript.exe .\default_browser.vbs //nologo"
	Remove-Item -Path ".\default_browser.vbs"

	# Setup edge redirect - https://github.com/rcmaehl/MSEdgeRedirect/wiki/Deploying-MSEdgeRedirect
	if ($configFile."Setup-edge-redirect") {
		Invoke-WebRequest "https://github.com/rcmaehl/MSEdgeRedirect/releases/latest/download/MSEdgeRedirect.exe" -OutFile .\MSEdgeRedirect.exe
		Invoke-WebRequest "https://raw.githubusercontent.com/likes-gay/win-config/main/edge_redirect.ini" -OutFile .\edge_redirect.ini
		Start-Process "MSEdgeRedirect.exe" -ArgumentList "/silentinstall",".\edge_redirect.ini" -PassThru
		Remove-Item -Path ".\edge_redirect.ini"
		Remove-Item -Path ".\MSEdgeRedirect.exe"
	}
}


if ($configFile."Close-edge") {
	try {
		Stop-Process -Name msedge -Force
	} catch {
		Write-Output "Microsoft Edge is already shut"
	}
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

# Set accent colour from config file
if ($configFile."Accent-colour") {
	$ColorValue = $configFile."Accent-colour".Split(" ") | ForEach-Object { "0x$_" }
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" -Name "AccentPalette" -Value ([byte[]]$ColorValue)
}

	$ColorValue = $configFile."Accent-colour".Split(" ") | ForEach-Object { "0x$_" }

if ($configFile."Accent-colour-on-task-bar") {
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "ColorPrevalence" -Value 1
}

Stop-Process -processName: Explorer # Restart explorer to apply changes that require it

# Easter egg ;)
if ($configFile."Funny-joe-biden") {
	$images = (Invoke-WebRequest "https://raw.githubusercontent.com/likes-gay/win-config/main/photos.txt").Content.Split([Environment]::NewLine)


	# Create folder to store downloaded images in to prevent clutter.
	$downloadPath = $env:USERPROFILE + "\Downloads\likes-gay-images"
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
