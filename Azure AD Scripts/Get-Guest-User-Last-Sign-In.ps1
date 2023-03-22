<#
    Author: Sean McAvinue
    Contact: Sean@seanmcavinue., Twitter: @Sean_McAvinue
    .SYNOPSIS
    Gets guest users last sign in action from AAD logs and exports user and signin list to CSV in C:\temp
 

#>
Connect-azuread
##Get all guest users
$guests = Get-AzureADUser -Filter "userType eq 'Guest'" -All $true 

##Loop Guest Users
foreach ($guest in $guests) {

    ##Get logs filtered by current guest
    $logs = Get-AzureADAuditSignInLogs -Filter "userprincipalname eq `'$($guest.mail)'" -ALL:$true 

    ##Check if multiple entries and tidy results
    if ($logs -is [array]) {
        $timestamp = $logs[0].createddatetime
    }
    else {
        $timestamp = $logs.createddatetime
    }

    ##Build Output Object
    $object = [PSCustomObject]@{

        Userprincipalname = $guest.userprincipalname
        Mail              = $guest.mail
        LastSignin        = $timestamp
        AppsUsed          = (($logs.resourcedisplayname | select -Unique) -join (';'))
    }

    ##Export Results
    $object | export-csv C:\temp\GuestUserSignins.csv -NoTypeInformation -Append

    Remove-Variable object
}



