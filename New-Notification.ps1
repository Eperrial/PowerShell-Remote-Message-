if(Get-Module -Name BurntToast ){

}else {
    Write-Host "Burnt Toast n'est pas installé, veuillez demander à votre administrateur"
}

function Parameter(){
    Param (
    [string]$Title,
    [string]$Body,
    [string]$signature
    )
    $Text1  = New-BTText -Text $Title
    $Text2 = New-BTText -Text $Body
    $image1 = New-BTImage -Source 'C:\ADEP\icone-adep.ico' -AppLogoOverride -Crop Circle
    $Audio1 = New-BTAudio -Source "ms-winsoundevent:Notification.Default"
    $binding1 = New-BTBinding -Children $Text1, $Text2 -AppLogoOverride $image1
    $visual1 = New-BTVisual -BindingGeneric $binding1
    $Script:content1 = New-BTContent -Visual $visual1 -Audio $Audio1
    Submit-BTNotification -Content $content1
    }


