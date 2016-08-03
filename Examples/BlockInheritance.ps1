# In this example, we block inheritance on the Example OU.

configuration BlockInheritance
{
    Import-DscResource -Module GPInheritance

    Node $AllNodes.NodeName
    {
        GPInheritance ExampleOU
        {
           Target = 'OU=Example,DC=testdomain,DC=local'
           Ensure = 'Absent'
        }
    }
}
BlockInheritance
