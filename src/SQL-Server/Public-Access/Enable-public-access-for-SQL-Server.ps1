[CmdletBinding()]
param (
    [Parameter()]
    [String] $sqlServerResourceGroupName,

    [Parameter()]
    [String] $sqlServerName
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Host "Checking if public access is enabled"
if((Invoke-Executable az sql server show --name $sqlServerName --resource-group $sqlServerResourceGroupName | ConvertFrom-Json).publicNetworkAccess -eq "Disabled")
{
     # Update setting for Public Network Access
     Write-Host "Public access is disabled. Enabling it now."
     Invoke-Executable az sql server update --name $sqlServerName --resource-group $sqlServerResourceGroupName --set publicNetworkAccess="Enabled"
}