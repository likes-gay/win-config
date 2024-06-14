# Settings Documentation

These files should be json in the format below.

For examples of what they should contain, look at the other json files in this folder.

If any keys are missing, then it shouldn't break the code.

## Values

Below the type, there is an example of what it could be.

| Name | Description | Type |
|--- |--- |--- |
| `Unpin-apps` | Unpins Microsoft Edge, Microsoft Store, and Mail from the taskbar | Boolean<br>(`true`/`false`) |
| `Dark-mode` | Turns on dark mode for the computer and apps | Boolean<br>(`true`/`false`) |
| `Remove-task-view` | Removes the task view buttom from the taskbar | Boolean<br>(`true`/`false`) |
| `File-extentions` | Shows the file extensions in File Explorer | Boolean<br>(`true`/`false`) |
| `Remove-desktop-icons` | Hides all the icons on the desktop | Boolean<br>(`true`/`false`) |
| `Seconds-in-clock` | Shows the seconds on the clock in the taskbar | Boolean<br>(`true`/`false`) |
| `12-hr-clock` | Change the clock to be in 12 hours (AM/PM) in the taskbar | Boolean<br>(`true`/`false`) |
| `clipboard-history` | Turns on clipboard history on the clipboard (Windows + V) | Boolean<br>(`true`/`false`) |
| `Print-scrn-snipping-tool` | When print screen (Prt Sc) is pressed, the snipping tool opens, allowing you to take a screenshot | Boolean<br>(`true`/`false`) |
| `Set-scroll-lines` | Changes the scrolling speed of the mouse | Integer between 1 and 100<br>(`3`, `7`) |
| `Enable-live-caption-chrome` | In Google Chrome, this enables the Live Caption setting. Which allows audio without subtitles to have subtitles | Boolean<br>(`true`/`false`) |
| `Default-browser-chrome` | Changes the default web browser to be Google Chrome. This happens by opening settings and moving focus. | Boolean<br>(`true`/`false`) |
| `Setup-edge-redirect` | When opening links from the start menu, these open in Microsoft Edge by default. However, this makes it now open in your default browser. This setting doesn't run when `Default-browser-chrome` is false | Boolean<br>(`true`/`false`) |
| `Close-edge` | Microsoft Edge opens by default. So, this closes it | Boolean<br>(`true`/`false`) |
| `Open-tabs` | This opens all these tabs in your default browser | Array of strings<br>(`["https://google.com", "https://github.com"]`) |
| `Funny-joe-biden` | This downloads and opens a bunch of images of mainly Joe Biden and others. The list of [images that open are here](https://github.com/likes-gay/win-config/blob/main/photos.txt) | Boolean<br>(`true`/`false`) |
| `Accent-colour` | Sets the accent colour of the system | String.<br>[Read here to find how to set the value](#how-to-find-the-accent-colour-value) |
| `Accent-colour-on-task-bar` | Apply the accent colour to the start menu, taskbar and action centre | Boolean<br>(`true`/`false`) |
| `Install-git` | This intalls Git onto the computers, and it also adds it to PATH | Boolean<br>(`true`/`false`) |
| `Task-bar-search-mode` | This changes how the taskbar's search bar appears. It could be hidden, or to show only the icon, or to show the entire bar. | String<br>(`Hidden`/`Icon`/`Bar`) |

## How to find the `Accent-colour` value

Open Settings, go to "Personalization", go to "Colors", and choose a "Window colors".

Then open Registry Editor, and enter `Computer\HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Accent` into the address bar.
Afterwards, right click on "AccentPalette", and press "Modify...", then copy this data into `Accent-colour` in your config file.