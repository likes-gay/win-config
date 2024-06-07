Set WshShell = WScript.CreateObject("WScript.Shell")
WshShell.Run "%windir%\system32\control.exe /name Microsoft.DefaultPrograms /page pageDefaultProgram\pageAdvancedSettings?pszAppName=MSEdgeHTM"
WScript.Sleep 2000
WshShell.SendKeys "{TAB}"
WScript.Sleep 100
WshShell.SendKeys "{TAB}"
WScript.Sleep 100
WshShell.SendKeys "{TAB}"
WScript.Sleep 100
WshShell.SendKeys "{TAB}"
WScript.Sleep 100
WshShell.SendKeys "{TAB}"
WScript.Sleep 100
WshShell.SendKeys " "
WScript.Sleep 100
WshShell.SendKeys " "
WScript.Sleep 100
WshShell.SendKeys "%{F4}"
WScript.Sleep 200
WScript.Quit