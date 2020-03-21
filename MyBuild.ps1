<#

.DESCRIPTION
 Build script for xPsDesiredStateConfiguration forked by mkht

#>
[CmdletBinding()]
param(
    [Parameter()]
    [String]
    $Author = 'mkht',

    [Parameter()]
    [String]
    $CompanyName = 'mkht',

    [Parameter()]
    [String]
    $moduleVersion = '9.1.0'
)

Begin
{
    $ErrorActionPreference = 'Stop'

    $OutputDirectory = 'output'
    $CopyDirectories = @(
        'source\en-US',
        'source\DSCResources',
        'source\Modules',
        'source\ResourceDesignerScripts'
    )

    Set-Location $PSScriptRoot
    if (Test-Path -LiteralPath $OutputDirectory -PathType Container)
    {
        Remove-Item -LiteralPath $OutputDirectory -Force -Recurse
    }

    New-Item $OutputDirectory -ItemType Directory
}

Process
{
    # Copy module files
    $CopyDirectories.ForEach( {
            Copy-Item -LiteralPath (Join-Path $PWD $_) -Destination $OutputDirectory -Force -Recurse
        })

    # Create module manifest
    $SourceManifest = 'source\xPSDesiredStateConfiguration.psd1'
    Copy-Item -Path (Join-Path $PWD $SourceManifest) -Destination $OutputDirectory -Force
    Update-ModuleManifest -Path (Join-Path $OutputDirectory 'xPSDesiredStateConfiguration.psd1') -Author $Author -CompanyName $CompanyName -ModuleVersion $moduleVersion
}
