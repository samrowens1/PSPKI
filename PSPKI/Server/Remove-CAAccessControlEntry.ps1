function Remove-CAAccessControlEntry {
<#
.ExternalHelp PSPKI.Help.xml
#>
[OutputType('SysadminsLV.PKI.Security.AccessControl.CertSrvSecurityDescriptor[]')]
[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('ACL')]
		[SysadminsLV.PKI.Security.AccessControl.CertSrvSecurityDescriptor[]]$InputObject,
		[Security.Principal.NTAccount[]]$User
	)
	process {
		foreach($ACL in $InputObject) {
			$User | ForEach-Object {
				$ACL.PurgeAccessRules($_)
			}
			$ACL
		}
	}
}