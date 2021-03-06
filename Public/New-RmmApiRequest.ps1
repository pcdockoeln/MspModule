﻿<# 

.DESCRIPTION 
    RMM Api Request Method

#>
function New-RmmApiRequest {
    param 
    (
        [string]$apiUrl,
        [string]$apiKey,
        [string]$apiSecretKey,
        [string]$apiMethod,
        [string]$apiRequest,
        [string]$apiRequestBody
    )
    begin {
        Write-Verbose "Variablen werden prepariert"
        # Erroraction preference
        $LastErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = 'stop'
            
        # Errorflag
        $Errorstate = $false

        # Verbose parameter
        if ($PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')
        }

        # Access token params
        $accesstokenparams = @{
            apiUrl         =	$apiUrl
            apiKey         =	$apiKey
            apiSecretKey   =	$apiSecretKey
        }
        
        # Getting AccessToken
        write-Verbose "Getting Access token"
        try {
            $apiAccessToken = New-RmmApiAccessToken @accesstokenparams
        }
        catch {
            write-Verbose "Error during getting access token"
            write-Error $_.Exception.Message
            $Errorstate = $true
        }
        

        # Define parameters for Invoke-WebRequest cmdlet
        $params = @{
            Uri         =	'{0}/api{1}' -f $apiUrl, $apiRequest
            Method      =	$apiMethod
            ContentType	= 'application/json'
            Headers     =	@{
                'Authorization'	=	'Bearer {0}' -f $apiAccessToken
            }
        }

    }            
    process {
        # Add body to parameters if present
        If ($apiRequestBody) {
            $params.Add('Body', $apiRequestBody)
        }

        # Make request
        try {
            Write-Verbose "Getting Request..."
            $Request = (Invoke-WebRequest @params).Content
        }
        catch {
            Write-Verbose "Fehler waehrend der Anfrage."
            Write-Error $_.Exception.Message
            $Errorstate = $true
        }
    }            
    end {
        $ErrorActionPreference = $LastErrorActionPreference
        if ($Errorstate) {
            return $null
        }
        return $Request | ConvertFrom-Json
    }
}