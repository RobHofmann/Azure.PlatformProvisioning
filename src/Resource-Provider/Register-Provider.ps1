[CmdletBinding()]
param (
    [Alias("Namespace")]
    [Parameter(Mandatory)][string] $ResourceProviderNamespace
)
#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

Invoke-Executable az provider register --namespace $ResourceProviderNamespace

Write-Footer