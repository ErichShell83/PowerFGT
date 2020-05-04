#
# Copyright 2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]
Param()
# default settings for test...
$script:pester_address1 = "pester_address1"
$script:pester_address2 = "pester_address2"
$script:pester_address3 = "pester_address3"
$script:pester_address4 = "pester_address4"
$script:pester_addressgroup = "pester_addressgroup"
$script:pester_vip1 = "pester_vip1"

. ../credential.ps1
#TODO: Add check if no ipaddress/login/password info...

$script:mysecpassword = ConvertTo-SecureString $password -AsPlainText -Force

if ($httpOnly) {
    Connect-FGT -Server $ipaddress -Username $login -password $mysecpassword -httpOnly
}
else {
    Connect-FGT -Server $ipaddress -Username $login -password $mysecpassword -SkipCertificateCheck
}
