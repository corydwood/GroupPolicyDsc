$Global:DSCModuleName      = 'GroupPolicyDsc'
$Global:DSCResourceName    = 'MSFT_GPOImport'

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
        function Get-GPO {}
        function Import-GPO {}
        $gpoName = 'Test GPO'
        $domainName = 'testdomain.local'
        $testParams = @{
            Name = $gpoName
            Path = "C:\Test Path\GPO Backups\$gpoName"
            BackupIdentity = $gpoName
            BackupIdentityType = 'Name'
            Domain = $domainName
            MigrationTable = 'C:\Test Path\GPO Backups\MigTable.mitable'
            Server = 'TestServer'
        }
        $fakeGPO = @{
            DisplayName = $gpoName
            DomainName = $domainName
        }
        #endregion


        #region Function Get-TargetResource
        Describe "$($Global:DSCResourceName)\Get-TargetResource" {
            It 'Returns a "System.Collections.Hashtable" object type' {
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName Get-GPO -MockWith {return $fakeGPO}
                $targetResource = Get-TargetResource @testParams
                $targetResource -is [System.Collections.Hashtable] | Should Be $true
            }

            It "Returns Ensure = Present when GPO is found" {
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName Get-GPO -MockWith {return $fakeGPO}
                $targetResource = Get-TargetResource @testParams
                $targetResource.Ensure | Should Be 'Present'
            }

            It "Returns TargetName = $($testParams.TargetName) when GPO is found" {
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName Get-GPO -MockWith {return $fakeGPO}
                $targetResource = Get-TargetResource @testParams
                $targetResource.TargetName | Should Be $testParams.TargetName
            }

            It "Returns Domain = $($testParams.Domain) when GPO is found" {
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName Get-GPO -MockWith {return $fakeGPO}
                $targetResource = Get-TargetResource @testParams
                $targetResource.Domain | Should Be $testParams.Domain
            }

            It "Returns Ensure = Absent when GPO is not found" {
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName Get-GPO -MockWith {}
                $targetResource = Get-TargetResource @testParams
                $targetResource.Ensure | Should Be 'Absent'
            }

            It "Returns an empty Domain when GPO is not found" {
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName Get-GPO -MockWith {}
                $targetResource = Get-TargetResource @testParams
                $targetResource.Domain | Should Be $null
            }
        }
        #endregion


        #region Function Test-TargetResource
        Describe "$($Global:DSCResourceName)\Test-TargetResource" {
            It 'Returns a "System.Boolean" object type' {
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName Get-GPO -MockWith {return $fakeGPO}
                $targetResource =  Test-TargetResource @testParams
                $targetResource -is [System.Boolean] | Should Be $true
            }

            It 'Passes when GPO found' {
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName Get-GPO -MockWith {return $fakeGPO}
                Test-TargetResource @testParams | Should Be $true
            }

            It 'Fails when GPO not found' {
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName Get-GPO -MockWith {}
                Test-TargetResource @testParams | Should Be $false
            }
        }
        #endregion


        #region Function Set-TargetResource
        Describe "$($Global:DSCResourceName)\Set-TargetResource" {
            It "Calls Import-GPO once" {
                Mock -CommandName Import-Module -MockWith {}
                Mock -CommandName Import-GPO -MockWith {}
                Set-TargetResource @testParams
                Assert-MockCalled -CommandName Import-GPO -Times 1 -Exactly -Scope It
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
