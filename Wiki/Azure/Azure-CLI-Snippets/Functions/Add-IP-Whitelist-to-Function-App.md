[[_TOC_]]

# Description
This snippet will Add an IP range from the whitelist so that the function app or SCM-part of the function app can be accessed by the given ip range. Please note that does not work if the function app has a private endpoint. So this should not work for a regular function app that is bound to the compliancy rules.

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Required | Example Value | Description |
|--|--|--|--|
| FunctionAppResourceGroupName | <input type="checkbox" checked> | `MyTeam-SomeApi-$(Release.EnvironmentName)` | The resourcegroup where the AppService resides in. |
| FunctionAppName | <input type="checkbox" checked> | `Function-App-name` | Name of the app service to set the whitelist on. | 
| AccessRestrictionRuleName | <input type="checkbox"> | `company hq` | You can override the name for this accessrule. If you leave this empty, the `CIDRToWhitelist` will be used for the naming (automatically). We recommend to leave this empty for ephemeral whitelists like Azure DevOps Hosted Agent ip's. |
| AccessRestrictionRuleDescription | <input type="checkbox"> | `Some machine in our network` | Description of the Rule to add to the whitelist  |
| CIDRToWhitelist | <input type="checkbox"> | `1.2.3.4/32` | IP range in [CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) notation that should be whitelisted. If you leave this value empty, it will whitelist the machine's ip where you're running the script from. |  
| FunctionAppDeploymentSlotName | <input type="checkbox"> | `staging` | Name of the deployment slot to add ip whitelisting to. This is an optional field. |
| AccessRestrictionAction | <input type="checkbox"> | `Deny` | The access restriction can be changed here. Value can be 'Allow' or 'Deny'. Default value is 'Allow' (this is an optional field). | 
| Priority | <input type="checkbox"> | `10` | The priority can be changed here. Default value is '10' (this is an optional field) |
| ApplyToAllSlots | <input type="checkbox"> | `$true`/`$false` | Applies the current script to all slots revolving this resource |
| ApplyToMainEntrypoint | <input type="checkbox"> | `$true`/`$false` | Allows you to enable/disable applying this rule to the main entrypoint of this webapp. Defaults to `$true` |
| ApplyToScmEntrypoint | <input type="checkbox"> | `$true`/`$false` | Allows you to enable/disable applying this rule to the scm entrypoint of this webapp. Defaults to `$true` |


# Code
[Click here to download this script](../../../../src/Functions/Add-IP-Whitelist-to-Function-App.ps1)

#Links

- [CIDR notation](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing)
- [Azure cli access restriction](https://docs.microsoft.com/en-us/cli/azure/functionapp/config/access-restriction?view=azure-cli-latest#az_functionapp_config_access_restriction)
