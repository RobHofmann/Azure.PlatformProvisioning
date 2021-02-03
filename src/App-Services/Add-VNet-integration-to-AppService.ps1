[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $AppServiceResourceGroupName,
    [Parameter(Mandatory)][string] $AppServiceName,
    [Alias("VnetName")]
    [Parameter(Mandatory)][string] $AppServiceVnetIntegrationVnetName,
    [Parameter(Mandatory)][string] $AppServiceVnetIntegrationSubnetName,
    [Parameter()][string] $AppServiceSlotName
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

$fullAppServiceName = $AppServiceName
$additionalParameters = @()

if ($AppServiceSlotName) {
    $additionalParameters += '--slot' , $AppServiceSlotName
    $fullAppServiceName += " [$AppServiceSlotName]"
}

$vnetIntegrations = Invoke-Executable az webapp vnet-integration list --resource-group $AppServiceResourceGroupName --name $AppServiceName @additionalParameters | ConvertFrom-Json
$matchedIntegrations = $vnetIntegrations | Where-Object  vnetResourceId -like "*/providers/Microsoft.Network/virtualNetworks/$AppServiceVnetIntegrationVnetName/subnets/$AppServiceVnetIntegrationSubnetName"
if ($matchedIntegrations) {
    Write-Host "VNET Integration found for $fullAppServiceName"
}
else {
    Write-Host "VNET Integration NOT found, adding it to $fullAppServiceName"
    Invoke-Executable az webapp vnet-integration add --resource-group $AppServiceResourceGroupName --name $AppServiceName --vnet $AppServiceVnetIntegrationVnetName --subnet $AppServiceVnetIntegrationSubnetName @additionalParameters
    Invoke-Executable az webapp restart --name $AppServiceName --resource-group $AppServiceResourceGroupName @additionalParameters
}

# Set WEBSITE_VNET_ROUTE_ALL=1 for vnet integration
Invoke-Executable az webapp config appsettings set --resource-group $AppServiceResourceGroupName --name $AppServiceName @additionalParameters --settings "WEBSITE_VNET_ROUTE_ALL=1"

Write-Footer