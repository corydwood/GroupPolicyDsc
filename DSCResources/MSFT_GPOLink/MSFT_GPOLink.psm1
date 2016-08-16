function Get-TargetResource {
    [OutputType([Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [string]
        $Identity,

        [ValidateSet('Name','Guid')]
        [string]
        $IdentityType = 'Name',

        [parameter(Mandatory = $true)]
        [string]
        $Target,

        [string]
        $Domain,

        [ValidateSet('Yes','No')]
        [string]
        $Enforced,

        [ValidateSet('Yes','No')]
        [string]
        $LinkEnabled,

        [int16]
        $Order,

        [string]
        $Server,

        [ValidateSet('Present','Absent')]
        [string]
        $Ensure = 'Present'
    )

    Import-Module $PSScriptRoot\..\Helper.psm1 -Verbose:$false
    Import-Module -Name GroupPolicy -Verbose:$false
    $target = Test-TargetDN @PSBoundParameters
    $gpInheritanceparams = @{
        Target = $target
    }
    if ($Server)
    {
        $gpInheritanceparams += @{
            Server = $Server
        }
    }
    if ($Domain)
    {
        $gpInheritanceparams += @{
            Domain = $Domain
        }
    }
    Write-Verbose -Message 'Getting GPO Links'
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
        <#
            Using the GpoId attribute of the GPO Links instead of the
            Name attribute because the Name attribute may take a while
            to replicate to all DCs if the GPO was recently created.
        #>
        $targetLink = $gpoLinks | Where-Object {$_.GpoId -eq $gpo.Id}
        if ($targetLink)
        {
            if ($targetLink.Enabled)
            {
                $targetResource.LinkEnabled = 'Yes'
            }
            else
            {
                $targetResource.LinkEnabled = 'No'
            }
            if ($targetLink.Enforced)
            {
                $targetResource.Enforced = 'Yes'
            }
            else
            {
                $targetResource.Enforced = 'No'
            }
            $targetResource.Order = $targetLink.Order
            $targetResource.Ensure = 'Present'
        }
        $targetResource.Domain = $gpo.DomainName
    }
    Write-Output -InputObject $targetResource
}

function Set-TargetResource {
    param
    (
        [parameter(Mandatory = $true)]
        [string]
        $Identity,

        [ValidateSet('Name','Guid')]
        [string]
        $IdentityType = 'Name',

        [parameter(Mandatory = $true)]
        [string]
        $Target,

        [string]
        $Domain,

        [ValidateSet('Yes','No')]
        [string]
        $Enforced,

        [ValidateSet('Yes','No')]
        [string]
        $LinkEnabled,

        [int16]
        $Order,

        [string]
        $Server,

        [ValidateSet('Present','Absent')]
        [string]
        $Ensure = 'Present'
    )

    Import-Module -Name GroupPolicy -Verbose:$false
    $targetResource = Get-TargetResource @PSBoundParameters
    $gpo = Get-GpoInfo @PSBoundParameters
    if ($Ensure -eq 'Present')
    {
        if ($targetResource.Ensure -eq 'Present')
        {
            $setGPLinkParams = @{
                Target = $targetResource.Target
            }
            if ($IdentityType -eq 'Name')
            {
                <#
                    Using the GpoId attribute of the GPO Links instead of the
                    Name attribute because the Name attribute may take a while
                    to replicate to all DCs if the GPO was recently created.
                #>
                $setGPLinkParams += @{
                    Guid = $gpo.Id
                }
            }
            else
            {
                $setGPLinkParams += @{
                    Guid = $Identity
                }
            }
            if ($Domain)
            {
                $setGPLinkParams += @{
                    Domain = $Domain
                }
            }
            if ($Enforced -and $targetResource.Enforced -ne $Enforced)
            {
                $setGPLinkParams += @{
                    Enforced = $Enforced
                }
            }
            if ($LinkEnabled -and $targetResource.LinkEnabled -ne $LinkEnabled)
            {
                $setGPLinkParams += @{
                    LinkEnabled = $LinkEnabled
                }
            }
            if ($Order -and $targetResource.Order -ne $Order)
            {
                $setGPLinkParams += @{
                    Order = $Order
                }
            }
            if ($Server)
            {
                $setGPLinkParams += @{
                    Server = $Server
                }
            }
            Write-Verbose -Message 'Updating GPO Link'
            Set-GPLink @setGPLinkParams
        }
        else
        {
            $newGPLinkParams = @{
                Target = $targetResource.Target
            }
            if ($IdentityType -eq 'Name')
            {
                <#
                    Using the GpoId attribute of the GPO Links instead of the
                    Name attribute because the Name attribute may take a while
                    to replicate to all DCs if the GPO was recently created.
                #>
                $newGPLinkParams += @{
                    Guid = $gpo.Id
                }
            }
            else
            {
                $newGPLinkParams += @{
                    Guid = $Identity
                }
            }
            if ($Domain)
            {
                $newGPLinkParams += @{
                    Domain = $Domain
                }
            }
            if ($Enforced)
            {
                $newGPLinkParams += @{
                    Enforced = $Enforced
                }
            }
            if ($LinkEnabled)
            {
                $newGPLinkParams += @{
                    LinkEnabled = $LinkEnabled
                }
            }
            if ($Order)
            {
                $newGPLinkParams += @{
                    Order = $Order
                }
            }
            if ($Server)
            {
                $newGPLinkParams += @{
                    Server = $Server
                }
            }
            Write-Verbose -Message 'Creating GPO Link'
            New-GPLink @newGPLinkParams
        }
    }
    else
    {
        $removeGPLinkParams = @{
            Target = $targetResource.Target
        }
        if ($IdentityType -eq 'Name')
        {
            <#
                Using the GpoId attribute of the GPO Links instead of the
                Name attribute because the Name attribute may take a while
                to replicate to all DCs if the GPO was recently created.
            #>
            $removeGPLinkParams += @{
                Guid = $gpo.Id
            }
        }
        else
        {
            $removeGPLinkParams += @{
                Guid = $Identity
            }
        }
        if ($Domain)
        {
            $removeGPLinkParams += @{
                Domain = $Domain
            }
        }
        if ($Server)
        {
            $removeGPLinkParams += @{
                Server = $Server
            }
        }
        Write-Verbose -Message 'Removing GPO Link'
        Remove-GPLink @removeGPLinkParams
    }
}

function Test-TargetResource {
[OutputType([Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [string]
        $Identity,

        [ValidateSet('Name','Guid')]
        [string]
        $IdentityType = 'Name',

        [parameter(Mandatory = $true)]
        [string]
        $Target,

        [string]
        $Domain,

        [ValidateSet('Yes','No')]
        [string]
        $Enforced,

        [ValidateSet('Yes','No')]
        [string]
        $LinkEnabled,

        [int16]
        $Order,

        [string]
        $Server,

        [ValidateSet('Present','Absent')]
        [string]
        $Ensure = 'Present'
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
        else
        {
            $targetResourceInCompliance = $false
        }
    }
    elseif ($targetResource.Ensure -eq 'Present')
    {
        $targetResourceInCompliance = $false
    }
    Write-Output -InputObject $targetResourceInCompliance
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

    Import-Module -Name GroupPolicy -Verbose:$false
    $getGPOParams = @{}
    if ($Server)
    {
        $getGPOParams += @{
            Server = $Server
        }
    }
    if ($Domain)
    {
        $getGPOParams += @{
            Domain = $Domain
        }
    }
    if ($IdentityType -eq 'Name')
    {
        $getGPOParams += @{
            Name = $Identity
        }
    }
    else
    {
        $getGPOParams += @{
            Guid = $Identity
        }
    }
    Write-Verbose -Message 'Getting GPO'
    Get-GPO @getGPOParams
}
