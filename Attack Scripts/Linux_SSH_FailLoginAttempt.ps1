<#
NOTE: To use the SSH cmdlets, the Posh-SSH Module is needed. Use the following commands to install onto your environment

Install-Module -Name Posh-SSH -Repository PSGallery -Force
Import-Module Posh-SSH
Get-Command -Module Posh-SSH //to verify
#>

Import-Module -Name SSHUtils
$ServerIPAddress = "1.0.0.0" #IPAddress of host to connect to
$username = "USERACCOUNT" #Name of account to login as
$wrongpassword = "WRONGPASSWORD" 
$rightpassword = "RIGHTPASSWORD" #Password to use to login successfully
$FailAttempts = 10 #Number of times to fail logon


for ($count = 1; $count -le $FailAttempts; $count++) {
    Write-Host "Attempt $count - Connecting to $ServerIPAddress..."
    try {
        $session = New-SSHSession -ComputerName $ServerIPAddress -Credential (New-Object System.Management.Automation.PSCredential($username, (ConvertTo-SecureString $wrongpassword -AsPlainText -Force))) -ErrorAction Stop
    } catch {
        Write-Host "Connection failed with error: $($_.Exception.Message)"
    }
}
#Below is optional if you want to have a successful attempt after the fail login attempts
$session = New-SSHSession -ComputerName $ServerIPAddress -Credential (New-Object System.Management.Automation.PSCredential($username, (ConvertTo-SecureString $rightpassword -AsPlainText -Force))) -ErrorAction Stop
Write-Host "Connected"
Remove-SSHSession -SessionId $session.SessionId
