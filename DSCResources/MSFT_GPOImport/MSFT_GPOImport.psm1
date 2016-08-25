function Get-TargetResource
{
    [OutputType([Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [string]
        $Name,

        [parameter(Mandatory = $true)]
        [string]
        $Path,

        [parameter(Mandatory = $true)]
        [string]
        $BackupIdentity,

        [ValidateSet('Name','Guid')]
        [string]
        $BackupIdentityType = 'Name',

        [string]
        $Domain,

        [string]
        $MigrationTable,

        [string]
        $Server,

        [ValidateSet('Present')]
        [string]
        $Ensure = 'Present'
    )

    Import-Module -Name GroupPolicy -Verbose:$false
    $getGPOParams = @{
        Name = $Name
        ErrorAction = 'SilentlyContinue'
    }
    if ($Domain)
    {
        $getGPOParams += @{
            Domain = $Domain
        }
    }
    if ($Server)
    {
        $getGPOParams += @{
            Server = $Server
        }
    }
    Write-Verbose -Message 'Getting GPO'
    $gpo = Get-GPO @getGPOParams
    $targetResource = @{
        Name = $Name
        Path = $Path
        BackupIdentity = $BackupIdentity
        BackupIdentityType = $BackupIdentityType
        Domain = $null
        MigrationTable = $null
        Server = $null
        Ensure = 'Absent'
    }
    if ($MigrationTable)
    {
        $targetResource.MigrationTable = $MigrationTable
    }
    if ($Server)
    {
        $targetResource.Server = $Server
    }
    if ($gpo)
    {
        $targetResource.Domain = $gpo.DomainName
        $targetResource.Ensure = 'Present'
    }
    Write-Output -InputObject $targetResource
}

function Set-TargetResource
{
    param
    (
        [parameter(Mandatory = $true)]
        [string]
        $Name,

        [parameter(Mandatory = $true)]
        [string]
        $Path,

        [parameter(Mandatory = $true)]
        [string]
        $BackupIdentity,

        [ValidateSet('Name','Guid')]
        [string]
        $BackupIdentityType = 'Name',

        [string]
        $Domain,

        [string]
        $MigrationTable,

        [string]
        $Server,

        [ValidateSet('Present')]
        [string]
        $Ensure = 'Present'
    )

    Import-Module -Name GroupPolicy -Verbose:$false
    $importGPOParams = @{
        TargetName = $Name
        Path = $Path
        CreateIfNeeded = $true
    }
    if ($BackupIdentityType -eq 'Name')
    {
        $importGPOParams += @{
            BackupGpoName = $BackupIdentity
        }
    }
    else
    {
        $importGPOParams += @{
            BackupId = $BackupIdentity
        }
    }
    if ($Domain)
    {
        $importGPOParams += @{
            Domain = $Domain
        }
    }
    if ($MigrationTable)
    {
        $importGPOParams += @{
            MigrationTable = $MigrationTable
        }
    }
    if ($Server)
    {
        $importGPOParams += @{
            Server = $Server
        }
    }
    Write-Verbose -Message 'Importing GPO'
    $null = Import-GPO @importGPOParams
}

function Test-TargetResource
{
[OutputType([Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [string]
        $Name,

        [parameter(Mandatory = $true)]
        [string]
        $Path,

        [parameter(Mandatory = $true)]
        [string]
        $BackupIdentity,

        [ValidateSet('Name','Guid')]
        [string]
        $BackupIdentityType = 'Name',

        [string]
        $Domain,

        [string]
        $MigrationTable,

        [string]
        $Server,

        [ValidateSet('Present')]
        [string]
        $Ensure = 'Present'
    )

    $targetResource = Get-TargetResource @PSBoundParameters
    if ($targetResource.Ensure -eq 'Present')
    {
        Write-Output -InputObject $true
    }
    else 
    {
        Write-Output -InputObject $false
    }
}
