# This script deploys sbasa.json template - it simplifies calling the ARM template by passing a number of parameters
# Pre-requisite: to have deployed deploy.ps1 as this will create the RG and IoT Hub and more. 

[CmdletBinding()]
Param(
  
  [Parameter(Mandatory=$True)]
  [string]$SubscriptionName,
  
  [Parameter(Mandatory=$True)]
  [string]$DeploymentPrefix,

  [Parameter(Mandatory=$False)]
  [string]$ArtifactsRootDir #optional for running locally, required for used by VSTS to pass current artifacts root dir

)


$ErrorActionPreference = "Stop"

#deployment of Resource group assumes identical prefix. change here if desired
$RGName = "$DeploymentPrefix-rg"
$serviceBusNamespaceName = "$DeploymentPrefix-sbqns"
$serviceBusQueueName = "$DeploymentPrefix-qu"
$asaName = "$DeploymentPrefix-asa"
$IoTHubName = "$DeploymentPrefix-hub"


# Check if user is already signed into Azure
try {
    Get-AzureRmContext
} catch {
    Write-Error "Cannot get Azure context, login to Azure using 'Login-AzureRm'"
    Exit
}

#when running local code, use relative path to script, if on VSTS, the artifacts dir is different from the current script's dir
if ($ArtifactsRootDir){
    $scriptDir = $ArtifactsRootDir
}else{
    $scriptDir = Split-Path $MyInvocation.MyCommand.Path
}

Select-AzureRmSubscription -SubscriptionName $SubscriptionName
Write-Host "Selected subscription: $SubscriptionName"

# Find existing or deploy new Resource Group:
$rg = Get-AzureRmResourceGroup -Name $RGName -ErrorAction SilentlyContinue
if (-not $rg)
{
    
    Write-Host "New resource group '$RGName' not found, aborting" 
    Exit
}

#deploy resource group
 New-AzureRmResourceGroupDeployment -Verbose -Force -ErrorAction Stop `
    -Name "asa" `
    -ResourceGroupName $RGName `
    -TemplateFile "$scriptDir/templates/sbasa.json" `
    -serviceBusNamespaceName "$serviceBusNamespaceName" `
    -serviceBusQueueName "$serviceBusQueueName" `
    -asaName "$asaName" `
    -numberOfStreamingUnits 1 `
    -iotHubName "$IoTHubName"


Write-Host "Finished provisioning the solution - new deployment Stream Analytics"
Write-Warning "Azure Stream Analytics job is stopped by default"


#Note for adding the Power BI output in ARM, see https://github.com/Azure/azure-rest-api-specs/blob/current/specification/streamanalytics/resource-manager/Microsoft.StreamAnalytics/2016-03-01/examples/Output_Create_PowerBI.json




