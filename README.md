# Win Config

Quickly configure Windows with the **objectively** best settings

## To add your own configuration

Please create a [pull request](https://github.com/likes-gay/win-config/pulls), and create a JSON file in the [configs directory](https://github.com/likes-gay/win-config/tree/main/configs). The file's name should be your username.

To see examples of what the file should be like, view other JSON files in there.

# The Options

All the options can all be found in the [configs' README.md](https://github.com/likes-gay/win-config/tree/main/configs#settings-documentation).

And all these different options are configurable per user.
It works by finding their config based off of the computer's username.

# To Run

## Single command to download and run the script

### Updated PowerShell command

```powershell
iwr "https://github.com/likes-gay/win-config/releases/latest/download/main.ps1" -OutFile main.ps1; .\main.ps1
```

### Legacy CMD command

```cmd
curl -L -o likes-gay-config.exe https://github.com/likes-gay/win-config/releases/latest/download/likes-gay-config.exe && likes-gay-config.exe && del likes-gay-config.exe
```

## Using a Rubber Ducky (badusb) to run the script

Upload the [`payload.dd`](https://github.com/likes-gay/win-config/blob/main/payload.dd) to your USB
