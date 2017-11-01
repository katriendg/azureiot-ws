# This script simplifies ARM deployment.
# For completing the architecture there are four scripts:
# deploy.ps1 - this one for provisioning the key services
# deploy-logic.ps1 - provisions the logic app - requires the deploy.ps1 to have been executed
# deploy-asa.ps1 - provision the Stream analytics job with an input and output, Service Bus Queue, adds a consumer group to IoT Hub

[CmdletBinding()]
Param(
  
  [Parameter(Mandatory=$True)]
  [string]$SubscriptionName,
  
  [Parameter(Mandatory=$True)]
  [string]$DeploymentPrefix,

  [Parameter(Mandatory=$True)]
  [string]$Location,
  
  [Parameter(Mandatory=$False)]
  [string]$TsiOwnerServicePrincipalObjectId, #optional for running locally, required for used by VSTS to pass desired TSI principal

  [Parameter(Mandatory=$False)]
  [string]$ArtifactsRootDir #optional for running locally, required for used by VSTS to pass current artifacts root dir

)


$ErrorActionPreference = "Stop"

#deployment of Resource group assumes identical prefix. change here if desired
$RGName = "$DeploymentPrefix-rg"
$IoTHubName = "$DeploymentPrefix-hub"
$IoTSkuName = "S1"
$TsiEnvironmentName = "$DeploymentPrefix-tsi"
$storageAccountIot = $DeploymentPrefix + "stor"
$routeColdContainerName = "archivetelemetry"

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

if(!$TsiOwnerServicePrincipalObjectId){
    Write-Host "No principal supplied, getting current user"

    $account = $(Get-AzureRmContext).Account
    Write-Host "Account type: $account"
    if($account.AccountType -eq "User"){
       $TsiOwnerServicePrincipalObjectId = $(Get-AzureRmADUser -UserPrincipalName $account.Id).Id
       Write-Host "Using the TsiOwnerServicePrincipalObjectId gotten via current user context"
    }else{
       throw "Current context is probably a Service Principal. Provide the desired owner GUID via parameter TsiOwnerServicePrincipalObjectId"
    }

}


Select-AzureRmSubscription -SubscriptionName $SubscriptionName
Write-Host "Selected subscription: $SubscriptionName"

# Find existing or deploy new Resource Group:
$rg = Get-AzureRmResourceGroup -Name $RGName -ErrorAction SilentlyContinue
if (-not $rg)
{
    New-AzureRmResourceGroup -Name "$RGName" -Location "$Location"
    Write-Host "New resource group deployed: $RGName"   
}
else{ Write-Host "Resource group found: $RGName"}


# Create Storage Account and container - needed to setup Routing to Storage (ARM can create the storage account but not the container)
$storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $RGName -Name $storageAccountIot -ErrorAction SilentlyContinue
if(!$storageAccount){
  $storageAccount = New-AzureRmStorageAccount -ResourceGroupName $RGName -Name $storageAccountIot -Location $Location -SkuName "Standard_LRS"
  Write-Host "New storage account created: $storageAccountIot"
}
else{ 
    Write-Host "Storage account already exists, nothing updated: $storageAccountIot"
}

# Create container for cold storage route destination, if not existing
$ctx = $storageAccount.Context
$routeContainer = New-AzureStorageContainer -Name $routeColdContainerName -Permission Off -Context $ctx -ErrorAction SilentlyContinue


#deploy resource group
 New-AzureRmResourceGroupDeployment -Verbose -Force -ErrorAction Stop `
    -Name "iot" `
    -ResourceGroupName $RGName `
    -TemplateFile "$scriptDir/templates/iot.json" `
    -iotHubName $IoTHubName `
    -iotSkuName $IoTSkuName `
    -tsiEnvironmentName $TsiEnvironmentName `
    -tsiOwnerServicePrincipalObjectId $TsiOwnerServicePrincipalObjectId `
    -storageNameCold $storageAccountIot `
    -routeContainerName $routeColdContainerName 


Write-Host "Finished provisioning the solution - with Storage and routing"






