Import-Module Microsoft.Graph

Connect-MgGraph -Scopes "Group.Read.All", "User.Read.All"

$teams = Get-MgGroup -Filter "resourceProvisioningOptions/Any(x:x eq 'Team')"

foreach ($team in $teams) {
    $channels = Get-MgTeamChannel -TeamId $team.Id
    
    foreach ($channel in $channels) {
        $owners = Get-MgGroupOwner -GroupId $team.Id | Select-Object DisplayName, UserPrincipalName
        
        Write-Host "Owners for Team: $($team.DisplayName), Channel: $($channel.DisplayName):"
        $owners | Format-Table -Property DisplayName, UserPrincipalName -AutoSize

        $ownerInfo = $owners | ForEach-Object {
            if ($_.DisplayName -and $_.UserPrincipalName) {
                "$($_.DisplayName) <$($_.UserPrincipalName)>"
            } else {
                "Owner details incomplete"
            }
        } -join ", "

        if (-not $ownerInfo) {
            $ownerInfo = "Unknown Owner"
        }

        $channelDetails = [PSCustomObject]@{
            "Team Name" = $team.DisplayName
            "Channel Name" = $channel.DisplayName
            "Owners" = $ownerInfo
        }
        $channelDetails | Format-Table -AutoSize
    }
}

Disconnect-MgGraph
