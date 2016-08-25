$gpoName = 'Test GPO'
$domainName = 'testdomain.local'
$GPO = @{
    Name = $gpoName
    Path = "C:\Test Path\GPO Backups\$gpoName"
    BackupIdentity = $gpoName
    BackupIdentityType = 'Name'
    Domain = $domainName
    MigrationTable = 'C:\Test Path\GPO Backups\MigTable.mitable'
    Server = 'localhost'
}
configuration 'MSFT_GPOImport_config' {
    Import-DscResource -Name 'MSFT_GPOImport'
    node localhost {
       GPOImport Integration_Test {
            Name = $GPO.Name
            Path = $GPO.Path
            BackupIdentity = $GPO.BackupIdentity
            BackupIdentityType = $GPO.BackupIdentityType
            Domain = $GPO.Domain
            MigrationTable = $GPO.MigrationTable
            Server = $GPO.Server
       }
    }
}
