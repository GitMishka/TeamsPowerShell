# Connect to Exchange Online
$UserCredential = Get-Credential
Connect-ExchangeOnline -Credential $UserCredential -ShowProgress $true

$AllTeamsInOrg = (Get-Team).GroupID
$TeamList = @()

foreach ($Team in $AllTeamsInOrg)
{
    $TeamGUID = $Team.ToString()
    $TeamGroup = Get-UnifiedGroup -Identity $TeamGUID
    $TeamName = (Get-Team | Where-Object {$_.GroupID -eq $Team}).DisplayName
    $TeamOwner = (Get-TeamUser -GroupId $Team | Where-Object {$_.Role -eq 'Owner'}).User
    $TeamUsers = Get-TeamUser -GroupId $Team
    $TeamUserCount = $TeamUsers.Count
    $GuestUsers = $TeamUsers | Where-Object {$_.User -like '*#EXT#*'} | Select-Object -ExpandProperty User
    $TeamGuest = if ($GuestUsers) {$GuestUsers -join ', '} else {"No Guests in Team"}
    $TeamChannels = (Get-TeamChannel -GroupId $Team).DisplayName
    $ChannelCount = (Get-TeamChannel -GroupId $Team).Count
    $TeamList += [PSCustomObject]@{
        TeamName = $TeamName;
        TeamObjectID = $TeamGUID;
        TeamOwners = ($TeamOwner -join ', ');
        TeamMemberCount = $TeamUserCount;
        NoOfChannels = $ChannelCount;
        ChannelNames = ($TeamChannels -join ', ');
        SharePointSite = $TeamGroup.SharePointSiteURL;
        AccessType = $TeamGroup.AccessType;
        TeamGuests = $TeamGuest
    }
}

$TeamList | Export-Csv -Path 'c:\temp\TeamsDatav2.csv' -NoTypeInformation
Write-Host "Data exported to 'c:\temp\TeamsDatav2.csv'"
