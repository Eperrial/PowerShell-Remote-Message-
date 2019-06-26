#Check if Module BurntToast has on the computer
if(Get-Module -Name BurntToast ){

}else {
    Write-Host "Burnt Toast n'est pas installé, veuillez demander à votre administrateur"
}

#Function to create message box with parameter
function Parameter(){
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


