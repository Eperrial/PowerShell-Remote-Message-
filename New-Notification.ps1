#Check if Module BurntToast has on the computer
if(Get-Module -Name BurntToast ){
    
}else {
    Write-Host "Burnt Toast n'est pas installe, veuillez demander e votre administrateur"
    Import-Module -Name BurntToast

}

#Function to create message box with parameter
function NewBox(){
    Param (
         #Title of the Notification
    [string]$Title,
        #Main text 
    [string]$Body,
         #Signature of admin //W-I-P 
    [string]$signature
    )
    #Initiate some $var to Text in Notification
    $Text1  = New-BTText -Text $Title
    $Text2 = New-BTText -Text $Body
    #Set image to the local machine
    $image1 = New-BTImage -Source 'C:\ADEP\icone-adep.ico' -AppLogoOverride -Crop Circle
    #Set Audio with Event Default by Windows
    $Audio1 = New-BTAudio -Source "ms-winsoundevent:Notification.Default"
    #Make Burned Toast 
    $binding1 = New-BTBinding -Children $Text1, $Text2 -AppLogoOverride $image1
    $visual1 = New-BTVisual -BindingGeneric $binding1
    #Use Scripts environnement for later 
    $Script:content1 = New-BTContent -Visual $visual1 -Audio $Audio1
    #Launch Notification on the local computer 
    Submit-BTNotification -Content $content1
    }

function OnStart() {
    param ()

while ($true) {

$Verif=(Get-Service -Name ReceptNotifAdep1 -ComputerName "VM-W10-05-01"| Select-Object -ExpandProperty DisplayName)
Write-Host "Shit, here we go again"
if($Verif -notlike "ADEPNotif1"){
$Verif -match '^Titre:(?<a>.+)\sBody:(?<b>.+)'
$Titre=$Matches.a
$Body=$Matches.b
Write-Host $Titre
Write-Host $Body   
NewBox -Title $Titre -Body $Body
}

Start-Sleep -Seconds 1
if($Verif -notlike "ADEPNotif1"){
Set-Service -ComputerName "VM-W10-05-01" -Name ReceptNotifAdep1 -DisplayName "ADEPNotif1" 
}}}


