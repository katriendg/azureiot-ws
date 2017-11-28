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

  [Parameter(Mandatory=$True)]
  [string]$EmailAddress,
  
  [Parameter(Mandatory=$False)]
  [string]$TsiOwnerServicePrincipalObjectId, #optional for running locally, required for used by VSTS to pass desired TSI principal

  [Parameter(Mandatory=$False)]
  [string]$ArtifactsRootDir #optional for running locally, required for used by VSTS to pass current artifacts root dir

)


$ErrorActionPreference = "Stop"


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

Write-Host "Part 1 - base services provision 'deploy.ps1'"

& "$scriptDir\deploy.ps1" -SubscriptionName $SubscriptionName -DeploymentPrefix $DeploymentPrefix -Location $Location -TsiOwnerServicePrincipalObjectId $TsiOwnerServicePrincipalObjectId -ArtifactsRootDir $ArtifactsRootDir

Write-Host "Part 1 finished"

Write-Host "Part 2 - Provisioning Logic App"

& "$scriptDir\deploy-logic.ps1" -SubscriptionName $SubscriptionName -DeploymentPrefix $DeploymentPrefix -EmailAddress $EmailAddress -ArtifactsRootDir $ArtifactsRootDir


Write-Host "Part 2 finished"

Write-Host "Part 3 - Provisioning Stream analytics"

& "$scriptDir\deploy-asa.ps1" -SubscriptionName $SubscriptionName -DeploymentPrefix $DeploymentPrefix -ArtifactsRootDir $ArtifactsRootDir

Write-Host "Part 3 finished"

Write-Host "Part 4 A - Provisioning Function app"

& "$scriptDir\deploy-function.ps1" -SubscriptionName $SubscriptionName -DeploymentPrefix $DeploymentPrefix -ArtifactsRootDir $ArtifactsRootDir

Write-Host "Part 4 finished"

Write-Host "Part 4 B - Deploying sample function code with webdeploy"

& "$scriptDir\webdeployfunc.ps1" -SubscriptionName $SubscriptionName -DeploymentPrefix $DeploymentPrefix

Write-Host "Part 4 B finished - DONE"

