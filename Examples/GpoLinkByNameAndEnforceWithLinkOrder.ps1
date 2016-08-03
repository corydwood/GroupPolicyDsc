# In this example, we link the Example GPO by name to the Example OU and enforce the link.
# We also change the link order to 1.

configuration LinkEnforcedGPOByName
{
    Import-DscResource -Module GPOLink

    Node $AllNodes.NodeName
    {
        GPOLink ExampleOU
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
