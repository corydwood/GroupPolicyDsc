$Global:DSCModuleName      = 'GroupPolicyDsc'
$Global:DSCResourceName    = 'MSFT_GPOLink'

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
        function Get-GPO {}
        function Get-GPInheritance {}
        function New-GPLink {}
        function Set-GPLink {}
        function Remove-GPLink {}
        $gpoName = 'Test GPO'
        $gpoId = '8451f164-0cff-4d3f-b4d1-6a54640c80ae'
        $rootDSE = 'DC=testdomain,DC=local'
        $ou = 'OU=Test OU'
        $domainName = 'testdomain.local'
        $presentParams = @{
            Name = $gpoName
            TargetDN = "$ou,$rootDSE"
            Domain = $domainName
            Enforced = 'No'
            LinkEnabled = 'Yes'
            Order = 1
            Ensure = 'Present'
        }
        $absentParams = $presentParams.Clone()
        $absentParams.Ensure = 'Absent'
        $gpInheritanceCorrectProperties = @{
            GpoLinks = @{
                GpoId = $gpoId
                DisplayName = $gpoName
                Enabled = $true
                Enforced = $false
                Target = "$ou,$rootDSE"
                Order = 1
            }
        }
        $gpInheritanceIncorrectProperties = @{
            GpoLinks = @{
                GpoId = $gpoId
                DisplayName = $gpoName
                Enabled = $false
                Enforced = $true
                Target = "$ou,$rootDSE"
                Order = 2
            }
        }
        $gpo = @{
            DisplayName = $gpoName
            Id = $gpoId
            DomainName = $domainName
        }
        #endregion


        #region Function Get-TargetResource
        Describe "$($Global:DSCResourceName)\Get-TargetResource" {
            It 'Returns a "System.Collections.Hashtable" object type' {
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName Get-GPInheritance -MockWith {}
                Mock -CommandName Get-GPO -MockWith {return $gpo}
                $targetResource = Get-TargetResource @presentParams
                $targetResource -is [System.Collections.Hashtable] | Should Be $true
            }

            It "Returns Ensure = Present when GPO Link is found" {
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName Get-GPInheritance -MockWith {return $gpInheritanceCorrectProperties}
                Mock -CommandName Get-GPO -MockWith {return $gpo}
                $targetResource = Get-TargetResource @presentParams
                $targetResource.Ensure | Should Be 'Present'
            }

            It "Returns Ensure = Absent when GPO Link is not found" {
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName Get-GPInheritance -MockWith {}
                Mock -CommandName Get-GPO -MockWith {return $gpo}
                $targetResource = Get-TargetResource @presentParams
                $targetResource.Ensure | Should Be 'Absent'
            }
        }
        #endregion


        #region Function Test-TargetResource
        Describe "$($Global:DSCResourceName)\Test-TargetResource" {
            It 'Returns a "System.Boolean" object type' {
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName Get-GPInheritance -MockWith {}
                Mock -CommandName Get-GPO -MockWith {return $gpo}
                $targetResource =  Test-TargetResource @presentParams
                $targetResource -is [System.Boolean] | Should Be $true
            }

            It 'Passes when Ensure = Present and GPO Link found with correct properties' {
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName Get-GPInheritance -MockWith {return $gpInheritanceCorrectProperties}
                Mock -CommandName Get-GPO -MockWith {return $gpo}
                Test-TargetResource @presentParams | Should Be $true
            }

            It 'Fails when Ensure = Present and GPO Link found with incorrect properties' {
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName Get-GPInheritance -MockWith {return $gpInheritanceIncorrectProperties}
                Mock -CommandName Get-GPO -MockWith {return $gpo}
                Test-TargetResource @presentParams | Should Be $false
            }

            It 'Fails when Ensure = Present and GPO Link not found' {
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName Get-GPInheritance -MockWith {}
                Mock -CommandName Get-GPO -MockWith {return $gpo}
                Test-TargetResource @presentParams | Should Be $false
            }

            It 'Passes when Ensure = Absent and GPO Link not found' {
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName Get-GPInheritance -MockWith {}
                Mock -CommandName Get-GPO -MockWith {return $gpo}
                Test-TargetResource @absentParams | Should Be $true
            }

            It 'Failes when Ensure = Absent and GPO Link found' {
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName Get-GPInheritance -MockWith {return $gpInheritanceCorrectProperties}
                Mock -CommandName Get-GPO -MockWith {return $gpo}
                Test-TargetResource @absentParams | Should Be $false
            }
        }
        #endregion


        #region Function Set-TargetResource
        Describe "$($Global:DSCResourceName)\Set-TargetResource" {
            It "Calls New-GPLink once when GPO Link not found" {
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName Get-GPInheritance -MockWith {}
                Mock -CommandName Get-GPO -MockWith {return $gpo}
                Mock -CommandName New-GPLink -MockWith {}
                Set-TargetResource @presentParams
                Assert-MockCalled -CommandName New-GPLink -Times 1 -Exactly -Scope It
            }

            It "Calls Set-GPLink once when GPO Link is found but the properties aren't correct" {
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName Get-GPInheritance -MockWith {return $gpInheritanceIncorrectProperties}
                Mock -CommandName Get-GPO -MockWith {return $gpo}
                Mock -CommandName Set-GPLink -MockWith {}
                Set-TargetResource @presentParams
                Assert-MockCalled -CommandName Set-GPLink -Times 1 -Exactly -Scope It
            }

            It "Calls Remove-GPLink once when Ensure = Absent and GPO Link found" {
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName Get-GPInheritance -MockWith {return $gpInheritanceCorrectProperties}
                Mock -CommandName Get-GPO -MockWith {return $gpo}
                Mock -CommandName Remove-GPLink -MockWith {}
                Set-TargetResource @absentParams
                Assert-MockCalled -CommandName Remove-GPLink -Times 1 -Exactly -Scope It
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
