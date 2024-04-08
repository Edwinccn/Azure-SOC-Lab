# Turn off Windows Defender Firewall for all profiles 
Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled False 

# Verify the change 
Get-NetFirewallProfile | Format-Table Name,Enabled
