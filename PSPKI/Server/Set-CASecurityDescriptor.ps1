function Set-CASecurityDescriptor {
<#
.ExternalHelp PSPKI.Help.xml
#>
[OutputType('SysadminsLV.PKI.Security.AccessControl.CertSrvSecurityDescriptor[]')]
[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('ACL')]
		[SysadminsLV.PKI.Security.AccessControl.CertSrvSecurityDescriptor[]]$InputObject,
		[switch]$RestartCA
	)
	process {
		foreach($ACL in $InputObject) {
			$ACL.SetObjectSecurity($RestartCA)
		}
	}
}