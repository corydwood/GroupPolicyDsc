# In this example, we link a GPO by GUID to the Example OU and disable the link.
# We also leave off the domain part of the OU DN so it's generated automatically for us.

configuration LinkGPOByGuidAndDisable
{
    Import-DscResource -Module GPOLink

    Node $AllNodes.NodeName
    {
        GPOLink ExampleOU
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
