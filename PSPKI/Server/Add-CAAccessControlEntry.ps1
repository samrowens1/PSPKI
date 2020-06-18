function Add-CAAccessControlEntry {
<#
.ExternalHelp PSPKI.Help.xml
#>
[OutputType('SysadminsLV.PKI.Security.AccessControl.CertSrvSecurityDescriptor[]')]
[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('ACL')]
		[SysadminsLV.PKI.Security.AccessControl.CertSrvSecurityDescriptor[]]$InputObject,
		[Alias('ACE')]
		[SysadminsLV.PKI.Security.AccessControl.CertSrvAccessRule[]]$AccessControlEntry
	)
	process {
		foreach($ACL in $InputObject) {
			$AccessControlEntry | ForEach-Object {
				[void]$ACL.AddAccessRule($_)
			}
			$ACL
		}
	}
}