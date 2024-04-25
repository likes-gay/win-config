#functions
function UnPin-App { param(
	[string]$appname
)
try {
	((New-Object -Com Shell.Application).NameSpace("shell:::{4234d49b-0245-4df3-b780-3893943456e1}").Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace("&", "") -match "Unpin from taskbar"} | %{$_.DoIt()}
	return "App '$appname' unpinned from Taskbar"
} catch {
	Write-Error "Error Unpinning App! (App-Name correct?)"
}
}

UnPin-App "Microsoft Edge"
UnPin-App "Microsoft Store"
UnPin-App "Mail"

# Turns on dark mode for apps and system
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0 -Type Dword -Force
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name SystemUsesLightTheme -Value 0 -Type Dword -Force

# Remove task view
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0 -Force

# Hide desktop icons
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideIcons" -Value 1 -Force
Stop-Process -processName: Explorer # Restart explorer to apply above two changes

# Enable the clipboard history
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Clipboard" -Name EnableClipboardHistory -Value 1

# Set print screen to open snipping tool
Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name PrintScreenKeyForSnippingEnabled -Value 1 -Type Dword

# Setup edge redirect - https://github.com/rcmaehl/MSEdgeRedirect/wiki/Deploying-MSEdgeRedirect
Invoke-WebRequest https://github.com/rcmaehl/MSEdgeRedirect/releases/latest/download/MSEdgeRedirect.exe -OutFile .\MSEdgeRedirect.exe
Start-Process MSEdgeRedirect.exe -ArgumentList "/silentinstall",".\edge_redirect.ini" -PassThru
Remove-Item -Path ".\MSEdgeRedirect.exe"

# Close the trash browser :(
Stop-Process -Name msedge -Force

Set-Content -Path $originalFile -Value $content

# Open useful tabs
Start-Process "chrome.exe" "https://www.bbc.co.uk/news"
Start-Process "chrome.exe" "https://github.com/login"
Start-Process "chrome.exe" "https://teams.microsoft.com/"
Start-Process "chrome.exe" "https://office.com"


# Easter egg ;)
Invoke-WebRequest -Uri https://upload.wikimedia.org/wikipedia/commons/1/1f/Joe_Biden_81st_birthday.jpg -OutFile $env:USERPROFILE\Downloads\Joe_Biden_81st_birthday.jpg
Start-Process $env:USERPROFILE\Downloads\Joe_Biden_81st_birthday.jpg