[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $SqlServerName,
    [Parameter(Mandatory)][string] $SqlServerResourceGroupName,
    [Parameter()][string] $AccessRuleName,
    [Parameter()][ValidatePattern('^$|^(?:(?:\d{1,3}.){3}\d{1,3})(?:\/(?:\d{1,2}))?$', ErrorMessage = "The text '{0}' does not match with the CIDR notation, like '1.2.3.4/32'")][string] $CIDRToRemoveFromWhitelist,
    [Parameter()][string] $SubnetName,
    [Parameter()][string] $VnetName,
    [Parameter()][string] $VnetResourceGroupName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$sqlServerLowerCase = $SqlServerName.ToLower()

if ($CIDRToRemoveFromWhitelist -and $SubnetName -and $VnetName -and $VnetResourceGroupName)
{
    throw "You can not enter a CIDRToWhitelist (CIDR whitelisting) in combination with SubnetName, VnetName, VnetResourceGroupName (Subnet whitelisting). Choose one of the two options."
}

# Autogenerate CIDR if no CIDR or Subnet is passed
if (!$CIDRToRemoveFromWhitelist -and !$AccessRuleName -and (!$SubnetName -or !$VnetName -or !$VnetResourceGroupName))
{
    $response = Invoke-WebRequest 'https://ipinfo.io/ip'
    $CIDRToRemoveFromWhitelist = $response.Content.Trim() + '/32'
}

# Fetch Subnet ID when subnet option is given.
if ($SubnetName -and $VnetName -and $VnetResourceGroupName)
{
    $subnetResourceId = (Invoke-Executable az network vnet subnet show --resource-group $VnetResourceGroupName --name $SubnetName --vnet-name $VnetName | ConvertFrom-Json).id
}

if (!$subnetResourceId)
{
    Remove-FirewallRulesIfExists -ServiceType 'sql' -ResourceGroupName $SqlServerResourceGroupName -ResourceName $sqlServerLowerCase -AccessRuleName:$AccessRuleName -CIDR:$CIDRToRemoveFromWhitelist
}
else
{
    Remove-VnetRulesIfExists -ServiceType 'sql' -ResourceGroupName $SqlServerResourceGroupName -ResourceName $sqlServerLowerCase -AccessRuleName:$AccessRuleName -SubnetResourceId:$subnetResourceId
}

Write-Footer -ScopedPSCmdlet $PSCmdlet