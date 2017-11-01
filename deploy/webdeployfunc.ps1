[CmdletBinding()]
Param(
  
  [Parameter(Mandatory=$True)]
  [string]$SubscriptionName,

  [Parameter(Mandatory=$True)]
  [string]$DeploymentPrefix
  
)

#deployment of Resource group assumes identical prefix. change here if desired
$RGName = "$DeploymentPrefix-rg"
$functionName = "$DeploymentPrefix-func"


Select-AzureRmSubscription -SubscriptionName $SubscriptionName
Write-Host "Selected subscription: $SubscriptionName"


# Determine current working directory:
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
$parentDirectoryPath = (Get-Item $directorypath).Parent.FullName

# Constants:
$webAppPublishingProfileFileName = $directorypath + "\function.publishsettings"
Write-Host "Web publishing profile will be stored to: $webAppPublishingProfileFileName"

# Determine which directory to deploy:
 $sourceDirToDeploy = $parentDirectoryPath + "\src\functions\"

# Select Subscription:
Get-AzureRmSubscription -SubscriptionName "$SubscriptionName" | Select-AzureRmSubscription
Write-Host "Selected Azure Subscription"

# Fetch publishing profile for web app:
Get-AzureRmWebAppPublishingProfile -Name $functionName -OutputFile $webAppPublishingProfileFileName -ResourceGroupName $RGName
Write-Host "Fetched Azure Web App Publishing Profile: $webAppPublishingProfileFileName"

# Parse values from .publishsettings file:
[Xml]$publishsettingsxml = Get-Content $webAppPublishingProfileFileName
$websiteName = $publishsettingsxml.publishData.publishProfile[0].msdeploySite
Write-Host "web site name: $websiteName"

$username = $publishsettingsxml.publishData.publishProfile[0].userName
Write-Host "user name: $username"

$password = $publishsettingsxml.publishData.publishProfile[0].userPWD
Write-Host "password: $password"

$computername = $publishsettingsxml.publishData.publishProfile[0].publishUrl
Write-Host "computer name: $computername"

# Deploy the function app - each folder under the /src/functions/ root is a new function
$msdeploy = "C:\Program Files (x86)\IIS\Microsoft Web Deploy V3\msdeploy.exe"

$msdeploycommand = $("-verb:sync -source:contentPath=`"{0}`" -dest:contentPath=`"{1}`",computerName=https://{2}/msdeploy.axd?site={3},userName={4},password={5},authType=Basic"   -f $sourceDirToDeploy, $websiteName, $computername, $websiteName, $username, $password)

Start-Process $msdeploy -NoNewWindow -ArgumentList $msdeploycommand -PassThru -Wait

#remove publish profile from disk
Remove-Item -Path  $webAppPublishingProfileFileName
