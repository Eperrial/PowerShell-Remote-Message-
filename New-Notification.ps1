
#Check if Module BurntToast has on the computer


if(Get-Module -Name BurntToast ){}else {
    if(-not (Test-Path "C:\ADEP\PowerShell")){
        New-Item -ItemType Directory -Name "PowerShell"
        Invoke-WebRequest -Uri "https://github.com/Windos/BurntToast/releases/download/v0.6.2/BurntToast.zip" -OutFile "C:\temp\BunrtToast.zip"
        Unblock-File "C:\temp\BurntToast.zip"
        Expand-Archive "C:\temp\BurntToast.zip" -DestinationPath "C:\ADEP\PowerShell\"
    
    } else {
        Invoke-WebRequest -Uri "https://github.com/Windos/BurntToast/releases/download/v0.6.2/BurntToast.zip" -OutFile "C:\temp\BunrtToast.zip"
        Unblock-File "C:\temp\BurntToast.zip"
        Expand-Archive "C:\temp\BurntToast.zip" -DestinationPath "C:\ADEP\PowerShell\"
    }
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


#Fonction qui va boucler à l'infini pour lire le descriptif de son service
function OnStart() {
    param ()
#Pas besoin de paramètre, elle est suffisante à elle même
while ($true) {
#Verifie le service qui est en cours d'exécution et ne prend que la valeur du DisplayName
$Verif=(Get-Service -Name ReceptNotifAdep1 | Select-Object -ExpandProperty DisplayName)
#Phrase pour voir si la boucle à bien lieu
#Write-Host "Here we go again !"
#Vérifie sur le Display name si le nom du service à été modifié ou non
if($Verif -notlike "ADEPNotif1"){
#Si oui, alors le format à du changer en Titre:XXX et Body:XXX , la regex suivant permet de 
#couper la chaine comme je le souhaite et avec le -match et de le mettre dans des variables 
$Verif -match '^Titre:(?<a>.+)\sBody:(?<b>.+)'
$Titre=$Matches.a
$Body=$Matches.b
#Pour le débug
#Write-Host $Titre
#Write-Host $Body   
#Lance la fonction pour faire une notification sur le poste local.
NewBox -Title $Titre -Body $Body
}
#On sleep un temps déterminé, pour éviter une loop trop répétitive 
Start-Sleep -Seconds 15
#Et on vérifie que le DisplayName est changé pour éviter de spam le changement
if($Verif -notlike "ADEPNotif1"){
Set-Service -Name ReceptNotifAdep1 -DisplayName "ADEPNotif1" 
}}}

OnStart
