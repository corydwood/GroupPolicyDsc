$ou = 'OU=Test OU,DC=testdomain,DC=local'
$GPInheritance = @{
    Target = $ou
    Server = 'localhost'
    Ensure = 'Present'
}
configuration 'MSFT_xGPInheritance_config' {
    Import-DscResource -Name 'MSFT_xGPInheritance'
    node localhost {
       xGPInheritance Integration_Test {
            Target = $GPInheritance.Target
            Server = $GPInheritance.Server
            Ensure = $GPInheritance.Ensure
       }
    }
}