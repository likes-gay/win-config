# Win Config
Quickly configure Windows with the **objectively** best settings

# The Options

All the options can all be found in the [configs' README.md](https://github.com/likes-gay/win-config/tree/main/configs#settings-documentation).

And all these different options are configurable per user.
It works by finding their config based off of the computer's username.

# To Run

## Single command to download and run the script

### Updated Powershell command
```powershell
Invoke-WebRequest -Uri "https://github.com/likes-gay/win-config/releases/latest/download/likes-gay-config.exe" -OutFile "likes-gay-config.exe"; Start-Process -FilePath ".\likes-gay-config.exe" -Wait; Remove-Item -Path "likes-gay-config.exe"
```

### Legacy CMD command
```cmd
curl -L -o likes-gay-config.exe https://github.com/likes-gay/win-config/releases/latest/download/likes-gay-config.exe && likes-gay-config.exe && del likes-gay-config.exe
```

## Using a Rubber Ducky (badusb) to run the script
Upload the [`payload.dd`](https://github.com/likes-gay/win-config/blob/main/payload.dd) to your USB
