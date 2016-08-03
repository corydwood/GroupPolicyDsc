# In this example, we import group policy settings into the Example GPO by specifying the backup GUID.

configuration ImportByGuid
{
    Import-DscResource -Module GPOImport

    Node $AllNodes.NodeName
    {
        GPOImport ExampleOU
        {
           TargetName = 'Example'
           Path = "C:\GPO Backups\Example"
           BackupIdentity = '7b230cb8-67fc-433d-812f-c93b53310dcf'
           BackupIdentityType = 'Guid'
           Ensure = 'Present'
        }
    }
}
ImportByGuid
