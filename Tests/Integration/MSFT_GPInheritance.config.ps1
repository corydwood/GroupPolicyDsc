$ou = 'OU=Test OU,DC=testdomain,DC=local'
$GPInheritance = @{
    Target = $ou
    Server = 'localhost'
    Ensure = 'Present'
}
configuration 'MSFT_GPInheritance_config' {
    Import-DscResource -Name 'MSFT_GPInheritance'
    node localhost {
       GPInheritance Integration_Test {
            Target = $GPInheritance.Target
            Server = $GPInheritance.Server
            Ensure = $GPInheritance.Ensure
       }
    }
}