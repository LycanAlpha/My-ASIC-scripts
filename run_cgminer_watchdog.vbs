Set WshShell = CreateObject("WScript.Shell")
WshShell.CurrentDirectory = "C:\Users\YoungWolf\Documents"
WshShell.Run """C:\Program Files\Git\bin\bash.exe"" -i -c 'sh cgminer_watchdog.sh'", 0
