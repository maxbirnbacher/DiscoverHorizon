# DisoverHorizon.psm1

# Private function to check if a computer is available using WSMan
function Test-ComputerAvailability {
    param (
        [string]$ComputerName
    )

    $ErrorActionPreference = 'SilentlyContinue'
    $result = Test-WSMan -ComputerName $ComputerName
    $ErrorActionPreference = 'Continue'

    return $result
}

# Public function to get information about available computers
function Get-ComputerInfo {
    [CmdletBinding()]
    param (
        [Parameter()]
        [PSCredential]$Credential
    )

    # Sample function that retrieves host name, MAC address, and IP addresses
    function Get-NetworkAdapterInfo {
        param (
            [string]$ComputerName,
            [PSCredential]$Credential
        )

        $networkAdapters = Get-WmiObject -Class Win32_NetworkAdapter -ComputerName $ComputerName -Credential $Credential | Where-Object { $_.MACAddress }

        foreach ($adapter in $networkAdapters) {
            $info = [PSCustomObject]@{
                ComputerName = $ComputerName
                HostName = $adapter.DNSHostName
                MACAddress = $adapter.MACAddress
                IPAddress = (Get-WmiObject -Class Win32_NetworkAdapterConfiguration -ComputerName $ComputerName -Credential $Credential | Where-Object { $_.MACAddress -eq $adapter.MACAddress }).IPAddress
            }
            Write-Output $info
        }
    }

    # Public function to get all PC hostnames from Active Directory
    function Get-ADComputerHostnames {
        param (
            [string]$DomainController,
            [PSCredential]$Credential
        )

        # Create a new session to the domain controller
        $session = New-PSSession -ComputerName $DomainController -Credential $Credential
        write-host $session
        write-host "Established session to $DomainController"

        # Import the ActiveDirectory module on the remote session
        Invoke-Command -Session $session -ScriptBlock { Import-Module ActiveDirectory }

        # Get the list of computer hostnames from Active Directory on the remote session
        $adComputers = Invoke-Command -Session $session -ScriptBlock { Get-ADComputer -Filter {OperatingSystem -like "Windows*"} -Property DNSHostName | Select-Object -ExpandProperty DNSHostName }

        # Close the remote session
        Remove-PSSession -Session $session

        Write-Output $adComputers
    }

    $domainController = "WIN-IUATAU19S8I"
    $computers = Get-ADComputerHostnames -DomainController $domainController -Credential $Credential

    # remove the .security.local from the end of each computer name
    $computers = $computers | ForEach-Object { $_.Split('.')[0] }

    foreach ($computer in $computers) {
        if (Test-ComputerAvailability -ComputerName $computer) {
            Get-NetworkAdapterInfo -ComputerName $computer -Credential $Credential
        } else {
            Write-Warning "Computer $computer is not available."
        }
    }
}
