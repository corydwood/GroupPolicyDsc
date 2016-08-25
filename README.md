{{AppVeyor build status badge for master branch}}

# GroupPolicyDsc

The **GroupPolicyDsc** module contains DSC resources for configuring Group Policy.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## How to Contribute
If you would like to contribute to this repository, please read the DSC Resource Kit [contributing guidelines](https://github.com/PowerShell/DscResource.Kit/blob/master/CONTRIBUTING.md).

## Resources

* **GPInheritance** blocks or unblocks inheritance for a specified domain or organizational unit (OU).
* **GPOImport** imports the Group Policy settings from a backed-up GPO into a new GPO.
It won't import settings into an existing GPO.
* **GPOLink** links a GPO to a site, domain, or organizational unit (OU).

### GPInheritance

* **TargetDN**: Specifies the domain or the OU for which to block or unblock inheritance by its LDAP distinguished name.
You can also leave off the domain part of the distinguished name and it will be generated automatically.
See the UnblockInheritance.ps1 example in the Examples folder.
* **Domain**: Specifies the domain to run against.
Optional.
* **Server**: Specifies the name of the domain controller that this resource contacts to complete the operation.
You can specify either the fully qualified domain name (FQDN) or the host name.
Optional.
* **Ensure**: Whether inheritance should be blocked (Absent) or unblocked (Present).
Defaults to Present.

### GPOImport

* **Name**: Specifies the display name of the GPO into which the settings are to be imported.
* **Path**: Specifies the path to the backup directory.
* **BackupIdentity**: Specifies the display name or backup ID of the backed-up GPO from which to import the settings.
* **BackupIdentityType**: Specifies the type of the BackupIdentity (Name or Guid).
Defaults to Name.
* **Domain**: Specifies the domain to run against.
Optional.
* **MigrationTable**: Specifies the path to a migration table file.
You can use a migration table to map security principals and UNC paths across domains.
* **Server**: Specifies the name of the domain controller that this resource contacts to complete the operation.
You can specify either the fully qualified domain name (FQDN) or the host name.
Optional.
* **Ensure**: Must be Present.
Defaults to Present.

### GPOLink

* **Name**: Specifies the name of the GPO to link.
* **TargetDN**: Specifies the LDAP distinguished name of the site, domain, or OU to which to link the GPO.
You can also leave off the domain part of the distinguished name and it will be generated automatically.
See the GpoLinkByGuidAndDisable.ps1 example in the Examples folder.
* **Domain**: Specifies the domain to run against.
Optional.
* **Enforced**: Specifies whether the GPO link is enforced.
You can specify Yes or No.
Defaults to No.
* **LinkEnabled**: Specifies whether the GPO link is enabled.
You can specify Yes or No.
Defaults to Yes.
* **Order**: Specifies the link order for the GPO link.
You can specify a number that is between one and the current number of GPO links to the target site, domain, or OU, plus one.
* **Server**: Specifies the name of the domain controller that this resource contacts to complete the operation.
You can specify either the fully qualified domain name (FQDN) or the host name.
Optional.
* **Ensure**: Whether the GPO Link should exist (Present) or not (Absent).
Defaults to Present.

## Versions

### Unreleased

### 1.0.0.0

* Initial release with the following resources:
    * GPInheritance
    * GPOImport
    * GPOLink
