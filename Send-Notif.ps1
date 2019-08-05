#Script pour l'utilisateur l'émetteur
function Notification (){
    Param(
        [string]$ville,
        [string]$groupe,
        [string]$titre,
        [string]$texte
    )
    Recup -ville $ville -groupe $groupe
    Traiment
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    Try
    {
        Foreach($ip in $Script:TableauRPRS){
        Set-Service -Name ReceptNotifAdep -ComputerName $ip -DisplayName "Titre:"+$titre+"Body:"+$texte
        Write-Host "OUI : $ip"
        }
    }
    catch{
       Write-Host "ALED"
    }
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    for($i=0;$i -le 15;$i++)
    {
        Start-Sleep -Seconds 1
        $a=15-$i
        Write-Host "$a seconde avant le retablissement d'ADEPNotif"
    }
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    Try
    {
        Foreach($ip in $Script:TableauRPRS){
        Set-Service -Name ReceptNotifAdep -ComputerName $ip -DisplayName "ADEPNotif"
        Write-Host "NON : $ip"
        }
    }
    catch{}
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}

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
    Write-Debug ville : $ville
    Write-Debug groupe : $groupe
    #Va chercher dans l'AD les @IP de chaque ordinateurs étant dans la hierachie : computeurs,ADEP,adep,local
    $ADCheck=@(Get-ADComputer -filter "*" -Properties IPv4address -SearchBase $groupe$ville"OU=COMPUTERS,OU=ADEP,DC=adep,DC=local" |Where-Object {$_.ipv4address} |  Select-Object -ExpandProperty ipv4address)
    Write-Host "//////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host "Chemin dans l'AD :"
    Write-Host $groupe$ville"OU=COMPUTERS,OU=ADEP,DC=adep,DC=local"
    Write-Host "//////////////////////////////////////////////////////////////////////////////////////////////////"
    $Script:oui = $ADCheck | Start-RSJob -Name {$_} -Throttle $env:NUMBER_OF_PROCESSORS  -ScriptBlock {
    param([string]$ip)
            if(Test-Connection -Count 1 -ComputerName $ip -Quiet)
            {
                #Write-Host "Ping sur $ip Reussi" 
                try
                {
                    if(Get-Service -Name ReceptAdepNotif)
                    {
                        #Write-Host "L'ordinateur d'ip : $ip à bien reussi le test du ping et du service"
                        [PSCustomObject]@{
                            Name = $ip
                            Ping = "Ok"
                            Service = "Ok"
                        }
                    }
                    else
                    {
                    #Write-Host "L'ordinateur d'ip : $ip à échoué dans le test du service mais est accessible !"  
                        [PSCustomObject]@{
                            Name = $ip
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
                    Name = $ip
                    Ping = "Erreur"
                    Service = "Erreur"
                }
            }
    }| Wait-RSJob | Receive-RSJob 
}

function Traitement {
    param ()
    
    
}


    
#Equivalent du main 
$ville= Read-Host "Entrez la ville que vous souhaitez viser (non obligatoire)"
if($ville)
{$groupe= Read-Host "Vous pouvez entrer le deuxieme argument pour completer le chemin dans l'AD (non obligatoire)"}
$titre= Read-Host "Le titre de la notification"
$texte= Read-Host "Le corps de texte de la notification"
Notification -ville $ville -groupe $groupe -titre $titre -texte $texte
Write-Host "//////////////////////////////////////////////////////////////////////////////////////////////////"
Write-Host "Voici les adresses IP qui ont reussi les tests"
$Script:TableauRPRS
Write-Host "//////////////////////////////////////////////////////////////////////////////////////////////////"
Write-Host "Voici les adresses IP qui ont reussi le ping mais echoue dans le check du service"
$Script:TableauRPES
Write-Host "//////////////////////////////////////////////////////////////////////////////////////////////////"
Write-Host "Voici les adresses IP qui n'ont pas repondu au ping "
$Script:TableauEchP
Write-Host "//////////////////////////////////////////////////////////////////////////////////////////////////"