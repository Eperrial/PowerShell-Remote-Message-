$ADCheck=@(Get-ADComputer -filter "*" -Properties IPv4address -SearchBase "OU=IT,OU=Beziers,OU=COMPUTERS,OU=ADEP,DC=adep,DC=local" |Where-Object {$_.ipv4address} |  Select-Object -Property ipv4address,Name)
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

foreach($select in $oui){
    if($select.Ping -like "Ok" -and $select.Service -like "Ok"){Write-host "L'IP : "$select.Ip "d'utilisateur" $select.Name "a reussi les deux test"}
    if($select.Ping -like "Ok" -and $select.Service -like "Erreur"){Write-host "L'IP : "$select.Ip "d'utilisateur" $select.Name "a reussi les deux test"}
    if($select.Ping -like "Erreur"){Write-Host "L'IP : "$select.Ip "d'utilisateur" $select.Name "a echoue les deux test"}
}

    