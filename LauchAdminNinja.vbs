Set oWShell = CreateObject("Wscript.Shell")
oWShell.Run """start test powershell.exe -command  start-process -filepath C:\ADEP\PowerShell\test.ps1 -windowstyle hidden""",2
Set oWSHell = Nothing 