#functions
function UnPin-App { param(
	[string]$appname
)
try {
	((New-Object -Com Shell.Application).NameSpace("shell:::{4234d49b-0245-4df3-b780-3893943456e1}").Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace("&", "") -match "Unpin from taskbar"} | %{$_.DoIt()}
	return "App "$appname" unpinned from Taskbar"
} catch {
	Write-Error "Error Unpinning App! (App-Name correct?)"
}
}

UnPin-App "Microsoft Edge"
UnPin-App "Microsoft Store"
UnPin-App "Mail"

# Turns on dark mode for apps and system
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name AppsUseLightTheme -Value 0 -Type Dword
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name SystemUsesLightTheme -Value 0 -Type Dword

# Remove task view
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0

# Turn on file extensions in File Explorer
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0

# Hide desktop icons
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideIcons" -Value 1
Stop-Process -processName: Explorer # Restart explorer to apply above two changes

# Enable the clipboard history
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Clipboard" -Name "EnableClipboardHistory" -Value 1

# Set print screen to open snipping tool
Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "PrintScreenKeyForSnippingEnabled" -Value 1 -Type Dword

# Set scroll lines to 7
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

# Setup edge redirect - https://github.com/rcmaehl/MSEdgeRedirect/wiki/Deploying-MSEdgeRedirect
Invoke-WebRequest "https://github.com/rcmaehl/MSEdgeRedirect/releases/latest/download/MSEdgeRedirect.exe" -OutFile MSEdgeRedirect.exe
Invoke-WebRequest "https://raw.githubusercontent.com/likes-gay/win-config/main/edge_redirect.ini" -OutFile edge_redirect.ini
Start-Process MSEdgeRedirect.exe -ArgumentList "/silentinstall","edge_redirect.ini" -PassThru
Remove-Item -Path "MSEdgeRedirect.exe"
Remove-Item -Path "edge_redirect.ini"

Stop-Process -Name msedge -Force # Close the trash browser :(
Stop-Process -Name Teams -Force

Set-Content -Path $originalFile -Value $content

# Open useful tabs
Start-Process "chrome.exe" "https://www.bbc.co.uk/news"
Start-Process "chrome.exe" "https://github.com/login"
Start-Process "chrome.exe" "https://teams.microsoft.com/v2"
Start-Process "chrome.exe" "https://office.com"

# Easter egg ;)
Invoke-WebRequest -Uri https://upload.wikimedia.org/wikipedia/commons/1/1f/Joe_Biden_81st_birthday.jpg -OutFile $env:USERPROFILE\Downloads\Joe_Biden_81st_birthday.jpg
Start-Process $env:USERPROFILE\Downloads\Joe_Biden_81st_birthday.jpg