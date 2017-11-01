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
$functionName = "$DeploymentPrefix-func"

#when running local code, use relative path to script, if on VSTS, the artifacts dir is different
if ($ArtifactsRootDir){
    $scriptDir = $ArtifactsRootDir
}else{
    $scriptDir = Split-Path $MyInvocation.MyCommand.Path
}

Select-AzureRmSubscription -SubscriptionName $SubscriptionName
Write-Host "Selected subscription: $SubscriptionName"


#proviation function with ARM template
 New-AzureRmResourceGroupDeployment -Verbose -Force -ErrorAction Stop `
    -Name "func" `
    -ResourceGroupName $RGName `
    -TemplateFile "$scriptDir/templates/function.json" `
    -functionAppName $functionName


