﻿#
# Copyright 2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
# Copyright 2020, Arthur Heijnen <arthur dot heijnen at live dot nl>
#
# SPDX-License-Identifier: Apache-2.0
#

function Add-FGTFirewallProxyPolicy {

    <#
        .SYNOPSIS
        Add a FortiGate ProxyPolicy

        .DESCRIPTION
        Add a FortiGate ProxyPolicy/Rules (source address, destination address, service, action, status...)

        .EXAMPLE
        Add-FGTFirewallProxyPolicy -proxytype explicit-web -dstintf port1 -srcaddr all -dstaddr all

        Add a explicit-web ProxyPolicy with destination interface port1, source-address and destination-address all

        .EXAMPLE
        Add-FGTFirewallProxyPolicy -proxytype transparent-web -dstintf port1 -srcaddr all -dstaddr all

        Add a transparent-web ProxyPolicy with destination interface port1, source-address and destination-address all

        .EXAMPLE
        Add-FGTFirewallProxyPolicy -proxytype explicit-web -dstintf port1 -srcaddr all -dstaddr all -action "deny"

        Add a explicit-web ProxyPolicy with action is Deny

        .EXAMPLE
        Add-FGTFirewallProxyPolicy -proxytype explicit-web -dstintf port1 -srcaddr all -dstaddr all -status:$false

        Add a explicit-web ProxyPolicy with status is disable

        .EXAMPLE
        Add-FGTFirewallProxyPolicy -proxytype explicit-web -dstintf port1 -srcaddr all -dstaddr all -service "HTTP, HTTPS, SSH"

        Add a explicit-web ProxyPolicy with multiple services

        .EXAMPLE
        Add-FGTFirewallProxyPolicy -proxytype explicit-web -dstintf port1 -srcaddr all -dstaddr all -schedule workhour

        Add a explicit-web ProxyPolicy with schedule is workhour

        .EXAMPLE
        Add-FGTFirewallProxyPolicy -proxytype explicit-web -dstintf port1 -srcaddr all -dstaddr all -comments "My FGT ProxyPolicy"

        Add a explicit-web ProxyPolicy with comment "My FGT ProxyPolicy"

        .EXAMPLE
        Add-FGTFirewallProxyPolicy -proxytype explicit-web -dstintf port1 -srcaddr all -dstaddr all -logtraffic "all"

        Add a explicit-web ProxyPolicy with log traffic all
    #>


    Param(
        [Parameter (Mandatory = $true)]
        [ValidateSet("explicit-web", "transparent-web")]
        [string]$proxytype = "explicit-web",
        [Parameter (Mandatory = $true)]
        [string[]]$dstintf,
        [Parameter (Mandatory = $true)]
        [string[]]$srcaddr,
        [Parameter (Mandatory = $true)]
        [string[]]$dstaddr,
        [Parameter (Mandatory = $false)]
        [ValidateSet("accept", "deny")]
        [string]$action = "accept",
        [Parameter (Mandatory = $false)]
        [switch]$status = $true,
        [Parameter (Mandatory = $false)]
        [string]$schedule = "always",
        [Parameter (Mandatory = $false)]
        [string[]]$service = "ALL",
        [Parameter (Mandatory = $false)]
        [ValidateLength(0, 255)]
        [string]$comments,
        [Parameter (Mandatory = $false)]
        [ValidateSet("disable", "utm", "all")]
        [string]$logtraffic,
        [Parameter (Mandatory = $false)]
        [string[]]$ippool,
        [Parameter (Mandatory = $false)]
        [switch]$skip,
        [Parameter(Mandatory = $false)]
        [String[]]$vdom,
        [Parameter(Mandatory = $false)]
        [psobject]$connection = $DefaultFGTConnection
    )

    Begin {
    }

    Process {

        $invokeParams = @{ }
        if ( $PsBoundParameters.ContainsKey('skip') ) {
            $invokeParams.add( 'skip', $skip )
        }
        if ( $PsBoundParameters.ContainsKey('vdom') ) {
            $invokeParams.add( 'vdom', $vdom )
        }

        $uri = "api/v2/cmdb/firewall/proxy-policy"

        # Destination interface
        $dstintf_array = @()
        #TODO check if the interface (zone ?) is valid
        foreach ($intf in $dstintf) {
            $dstintf_array += @{ 'name' = $intf }
        }

        # Source address
        $srcaddr_array = @()
        #TODO check if the address (group, vip...) is valid
        foreach ($addr in $srcaddr) {
            $srcaddr_array += @{ 'name' = $addr }
        }

        # Destination address
        $dstaddr_array = @()
        #TODO check if the address (group, vip...) is valid
        foreach ($addr in $dstaddr) {
            $dstaddr_array += @{ 'name' = $addr }
        }

        # Service
        $service_array = @()
        #TODO check if the service (group...) is valid
        foreach ($s in $service) {
            $service_array += @{ 'name' = $s }
        }

        $policy = new-Object -TypeName PSObject

        $policy | add-member -name "proxy" -membertype NoteProperty -Value $proxytype

        $policy | add-member -name "dstintf" -membertype NoteProperty -Value $dstintf_array

        $policy | add-member -name "srcaddr" -membertype NoteProperty -Value $srcaddr_array

        $policy | add-member -name "dstaddr" -membertype NoteProperty -Value $dstaddr_array

        $policy | add-member -name "action" -membertype NoteProperty -Value $action

        if ($status) {
            $policy | add-member -name "status" -membertype NoteProperty -Value "enable"
        }
        else {
            $policy | add-member -name "status" -membertype NoteProperty -Value "disable"
        }

        $policy | add-member -name "schedule" -membertype NoteProperty -Value $schedule

        $policy | add-member -name "service" -membertype NoteProperty -Value $service_array

        if ( $PsBoundParameters.ContainsKey('comments') ) {
            $policy | add-member -name "comments" -membertype NoteProperty -Value $comments
        }

        if ( $PsBoundParameters.ContainsKey('logtraffic') ) {
            $policy | add-member -name "logtraffic" -membertype NoteProperty -Value $logtraffic
        }

        $mkey = Invoke-FGTRestMethod -method "POST" -body $policy -uri $uri -connection $connection @invokeParams

        Get-FGTFirewallProxyPolicy -policyid $mkey.mkey -connection $connection @invokeParams

    }

    End {
    }
}

