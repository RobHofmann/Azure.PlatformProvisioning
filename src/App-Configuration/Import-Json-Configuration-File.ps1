[CmdletBinding()]
param (
    [Parameter()]
    [String] $appConfigName,

    [Parameter()]
    [String] $label,

    [Parameter()]
    [String] $jsonFilePath,

    [Parameter()]
    [String] $keyValuePairSeparator = ":",

    [Parameter()]
    [String] $keyPrefix
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

Invoke-Executable az appconfig kv import --name $appConfigName --label $label --source file --path $jsonFilePath --format json --separator $keyValuePairSeparator --prefix $keyPrefix --yes

Write-Footer