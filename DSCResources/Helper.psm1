<#
    .SYNOPSIS
        Tests the $Target parameter to ensure it contains the RootDSE and adds it if it doesn't.

    .PARAMETER Name
        Not used. Included to allow @PSBoundParameters in function call.

    .PARAMETER Target
        The target OU Distinguished Name with or without the RootDSE.

    .PARAMETER Domain
        Not used. Included to allow @PSBoundParameters in function call.

    .PARAMETER Server
        The name of the server. Optional.

    .PARAMETER Ensure
        Not used. Included to allow @PSBoundParameters in function call.

#>
function Test-TargetDN
{
    param
    (
        [string]
        $Name,

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

    $getADDomainParams = @{}
    if ($Server)
    {
        $getADDomainParams += @{
            Server = $Server
        }
    }
    Write-Verbose -Message ("Checking the Domain Distinguished Name is " +
        "present on the Target Distinguished Name.")
    $domainDN = (Get-ADDomain @getADDomainParams).DistinguishedName
    if ($TargetDN -like "*$domainDN")
    {
        Write-Verbose -Message "Target has full DN."
    }
    else
    {
        Write-Verbose -Message "Adding the Domain Distinguished Name to the Target DN."
        if ($TargetDN.EndsWith(","))
        {
            $TargetDN = "$TargetDN$domainDN"
        }
        else
        {
            $TargetDN = "$TargetDN,$domainDN"
        }
    }
    Write-Output -InputObject $TargetDN
}
