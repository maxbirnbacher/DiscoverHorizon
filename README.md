# DiscoverHorizon
A (very unoptimized) script to discover hosts in a network and to get their IP addresses by using a remote session to the domain controller.

## Usage:

Load the files to the path

```PowerShell
path\to\loader.ps1
```

Store the credentials in a variable

```PowerShell
$creds = Get-Credential
```

Import the module

```PowerShell
Import-Module -Name DiscoverHorizon
```

Execute the public function

```PowerShell
Get-ComputerInfo -Credential $creds
```

Note that you may get one or many error messages.
