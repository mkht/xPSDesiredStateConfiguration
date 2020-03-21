[CmdletBinding()]
param (
    [string]$AzDOAccountName = 'mkht',
    [string]$AzDOProjectName = 'xPsDesiredStateConfiguration',
    [string]$AzDOArtifactFeedName = 'mkhtPSRepository',
    [string]$AzDOPat = $(secret.AzDOPAT),
    [string]$ModuleFolderPath = (Join-Path -Path $env:SYSTEM_ARTIFACTSDIRECTORY -ChildPath "output\xPSDesiredStateConfiguration")
)

$ErrorActionPreference = 'Stop'

# Variables
$packageSourceUrl = "https://pkgs.dev.azure.com/$AzDOAccountName/$AzDOProjectName/_packaging/$AzDOArtifactFeedName/nuget/v2" # NOTE: v2 Feed

# Create credential
$env:VSS_NUGET_EXTERNAL_FEED_ENDPOINTS = "{`"endpointCredentials`": [{`"endpoint`":`"$packageSourceUrl`", `"username`":`"$AzDOAccountName`", `"password`":`"$AzDOPat`"}]}"

# Register feed
$registerParams = @{
    Name                      = $AzDOArtifactFeedName
    SourceLocation            = $packageSourceUrl
    PublishLocation           = $packageSourceUrl
    InstallationPolicy        = 'Trusted'
    PackageManagementProvider = 'NuGet'
    Verbose                   = $true
}
Register-PSRepository @registerParams

# Publish PowerShell module
$publishParams = @{
    Path        = $ModuleFolderPath
    Repository  = $AzDOArtifactFeedName
    NugetApiKey = 'AzureDevOpsServices'
    Force       = $true
    Verbose     = $true
    Credential  = $credential
}
Publish-Module @publishParams
