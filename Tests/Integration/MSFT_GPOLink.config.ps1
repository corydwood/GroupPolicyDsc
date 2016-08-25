$GPOLink = @{
    Name = 'Test GPO'
    TargetDN = 'OU=Test OU,DC=testdomain,DC=local'
    Enforced = 'No'
    LinkEnabled = 'Yes'
    Order = 1
    Ensure = 'Present'
}
configuration 'MSFT_GPOLink_config' {
    Import-DscResource -Name 'MSFT_GPOLink'
    node localhost {
       GPOLink Integration_Test {
            Name = $GPOLink.Identity
            TargetDN = $GPOLink.TargetDN
            Enforced = $GPOLink.Enforced
            LinkEnabled = $GPOLink.LinkEnabled
            Order = $GPOLink.Order
            Ensure = $GPOLink.Ensure
       }
    }
}
