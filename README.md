[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3a%2f%2fraw.githubusercontent.com%2feamonoreilly%2fStartStopPowerShellFunction%2fmaster%2fazuredeploy.json) 
<a href="http://armviz.io/#/?load=https%3a%2f%2fraw.githubusercontent.com%2feamonoreilly%2fStartStopPowerShellFunction%2fmaster%2fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

# Sample to Start or Stop VMs using a timer trigger

The deployment creates an [Azure function](https://learn.microsoft.com/en-us/azure/azure-functions/) application and (deploy)[https://learn.microsoft.com/en-us/azure/azure-functions/functions-create-first-function-resource-manager?tabs=azure-cli] functions that starts or stops virtual machines[https://learn.microsoft.com/en-us/azure/virtual-machines/overview] in the specified resource group or, subscription.

---
## Prerequisites

Before running this sample, you must have the following:

+ Install [Azure Core Tools version 2.x](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local)

+ Install the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)


## How it works
---
### Create a new resource group and function application on Azure

Run the following PowerShell command and specify the value for the function application name in the TemplateParameterObject hashtable.

```powershell
New-AzResourceGroup -Name <resource-group-name> -Location <resource-group-location> #use this command when you need to create a new resource group for your deployment

New-AzResourceGroupDeployment -ResourceGroupName <resource-group-name> -TemplateUri https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/quickstarts/microsoft.web/functions-managed-identity/azuredeploy.json
```

This should create a new resource group with a function application and a managed service identity enabled. The id of the service principal for the MSI should be returned as an output from the deployment.

Example: principalId    String   cac1fa06-2ad8-437d-99f6-b75edaae2921

[Install and configure Azure PowerShell](https://azure.microsoft.com/en-us/documentation/articles/powershell-install-configure/)

### Grant the managed service identity contributor access to the subscription or resource group so it can perform actions

The below command sets the access at the subscription level.

```powershell
$Context = Get-AzContext
New-AzRoleAssignment -ObjectId <principalId> -RoleDefinitionName Contributor -Scope "/subscriptions/$($Context.Subscription)"
```

### Clone repository or download files to local machine

+ Download the repository files or clone to local machine.

+ Change to the PowerShell/StartStopVMOnTimer directory.

### Get the local.settings.json values from the function application created in Azure

```powershell
func azure functionapp fetch-app-settings <function app name>
```

This should create a local.settings.json file in the StartStopVMOnTimer directory beside the host.json with the settings from the Azure function app.

### Test the functions locally

Start the function with the following command

```powershell
func start
```

You can then call a trigger function by performing a post against the function on the admin api. Open up another Powershell console session and run:

```powershell
Invoke-RestMethod "http://localhost:7071/admin/functions/StartVMOnTimer" -Method post -Body '{}' -ContentType "application/json"
```

Modify the start and stop time in the function.json file. They are currently set to 8am and 8pm UTC. You can change the timezone by modifying the application setting WEBSITE_TIME_ZONE.

```json
{
  "disabled": false,
  "bindings": [
    {
      "name": "Timer",
      "type": "timerTrigger",
      "direction": "in",
      "schedule": "0 0 20 * * *"
    }
  ]
}
```

## Publish the functions to the function application in Azure

```powershell
func azure functionapp publish <function app name>
```

## Shout Out.

This repo was created off [eamonoreilly](https://github.com/eamonoreilly/StartStopPowerShellFunction)'s repo.