$ou = 'OU=Test OU,DC=testdomain,DC=local'
$GPInheritance = @{
    TargetDN = $ou
    Server = 'localhost'
    Ensure = 'Present'
}
configuration 'MSFT_GPInheritance_config' {
    Import-DscResource -Name 'MSFT_GPInheritance'
    node localhost {
       GPInheritance Integration_Test {
            TargetDN = $GPInheritance.TargetDN
            Server = $GPInheritance.Server
            Ensure = $GPInheritance.Ensure
       }
    }
}
