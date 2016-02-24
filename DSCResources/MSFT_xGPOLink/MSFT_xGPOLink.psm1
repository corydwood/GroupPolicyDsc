function Get-TargetResource {
    [OutputType([Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [string]$Identity,
        [ValidateSet('Name','Guid')]
        [string]$IdentityType = 'Name',
        [parameter(Mandatory = $true)]
        [string]$Target,
        [string]$Domain,
        [ValidateSet('Yes','No')]
        [string]$Enforced,
        [ValidateSet('Yes','No')]
        [string]$LinkEnabled,
        [int16]$Order,
        [string]$Server,
        [ValidateSet('Present','Absent')]
        [string]$Ensure = 'Present'
    )
    $target = Test-TargetDN @PSBoundParameters
    $gpInheritanceparams = @{
        Target = $target
    }
    if ($Server) {$gpInheritanceparams += @{Server = $Server}}
    if ($Domain) {$gpInheritanceparams += @{Domain = $Domain}}
    Import-Module GroupPolicy -Verbose:$false
    Write-Verbose 'Getting GPO Links'
    $gpoLinks = (Get-GPInheritance @gpInheritanceparams).GpoLinks
    $gpo = Get-GpoInfo @PSBoundParameters
    $targetResource = @{
        Identity = $Identity
        IdentityType = $IdentityType
        Target = $Target
        Domain = $null
        Enforced = $null
        LinkEnabled = $null
        Order = $null
        Server = $Server
        Ensure = 'Absent'
    }
    if ($gpo)
    {
        # Using the GpoId attribute of the GPO Links instead of the
        # Name attribute because the Name attribute may take a while
        # to replicate to all DCs if the GPO was recently created.
        $targetLink = $gpoLinks | where {$_.GpoId -eq $gpo.Id}
        if ($targetLink)
        {
            if ($targetLink.Enabled) {$targetResource.LinkEnabled = 'Yes'}
            else {$targetResource.LinkEnabled = 'No'}
            if ($targetLink.Enforced) {$targetResource.Enforced = 'Yes'}
            else {$targetResource.Enforced = 'No'}
            $targetResource.Order = $targetLink.Order
            $targetResource.Ensure = 'Present'
        }
        $targetResource.Domain = $gpo.DomainName
    }
    $targetResource
}

function Set-TargetResource {
    param
    (
        [parameter(Mandatory = $true)]
        [string]$Identity,
        [ValidateSet('Name','Guid')]
        [string]$IdentityType = 'Name',
        [parameter(Mandatory = $true)]
        [string]$Target,
        [string]$Domain,
        [ValidateSet('Yes','No')]
        [string]$Enforced,
        [ValidateSet('Yes','No')]
        [string]$LinkEnabled,
        [int16]$Order,
        [string]$Server,
        [ValidateSet('Present','Absent')]
        [string]$Ensure = 'Present'
    )
    Import-Module GroupPolicy -Verbose:$false
    $targetResource = Get-TargetResource @PSBoundParameters
    $gpo = Get-GpoInfo @PSBoundParameters
    if ($Ensure -eq 'Present')
    {
        if ($targetResource.Ensure -eq 'Present')
        {
            $setParams = @{Target = $targetResource.Target}
            if ($IdentityType -eq 'Name')
            {
                # Using the GpoId attribute of the GPO Links instead of the
                # Name attribute because the Name attribute may take a while
                # to replicate to all DCs if the GPO was recently created.
                $setParams += @{Guid = $gpo.Id}
            }
            else {$setParams += @{Guid = $Identity}}
            if ($Domain) {$setParams += @{Domain = $Domain}}
            if ($Enforced -and $targetResource.Enforced -ne $Enforced)
            {
                $setParams += @{Enforced = $Enforced}
            }
            if ($LinkEnabled -and $targetResource.LinkEnabled -ne $LinkEnabled)
            {
                $setParams += @{LinkEnabled = $LinkEnabled}
            }
            if ($Order -and $targetResource.Order -ne $Order)
            {
                $setParams += @{Order = $Order}
            }
            if ($Server) {$setParams += @{Server = $Server}}
            Write-Verbose 'Updating GPO Link'
            Set-GPLink @setParams
        }
        else
        {
            $newParams = @{Target = $targetResource.Target}
            if ($IdentityType -eq 'Name')
            {
                # Using the GpoId attribute of the GPO Links instead of the
                # Name attribute because the Name attribute may take a while
                # to replicate to all DCs if the GPO was recently created.
                $newParams += @{Guid = $gpo.Id}
            }
            else {$newParams += @{Guid = $Identity}}
            if ($Domain) {$newParams += @{Domain = $Domain}}
            if ($Enforced) {$newParams += @{Enforced = $Enforced}}
            if ($LinkEnabled) {$newParams += @{LinkEnabled = $LinkEnabled}}
            if ($Order) {$newParams += @{Order = $Order}}
            if ($Server) {$newParams += @{Server = $Server}}
            Write-Verbose 'Creating GPO Link'
            New-GPLink @newParams
        }
    }
    else
    {
        $removeParams = @{Target = $targetResource.Target}
        if ($IdentityType -eq 'Name')
        {
            # Using the GpoId attribute of the GPO Links instead of the
            # Name attribute because the Name attribute may take a while
            # to replicate to all DCs if the GPO was recently created.
            $removeParams += @{Guid = $gpo.Id}
        }
        else {$removeParams += @{Guid = $Identity}}
        if ($Domain) {$removeParams += @{Domain = $Domain}}
        if ($Server) {$removeParams += @{Server = $Server}}
        Write-Verbose 'Removing GPO Link'
        Remove-GPLink @removeParams
    }
}

function Test-TargetResource {
[OutputType([Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [string]$Identity,
        [ValidateSet('Name','Guid')]
        [string]$IdentityType = 'Name',
        [parameter(Mandatory = $true)]
        [string]$Target,
        [string]$Domain,
        [ValidateSet('Yes','No')]
        [string]$Enforced,
        [ValidateSet('Yes','No')]
        [string]$LinkEnabled,
        [int16]$Order,
        [string]$Server,
        [ValidateSet('Present','Absent')]
        [string]$Ensure = 'Present'
    )
    $targetResource = Get-TargetResource @PSBoundParameters
    $targetResourceInCompliance = $true
    if ($Ensure -eq 'Present')
    {
        if ($targetResource.Ensure -eq 'Present')
        {
            if ($Enforced -and $targetResource.Enforced -ne $Enforced)
            {
                $targetResourceInCompliance = $false
            }
            if ($LinkEnabled -and $targetResource.LinkEnabled -ne $LinkEnabled)
            {
                $targetResourceInCompliance = $false
            }
            if ($Order -and $targetResource.Order -ne $Order)
            {
                $targetResourceInCompliance = $false
            }
        }
        else {$targetResourceInCompliance = $false}
    }
    elseif ($targetResource.Ensure -eq 'Present')
    {
        $targetResourceInCompliance = $false
    }
    $targetResourceInCompliance
}

function Test-TargetDN
{
    param
    (
        [parameter(Mandatory = $true)]
        [string]$Identity,
        [ValidateSet('Name','Guid')]
        [string]$IdentityType = 'Name',
        [parameter(Mandatory = $true)]
        [string]$Target,
        [string]$Domain,
        [ValidateSet('Yes','No')]
        [string]$Enforced,
        [ValidateSet('Yes','No')]
        [string]$LinkEnabled,
        [int16]$Order,
        [string]$Server,
        [ValidateSet('Present','Absent')]
        [string]$Ensure = 'Present'
    )
    $params = @{}
    if ($Server) {$params += @{Server = $Server}}
    Write-Verbose "Checking the Domain Distinguished Name is present on the Target Distinguished Name."
    $domainDN = (Get-ADDomain @params).DistinguishedName
    if ($Target -like "*$domainDN")
    {
        Write-Verbose "Target has full DN."
    }
    else
    {
    Write-Verbose "Adding the Domain Distinguished Name to the Target DN."
    if ($Target.EndsWith(","))
        {
        $Target = "$Target$domainDN"
        }
    else
        {
        $Target = "$Target,$domainDN"
        }
    }
    $Target
}

function Get-GpoInfo
{
    param
    (
        [parameter(Mandatory = $true)]
        [string]$Identity,
        [ValidateSet('Name','Guid')]
        [string]$IdentityType = 'Name',
        [parameter(Mandatory = $true)]
        [string]$Target,
        [string]$Domain,
        [ValidateSet('Yes','No')]
        [string]$Enforced,
        [ValidateSet('Yes','No')]
        [string]$LinkEnabled,
        [int16]$Order,
        [string]$Server,
        [ValidateSet('Present','Absent')]
        [string]$Ensure = 'Present'
    )
    $gpoParams = @{}
    if ($Server)
    {
        $gpoParams += @{Server = $Server}
    }
    if ($Domain)
    {
        $gpoParams += @{Domain = $Domain}
    }
    if ($IdentityType -eq 'Name') {$gpoParams += @{Name = $Identity}}
    else {$gpoParams += @{Guid = $Identity}}
    Import-Module GroupPolicy -Verbose:$false
    Write-Verbose 'Getting GPO'
    Get-GPO @gpoParams
}