function Get-FGTFirewallProxyPolicy {

    <#
        .SYNOPSIS
        Get list of all ProxyPolicies/rules

        .DESCRIPTION
        Get list of all ProxyPolicies (source address, destination address, service, action, status...)

        .EXAMPLE
        Get-FGTFirewallProxyPolicy

        Get list of all Proxypolicies

        .EXAMPLE
        Get-FGTFirewallProxyPolicy -policyid 23

        Get policy with id 23

        .EXAMPLE
        Get-FGTFirewallProxyPolicy -uuid 9e73a10e-1772-51ea-a8d7-297686fd7702

        Get policy with uuid 9e73a10e-1772-51ea-a8d7-297686fd7702

        .EXAMPLE
        Get-FGTFirewallProxyPolicy -skip

        Get list of all policies (but only relevant attributes)

        .EXAMPLE
        Get-FGTFirewallPolicy -vdom vdomX

        Get list of all policies on vdomX
    #>

    [CmdletBinding(DefaultParameterSetName = "default")]
    Param(
        [Parameter (Mandatory = $false, ParameterSetName = "uuid")]
        [string]$uuid,
        [Parameter (Mandatory = $false, ParameterSetName = "policyid")]
        [string]$policyid,
        [Parameter (Mandatory = $false, ParameterSetName = "filter_build")]
        [string]$filter_attribute,
        [Parameter (Mandatory = $false, ParameterSetName = "uuid")]
        [Parameter (ParameterSetName = "policyid")]
        [Parameter (ParameterSetName = "filter_build")]
        [ValidateSet('equal', 'notequal', 'contains', 'notcontains', 'less', 'lessorequal', 'greater', 'greaterorequal')]
        [string]$filter_type = "equal",
        [Parameter (Mandatory = $false, ParameterSetName = "filter_build")]
        [psobject]$filter_value,
        [Parameter(Mandatory = $false)]
        [switch]$skip,
        [Parameter(Mandatory = $false)]
        [String[]]$vdom,
        [Parameter(Mandatory = $false)]
        [psobject]$connection = $DefaultFGTConnection
    )

    Begin {
    }

    Process {

        $invokeParams = @{ }
        if ( $PsBoundParameters.ContainsKey('skip') ) {
            $invokeParams.add( 'skip', $skip )
        }
        if ( $PsBoundParameters.ContainsKey('vdom') ) {
            $invokeParams.add( 'vdom', $vdom )
        }

        #Filtering
        switch ( $PSCmdlet.ParameterSetName ) {
            "uuid" {
                $filter_value = $uuid
                $filter_attribute = "uuid"
            }
            "policyid" {
                $filter_value = $policyid
                $filter_attribute = "policyid"
            }
            default { }
        }

        #if filter value and filter_attribute, add filter (by default filter_type is equal)
        if ( $filter_value -and $filter_attribute ) {
            $invokeParams.add( 'filter_value', $filter_value )
            $invokeParams.add( 'filter_attribute', $filter_attribute )
            $invokeParams.add( 'filter_type', $filter_type )
        }

        $reponse = Invoke-FGTRestMethod -uri 'api/v2/cmdb/firewall/proxy-policy' -method 'GET' -connection $connection @invokeParams
        $reponse.results
    }

    End {
    }
}

