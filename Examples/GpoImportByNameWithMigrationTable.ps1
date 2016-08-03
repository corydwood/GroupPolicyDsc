# In this example, we import group policy settings into the Example GPO by specifying the backup name.
# We also use a migration table.

configuration ImportByName
{
    Import-DscResource -Module GPOImport

    Node $AllNodes.NodeName
    {
        GPOImport ExampleOU
        {
           TargetName = 'Example'
           Path = "C:\GPO Backups\Example"
           BackupIdentity = 'Example'
           BackupIdentityType = 'Name'
           MigrationTable = 'C:\GPO Backups\ExampleMigTable.mitable'
           Ensure = 'Present'
        }
    }
}
ImportByName
