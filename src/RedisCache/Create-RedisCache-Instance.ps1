[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $RedisInstanceLocation,
    [Parameter(Mandatory)][string] $RedisInstanceName,
    [Parameter(Mandatory)][string] $RedisInstanceResourceGroupName,
    [Parameter(Mandatory)][ValidateSet('Basic', 'Standard', 'Premium')][string] $RedisInstanceSkuName,
    [Parameter(Mandatory)][ValidateSet('C0', 'C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'P1', 'P2', 'P3', 'P4', 'P5')][string] $RedisInstanceVmSize,
    [Parameter()][bool] $RedisInstanceEnableNonSslPort = $false,
    [Parameter()][ValidateSet('', '1.0', '1.1', '1.2')][string] $RedisInstanceMinimalTlsVersion = '1.2',
    [Parameter(Mandatory)][System.Object[]] $ResourceTags,
    
    # Private Endpoints
    [Parameter()][string] $RedisInstancePrivateEndpointVnetResourceGroupName,
    [Parameter()][string] $RedisInstancePrivateEndpointVnetName,
    [Parameter()][string] $RedisInstancePrivateEndpointSubnetName,
    [Parameter()][string] $RedisInstancePrivateDnsZoneName = 'privatelink.redis.cache.windows.net',
    [Parameter()][string] $DNSZoneResourceGroupName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Create Redis Instance.
if(!(Invoke-Executable -AllowToFail az redis show --name $RedisInstanceName --resource-group $RedisInstanceResourceGroupName))
{
    $additionalParameters = @()
    if ($RedisInstanceEnableNonSslPort) {
        $additionalParameters += '--enable-non-ssl-port'
    }
    if ($RedisInstanceMinimalTlsVersion) {
        $additionalParameters += '--minimum-tls-version', $RedisInstanceMinimalTlsVersion
    }
    if ($RedisInstanceSubnetId) {
        $additionalParameters += '--subnet-id', $RedisInstanceSubnetId
    }
    Invoke-Executable az redis create --name $RedisInstanceName --resource-group $RedisInstanceResourceGroupName --sku $RedisInstanceSkuName --vm-size $RedisInstanceVmSize --location $RedisInstanceLocation --tags ${ResourceTags} @additionalParameters
    while(((Invoke-Executable az redis show --name $RedisInstanceName --resource-group $RedisInstanceResourceGroupName) | ConvertFrom-Json).provisioningState -eq 'Creating')
    {
        Write-Host "Redis still creating... waiting for it to complete..."
        Start-Sleep -Seconds 60
    }
}

if ($RedisInstancePrivateEndpointVnetResourceGroupName -and $RedisInstancePrivateEndpointVnetName -and $RedisInstancePrivateEndpointSubnetName -and $RedisInstancePrivateDnsZoneName -and $DNSZoneResourceGroupName)
{
    Write-Host "A private endpoint is desired. Adding the needed components."
    # Fetch needed information
    $redisInstanceResourceId = (Invoke-Executable az redis show --name $RedisInstanceName --resource-group $RedisInstanceResourceGroupName | ConvertFrom-Json).id
    $vnetId = (Invoke-Executable az network vnet show --resource-group $RedisInstancePrivateEndpointVnetResourceGroupName --name $RedisInstancePrivateEndpointVnetName | ConvertFrom-Json).id
    $redisInstancePrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $RedisInstancePrivateEndpointVnetResourceGroupName --name $RedisInstancePrivateEndpointSubnetName --vnet-name $RedisInstancePrivateEndpointVnetName | ConvertFrom-Json).id
    $redisInstancePrivateEndpointName = "$($RedisInstanceName)-pvtredis"

    # Add private endpoint & Setup Private DNS
    Add-PrivateEndpoint -PrivateEndpointVnetId $vnetId -PrivateEndpointSubnetId $redisInstancePrivateEndpointSubnetId -PrivateEndpointName $redisInstancePrivateEndpointName -PrivateEndpointResourceGroupName $RedisInstanceResourceGroupName -TargetResourceId $redisInstanceResourceId -PrivateEndpointGroupId redisCache -DNSZoneResourceGroupName $DNSZoneResourceGroupName -PrivateDnsZoneName $RedisInstancePrivateDnsZoneName -PrivateDnsLinkName "$($RedisInstancePrivateEndpointVnetName)-redis"
}

Write-Footer -ScopedPSCmdlet $PSCmdlet