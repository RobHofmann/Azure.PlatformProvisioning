[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $ContainerRegistryName,
    [Parameter(Mandatory)][string] $ContainerRegistryResourceGroupName,
    [Parameter()][string] $CIDRToWhitelist
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if(!$CIDRToWhitelist)
{
    $response  = Invoke-WebRequest 'https://ipinfo.io/ip'
    $CIDRToWhitelist = $response.Content.Trim()
    $CIDRToWhitelist += '/32'
}

Invoke-Executable az acr network-rule add --name $ContainerRegistryName --resource-group $ContainerRegistryResourceGroupName --ip-address $CIDRToWhitelist

Write-Footer -ScopedPSCmdlet $PSCmdlet