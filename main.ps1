#functions

function UnPin-App { param(
        [string]$appname
    )
    try {
        ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'Unpin from taskbar'} | %{$_.DoIt()}
        return "App '$appname' unpinned from Taskbar"
    } catch {
        Write-Error "Error Unpinning App! (App-Name correct?)"
    }
}

UnPin-App "Edge"
UnPin-App "Microsoft Store"
UnPin-App "Mail"

# Remove task view
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0 -Force

# Enable the clipboard history
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Clipboard -Name EnableClipboardHistory -Value 0

# Turns on dark mode, for some reasons we create it
New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0 -Type Dword -Force

# Close the SHIT browser
Stop-Process -Name msedge -Force

# Define the path to the registry key
$registryPath = ""

# Define the ProgId for the browser you want to set as default
# For Google Chrome, it's "ChromeHTML"
$browserProgId = "ChromeHTML"

# Change the default browser
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice -Name ProgId -Value ChromeHTML

# Open useful tabs
Start-Process "chrome.exe" "https://www.bbc.co.uk/news",'--profile-directory="Default"'
Start-Process "chrome.exe" "https://github.com/login",'--profile-directory="Default"'
Start-Process "chrome.exe" "https://teams.microsoft.com/",'--profile-directory="Default"'
Start-Process "chrome.exe" "https://office.com",'--profile-directory="Default"'