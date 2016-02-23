{{AppVeyor build status badge for master branch}}

# xGroupPolicy

The **xGroupPolicy** module contains DSC resources for configuring Group Policy.

## Contributing
Please check out common DSC Resources [contributing guidelines](https://github.com/PowerShell/DscResource.Kit/blob/master/CONTRIBUTING.md).

## Resources

* **xGPInheritance** blocks or unblocks inheritance for a specified domain or organizational unit (OU).
* **xGPOImport** imports the Group Policy settings from a backed-up GPO into a new GPO. It won't import settings into an existing GPO.
* **xGPOLink** links a GPO to a site, domain, or organizational unit (OU).

### xGPInheritance

* **Target**: Specifies the domain or the OU for which to block or unblock inheritance by its LDAP distinguished name. You can also leave off the domain part of the distinguished name and it will be generated automatically. See the example below.
* **Domain**: Optional. Specifies the domain to run against.
* **Server**: Optional. Specifies the name of the domain controller that this resource contacts to complete the operation. You can specify either the fully qualified domain name (FQDN) or the host name.
* **Ensure**: Whether inheritance should be blocked (Absent) or unblocked (Present). Defaults to Present.

### xGPOImport

* **TargetName**: Specifies the display name of the GPO into which the settings are to be imported.
* **Path**: Specifies the path to the backup directory.
* **BackupIdentity**: Specifies the display name or backup ID of the backed-up GPO from which to import the settings.
* **BackupIdentityType**: Specifies the type of the BackupIdentity (Name or Guid). Defaults to Name.
* **Domain**: Optional. Specifies the domain to run against.
* **MigrationTable**: Specifies the path to a migration table file.
* **Server**: Optional. Specifies the name of the domain controller that this resource contacts to complete the operation. You can specify either the fully qualified domain name (FQDN) or the host name.
* **Ensure**: Must be Present. Defaults to Present.

### xGPOLink

* **Identity**: Specifies the GPO to link by its display name or GUID.
* **IdentityType**: Specifies the type of the Identity (Name or Guid). Defaults to Name.
* **Target**: Specifies the LDAP distinguished name of the site, domain, or OU to which to link the GPO. You can also leave off the domain part of the distinguished name and it will be generated automatically. See the example below.
* **Domain**: Optional. Specifies the domain to run against.
* **Enforced**: Specifies whether the GPO link is enforced. You can specify Yes or No. Defaults to No.
* **LinkEnabled**: Specifies whether the GPO link is enabled. You can specify Yes or No. Defaults to Yes.
* **Order**: Specifies the link order for the GPO link. You can specify a number that is between one and the current number of GPO links to the target site, domain, or OU, plus one.
* **Server**: Optional. Specifies the name of the domain controller that this resource contacts to complete the operation. You can specify either the fully qualified domain name (FQDN) or the host name.
* **Ensure**: Whether the GPO Link should exist (Present) or not (Absent). Defaults to Present.

## Versions

### Unreleased

### 1.0.0.0

* Initial release with the following resources:
    * xGPInheritance
    * xGPOImport
    * xGPOLink

## Examples
### Block inheritance on OU

In this example, we block inheritance on the Example OU.

```
configuration BlockInheritance
{
    Import-DscResource -Module xGPInheritance

    Node $AllNodes.NodeName
    {
        xGPInheritance ExampleOU
        {
           Target = 'OU=Example,DC=testdomain,DC=local'
           Ensure = 'Absent'
        }
    }
}
BlockInheritance
```

### Unblock inheritance on OU

In this example, we unblock inheritance on the Example OU. We also leave off the domain part of the OU DN so it's generated automatically for us.

```
configuration UnblockInheritance
{
    Import-DscResource -Module xGPInheritance

    Node $AllNodes.NodeName
    {
        xGPInheritance ExampleOU
        {
           Target = 'OU=Example,'
           Ensure = 'Absent'
        }
    }
}
UnblockInheritance
```

### Import Group Policy Settings by Name with Migration Table

In this example, we import group policy settings into the Example GPO by specifying the backup name. We also use a migration table.

```
configuration ImportByName
{
    Import-DscResource -Module xGPOImport

    Node $AllNodes.NodeName
    {
        xGPOImport ExampleOU
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
```

### Import Group Policy Settings by GUID

In this example, we import group policy settings into the Example GPO by specifying the backup GUID.

```
configuration ImportByGuid
{
    Import-DscResource -Module xGPOImport

    Node $AllNodes.NodeName
    {
        xGPOImport ExampleOU
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
```

### Link and Enforce GPO by Name.

In this example, we link the Example GPO by name to the Example OU and enforce the link. We also change the link order to 1.

```
configuration LinkEnforcedGPOByName
{
    Import-DscResource -Module xGPOLink

    Node $AllNodes.NodeName
    {
        xGPOLink ExampleOU
        {
           Identity = 'Example'
           IdentityType = 'Name'
           Target = 'OU=Example,DC=testdomain,DC=local'
           Enforced = 'Yes'
           Order = 1
           Ensure = 'Present'
        }
    }
}
LinkEnforcedGPOByName
```

### Link GPO by GUID and Disable Link.

In this example, we link a GPO by GUID to the Example OU and disable the link. We also leave off the domain part of the OU DN so it's generated automatically for us.

```
configuration LinkGPOByGuidAndDisable
{
    Import-DscResource -Module xGPOLink

    Node $AllNodes.NodeName
    {
        xGPOLink ExampleOU
        {
           Identity = '9b74f3ec-a20e-4567-a1cd-f0b13a339037'
           IdentityType = 'Guid'
           Target = 'OU=Example,'
           LinkEnabled = 'No'
           Ensure = 'Present'
        }
    }
}
LinkGPOByGuidAndDisable
```
