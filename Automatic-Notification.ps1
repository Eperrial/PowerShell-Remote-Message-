Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip {
    param( [string]$ziparchive, [string]$extractpath )
	[System.IO.Compression.ZipFile]::ExtractToDirectory( $ziparchive, $extractpath )
}

#Check if Module BurntToast has on the computer
if(Get-Module -Name BurntToast )
{
    start-process PowerShell.exe -arg "C:\ADEP\PowerShell\New-Notification.ps1" -WindowStyle Hidden 
}
else 
{
$user=[Environment]::UserName
try{New-Item -Name "WindowsPowerShell" -ItemType Directory -Path C:\Users\$user\Documents}
catch{}
try{New-Item -Name "modules" -ItemType Directory -Path "C:\Users\$user\Documents\WindowsPowerShell"}
catch{}
Copy-Item -Path "P:\BurntToast.zip" -Destination "C:\Users\$user\Documents\WindowsPowerShell\modules"
Unblock-File "C:\Users\$user\Documents\WindowsPowerShell\modules\BurntToast.zip"
Unzip "C:\Users\$user\Documents\WindowsPowerShell\modules\BurntToast.zip" "C:\Users\$user\Documents\WindowsPowerShell\modules"
Remove-Item "C:\Users\$user\Documents\WindowsPowershell\modules\BurntToast.zip"
Import-Module -Name BurntToast
if (Get-Module -Name BurntToast)
{
    start-process PowerShell.exe -arg "C:\ADEP\PowerShell\New-Notification.ps1" -WindowStyle Hidden 
}
}