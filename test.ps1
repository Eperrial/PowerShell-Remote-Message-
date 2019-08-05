$Script:TableauReussi=@()
$Script:TableauEchP=@()
$Script:TableauRPES=@()
$Script:TableauRPRS=@()
foreach($ip in $ADCheck)
{
    if(Test-NetConnection $ip | Select-Object -ExpandProperty PingSucceeded)
    {
        Write-Host "Ping sur $ip Reussi" 
        try {
            
            if(Get-Service -Name ReceptAdepNotif)
            {
            Write-Debug "L'ordinateur d'ip : $ip à bien reussi le test du ping et du service"
            $Script:TableauRPRS += $ip
            }
            else
            {
            Write-Debug "L'ordinateur d'ip : $ip à échoué dans le test du service mais est accessible !"  
            $Script:TableauRPES += $ip
            }
        }
        catch{}
    }
    else
    {
        Write-Host "Ping sur $ip : Echoue" 
        $Script:TableauEchP += $ip
    }
}
#Fait sortir $ADCheck de la fonction
return $Script:TableauRPRS
}