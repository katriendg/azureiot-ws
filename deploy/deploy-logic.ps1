# This script simplifies ARM deployment.

[CmdletBinding()]
Param(
  
  [Parameter(Mandatory=$True)]
  [string]$SubscriptionName,
  
  [Parameter(Mandatory=$True)]
  [string]$DeploymentPrefix,

  [Parameter(Mandatory=$True)]
  [string]$EmailAddress,

  [Parameter(Mandatory=$False)]
  [string]$ArtifactsRootDir #optional for running locally, required for used by VSTS to pass current artifacts root dir

)


$ErrorActionPreference = "Stop"

#deployment of Resource group assumes identical prefix. change here if desired
$RGName = "$DeploymentPrefix-rg"
$logicApp = "$DeploymentPrefix-logic"


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
    -Name "logic" `
    -ResourceGroupName $RGName `
    -TemplateFile "$scriptDir/templates/logicapp.json" `
    -logicAppName "$logicApp" `
    -emailAddress "$EmailAddress"


Write-Host "Finished provisioning the solution - new deployment Logic app"
Write-Warning "The Logic app is in disabled state by default, first authenticate the O365 connection and then enable"







