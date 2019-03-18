<# 

.DESCRIPTION 
    Create an MspEventLog

#>

function New-MspEventLogEntry {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true, Position = 0)]
        [int32]$ID,

        [parameter(Mandatory = $true, Position = 1)]
        [string]$Message,

        [parameter(Mandatory = $false)]
        [ValidateSet('Information','Error','Warning')]
        [string]$Type,

        [parameter(Mandatory = $false)]
        [string]$Source,

        [parameter(Mandatory = $false)]
        [string]$Logname
    )   
    begin {
        if (!$PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')
        }
        # Erroraction preference
        $LastErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = "stop"
        # Check Logname and Source
        if (!$Source) {
            $Source = "RMM"
        }
        if (!$Logname) {
            $Logname = "MspEventLog"
        }
        if (!$Type) {
            $Type = "Information"
        }
    }            
    process {
        Write-Verbose "Erstelle Eventlog-Eintrag"
        if ([System.Diagnostics.EventLog]::Exists($Logname)) {
            write-Verbose "$Logname existiert"
            try {
                Write-EventLog -LogName $Logname -Source $Source -EventId $ID -Message $Message -EntryType $Type -ErrorAction "stop"
                Write-Verbose "Eventlog-Eintrag wurde erstellt"
            }
            catch {
                Write-Verbose "ERROR: Es ist ein Fehler bei der Erstellung eines MspEventLog-Eintrages aufgetreten"
                Write-Verbose "ERROR: $($_.Exception.Message)"
                $Errorstate = $true
            }
        } else {
            if (!$PSBoundParameters.ContainsKey('Verbose')) {
                New-MspEventLog $Logname $Source -Verbose
            } else {
                New-MspEventLog $Logname $Source
            }
        }
    }            
    end {
        $ErrorActionPreference = $LastErrorActionPreference
        Write-Verbose "Abgeschlossen"
        if ($Errorstate) {
            return "Beim Erstellen des Eventlog-Eintrages ist ein Fehler aufgetreten. Nutzen Sie den Parameter '-Verbose' für mehr Informationen"
        }
        return "Eventlog-Eintrag wurde erstellt."
    }
}

New-MspEventLogEntry -ID 1 -Message "Test" -Verbose