function Remove-FGTFirewallProxyPolicy {

    <#
        .SYNOPSIS
        Remove a FortiGate ProxyPolicy

        .DESCRIPTION
        Remove a ProxyPolicy/Rule object on the FortiGate

        .EXAMPLE
        $MyFGTProxyPolicy = Get-FGTFirewallProxyPolicy -name MyFGTProxyPolicy
        PS C:\>$MyFGTProxyPolicy | Remove-FGTFirewallProxyPolicy

        Remove ProxyPolicy object $MyFGTProxyPolicy

        .EXAMPLE
        $MyFGTProxyPolicy = Get-FGTFirewallproxyPolicy -name MyFGTproxyPolicy
        PS C:\>$MyFGTproxyPolicy | Remove-FGTFirewallproxyPolicy -noconfirm

        Remove ProxyPolicy object MyFGTproxyPolicy with no confirmation

    #>

    Param(
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1)]
        [ValidateScript( { Confirm-FGTFirewallproxyPolicy $_ })]
        [psobject]$policy,
        [Parameter(Mandatory = $false)]
        [switch]$noconfirm,
        [Parameter(Mandatory = $false)]
        [String[]]$vdom,
        [Parameter(Mandatory = $false)]
        [psobject]$connection = $DefaultFGTConnection
    )

    Begin {
    }

    Process {

        $invokeParams = @{ }
        if ( $PsBoundParameters.ContainsKey('vdom') ) {
            $invokeParams.add( 'vdom', $vdom )
        }

        $uri = "api/v2/cmdb/firewall/proxy-policy/$($policy.policyid)"

        if ( -not ( $Noconfirm )) {
            $message = "Remove Policy on Fortigate"
            $question = "Proceed with removal of ProxyPolicy $($policy.uuid) ?"
            $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
            $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
            $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))

            $decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
        }
        else { $decision = 0 }
        if ($decision -eq 0) {
            Write-Progress -activity "Remove ProxyPolicy"
            $null = Invoke-FGTRestMethod -method "DELETE" -uri $uri -connection $connection @invokeParams
            Write-Progress -activity "Remove ProxyPolicy" -completed
        }
    }

    End {
    }
}
