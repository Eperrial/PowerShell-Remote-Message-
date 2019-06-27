#Script pour l'utilisateur admin

function Notification () {
    Param(
        [script]$ville,
        [script]$groupe,
        [script]$titre,
        [script]$texte
    )
    $Script:ADCheck = Recup -ville $ville -groupe $groupe 
    Foreach($ip in $Script:ADCheck){
    Set-Service -Name ReceptNotifAdep -ComputerName $ip -DisplayName "Titre:"+$texte+"Body:"+$titre
    }
    Start-Sleep -Seconds 15
    Foreach($ip in $Script:ADCheck){
    Set-Service -Name ReceptNotifAdep -ComputerName $ip -DisplayName "ADEPNotif"
    }
    }


function Recup (){
    Param(
    [string]$ville,
    [string]$groupe
    )
    #Met le bon formatage pour la commande Get-ADComputer
    if ($ville)
    {
        $ville="OU=$ville,"
    }
    if ($groupe)
    {
        $groupe="OU=$groupe,"
    }

    #Vérification visuel que les arguments sont bien traités
    Write-Host ville : $ville
    Write-Host groupe : $groupe

    #Va chercher dans l'AD les @IP de chaque ordinateurs étant dans la hierachie : computeurs,ADEP,adep,local
    $Script:ADCheck = @(Get-ADComputer -filter "*" -Properties IPv4address -SearchBase "$groupe $ville OU=COMPUTERS,OU=ADEP,DC=adep,DC=local" |Where-Object {$_.ipv4address -and $_.Name} |  Select-Object -Property ipv4address, Name)

    #Fait sortir $ADCheck de la fonction
    return $Script:ADCheck
    }

    #Fonction pour afficher
    function Afficher ($tab){

    #Parcours le tableau et saute la boucle sur une case se trouve vide
    for($i=0; $tab[$i];$i++){
    if ([string]::IsNullOrEmpty($tab[$i])){
    Write-Output "La valeur IP est vide - Suivant."
    break 
    }
    Write-Host $tab[$i]
    }}