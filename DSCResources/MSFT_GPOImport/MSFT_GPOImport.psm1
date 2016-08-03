function Get-TargetResource
{
    [OutputType([Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [string]$TargetName,
        [parameter(Mandatory = $true)]
        [string]$Path,
        [parameter(Mandatory = $true)]
        [string]$BackupIdentity,
        [ValidateSet('Name','Guid')]
        [string]$BackupIdentityType = 'Name',
        [string]$Domain,
        [string]$MigrationTable,
        [string]$Server,
        [ValidateSet('Present')]
        [string]$Ensure = 'Present'
    )
    Import-Module GroupPolicy -Verbose:$false
    $params = @{
        Name = $TargetName
        ErrorAction = 'SilentlyContinue'
    }
    if ($Domain) {$params += @{Domain = $Domain}}
    if ($Server) {$params += @{Server = $Server}}
    Write-Verbose 'Getting GPO'
    $gpo = Get-GPO @params
    $targetResource = @{
        TargetName = $TargetName
        Path = $Path
        BackupIdentity = $BackupIdentity
        BackupIdentityType = $BackupIdentityType
        Domain = $null
        MigrationTable = $null
        Server = $null
        Ensure = 'Absent'
    }
    if ($MigrationTable) {$targetResource.MigrationTable = $MigrationTable}
    if ($Server) {$targetResource.Server = $Server}
    if ($gpo)
    {
        $targetResource.Domain = $gpo.DomainName
        $targetResource.Ensure = 'Present'
    }
    $targetResource
}

function Set-TargetResource
{
    param
    (
        [parameter(Mandatory = $true)]
        [string]$TargetName,
        [parameter(Mandatory = $true)]
        [string]$Path,
        [parameter(Mandatory = $true)]
        [string]$BackupIdentity,
        [ValidateSet('Name','Guid')]
        [string]$BackupIdentityType = 'Name',
        [string]$Domain,
        [string]$MigrationTable,
        [string]$Server,
        [ValidateSet('Present')]
        [string]$Ensure = 'Present'
    )
    Import-Module GroupPolicy -Verbose:$false
    $params = @{
        TargetName = $TargetName
        Path = $Path
        CreateIfNeeded = $true
    }
    if ($BackupIdentityType -eq 'Name') {$params += @{BackupGpoName = $BackupIdentity}}
    else {$params += @{BackupId = $BackupIdentity}}
    if ($Domain) {$params += @{Domain = $Domain}}
    if ($MigrationTable) {$params += @{MigrationTable = $MigrationTable}}
    if ($Server) {$params += @{Server = $Server}}
    Write-Verbose 'Importing GPO'
    $null = Import-GPO @params
}

function Test-TargetResource
{
[OutputType([Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [string]$TargetName,
        [parameter(Mandatory = $true)]
        [string]$Path,
        [parameter(Mandatory = $true)]
        [string]$BackupIdentity,
        [ValidateSet('Name','Guid')]
        [string]$BackupIdentityType = 'Name',
        [string]$Domain,
        [string]$MigrationTable,
        [string]$Server,
        [ValidateSet('Present')]
        [string]$Ensure = 'Present'
    )
    $targetResource = Get-TargetResource @PSBoundParameters
    if ($targetResource.Ensure -eq 'Present') {$true}
    else {$false}
}
