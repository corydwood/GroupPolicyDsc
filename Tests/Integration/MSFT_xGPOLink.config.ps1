$GPOLink = @{
    Identity = 'Test GPO'
    IdentityType = 'Name'
    Target = 'OU=Test OU,DC=testdomain,DC=local'
    Enforced = 'No'
    LinkEnabled = 'Yes'
    Order = 1
    Ensure = 'Present'
}
configuration 'MSFT_xGPOLink_config' {
    Import-DscResource -Name 'MSFT_xGPOLink'
    node localhost {
       xGPOLink Integration_Test {
            Identity = $GPOLink.Identity
            IdentityType = $GPOLink.IdentityType
            Target = $GPOLink.Target
            Enforced = $GPOLink.Enforced
            LinkEnabled = $GPOLink.LinkEnabled
            Order = $GPOLink.Order
            Ensure = $GPOLink.Ensure
       }
    }
}