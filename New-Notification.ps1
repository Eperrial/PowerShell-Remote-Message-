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
    $Text  = New-BTText -Text $Title
    $Text0 = New-BTText -Text $Body
    #Set image to the local machine
    $image = New-BTImage -Source 'C:\ADEP\icone-adep.ico' -AppLogoOverride -Crop Circle
    #Set Audio with Event Default by Windows
    $Audio = New-BTAudio -Source "ms-winsoundevent:Notification.Default"
    $Id= New-BTAppId -AppId 'Informatique'
    #Make Burned Toast 
    $binding = New-BTBinding -Children $Text, $Text0 -AppLogoOverride $image
    $visual = New-BTVisual -BindingGeneric $binding
    #Use Scripts environnement for later 
    $Script:content = New-BTContent -Visual $visual -Audio $Audio
    #Launch Notification on the local computer 
    Submit-BTNotification -Content $Script:content 
    }


#Fonction qui va boucler à l'infini pour lire le descriptif de son service
function OnStart() {
    param ()
#Pas besoin de paramètre, elle est suffisante à elle même
while ($true) {
#Verifie le service qui est en cours d'exécution et ne prend que la valeur du DisplayName
$Verif=(Get-Service -Name ReceptNotifAdep | Select-Object -ExpandProperty DisplayName)
#Phrase pour voir si la boucle à bien lieu
#Write-Host "Here we go again !"
#Vérifie sur le Display name si le nom du service à été modifié ou non
if($Verif -notlike "ADEPNotif"){
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
Start-Sleep -Seconds 25
}

Start-Sleep -Seconds 15 
#On sleep un temps déterminé, pour éviter une loop trop répétitive 
}}

OnStart

