function Get-TargetResource
{
    [OutputType([Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [string]
        $TargetDN,

        [string]
        $Domain,

        [string]
        $Server,

        [ValidateSet('Present','Absent')]
        [string]
        $Ensure = 'Present'
    )

    Import-Module $PSScriptRoot\..\Helper.psm1 -Verbose:$false
    Import-Module -Name GroupPolicy -Verbose:$false
    $testTargetDN = Test-TargetDN @PSBoundParameters
    $targetResource =  @{
        TargetDN = $testTargetDN
        Domain = $null
        Server = $null
        Ensure = $null
    }
    $getGPInheritanceParams = @{
        Target = $testTargetDN
    }
    if ($Domain)
    {
        $targetResource.Domain = $Domain
        $getGPInheritanceParams += @{
            Domain = $Domain
        }
    }
    if ($Server)
    {
        $targetResource.Server = $Server
        $getGPInheritanceParams += @{
            Server = $Server
        }
    }
    Write-Verbose -Message 'Getting Group Policy Inheritance'
    $gpoInheritanceBlocked = (Get-GPInheritance @getGPInheritanceParams).GpoInheritanceBlocked
    if (!$gpoInheritanceBlocked)
    {
        $targetResource.Ensure = 'Present'
    }
    else
    {
        $targetResource.Ensure = 'Absent'
    }
    Write-Output -InputObject $targetResource
}

function Set-TargetResource
{
    param
    (
        [parameter(Mandatory = $true)]
        [string]
        $TargetDN,

        [string]
        $Domain,

        [string]
        $Server,

        [ValidateSet('Present','Absent')]
        [string]
        $Ensure = 'Present'
    )

    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message 'Enabling Group Policy Inheritance'
        $isBlocked = 'No'
    }
    else
    {
        Write-Verbose -Message 'Disabling Group Policy Inheritance'
        $isBlocked = 'Yes'
    }
    $testTargetDN = Test-TargetDN @PSBoundParameters
    $setGPInheritanceParams = @{
        Target = $testTargetDN
        IsBlocked = $IsBlocked
    }
    if ($Domain)
    {
        $setGPInheritanceParams += @{
            Domain = $Domain
        }
    }
    if ($Server)
    {
        $setGPInheritanceParams += @{
            Server = $Server
        }
    }
    Import-Module -Name GroupPolicy -Verbose:$false
    $null = Set-GPInheritance @setGPInheritanceParams
}

function Test-TargetResource
{
[OutputType([Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [string]
        $TargetDN,

        [string]
        $Domain,

        [string]
        $Server,

        [ValidateSet('Present','Absent')]
        [string]
        $Ensure = 'Present'
    )

    $targetResource = Get-TargetResource @PSBoundParameters
    switch ($Ensure)
    {
        Present
        {
            if ($targetResource.Ensure -eq 'Present')
            {
                Write-Output -InputObject $true
            }
            else
            {
                Write-Output -InputObject $false
            }
        }
        Absent
        {
            if ($targetResource.Ensure -eq 'Absent')
            {
                Write-Output -InputObject $true
            }
            else
            {
                Write-Output -InputObject $false
            }
        }
    }
}
