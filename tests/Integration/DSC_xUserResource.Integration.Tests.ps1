<#
    To run these tests, the currently logged on user must have rights to create a user.
    These integration tests cover creating a brand new user, updating values
    of a user that already exists, and deleting a user that exists.
#>
# Suppressing this rule since we need to create a plaintext password to test this resource
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
param ()

$script:dscModuleName = 'xPSDesiredStateConfiguration'
$script:dscResourceName = 'DSC_xUserResource'

try
{
    Import-Module -Name DscResource.Test -Force -ErrorAction 'Stop'
}
catch [System.IO.FileNotFoundException]
{
    throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
}

$script:testEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:dscModuleName `
    -DSCResourceName $script:dscResourceName `
    -ResourceType 'Mof' `
    -TestType 'Integration'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\CommonTestHelper.psm1')
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\DSC_xUserResource.TestHelper.psm1')

# Begin Testing
try
{
    Describe 'xUserResource Integration Tests' {
        $configFile = Join-Path -Path $PSScriptRoot -ChildPath 'DSC_xUserResource.config.ps1'

        $ConfigData = @{
            AllNodes = @(
                @{
                    NodeName = '*'
                    PSDscAllowPlainTextPassword = $true
                }
                @{
                    NodeName = 'localhost'
                }
            )
        }

        Context 'Should create a new user' {
            $configurationName = 'DSC_xUser_NewUser'
            $configurationPath = Join-Path -Path $TestDrive -ChildPath $configurationName

            $logPath = Join-Path -Path $TestDrive -ChildPath 'NewUser.log'

            $testUserName = 'TestUserName12345'
            $testUserPassword = 'StrongOne7.'
            $testDescription = 'Test Description'
            $secureTestPassword = ConvertTo-SecureString $testUserPassword -AsPlainText -Force
            $testCredential = New-Object PSCredential ($testUserName, $secureTestPassword)

            try
            {
                It 'Should compile without throwing' {
                    {
                        . $configFile -ConfigurationName $configurationName
                        & $configurationName -UserName $testUserName `
                                            -Password $testCredential `
                                            -Description $testDescription `
                                            -OutputPath $configurationPath `
                                            -ConfigurationData $ConfigData `
                                            -ErrorAction Stop
                        Start-DscConfiguration -Path $configurationPath -Wait -Force
                    } | Should -Not -Throw
                }

                It 'Should be able to call Get-DscConfiguration without throwing' {
                    { Get-DscConfiguration -ErrorAction Stop } | Should -Not -Throw
                }

                It 'Should return the correct configuration' {
                    $currentConfig = Get-DscConfiguration -ErrorAction Stop
                    $currentConfig.UserName | Should -Be $testUserName
                    $currentConfig.Ensure | Should -Be 'Present'
                    $currentConfig.Description | Should -Be $TestDescription
                    $currentConfig.Disabled | Should -BeFalse
                    $currentConfig.PasswordChangeRequired | Should -Be $null
                }
            }
            finally
            {
                if (Test-Path -Path $logPath) {
                    Remove-Item -Path $logPath -Recurse -Force
                }

                if (Test-Path -Path $configurationPath)
                {
                    Remove-Item -Path $configurationPath -Recurse -Force
                }
            }
        }

        Context 'Should update an existing user' {
            $configurationName = 'DSC_xUser_UpdateUser'
            $configurationPath = Join-Path -Path $TestDrive -ChildPath $configurationName

            $logPath = Join-Path -Path $TestDrive -ChildPath 'UpdateUser.log'

            $testUserName = 'TestUserName12345'
            $testUserPassword = 'StrongOne7.'
            $testDescription = 'New Test Description'
            $secureTestPassword = ConvertTo-SecureString $testUserPassword -AsPlainText -Force
            $testCredential = New-Object PSCredential ($testUserName, $secureTestPassword)

            try
            {
                It 'Should compile without throwing' {
                    {
                        . $configFile -ConfigurationName $configurationName
                        & $configurationName -UserName $testUserName `
                                            -Password $testCredential `
                                            -Description $testDescription `
                                            -OutputPath $configurationPath `
                                            -ConfigurationData $ConfigData `
                                            -ErrorAction Stop
                        Start-DscConfiguration -Path $configurationPath -Wait -Force
                    } | Should -Not -Throw
                }

                It 'Should be able to call Get-DscConfiguration without throwing' {
                    { Get-DscConfiguration -ErrorAction Stop } | Should -Not -Throw
                }

                It 'Should return the correct configuration' {
                    $currentConfig = Get-DscConfiguration -ErrorAction Stop
                    $currentConfig.UserName | Should -Be $testUserName
                    $currentConfig.Ensure | Should -Be 'Present'
                    $currentConfig.Description | Should -Be $TestDescription
                    $currentConfig.Disabled | Should -BeFalse
                    $currentConfig.PasswordChangeRequired | Should -Be $null
                }
            }
            finally
            {
                if (Test-Path -Path $logPath) {
                    Remove-Item -Path $logPath -Recurse -Force
                }

                if (Test-Path -Path $configurationPath)
                {
                    Remove-Item -Path $configurationPath -Recurse -Force
                }
            }
        }

        Context 'Should delete an existing user' {
            $configurationName = 'DSC_xUser_DeleteUser'
            $configurationPath = Join-Path -Path $TestDrive -ChildPath $configurationName

            $logPath = Join-Path -Path $TestDrive -ChildPath 'DeleteUser.log'

            $testUserName = 'TestUserName12345'
            $testUserPassword = 'StrongOne7.'
            $secureTestPassword = ConvertTo-SecureString $testUserPassword -AsPlainText -Force
            $testCredential = New-Object PSCredential ($testUserName, $secureTestPassword)

            try
            {
                It 'Should compile without throwing' {
                    {
                        . $configFile -ConfigurationName $configurationName
                        & $configurationName -UserName $testUserName `
                                            -Password $testCredential `
                                            -OutputPath $configurationPath `
                                            -ConfigurationData $ConfigData `
                                            -Ensure 'Absent' `
                                            -ErrorAction Stop
                        Start-DscConfiguration -Path $configurationPath -Wait -Force
                    } | Should -Not -Throw
                }

                It 'Should be able to call Get-DscConfiguration without throwing' {
                    { Get-DscConfiguration -ErrorAction Stop } | Should -Not -Throw
                }

                It 'Should return the correct configuration' {
                    $currentConfig = Get-DscConfiguration -ErrorAction Stop
                    $currentConfig.UserName | Should -Be $testUserName
                    $currentConfig.Ensure | Should -Be 'Absent'
                }
            }
            finally
            {
                if (Test-Path -Path $logPath) {
                    Remove-Item -Path $logPath -Recurse -Force
                }

                if (Test-Path -Path $configurationPath)
                {
                    Remove-Item -Path $configurationPath -Recurse -Force
                }
            }
        }
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}
