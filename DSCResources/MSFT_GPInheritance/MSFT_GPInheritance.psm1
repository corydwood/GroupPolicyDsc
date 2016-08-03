function Get-TargetResource
{
    [OutputType([Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [string]$Target,
        [string]$Domain,
        [string]$Server,
        [ValidateSet('Present','Absent')]
        [string]$Ensure = 'Present'
    )
    $Target = Test-TargetDN @PSBoundParameters
    $targetResource =  @{
        Target = $Target
        Domain = $null
        Server = $null
        Ensure = $null
    }
    $params = @{Target = $Target}
    if ($Domain)
    {
        $targetResource.Domain = $Domain
        $params += @{Domain = $Domain}
    }
    if ($Server)
    {
        $targetResource.Server = $Server
        $params += @{Server = $Server}
    }
    Import-Module GroupPolicy -Verbose:$false
    Write-Verbose 'Getting Group Policy Inheritance'
    $gpoInheritanceBlocked = (Get-GPInheritance @params).GpoInheritanceBlocked
    if (!$gpoInheritanceBlocked) {$targetResource.Ensure = 'Present'}
    else {$targetResource.Ensure = 'Absent'}
    Write-Output $targetResource
}

function Set-TargetResource
{
    param
    (
        [parameter(Mandatory = $true)]
        [string]$Target,
        [string]$Domain,
        [string]$Server,
        [ValidateSet('Present','Absent')]
        [string]$Ensure = 'Present'
    )
    if ($Ensure -eq 'Present')
    {
        Write-Verbose 'Enabling Group Policy Inheritance'
        $isBlocked = 'No'
    }
    else
    {
        Write-Verbose 'Disabling Group Policy Inheritance'
        $isBlocked = 'Yes'
    }
    $Target = Test-TargetDN @PSBoundParameters
    $params = @{
        Target = $Target
        IsBlocked = $IsBlocked
    }
    if ($Domain)
    {
        $params += @{Domain = $Domain}
    }
    if ($Server)
    {
        $params += @{Server = $Server}
    }
    Import-Module GroupPolicy -Verbose:$false
    $null = Set-GPInheritance @params
}

function Test-TargetResource
{
[OutputType([Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [string]$Target,
        [string]$Domain,
        [string]$Server,
        [ValidateSet('Present','Absent')]
        [string]$Ensure = 'Present'
    )
    $targetResource = Get-TargetResource @PSBoundParameters
    switch ($Ensure)
    {
        Present
        {
            if ($targetResource.Ensure -eq 'Present') {$true}
            else {$false}
        }
        Absent
        {
            if ($targetResource.Ensure -eq 'Absent') {$true}
            else {$false}
        }
    }
}

function Test-TargetDN
{
    param
    (
        [parameter(Mandatory = $true)]
        [string]$Target,
        [string]$Domain,
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
