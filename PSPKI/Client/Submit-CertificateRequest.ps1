function Submit-CertificateRequest {
<#
.ExternalHelp PSPKI.Help.xml
#>
[OutputType('PKI.Enrollment.CertRequestStatus')]
[CmdletBinding(DefaultParameterSetName = '__dcom')]
	param(
		[Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true)]
		[string[]]$Path,
		[Parameter(Mandatory = $false, Position = 0)]
		[string[]]$CsrContents,
		[Parameter(Mandatory = $true, ParameterSetName = '__dcom')]
		[Alias('CA')]
		[PKI.CertificateServices.CertificateAuthority]$CertificationAuthority,
		[Parameter(Mandatory = $true, ParameterSetName = '__xcep')]
		[Alias('CEP')]
		[PKI.Enrollment.Policy.PolicyServerClient]$EnrollmentPolicyServer,
		[System.Management.Automation.PSCredential]$Credential,
		[String[]]$Attribute
	)
	begin {
		$ErrorActionPreference = "Stop"
		$CertRequest = New-Object -ComObject CertificateAuthority.Request
		switch ($PsCmdlet.ParameterSetName) {
			"__xcep" {
				if ($NoCAPIv2) {throw New-Object NotSupportedException}
				if (![string]::IsNullOrEmpty($Credential.UserName)) {
					switch ($EnrollmentPolicyServer.Authentication) {
						"UserNameAndPassword" {
							$CertRequest.SetCredential(
								0,
								[int]$EnrollmentPolicyServer.Authentication,
								$Credential.UserName,
								[Runtime.InteropServices.Marshal]::PtrToStringAuto(
									[Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password)
								)
							)
						}
						"ClientCertificate" {							
							$CertRequest.SetCredential(
								0,
								[int]$EnrollmentPolicyServer.Authentication,
								$Credential.UserName,
								$null
							)
						}
					}
				}
			}
			"__dcom" {
				if (!$CertificationAuthority.PingRequest()) {
					$e = New-Object PKI.Exceptions.ServerUnavailableException $CertificationAuthority.DisplayName
					throw $e
				}
			}
		}
		if ($Attribute -eq $null) {
			$strAttribute = [string]::Empty
		} else {
			$SB = New-Object Text.StringBuilder
			foreach ($attrib in $Attribute) {
				[Void]$SB.Append($attrib + "`n")
			}
			$strAttribute = $SB.ToString()
			$strAttribute = $strAttribute.Substring(0,$strAttribute.Length - 1)
		}
	}
	process {

        $Requests = @()

        if($Path -ne $null) {
            $Path | ForEach-Object {
                $Requests += [IO.File]::ReadAllText((Resolve-Path $_).ProviderPath)
            }
        } elseif($CsrContents -ne $null) {
            $Requests = $CsrContents
        }
        
		$Requests | ForEach-Object {
			try {
				$Status = $CertRequest.Submit(0xff,$_,$strAttribute,$CertificationAuthority.ConfigString)
				$Output = New-Object PKI.Enrollment.CertRequestStatus -Property @{
					CertificationAuthority = $CertificationAuthority;
					Status = $Status;
					RequestID = $CertRequest.GetRequestId()
				}
				if ($Status -eq 3) {
					$CsrContents = $CertRequest.GetCertificate(1)
					$Output.Certificate = New-Object Security.Cryptography.X509Certificates.X509Certificate2 (,[Convert]::FromBase64String($base64))
				} else {
					$Output.ErrorInformation = $CertRequest.GetDispositionMessage()
				}
				$Output
			} catch {throw $_}
		}
	}
}
