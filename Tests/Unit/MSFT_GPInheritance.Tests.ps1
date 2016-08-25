$Global:DSCModuleName      = 'GroupPolicyDsc'
$Global:DSCResourceName    = 'MSFT_GPInheritance'

#region HEADER
[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'))
}
else
{
    & git @('-C',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'),'pull')
}
Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Global:DSCModuleName `
    -DSCResourceName $Global:DSCResourceName `
    -TestType Unit 
#endregion

# Begin Testing
try
{

    #region Pester Tests

    # The InModuleScope command allows you to perform white-box unit testing on the internal
    # (non-exported) code of a Script Module.
    InModuleScope $Global:DSCResourceName {

        #region Pester Test Initialization
        function Get-ADDomain {}
        function Get-GPInheritance {}
        function Set-GPInheritance {}
        $rootDSE = 'DC=testdomain,DC=local'
        $ou = 'OU=Test OU'
        $presentParams = @{
            TargetDN = "$ou,$rootDSE"
            Server = 'localhost'
            Ensure = 'Present'
        }
        $absentParams = @{
            TargetDN = "$ou,$rootDSE"
            Server = 'localhost'
            Ensure = 'Absent'
        }
        $fakeADDomain = @{
            DistinguishedName = $rootDSE
        }
        $fakeGPInheritanceNotBlocked = @{
            GpoInheritanceBlocked = $false
        }
        $fakeGPInheritanceBlocked = @{
            GpoInheritanceBlocked = $true
        }
        #endregion


        #region Function Get-TargetResource
        Describe "$($Global:DSCResourceName)\Get-TargetResource" {
            It 'Returns a "System.Collections.Hashtable" object type' {
                Mock -CommandName Get-ADDomain -MockWith {$fakeADDomain}
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName Get-GPInheritance -MockWith {$fakeGPInheritanceNotBlocked}
                $targetResource = Get-TargetResource @presentParams
                $targetResource -is [System.Collections.Hashtable] | Should Be $true
            }

            It "Returns Ensure = Present when group policy inheritance is not blocked on the Target" {
                Mock -CommandName Get-ADDomain -MockWith {$fakeADDomain}
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName Get-GPInheritance -MockWith {$fakeGPInheritanceNotBlocked}
                $targetResource = Get-TargetResource @presentParams
                $targetResource.Ensure | Should Be 'Present'
            }

            It "Returns Ensure = Absent when group policy inheritance is blocked on the Target" {
                Mock -CommandName Get-ADDomain -MockWith {$fakeADDomain}
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName Get-GPInheritance -MockWith {$fakeGPInheritanceBlocked}
                $targetResource = Get-TargetResource @presentParams
                $targetResource.Ensure | Should Be 'Absent'
            }
        }
        #endregion


        #region Function Test-TargetResource
        Describe "$($Global:DSCResourceName)\Test-TargetResource" {
            It 'Returns a "System.Boolean" object type' {
                Mock -CommandName Get-ADDomain -MockWith {$fakeADDomain}
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName Get-GPInheritance -MockWith {$fakeGPInheritanceNotBlocked}
                $targetResource =  Test-TargetResource @presentParams
                $targetResource -is [System.Boolean] | Should Be $true
            }

            It 'Passes when Ensure = Present and group policy inheritance is not blocked on the Target' {
                Mock -CommandName Get-ADDomain -MockWith {$fakeADDomain}
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName Get-GPInheritance -MockWith {$fakeGPInheritanceNotBlocked}
                Test-TargetResource @presentParams | Should Be $true
            }

            It 'Fails when Ensure = Present and group policy inheritance is blocked on the Target' {
                Mock -CommandName Get-ADDomain -MockWith {$fakeADDomain}
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName Get-GPInheritance -MockWith {$fakeGPInheritanceBlocked}
                Test-TargetResource @presentParams | Should Be $false
            }

            It 'Passes when Ensure = Absent and group policy inheritance is blocked on the Target' {
                Mock -CommandName Get-ADDomain -MockWith {$fakeADDomain}
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName Get-GPInheritance -MockWith {$fakeGPInheritanceBlocked}
                Test-TargetResource @absentParams | Should Be $true
            }

            It 'Fails when Ensure = Absent and group policy inheritance is not blocked on the Target' {
                Mock -CommandName Get-ADDomain -MockWith {$fakeADDomain}
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName Get-GPInheritance -MockWith {$fakeGPInheritanceNotBlocked}
                Test-TargetResource @absentParams | Should Be $false
            }
        }
        #endregion


        #region Function Set-TargetResource
        Describe "$($Global:DSCResourceName)\Set-TargetResource" {
            It "Calls Import-GPO once" {
                Mock -CommandName Get-ADDomain -MockWith {$fakeADDomain}
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName Set-GPInheritance -MockWith {}
                Set-TargetResource @presentParams
                Assert-MockCalled -CommandName Set-GPInheritance -Times 1 -Exactly -Scope It
            }
        }
        #endregion
    }
    #endregion
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
