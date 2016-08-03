# In this example, we unblock inheritance on the Example OU.
# We also leave off the domain part of the OU DN so it's generated automatically for us.

configuration UnblockInheritance
{
    Import-DscResource -Module GPInheritance

    Node $AllNodes.NodeName
    {
        GPInheritance ExampleOU
        {
           Target = 'OU=Example,'
           Ensure = 'Present'
        }
    }
}
UnblockInheritance
