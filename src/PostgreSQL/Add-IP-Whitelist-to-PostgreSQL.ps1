[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $PostgreSqlServerName,
    [Parameter(Mandatory)][string] $PostgreSqlServerResourceGroupName,
    [Parameter()][string] $AccessRuleName,
    [Parameter()][ValidatePattern('^$|^(?:(?:\d{1,3}.){3}\d{1,3})(?:\/(?:\d{1,2}))?$', ErrorMessage = "The text '{0}' does not match with the CIDR notation, like '1.2.3.4/32'")][string] $CIDRToWhitelist,
    [Parameter()][string] $SubnetName,
    [Parameter()][string] $VnetName,
    [Parameter()][string] $VnetResourceGroupName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if ($CIDRToWhitelist -and $SubnetName -and $VnetName -and $VnetResourceGroupName)
{
    throw "You can not enter a CIDRToWhitelist (CIDR whitelisting) in combination with SubnetName, VnetName, VnetResourceGroupName (Subnet whitelisting). Choose one of the two options."
}

# Autogenerate CIDR if no CIDR or Subnet is passed
if (!$CIDRToWhitelist -and (!$SubnetName -or !$VnetName -or !$VnetResourceGroupName))
{
    $response = Invoke-WebRequest 'https://ipinfo.io/ip'
    $CIDRToWhitelist = $response.Content.Trim() + '/32'
}

# Fetch Subnet ID when subnet option is given.
if ($SubnetName -and $VnetName -and $VnetResourceGroupName)
{
    $subnetResourceId = (Invoke-Executable az network vnet subnet show --resource-group $VnetResourceGroupName --name $SubnetName --vnet-name $VnetName | ConvertFrom-Json).id
}

# Autogenerate name if no name is given
if (!$AccessRuleName -and $CIDRToWhitelist)
{
    $AccessRuleName = ($CIDRToWhitelist -replace "\.", "-") -replace "/", "-"
}
elseif (!$AccessRuleName -and $SubnetName -and $VnetName -and $VnetResourceGroupName)
{
    $AccessRuleName = ToMd5Hash -InputString "$($VnetResourceGroupName)_$($VnetName)_$($SubnetName)_allow"
}

if (!$subnetResourceId)
{
    # Preparation
    $startIpAddress = Get-StartIpInIpv4Network -SubnetCidr $CIDRToWhitelist
    $endIpAddress = Get-EndIpInIpv4Network -SubnetCidr $CIDRToWhitelist

    # Execute whitelist
    Invoke-Executable az postgres server firewall-rule create --resource-group $PostgreSqlServerResourceGroupName --server-name $PostgreSqlServerName --name $AccessRuleName --start-ip-address $startIpAddress --end-ip-address $endIpAddress
}
else
{
    # Add subnet rule
    Invoke-Executable az postgres server vnet-rule create --resource-group $PostgreSqlServerResourceGroupName --server-name $PostgreSqlServerName --name $AccessRuleName --subnet $subnetResourceId
}

Write-Footer -ScopedPSCmdlet $PSCmdlet