#reset de quelque variable
$groupe= $null
$ville=$null
$Script:TableauRPRS= $null
$Script:TableauRPRS= @()
#Script pour l'utilisateur l'émetteur
function Notification (){
    Param(
        [string]$ville,
        [string]$groupe,
        [string]$titre,
        [string]$texte
    )
    Recup -ville $ville -groupe $groupe
    Write-Host "Oui mais non"
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        Foreach($ip in $Script:TableauRPRS){
        #Set-Service -Name ReceptNotifAdep -ComputerName $ip -DisplayName "Titre:"+$titre+"Body:"+$texte
        Write-Host "OUI : $ip"
        }
        Write-Host "Oui mais non1"
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    for($i=0;$i -le 15;$i++)
    {
        Start-Sleep -Seconds 1
        $a=15-$i
        Write-Host "$a seconde avant le retablissement d'ADEPNotif"
    }
    Write-Host "Oui mais non2"
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        Foreach($ip in $Script:TableauRPRS){
        #Set-Service -Name ReceptNotifAdep -ComputerName $ip -DisplayName "ADEPNotif"
        Write-Host "NON : $ip"
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Write-Host "Oui mais non3"
}}

function Recup (){
    Param(
    [string]$ville,
    [string]$groupe
    )
    #Met le bon formatage pour la commande Get-ADComputer
    if ($ville)
    {$ville="OU=$ville,"}
    if ($groupe)
    {$groupe="OU=$groupe,"}
    #Vérification visuel que les arguments sont bien traités
    Write-Debug "ville : $ville"
    Write-Debug "groupe : $groupe"
    #Va chercher dans l'AD les @IP de chaque ordinateurs étant dans la hierachie : computeurs,ADEP,adep,local
    $ADCheck=@(Get-ADComputer -filter "*" -Properties IPv4address -SearchBase $groupe$ville"OU=COMPUTERS,OU=ADEP,DC=adep,DC=local" |Where-Object {$_.ipv4address} |  Select-Object -Property ipv4address,Name)
    Write-Host "//////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host "Chemin dans l'AD :"
    Write-Host $groupe$ville"OU=COMPUTERS,OU=ADEP,DC=adep,DC=local"
    Write-Host "//////////////////////////////////////////////////////////////////////////////////////////////////"
    $Script:oui = $ADCheck | Start-RSJob -Name {$_} -Throttle $env:NUMBER_OF_PROCESSORS  -ScriptBlock {
        param($ip)
                if(Test-Connection -Count 1 -ComputerName $ip.ipv4address -Quiet)
                {
                    #Write-Host "Ping sur $ip Reussi" 
                    try
                    {
                        if(Get-Service -Name ReceptAdepNotif)
                        {
                            #Write-Host "L'ordinateur d'ip : $ip à bien reussi le test du ping et du service"
                            [PSCustomObject]@{
                                Name = $ip.Name
                                Ip= $ip.ipv4address
                                Ping = "Ok"
                                Service = "Ok"
                            }
                        }
                        else
                        {
                        #Write-Host "L'ordinateur d'ip : $ip à échoué dans le test du service mais est accessible !"  
                            [PSCustomObject]@{
                                Name = $ip.Name
                                Ip= $ip.ipv4address
                                Ping = "Ok"
                                Service = "Erreur"            
                            }
                        }
                    }      
                catch{}
                }
                else
                {
                    #Write-Host "Ping sur $ip : Echoue" 
                    [PSCustomObject]@{
                        Name = $ip.Name
                        Ip= $ip.ipv4address
                        Ping = "Erreur"
                        Service = "Erreur"
                    }
                }
        }| Wait-RSJob | Receive-RSJob 
        foreach($select in $Script:oui){
            if($select.Ping -like "Ok" -and $select.Service -like "Ok"){$Script:TableauRPRS+=$select.Ip}
        }

}
    
#Equivalent du main 
$ville= Read-Host "Entrez la ville que vous souhaitez viser (non obligatoire)"
if($ville)
{$groupe= Read-Host "Vous pouvez entrer le deuxieme argument pour completer le chemin dans l'AD (non obligatoire)"}
$titre= Read-Host "Le titre de la notification"
$texte= Read-Host "Le corps de texte de la notification"

Notification -ville $ville -groupe $groupe -titre $titre -texte $texte

foreach($select in $Script:oui){
    if($select.Ping -like "Ok" -and $select.Service -like "Ok")
    {Write-host  -ForegroundColor Green "IP :"$select.Ip "USER :" $select.Name "|| PING: |OK| -- SERVICE: |OK|"
    $Script:TableauRPRS}
    if($select.Ping -like "Ok" -and $select.Service -like "Erreur")
    {Write-host  -ForegroundColor Yellow "IP :"$select.Ip "USER :" $select.Name "|| PING: |OK| -- SERVICE: |ERREUR|"}
    if($select.Ping -like "Erreur")
    {Write-Host  -ForegroundColor Red "IP :"$select.Ip "USER :" $select.Name "|| PING: |ERREUR| -- SERVICE: |ERREUR|"}
}