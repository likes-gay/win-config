function UnPin-App { param(
		[string]$appname
	)
	((New-Object -Com Shell.Application).NameSpace("shell:::{4234d49b-0245-4df3-b780-3893943456e1}").Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace("&","") -match "Unpin from taskbar"} | %{$_.DoIt()}
}

UnPin-App "Microsoft Edge"
UnPin-App "Microsoft Store"
UnPin-App "Mail"

# Turns on dark mode for apps and system
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0 -Type Dword -Force
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name SystemUsesLightTheme -Value 0 -Type Dword -Force

# Remove task view
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowTaskViewButton -Value 0 -Force

# Enable the clipboard history
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Clipboard -Name EnableClipboardHistory -Value 1

# Set print screen to open snipping tool
Set-ItemProperty -Path HKCU:\Control Panel\Keyboard -Name PrintScreenKeyForSnippingEnabled -Value 1 -Type Dword

# Change default browser to Chrome
$originalFile = "C:\Windows\System32\OEMDefaultAssociations.xml"
$content = Get-Content $originalFile

# Replace the Microsoft Edge associations with Google Chrome
$content = $content.Replace('<Association Identifier="http" ProgId="AppXq0fevzme2pys62n3e0fbqa7peapykr8v" ApplicationName="Microsoft Edge" />', '<Association Identifier="http" ProgId="ChromeHTML" ApplicationName="Google Chrome" />')
$content = $content.Replace('<Association Identifier="https" ProgId="AppX90nv6nhay5n6a98fnetv7tpk64pp35es" ApplicationName="Microsoft Edge" />', '<Association Identifier="https" ProgId="ChromeHTML" ApplicationName="Google Chrome" />')
$content = $content.Replace('<Association Identifier=".htm" ProgId="AppX4hxtad77fbk3jkkeerkrm0ze94wjf3s9" ApplicationName="Microsoft Edge" />', '<Association Identifier=".htm" ProgId="ChromeHTML" ApplicationName="Google Chrome" />')
$content = $content.Replace('<Association Identifier=".html" ProgId="AppX4hxtad77fbk3jkkeerkrm0ze94wjf3s9" ApplicationName="Microsoft Edge" />', '<Association Identifier=".html" ProgId="ChromeHTML" ApplicationName="Google Chrome" />')

Set-Content -Path $originalFile -Value $content

# Open useful tabs
Start-Process "chrome.exe" "https://www.bbc.co.uk/news","--profile-directory="Default""
Start-Process "chrome.exe" "https://github.com/login","--profile-directory="Default""
Start-Process "chrome.exe" "https://teams.microsoft.com/","--profile-directory="Default""
Start-Process "chrome.exe" "https://office.com","--profile-directory="Default""

# Close the trash browser
Stop-Process -Name msedge -Force


# Easter egg ;)
Invoke-WebRequest -Uri https://upload.wikimedia.org/wikipedia/commons/1/1f/Joe_Biden_81st_birthday.jpg -OutFile $env:USERPROFILE\Downloads\Joe_Biden_81st_birthday.jpg
Start-Process $env:USERPROFILE\Downloads\Joe_Biden_81st_birthday.jpg